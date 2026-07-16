---
name: adaptive-workflow
description: >-
  The process manual for this repo's Adaptive Self-Correcting Workflow (v4.4) —
  how to run any coding task across sessions without losing state or letting docs
  go stale. Use whenever you start real work in flutter-ui-kit: "let's start on X",
  "let's add a new UiXxx component", "continue where we left off", "what's next on
  the roadmap", "pick up the unfinished plan", "wrap up / close out this task",
  "we finished X — archive it", or "what did we do about Y before?". It defines
  Phase 0 (git sync, env, core docs, surface UNFINISHED.md, daily workflow-update
  check), Phase 1 (meta-plan + roadmap chunking), Phase 2 (execute + conditional
  doc/ledger updates + the Documentation Standard's provenance frontmatter), and
  Phase 3 (archive the plan, clear UNFINISHED.md, commit), plus filesystem-native
  history retrieval via grep/ls. Does NOT apply to trivial one-shot Q&A that
  touches no repo state (a lookup, a quick explanation, a single throwaway rename),
  and does NOT govern unrelated repos — only this working tree, whose invariants
  live in CLAUDE.md. For how to WRITE the Dart code itself, pair this with the
  dart-solid-principles and flutter-ui-kit-component skills.
---

# Adaptive Self-Correcting Workflow (v4.4) — flutter-ui-kit

This repo adopts the workflow as a **git submodule** at `.claude/workflow-core`
(pinned to a reviewed commit). The canonical process manual and full reference now
live there — this file is a **thin pointer** so the skill stays discoverable under
`.claude/skills/`, plus the flutter-specific bindings the generic manual doesn't know.

**Read these for the authoritative process (do not duplicate them here):**
- Agent manual: [`.claude/workflow-core/skills/adaptive-workflow/SKILL.md`](../../workflow-core/skills/adaptive-workflow/SKILL.md)
  — the Phase 0–3 checklists, conditional triggers, ledger, and the Documentation Standard.
- Full reference: [`.claude/workflow-core/GUIDE.md`](../../workflow-core/GUIDE.md) (v4.4).
- The immutable subset is the Constitution in [CLAUDE.md](../../../CLAUDE.md) (always
  loaded). When any of these disagree, CLAUDE.md and the workflow-core GUIDE win.

Two sibling skills govern *how to write the code*: **`dart-solid-principles`** (Dart
design/SOLID) and **`flutter-ui-kit-component`** (the token-only rule, the
default-with-override pattern via `UiTuning`, testing/versioning for `Ui<Name>`
widgets). Reach for those in Phase 2.

## This project's bindings (what the generic manual maps to here)

- **Config:** [`.claude/workflow_config.json`](../../workflow_config.json) —
  `source_directories: ["lib"]`, `documentation_directories: ["docs", ".ai"]`,
  `roadmap_file: ROADMAP.md`, `ledger.directory: history`, `main_branch: main`.
- **F1 Git sync:** `git pull --rebase`; never silently skip on a dirty tree or an
  unreachable remote — a stale base is how two sessions clobber each other.
- **F2 Environment:** `.ai/env_check.ps1` (PowerShell, puro-aware — falls back to the
  puro binary path when `flutter`/`dart` aren't on PATH). A `MISSING` line is
  information, not a gate. This is injected by the local **supplement hook**
  (`.claude/hooks/supplement.py`), which runs *alongside* the workflow-core hook and
  also injects the living-doc summaries and the next `ROADMAP.md` `- [ ]` item, and
  blocks at Stop on a *human-authored* `plans/UNFINISHED.md`.
- **F5 Daily workflow-update check:** owned by the **upstream** `workflow_hook.py`
  and enabled for this repo via `workflow_update_check.enabled: true` in
  `workflow_config.json`. Once/day the SessionStart hook fetches the `workflow-core`
  submodule and injects a `🔄 Workflow updates available` notice if it is behind
  (once/day marker `.ai/.workflow_check_date`, gitignored). Detection-only — running
  `git submodule update --remote` stays user-approved (GUIDE §9).
- **F3 Core docs:** `.ai/best_practices.md`, `.ai/naming_conventions.md`,
  `docs/golden-rule/design-system-contract.md`. The SessionStart supplement pre-injects
  summaries; request the full doc when a summary is too terse.
- **Validation (Phase 2):** `flutter analyze` (keep at "No issues found") and
  `flutter test` (every new/changed widget gets a mirrored test under `test/`).
- **Versioning:** token/API/contract change → update `docs/golden-rule/design-system-contract.md`
  dated, bump the semver + repo-root `CHANGELOG.md`; tag `vMAJOR.MINOR.PATCH` only once
  analyze/test are clean on `main`.
- **Promotion rule:** app-specific screens/layouts stay in the consuming app; a
  composition is promoted into `lib/src/molecules/` (stateless) or `lib/src/organisms/`
  (local UI state) only once a **second** app has an identical use case. Don't roadmap
  speculative compositions as active work.

## Checklist-driven execution + branch/PR merge-gate

The phases are a **master checklist, not a rigid pipeline** — for any task, *select the
applicable rows*. Two tiers keep the flexibility safe (full authority: [CLAUDE.md → Git
workflow](../../../CLAUDE.md) and its bindings section; CLAUDE.md wins on disagreement):

- **Mandatory gates (always):** **G1** git sync before editing (F1) · **G2** branch/PR
  merge-gate — no unverified code reaches `main` · **G3** ledger entry for any real change ·
  **G4** no dangling `plans/UNFINISHED.md` at rest.
- **Selectable rows (pick per task, each with its own trigger):** branch-or-not · PR-or-not ·
  doc frontmatter · roadmap update · provenance · retro · `SCOPE.md` · test scope ·
  version/`CHANGELOG` bump · env check.

Phase 1 = look at the task → tick the applicable selectable rows → that (plus G1–G4) is the plan.

**Branch/PR merge-gate — the repo-local override of the generic "commit & push to `main`" close:**

- **F6 (Phase 0, after F1):** `gh pr list --state open`; if a PR is open, ask *"Is PR #N verified
  and ready to merge?"* → **yes**: `gh pr merge <n> --squash --delete-branch` then
  `git checkout main && git pull`; **no**: leave it, ask branch-or-fresh. Never stack new work on
  an unverified PR. If `gh auth status` fails, defer the merge to the user.
- **Branch decision (Phase 1, pragmatic scope rule):** branch on a substantive change to `lib/`,
  tokens, the version, or canonical guidance (`docs/golden-rule/`, `CLAUDE.md`, `.claude/skills/`);
  trivial doc/ledger/typo edits (including a skill typo) may go straight to `main`. Branch name
  `<type>/<slug>`, `type` ∈ `feat | fix | docs | chore`.
- **Branch close (Phase 3):** commit on the branch → `git push -u origin <branch>` →
  `gh pr create` (title = plan summary; body = what/why + analyze/test results). **No same-session
  merge** — merge is the next session's F6 gate after the user verifies. Fallback if `gh` is
  unavailable: `git push -u origin <branch>` and hand the user the compare-URL. Self-check: not
  done until the branch is pushed and the PR is opened (plus `UNFINISHED.md` cleared, ledger
  written). Trivial non-branch edits still close with a direct commit to `main`.

## Historical context retrieval (filesystem-native, no index)

- **Time-ordered — the ledger `history/`:** `ls history/` lists the weeks; open a
  `YYYY-Www.md` to read every change; `grep -rn "UiButton" history/` traces one topic.
- **Task-depth — the archive `plans/archive/`:** `grep -r "keyword" plans/archive/`,
  `ls plans/archive/ | grep 2026-07`. Read only the file you need — never load the
  whole archive or the whole `history/` dir.

## Contributing improvements upstream

The three ambient features the `supplement.py` hook adds (living-doc injection,
ROADMAP `- [ ]` scan, human-authored-UNFINISHED-in-Stop) are candidates to fold back
into workflow-core rather than carried locally forever — see
[`.claude/workflow-core/CONTRIBUTING.md`](../../workflow-core/CONTRIBUTING.md) and
GUIDE §10 for the classification + PR process. (F5 was previously a fourth local
feature; it is now **owned upstream** — `workflow_hook.py` + a `workflow_update_check`
key in the upstream `config_schema.json` — so it has been retired from the supplement.)
