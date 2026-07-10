# Claude Code Hook Integration  
*For Adaptive Self‑Correcting Workflow (v3.2)*  
**Definitive Implementation Guide**  
*Production‑Ready v1.0*

---

## Overview

This document provides the **complete, validated implementation** of Claude Code hooks that augment the Adaptive Self‑Correcting Workflow. The hooks automate ambient awareness – injecting essential context, reminding the agent of discipline, and guarding against unfinished work – while preserving agent autonomy.

All hooks are defined in the project’s `settings.json` (or `.claude/settings.json`) and their scripts reside in `.claude/hooks/`.

> **Implementation note (this repo):** All three hooks are a **single Python dispatcher**,
> `.claude/hooks/adaptive_workflow_hook.py`, wired to every event and branching on the
> `hook_event_name` field each event delivers on stdin. It is invoked via `python` (guaranteed on
> PATH here; `node` is not). The per-event sections below describe each branch of that one file; the
> code shown is the actual handler, not a separate script. Every handler **fails soft** — any
> unexpected error exits 0, so a hook can never break a tool call or trap a turn — and per-session
> state is a small JSON file in the temp dir, keyed by `session_id`.

---

## Hook Events Used

| Hook Event | When It Fires | Purpose in Workflow |
|------------|---------------|----------------------|
| **`SessionStart`** | When a Claude Code session begins or resumes | Run environment check, load core docs, detect unfinished plan, summarise roadmap |
| **`PostToolUse`** | After any tool call succeeds | Remind agent to update docs/roadmap if source changed |
| **`Stop`** (optional) | When Claude finishes a response | Block session closure if `UNFINISHED.md` still exists |

---

## 1. `SessionStart` Hook

### 1.1 Trigger & Matchers
- **Event**: `SessionStart`
- **Matcher**: Optional – matches on how the session started: `startup`, `resume`, `clear`, `compact`.
- **Input (stdin JSON)**:

```json
{
  "session_id": "uuid",
  "transcript_path": "/path/to/transcript.json",
  "cwd": "/project/root",
  "permission_mode": "default",
  "hook_event_name": "SessionStart",
  "prompt_id": "uuid"
}
```

> **Note**: `effort` is **not** present for `SessionStart`.

### 1.2 Output – What You Can Return

You may return either plain `stdout` text (injected as `additionalContext`) or a JSON object with these supported fields:

| Field | Type | Description |
|-------|------|-------------|
| `hookSpecificOutput.additionalContext` | string | Injected into the agent’s conversation as initial context |
| `initialUserMessage` | string | Sets the very first user message (useful in `-p` non‑interactive mode) |
| `sessionTitle` | string | Automatically names the session (like `/rename`) – good for tying to roadmap epic |
| `watchPaths` | array of strings | Absolute paths to watch for `FileChanged` events during the session |
| `reloadSkills` | boolean | Forces re‑scan of skill directories after the hook completes |

**Important**: `SessionStart` runs **before MCP servers finish connecting**. Avoid relying on MCP tools inside this hook. Use standard filesystem operations.

### 1.3 Implementation (`handle_session_start` in `adaptive_workflow_hook.py`)

The SessionStart branch injects: environment status (from `.ai/env_check.ps1`), summaries of the
three living docs (full if under `DOC_SUMMARY_CHARS`, else truncated with a "full document available"
note), a `plans/UNFINISHED.md` alert if present, and the next actionable roadmap item. It also names
the session. Note the two corrected schemas: context is wrapped in
`hookSpecificOutput.additionalContext` (not `decision:"approve"`), and the roadmap scan stops at
`## Completed Epics` / `## Backlog` so it never surfaces a completed item as "next".

