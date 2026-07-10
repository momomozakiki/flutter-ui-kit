#!/usr/bin/env python
"""Unified Adaptive Self-Correcting Workflow hook (v3.3) — flutter-ui-kit edition.

One dispatcher wired to three Claude Code hook events. It branches on the
``hook_event_name`` field every event delivers on stdin:

- ``SessionStart`` (startup|resume) — injects Phase 0 context: environment
  status, summaries of the living docs, an unfinished-plan alert, and the next
  actionable ROADMAP item. Also names the session.
- ``PostToolUse`` (Edit|Write|MultiEdit) — advisory (never-blocking) nudge to
  update docs/roadmap when source code changes (fires once per session). Also
  records two session-state flags for the change-history ledger: a write under
  ``history/`` sets ``ledger_entry_written``; a change to any tracked repo area
  sets ``traceable_change_made``.
- ``Stop`` — reminds the agent to run Phase 3 before closing: it re-prompts while
  ``plans/UNFINISHED.md`` exists (archive + clear) AND once if tracked files changed
  this session without a ``history/YYYY-Www.md`` ledger entry. Bounded by
  ``MAX_STOP_BLOCKS`` so a turn is never trapped.

Design notes
------------
- Every handler fails soft: any unexpected error exits 0, so a hook never breaks
  a tool call or a turn. Git/env failures degrade to a note, never an error.
- Session state lives in one small JSON file in the temp dir, keyed by session id.
- Schemas follow the validated hook-integration guide, NOT the outdated spec
  examples: SessionStart/PostToolUse use ``hookSpecificOutput.additionalContext``;
  Stop uses a top-level ``decision``/``reason``.

flutter-ui-kit adaptation: this is a pure Dart/Flutter package (puro toolchain,
``lib/`` source, ``flutter analyze``/``flutter test``). The living-doc set uses
``docs/design-system-contract.md`` as the architecture authority (there is no
``docs/architecture.md`` here), and ``SOURCE_PREFIXES`` is ``lib/``.
"""
from __future__ import annotations

import json
import os
import re
import subprocess
import sys
import tempfile
import time
from pathlib import Path

# --- tunables ---------------------------------------------------------------
MAX_STOP_BLOCKS = 2            # how many times Stop may block before giving up
STATE_TTL_SECONDS = 24 * 3600  # SessionStart deletes state files older than this
ENV_CHECK_TIMEOUT = 30         # seconds before giving up on env_check.ps1
# Conservative doc-summary cutoff. Living docs shorter than this are injected in
# full; longer ones are truncated with a "full document available" note.
DOC_SUMMARY_CHARS = 2000
# Source roots whose edits should prompt a "consider updating docs" nudge. Flutter
# packages keep all source under lib/ (lib/src/... is covered by this prefix).
SOURCE_PREFIXES = ("lib/",)

# The weekly change-history ledger. A write anywhere under this prefix marks the
# ledger as updated this session (see ledger_entry_written). It is deliberately NOT
# in SOURCE_PREFIXES, so touching the ledger never triggers the doc nudge.
LEDGER_PREFIX = "history/"

# Repo areas whose modification is "worth tracing" and therefore warrants a ledger
# entry. Used only to decide whether to remind at Stop — not to block a tool call.
TRACEABLE_MARKERS = (
    ".ai/", "docs/", "lib/", "test/", "templates/", ".claude/",
    "ROADMAP.md", "CLAUDE.md", "README.md",
)

LIVING_DOCS = (
    (".ai/best_practices.md", "Best Practices"),
    (".ai/naming_conventions.md", "Naming Conventions"),
    ("docs/design-system-contract.md", "Design-System Contract"),
)

DOC_NUDGE = (
    "Source changed. Per the conditional-update triggers in CLAUDE.md, consider "
    "whether this affects shared knowledge: update docs/design-system-contract.md, "
    ".ai/best_practices.md, or .ai/naming_conventions.md (and ROADMAP.md if it "
    "changes future work). If it has no impact on shared knowledge, do nothing. "
    "And if this change is worth tracing later, append a dated entry to the current "
    "weekly ledger history/YYYY-Www.md (required — minor changes get a one-liner). "
    "(This reminder fires once per session.)"
)

# Session-state flags related to the change-history ledger. Reset each SessionStart.
LEDGER_FLAGS = ("ledger_entry_written", "traceable_change_made", "ledger_reminder_emitted")


# --- state helpers ----------------------------------------------------------
def _state_path(session_id: str) -> Path:
    safe = re.sub(r"[^A-Za-z0-9_.-]", "_", session_id or "default")
    return Path(tempfile.gettempdir()) / f"adaptive_hook_state_{safe}.json"


def _load_state(session_id: str) -> dict:
    try:
        return json.loads(_state_path(session_id).read_text(encoding="utf-8"))
    except (OSError, ValueError):
        return {}


def _save_state(session_id: str, state: dict) -> None:
    try:
        _state_path(session_id).write_text(json.dumps(state), encoding="utf-8")
    except OSError:
        pass


def _project_dir(data: dict) -> Path:
    return Path(os.environ.get("CLAUDE_PROJECT_DIR") or data.get("cwd") or ".")


def _tool_input(data: dict) -> dict:
    ti = data.get("tool_input")
    return ti if isinstance(ti, dict) else {}


# --- output helpers ---------------------------------------------------------
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


def _emit_stop_block(reason: str) -> int:
    print(json.dumps({"decision": "block", "reason": reason}))
    return 0


# --- SessionStart pieces ----------------------------------------------------
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
    # Reset the per-session ledger flags so a resumed session_id starts clean —
    # the ledger reminder is judged against work done in *this* session.
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


# --- PostToolUse ------------------------------------------------------------
def _modified_paths(tool: str, ti: dict) -> list[str]:
    paths: list[str] = []
    if tool in ("Edit", "Write", "NotebookEdit", "MultiEdit"):
        fp = ti.get("file_path")
        if fp:
            paths.append(str(fp))
    return [p.replace("\\", "/") for p in paths]


def _matches(path: str, marker: str) -> bool:
    """True if `marker` is a leading or embedded path segment of `path`."""
    return path.startswith(marker) or f"/{marker}" in path


def _touches_ledger(path: str) -> bool:
    return _matches(path, LEDGER_PREFIX)


def _is_traceable(path: str) -> bool:
    """A change worth a ledger entry — any tracked repo area except the ledger itself."""
    if _touches_ledger(path):
        return False
    return any(_matches(path, m) for m in TRACEABLE_MARKERS)


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


# --- Stop -------------------------------------------------------------------
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


# --- misc -------------------------------------------------------------------
def _cleanup_stale_state() -> None:
    cutoff = time.time() - STATE_TTL_SECONDS
    try:
        for p in Path(tempfile.gettempdir()).glob("adaptive_hook_state_*.json"):
            try:
                if p.stat().st_mtime < cutoff:
                    p.unlink()
            except OSError:
                pass
    except OSError:
        pass


_HANDLERS = {
    "SessionStart": handle_session_start,
    "PostToolUse": handle_post_tool_use,
    "Stop": handle_stop,
}


def main() -> int:
    try:
        data = json.load(sys.stdin)
    except (json.JSONDecodeError, ValueError):
        return 0
    if not isinstance(data, dict):
        return 0
    event = data.get("hook_event_name") or data.get("hookEventName") or ""
    session_id = str(data.get("session_id") or "default")
    handler = _HANDLERS.get(event)
    if handler is None:
        return 0
    try:
        return handler(data, session_id)
    except Exception:  # fail soft — a hook must never break a tool call/turn
        return 0


if __name__ == "__main__":
    sys.exit(main())
