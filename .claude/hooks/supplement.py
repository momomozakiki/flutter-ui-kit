#!/usr/bin/env python
"""Local supplement hook — flutter-ui-kit.

Runs *alongside* the canonical workflow-core dispatcher
(`.claude/workflow-core/hooks/workflow_hook.py`), chained as a second command
hook per event in `.claude/settings.json`. It provides only the three ambient
features the upstream v4.4 hook does not, so the submodule stays pristine (no
fork) and nothing regresses versus the old bespoke v3.3 hook:

- ``SessionStart`` — injects Phase 0 context the upstream hook omits:
  ``.ai/env_check.ps1`` output (with its puro fallback, so Flutter/Dart are
  reported correctly on this puro-managed box), living-doc summaries, and the
  next actionable ROADMAP ``- [ ]`` item. (Git status + reminders come from the
  upstream hook; env there is disabled via an empty ``env_check.tool_paths``.)
- ``Stop`` — surfaces an unarchived *human-authored* ``plans/UNFINISHED.md`` (the
  workflow's core closure guardrail), bounded so a turn is never trapped. Skips an
  auto-breadcrumb file written by the upstream Stop hook (marked with
  ``BREADCRUMB_MARKER``) — that one is upstream's to own and it re-surfaces it next
  SessionStart via F4. Uses its own state key so it never fights the upstream Stop
  hook's ledger/dirty reminders/breadcrumb.
- ``PostToolUse`` — intentionally a no-op; the upstream hook owns the doc nudge
  and ledger/source tracking.

Every handler fails soft: any error exits 0, so a hook never breaks a turn.
Schemas match the validated hook-integration contract: SessionStart uses
``hookSpecificOutput.additionalContext``; Stop uses top-level ``decision``/``reason``.
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
# Living docs shorter than this are injected in full; longer ones are truncated.
DOC_SUMMARY_CHARS = 2000

# Marker the upstream workflow-core Stop hook writes at the top of an
# auto-generated plans/UNFINISHED.md breadcrumb. We skip such files so this
# supplement only blocks on a genuine, human-authored plan — the upstream hook
# owns the dirty-tree breadcrumb and its F4 surfacing next SessionStart.
BREADCRUMB_MARKER = "<!-- workflow-hook: auto-breadcrumb -->"

LIVING_DOCS = (
    (".ai/best_practices.md", "Best Practices"),
    (".ai/naming_conventions.md", "Naming Conventions"),
    ("docs/design-system-contract.md", "Design-System Contract"),
)


# --- state helpers ----------------------------------------------------------
def _state_path(session_id: str) -> Path:
    safe = re.sub(r"[^A-Za-z0-9_.-]", "_", session_id or "default")
    return Path(tempfile.gettempdir()) / f"supplement_hook_state_{safe}.json"


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
    # An auto-breadcrumb written by the upstream workflow-core Stop hook is owned
    # by that hook (it also surfaces it next SessionStart via F4). Don't block on
    # it here — this handler exists only to guard a genuine, human-authored plan.
    if BREADCRUMB_MARKER in text:
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
    _save_state(session_id, {})  # reset per-session flags for a resumed id
    project_dir = _project_dir(data)

    parts: list[str] = [f"[{_env_status(project_dir)}]"]

    for rel, label in LIVING_DOCS:
        summary = _doc_summary(project_dir, rel)
        if summary:
            parts.append(f"[{label} — {rel}]\n{summary}")

    next_item = _next_roadmap_item(project_dir)
    if next_item:
        parts.append(f"[Roadmap] Next: {next_item}")

    return _emit_context("SessionStart", "\n\n".join(parts))


# --- Stop -------------------------------------------------------------------
def handle_stop(data: dict, session_id: str) -> int:
    project_dir = _project_dir(data)
    state = _load_state(session_id)

    unfinished = _unfinished_summary(project_dir)
    if unfinished is None:
        return 0  # no unarchived plan — let the turn end

    blocks = int(state.get("stop_blocks", 0))
    if blocks >= MAX_STOP_BLOCKS or bool(data.get("stop_hook_active")):
        return 0  # budget exhausted — never trap the turn

    state["stop_blocks"] = blocks + 1
    _save_state(session_id, state)
    return _emit_stop_block(
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


# --- misc -------------------------------------------------------------------
def _cleanup_stale_state() -> None:
    cutoff = time.time() - STATE_TTL_SECONDS
    try:
        for p in Path(tempfile.gettempdir()).glob("supplement_hook_state_*.json"):
            try:
                if p.stat().st_mtime < cutoff:
                    p.unlink()
            except OSError:
                pass
    except OSError:
        pass


_HANDLERS = {
    "SessionStart": handle_session_start,
    "Stop": handle_stop,
    # PostToolUse: intentionally unhandled — the upstream hook owns it.
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
