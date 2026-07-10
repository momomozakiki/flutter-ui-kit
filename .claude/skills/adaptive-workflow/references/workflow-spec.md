# Workflow Spec — Deep Dive (v3.3)

The complete concept, phase definitions, and worked examples for the Adaptive
Self-Correcting Workflow, minus the Constitution (which is
[CLAUDE.md](../../../CLAUDE.md)). Loaded on demand from [../SKILL.md](../SKILL.md).

> **Canonical source.** The exhaustive, authoritative text is
> `docs/adaptive-workflow/Adaptive Self‑Correcting Workflow.md`. This file is a
> working distillation; when they disagree, the canonical doc wins. Keep this file
> consistent with it (conditional-update discipline applies to the skill's own
> references too).

## Table of contents
1. Concept & philosophy
2. The chunked-memory file structure
3. The full workflow (Phases 0–3)
4. Worked examples
5. Design rationale / FAQ

## 1. Concept & philosophy

A disciplined but flexible meta-framework guiding an AI agent through every task.
It combines fixed operational invariants (git sync, env check, core-doc awareness),
per-task dynamic planning, roadmap-driven chunking, conditional documentation
updates, hook-based ambient automation, a Constitution+Skill split, and
filesystem-native memory retrieval.

It exists because multi-session AI development fails predictably: docs go stale (no
session is forced to update them), handoff breaks (a new session doesn't know
what's unfinished), large tasks overflow one session, and an ever-growing history
index crowds out the token budget. The guarantee: after every task, shared memory
(living docs, conventions, roadmap, unfinished plan) is either current or
consciously left untouched; every new session starts from a minimal, accurate
picture; big goals are split into manageable chunks; history is fetched only on
demand.

Philosophy in one line: **fixed invariants for safety; dynamic planning for
agility; roadmap for direction; hooks for ambient awareness; filesystem for
selective recall.**

## 2. The chunked-memory file structure

```
CLAUDE.md                     # Constitution — immutable, always loaded
.claude/
  skills/adaptive-workflow/   # this skill — full manual, on demand
  skills/dart-solid-principles/     # how to write the Dart code (SOLID/DRY)
  skills/flutter-ui-kit-component/  # how to write Ui<Name> widgets + tokens
  hooks/                      # unified dispatcher
  settings.json               # hook wiring + permissions
.ai/                          # agent's living memory (always current)
  best_practices.md
  naming_conventions.md
  env_check.ps1               # Windows-native pre-flight (Flutter/Dart/Git)
docs/                         # human + agent reference docs
  design-system-contract.md   # the architecture/contract authority for this kit
  adaptive-workflow/          # canonical spec (self-contained copy)
ROADMAP.md                    # epics & milestones
plans/
  UNFINISHED.md               # the ONE active plan (absent at rest)
  archive/YYYY-MM-DD_<slug>/  # completed tasks (no index; grep/ls)
history/YYYY-Www.md           # required weekly change ledger (no index; ls)
```

Key decisions: the Constitution is always loaded so invariants can't be missed;
the full manual is a skill loaded on demand (too large for every session); the
archive has **no index** (filesystem search replaces it, zero maintenance); the
roadmap keeps only active epics (completed ones move to `## Completed Epics`);
`UNFINISHED.md` is the single source of truth for session handoff.

## 3. The full workflow

**Phase 0 — Fixed invariants (always first).** F1 git sync (`git pull --rebase`,
check dirty tree, don't proceed dirty without approval); F2 environment pre-flight
(`.ai/env_check.ps1` — reports Flutter/Dart/Git); F3 absorb the core living docs;
F4 surface any `plans/UNFINISHED.md` immediately and ask continue-or-archive. The
SessionStart hook pre-injects a summary of all four, but acting on them is the
agent's job.

**Phase 1 — Meta-planning.** Evaluate the request on six axes (scope, multi-task
potential, doc impact, traceability/handoff, validation rigor, retro value). If
it's too large for one `UNFINISHED.md`, create/extend `ROADMAP.md`, pick the next
unblocked chunk, and put only that chunk in `UNFINISHED.md`. Produce a bullet plan
with acceptance criteria and include only the process modules the task warrants
(lint, test, doc update, decision log, retro, archive).

**Phase 2 — Execute.** For each bullet: implement, then run required validations
(`flutter analyze`, `flutter test`); if an obstacle arises, log it and propose an
updated plan. Apply the conditional-update triggers during and after (see the table
in CLAUDE.md). The governing restraint: **no impact on shared knowledge → do
nothing** (except the ledger, which logs everything at scaled detail).

**Phase 3 — Closure.** Archive `UNFINISHED.md` → `plans/archive/YYYY-MM-DD_<slug>/`
(plan + optional logs/retro/diff); clear `UNFINISHED.md`; append a ledger entry to
`history/YYYY-Www.md`; update `ROADMAP.md` if triggered and check off the item;
commit and push. Never end a traced task without clearing and archiving. If a
session must stop mid-task, leave `UNFINISHED.md` intact and say so plainly.

## 4. Worked examples

- **Trivial fix** (a doc typo, a one-line default tweak, no contract impact):
  minimal meta-plan, no archive folder, a one-line ledger entry, quick commit.
- **New component / single-session feature with doc impact** (e.g. a new `UiXxx`
  widget or a new token): create `UNFINISHED.md`, implement following
  `flutter-ui-kit-component`, add the mirrored test, update
  `docs/design-system-contract.md` + `CHANGELOG.md` and bump the version per the
  trigger table, archive to `plans/archive/<date>_<slug>/`, check the roadmap item,
  commit.
- **Multi-session epic** ("rework the whole theming/tuning layer"): create/extend
  `ROADMAP.md` with epics, do the first chunk as `UNFINISHED.md`, archive it, update
  the roadmap; the next session's SessionStart hook surfaces the next item and picks
  up automatically.
- **Historical retrieval** ("what did we decide about the tuning panel?"):
  `grep -rn "tuning panel" history/` for the timeline, or
  `grep -r "tuning" plans/archive/`, then read only the matching file.

## 5. Design rationale / FAQ

- **Constitution vs skill.** CLAUDE.md is short, immutable, always loaded; this
  skill is the full manual, loaded on demand. Splitting them keeps the always-on
  token cost tiny.
- **Why no archive index?** An index grows endlessly and forces loading irrelevant
  history. `grep`/`ls` find exactly what's needed with zero maintenance.
- **What if the agent forgets to archive?** The Stop hook blocks closure while
  `UNFINISHED.md` exists; even if that's bypassed, the next SessionStart surfaces
  it. The system is resilient by layering.
- **Is the roadmap mandatory?** No. Without it, the workflow handles one task at a
  time. It earns its keep only for goals that span sessions.
- **Why Python hooks in a Dart repo?** The hook is dev-only tooling, not a package
  dependency — the kit's zero-dependency rule governs the shipped Flutter package,
  which is untouched. `python` is on PATH here; a single dispatcher centralises the
  fail-soft logic and the Stop-block counter.
- **Updating the workflow itself.** The retro step can propose changes to CLAUDE.md
  or this skill; because they're versioned in git, changes are reviewable.
