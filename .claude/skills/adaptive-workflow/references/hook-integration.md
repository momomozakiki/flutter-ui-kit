# Hook Integration — Validated Schemas & Reference

Everything needed to understand or modify `.claude/hooks/adaptive_workflow_hook.py`.
Loaded on demand from [../SKILL.md](../SKILL.md). Canonical source:
`docs/adaptive-workflow/Claude Code Hook Integration.md`.

## Table of contents
1. Architecture (one dispatcher, three events)
2. The two documented schema bugs to avoid
3. SessionStart contract
4. PostToolUse contract
5. Stop contract
6. settings.json wiring
7. Modifying the hook safely

## 1. Architecture

One Python file (`adaptive_workflow_hook.py`) is wired to all three events and
branches on the `hook_event_name` field every event delivers on stdin. Every
handler **fails soft**: any unexpected error exits 0, so a hook can never break a
tool call or trap a turn. Per-session state is a small JSON file in the temp dir,
keyed by `session_id`. This unified-dispatcher shape is deliberately chosen over the
spec's three separate JS scripts: `python` is on PATH here, `node` is not
guaranteed, and one file centralises the fail-soft logic and the Stop-block counter.
Python is dev-only tooling — it is not a package dependency, so the kit's
zero-dependency rule (which governs the shipped Flutter package) is unaffected.

## 2. The two documented schema bugs to avoid

The design docs contain two mistakes — the live hook implements the corrected
forms, and any change must preserve them:

- **`decision: "approve"` is outdated.** Spec §6.1 shows
  `{"decision":"approve","additionalContext":…}` for SessionStart/PostToolUse.
  The correct contract (hook guide §1.2/§2.2) wraps context inside
  `hookSpecificOutput.additionalContext`. Approve/deny is not how these events
  return context.
- **The roadmap regex must respect section boundaries.** The JS reference used
  `/- \[ \] .*/`, which matches an unchecked box *anywhere*, including under
  `## Completed Epics`. The Python `_next_roadmap_item` stops scanning at
  `## Completed Epics` / `## Backlog`, so it returns the first unchecked item of
  the first **active** epic.

## 3. SessionStart contract

- Matcher: `startup|resume`. Fires before MCP servers finish connecting — use only
  filesystem/subprocess, never MCP tools. No `effort` field is present.
- Output: `hookSpecificOutput.additionalContext` (string injected as initial
  context). May also set top-level `sessionTitle` (names the session). Other
  supported fields: `initialUserMessage`, `watchPaths`, `reloadSkills`.
- Our handler injects: env status (from `.ai/env_check.ps1`), summaries of the
  three living docs (`.ai/best_practices.md`, `.ai/naming_conventions.md`,
  `docs/design-system-contract.md` — full if under the char cutoff, else truncated
  with a "full document available" note), a `plans/UNFINISHED.md` alert if present,
  and the next roadmap item. Target the whole injection under ~1000 tokens.

## 4. PostToolUse contract

- Matcher: tool names — wired as `Edit|Write|MultiEdit`.
- Output **must** wrap `additionalContext` inside `hookSpecificOutput`. It
  **cannot block** — the tool already ran (only PreToolUse can block).
- Our handler emits a once-per-session advisory nudge when an edited path is under
  a source prefix (`lib/`), reminding the agent to *consider* the
  conditional-update triggers. It is intentionally quiet: one nudge, then silent.
  The nudge is suppressed if the same tool call also touched `docs/` — matching
  the canonical spec's `srcModified && !docModified` condition — so a call that
  already updates docs alongside source doesn't get a redundant reminder. It also
  records the ledger state flags (`ledger_entry_written`, `traceable_change_made`)
  that the Stop guard reads.

## 5. Stop contract

- No matcher (Stop ignores any `matcher`).
- To keep the turn going, return top-level `{"decision":"block","reason":…}`. Stop
  does **not** support `hookSpecificOutput`/`additionalContext` — all instruction
  goes in `reason`, which the agent reads as its next instruction.
- Claude Code overrides the hook after **8 consecutive blocks**. Our handler adds
  its own tunable cap (`MAX_STOP_BLOCKS`, default 2) plus a `stop_hook_active`
  check, so it blocks *while* `plans/UNFINISHED.md` exists (and once for a missing
  ledger entry), then gives up rather than trapping the turn. Block → agent runs
  Phase 3 → next Stop re-checks → passes.

## 6. settings.json wiring

```json
{
  "hooks": {
    "SessionStart": [
      { "matcher": "startup|resume",
        "hooks": [ { "type": "command",
          "command": "python \"$CLAUDE_PROJECT_DIR/.claude/hooks/adaptive_workflow_hook.py\"" } ] }
    ],
    "PostToolUse": [
      { "matcher": "Edit|Write|MultiEdit",
        "hooks": [ { "type": "command",
          "command": "python \"$CLAUDE_PROJECT_DIR/.claude/hooks/adaptive_workflow_hook.py\"" } ] }
    ],
    "Stop": [
      { "hooks": [ { "type": "command",
          "command": "python \"$CLAUDE_PROJECT_DIR/.claude/hooks/adaptive_workflow_hook.py\"" } ] }
    ]
  }
}
```

Hook commands are executed directly by Claude Code and are **not** gated by the
`permissions.allow` `Bash(...)` list — so no `Bash(python:*)` entry is required for
the hook to fire. If `python` isn't found at runtime (version managers can hide it),
use an absolute path in the command. Hook scripts must be readable; they don't need
`+x` since they're invoked via `python`.

## 7. Modifying the hook safely

- Verify offline before relying on it: pipe a synthetic payload to the script and
  inspect stdout, e.g.
  `echo '{"hook_event_name":"SessionStart","session_id":"t1"}' | python .claude/hooks/adaptive_workflow_hook.py`.
  The once-per-session flags live in the temp dir keyed by `session_id`; use a fresh
  id (or delete `%TEMP%/adaptive_hook_state_<id>.json`) to re-observe a nudge.
- Keep every handler fail-soft. A hook that raises is worse than a hook that does
  nothing.
- Never let `plans/UNFINISHED.md` exist at rest in the repo — the Stop guard keys
  off it and would block every session.
- If you add source roots, update `SOURCE_PREFIXES`; if you add tracked areas,
  update `TRACEABLE_MARKERS`; if the living-doc set changes, update `LIVING_DOCS`.