```python
def _env_status(project_dir: Path) -> str:
    script = project_dir / ".ai" / "env_check.ps1"
    if not script.exists():
        return "Environment: (no .ai/env_check.ps1 found)"
    try:
        proc = subprocess.run(
            ["powershell", "-NoProfile", "-ExecutionPolicy", "Bypass",
             "-File", str(script)],
            capture_output=True, text=True, timeout=ENV_CHECK_TIMEOUT,
        )
        text = (proc.stdout or "").strip()
        return text or "Environment: (env check produced no output)"
    except Exception:
        return "Environment: (env_check.ps1 could not run)"


def _doc_summary(project_dir: Path, rel: str) -> str | None:
    try:
        text = (project_dir / rel).read_text(encoding="utf-8").strip()
    except OSError:
        return None
    if len(text) <= DOC_SUMMARY_CHARS:
        return text
    return text[:DOC_SUMMARY_CHARS].rstrip() + \
        "\n… (truncated — full document available on request)"


def _unfinished_summary(project_dir: Path) -> str | None:
    try:
        text = (project_dir / "plans" / "UNFINISHED.md").read_text(encoding="utf-8")
    except OSError:
        return None
    lines = [ln.strip() for ln in text.splitlines() if ln.strip()]
    return " ".join(lines[:3]) if lines else "(empty plan)"


def _next_roadmap_item(project_dir: Path) -> str | None:
    """First unchecked item of the first active epic.

    Stops scanning at the '## Completed Epics' / '## Backlog' headings so
    completed or icebox items are never surfaced as "next".
    """
    try:
        text = (project_dir / "ROADMAP.md").read_text(encoding="utf-8")
    except OSError:
        return None
    current_epic: str | None = None
    for line in text.splitlines():
        stripped = line.strip()
        if stripped.startswith("## "):
            heading = stripped[3:].strip()
            low = heading.lower()
            if low.startswith("completed epics") or low.startswith("backlog"):
                break
            current_epic = heading
            continue
        m = re.match(r"^- \[ \]\s+(.*)", stripped)
        if m:
            item = m.group(1).strip()
            return f"{item}  (in: {current_epic})" if current_epic else item
    return None


def handle_session_start(data: dict, session_id: str) -> int:
    _cleanup_stale_state()
    # Reset the per-session ledger flags so a resumed session_id starts clean.
    state = _load_state(session_id)
    if any(state.get(f) for f in LEDGER_FLAGS):
        for f in LEDGER_FLAGS:
            state.pop(f, None)
        _save_state(session_id, state)
    project_dir = _project_dir(data)

    parts: list[str] = [f"[{_env_status(project_dir)}]"]

    for rel, label in LIVING_DOCS:
        summary = _doc_summary(project_dir, rel)
        if summary:
            parts.append(f"[{label} — {rel}]\n{summary}")

    unfinished = _unfinished_summary(project_dir)
    if unfinished is not None:
        parts.append(
            f"⚠️ UNFINISHED PLAN detected: {unfinished}\n"
            "Surface this to the user immediately: continue it or archive it "
            "(Phase 3 closure) before starting new work."
        )
    else:
        parts.append("No unfinished plan.")

    next_item = _next_roadmap_item(project_dir)
    if next_item:
        parts.append(f"[Roadmap] Next: {next_item}")

    # Name the session after the most task-relevant signal available.
    if unfinished is not None:
        title = f"Continue: {unfinished[:60]}"
    elif next_item:
        title = f"Roadmap: {next_item[:60]}"
    else:
        title = "New Session"

    return _emit_context("SessionStart", "\n\n".join(parts), session_title=title)
```

where `_emit_context` builds the validated JSON payload:

```python
def _emit_context(event: str, message: str, session_title: str | None = None) -> int:
    payload: dict = {
        "hookSpecificOutput": {
            "hookEventName": event,
            "additionalContext": message,
        }
    }
    if session_title:
        payload["sessionTitle"] = session_title
    print(json.dumps(payload))
    return 0
```

---

## 2. `PostToolUse` Hook – Documentation & Roadmap Reminder

### 2.1 Trigger & Matchers
- **Event**: `PostToolUse`
- **Matcher**: Tool names – e.g., `Bash`, `Edit|Write`, `mcp__.*`
- **Input (stdin JSON)**:

```json
{
  "session_id": "uuid",
  "transcript_path": "/path/to/transcript.json",
  "cwd": "/project/root",
  "permission_mode": "default",
  "hook_event_name": "PostToolUse",
  "prompt_id": "uuid",
  "effort": { "level": "medium" },
  "tool_name": "Edit",
  "tool_input": { "file_path": "src/auth.py", ... },
  "tool_response": { ... }
}
```

### 2.2 Output – What You Can Return

For `PostToolUse`, you **must** wrap `additionalContext` inside `hookSpecificOutput`:

```json
{
  "hookSpecificOutput": {
    "hookEventName": "PostToolUse",
    "additionalContext": "Your reminder text"
  }
}
```

> **Note**: `PostToolUse` **cannot** block the tool or use `permissionDecision` – the tool has already run. Only `PreToolUse` can block.

### 2.3 Implementation (`handle_post_tool_use` in `adaptive_workflow_hook.py`)

The PostToolUse branch is advisory and never blocks. It emits a **once-per-session** nudge when an
edited path is under a source prefix (`src/`, `lib/`) *and* the same call didn't also touch `docs/`
(matching the spec's `srcModified && !docModified` condition). It also records two session-state flags
used later by the Stop guard: a write under `history/` sets `ledger_entry_written`, and a change to
any tracked repo area sets `traceable_change_made`.

```python
def _modified_paths(tool: str, ti: dict) -> list[str]:
    paths: list[str] = []
    if tool in ("Edit", "Write", "NotebookEdit"):
        fp = ti.get("file_path")
        if fp:
            paths.append(str(fp))
    elif tool == "MultiEdit":
        fp = ti.get("file_path")
        if fp:
            paths.append(str(fp))
    return [p.replace("\\", "/") for p in paths]


def handle_post_tool_use(data: dict, session_id: str) -> int:
    tool = (data.get("tool_name") or "").strip()
    if tool == "Bash":
        return 0  # can't reliably tell which files a Bash command touched

    paths = _modified_paths(tool, _tool_input(data))
    if not paths:
        return 0

    state = _load_state(session_id)
    dirty = False

    # A write under history/ counts as the session's ledger entry.
    if any(_touches_ledger(p) for p in paths) and not state.get("ledger_entry_written"):
        state["ledger_entry_written"] = True
        dirty = True
    # A change to any tracked repo area means a ledger entry is warranted at Stop.
    if any(_is_traceable(p) for p in paths) and not state.get("traceable_change_made"):
        state["traceable_change_made"] = True
        dirty = True

    # Source-change doc nudge (once per session): source touched, docs not.
    touched_source = any(
        any(seg in p for seg in (f"/{pre}" for pre in SOURCE_PREFIXES))
        or any(p.startswith(pre) for pre in SOURCE_PREFIXES)
        for p in paths
    )
    touched_docs = any(p.startswith("docs/") or "/docs/" in p for p in paths)
    emit_nudge = (
        touched_source and not touched_docs and not state.get("doc_nudge_emitted")
    )
    if emit_nudge:
        state["doc_nudge_emitted"] = True
        dirty = True

    if dirty:
        _save_state(session_id, state)
    if emit_nudge:
        return _emit_context("PostToolUse", DOC_NUDGE)
    return 0
```

---

## 3. `Stop` Hook – Unfinished Plan Guard (Optional)

### 3.1 Trigger & Matchers
- **Event**: `Stop`
- **Matchers**: None – `Stop` does not support matchers. Any `matcher` field is ignored.
- **Input (stdin JSON)**:

```json
{
  "session_id": "uuid",
  "transcript_path": "/path/to/transcript.json",
  "cwd": "/project/root",
  "permission_mode": "default",
  "hook_event_name": "Stop",
  "prompt_id": "uuid",
  "effort": { "level": "medium" }
}
```

### 3.2 Output – Blocking Behavior

To prevent the agent from stopping (i.e., to force it to continue the turn), return:

```json
{
  "decision": "block",
  "reason": "Explain why Claude must continue."
}
```

> **Safety Cap**: Claude Code overrides the hook and ends the turn after **8 consecutive blocks** to prevent infinite loops.

**Important**: The `Stop` hook **does not support `hookSpecificOutput`** or `additionalContext` as a separate field. All instructional context must be placed inside the top‑level `reason` string. The agent reads the `reason` as its next instruction.

### 3.3 Implementation (`handle_stop` in `adaptive_workflow_hook.py`)

The Stop branch re-prompts while `plans/UNFINISHED.md` exists (archive + clear) **and** once if
tracked files changed this session without a `history/YYYY-Www.md` ledger entry. It is bounded by
`MAX_STOP_BLOCKS` (default 2) plus a `stop_hook_active` check so a turn is never trapped — well within
Claude Code's own 8-consecutive-block safety cap. All instruction goes in the top-level `reason`
string (Stop does not support `hookSpecificOutput`).

```python
def handle_stop(data: dict, session_id: str) -> int:
    project_dir = _project_dir(data)
    state = _load_state(session_id)

    unfinished = _unfinished_summary(project_dir)

    # Ledger reminder (once per session): tracked files changed but no history/
    # entry was written this session. A warning, not a hard gate — bounded so it
    # never loops.
    ledger_due = (
        state.get("traceable_change_made")
        and not state.get("ledger_entry_written")
        and not state.get("ledger_reminder_emitted")
    )

    if unfinished is None and not ledger_due:
        return 0  # nothing to remind about — let the turn end

    blocks = int(state.get("stop_blocks", 0))
    if blocks >= MAX_STOP_BLOCKS or bool(data.get("stop_hook_active")):
        return 0  # budget exhausted — never trap the turn

    reasons: list[str] = []
    if unfinished is not None:
        reasons.append(
            f'An active plans/UNFINISHED.md remains: "{unfinished}".\n'
            "Run Phase 3 (Closure) before stopping:\n"
            "  - Move it to plans/archive/YYYY-MM-DD_<slug>/plan.md "
            "(+ execution_log.md / retro.md if warranted).\n"
            "  - Clear plans/UNFINISHED.md (it must not exist at rest).\n"
            "  - Append a closure entry to history/YYYY-Www.md.\n"
            "  - Update ROADMAP.md if triggered; check off the completed item.\n"
            "  - git commit && git push.\n"
            "If the work is genuinely incomplete, leave UNFINISHED.md intact and tell "
            "the user the plan is unfinished so the next session resumes it."
        )
    if ledger_due:
        reasons.append(
            "Tracked files changed this session but no entry was added to the weekly "
            "change ledger history/YYYY-Www.md. Per CLAUDE.md this is required — append "
            "a dated entry (substantial change → What/Why/Refs; minor → one line), then "
            "stop. If nothing here is worth tracing, you may stop without one."
        )
        state["ledger_reminder_emitted"] = True

    state["stop_blocks"] = blocks + 1
    _save_state(session_id, state)
    return _emit_stop_block("\n\n".join(reasons))
```

where `_emit_stop_block` returns the top-level blocking payload:

```python
def _emit_stop_block(reason: str) -> int:
    print(json.dumps({"decision": "block", "reason": reason}))
    return 0
```

---

## Configuration: `settings.json`

Place the hooks in your project’s `.claude/settings.json` (or `~/.claude/settings.json` for global).
All three events point at the **same** Python file — it branches internally on `hook_event_name`, so
there is one script to maintain, not three:

```json
{
  "hooks": {
    "SessionStart": [
      {
        "matcher": "startup|resume",
        "hooks": [
          { "type": "command", "command": "python \"$CLAUDE_PROJECT_DIR/.claude/hooks/adaptive_workflow_hook.py\"" }
        ]
      }
    ],
    "PostToolUse": [
      {
        "matcher": "Edit|Write|MultiEdit",
        "hooks": [
          { "type": "command", "command": "python \"$CLAUDE_PROJECT_DIR/.claude/hooks/adaptive_workflow_hook.py\"" }
        ]
      }
    ],
    "Stop": [
      {
        "hooks": [
          { "type": "command", "command": "python \"$CLAUDE_PROJECT_DIR/.claude/hooks/adaptive_workflow_hook.py\"" }
        ]
      }
    ]
  }
}
```

> **Note**: The `Stop` hook does not support a `matcher`; omitting it is correct.

---

## Summary of Validated Schemas

| Aspect | `SessionStart` | `PostToolUse` | `Stop` |
|--------|---------------|---------------|--------|
| **Effort field** | ❌ Not present | ✅ Present | ✅ Present |
| **Matcher support** | ✅ (startup, resume, clear, compact) | ✅ (tool name) | ❌ None |
| **additionalContext** | ✅ via stdout or JSON | ✅ must be inside `hookSpecificOutput` | ❌ Not supported; use `reason` instead |
| **Blocking decision** | ❌ Not applicable | ❌ (tool already ran; cannot block) | ✅ `decision: "block"` with `reason` |
| **SessionTitle** | ✅ Supported | ❌ | ❌ |
| **WatchPaths / ReloadSkills** | ✅ Supported | ❌ | ❌ |
| **Block safety cap** | – | – | 8 consecutive blocks |

---

## Deployment Checklist

Before deploying to production, verify the following operational details:

1. **Python Availability**:  
   Ensure the `python` executable is in the system `PATH` where Claude Code runs. If using a version manager (pyenv, conda), Claude Code might not see it. If you encounter "command not found: python" errors, change the `settings.json` command to the absolute path, e.g., `"C:\\Python312\\python.exe \"$CLAUDE_PROJECT_DIR/.claude/hooks/adaptive_workflow_hook.py\""`. The hook uses only the Python standard library — there are no third-party dependencies to install.

2. **File Permissions**:  
   Ensure the `.claude/hooks/` directory and `adaptive_workflow_hook.py` are readable by the user running Claude Code. (It does not need to be executable (`chmod +x`) since you invoke it via `python`, but it must be readable.)

3. **Git Ignore**:  
   Add `.claude/settings.local.json` to your `.gitignore` if you plan to keep personal hook configurations separate, but commit `.claude/settings.json` and the hooks scripts so your team shares the workflow.

4. **Testing**:  
   - Start a new session with an existing `UNFINISHED.md` – verify the hook injects the summary and the agent asks about continuation.  
   - Edit a source file without touching docs – confirm the reminder appears.  
   - Attempt to end a session while `UNFINISHED.md` exists – verify Claude does not stop and attempts to archive the plan.

---

## References

- Official Claude Code Hooks Documentation:  
  - `https://code.claude.com/docs/en/hooks`  
  - `https://docs.anthropic.com/en/docs/claude-code/hooks`

- Adaptive Self‑Correcting Workflow (v3.2):  
  *(link to your workflow document)*

---

*End of Document – Definitive Implementation Guide v1.0*  
**Status: APPROVED FOR IMPLEMENTATION**