---
name: adaptive-workflow
description: >-
  The process manual for this repo's Adaptive Self-Correcting Workflow (v3.3) —
  how to run any coding task across sessions without losing state or letting docs
  go stale. Use whenever you start real work in flutter-ui-kit: "let's start on X",
  "let's add a new UiXxx component", "continue where we left off", "what's next on
  the roadmap", "pick up the unfinished plan", "wrap up / close out this task",
  "we finished X — archive it", or "what did we do about Y before?". It defines
  Phase 0 (git sync, env, core docs, surface UNFINISHED.md), Phase 1 (meta-plan +
  roadmap chunking), Phase 2 (execute + conditional doc/roadmap updates), and
  Phase 3 (archive the plan, clear UNFINISHED.md, commit), plus filesystem-native
  history retrieval via grep/ls. Does NOT apply to trivial one-shot Q&A that
  touches no repo state (a lookup, a quick explanation, a single throwaway rename),
  and does NOT govern unrelated repos — only this working tree, whose invariants
  live in CLAUDE.md. For how to WRITE the Dart code itself, pair this with the
  dart-solid-principles and flutter-ui-kit-component skills.
---

# Adaptive Self-Correcting Workflow (v3.3)

The full manual for the meta-framework this repo runs. The immutable subset lives
in [CLAUDE.md](../../../CLAUDE.md) (the Constitution, always loaded); this skill is
the detailed process, loaded on demand. When the two disagree, CLAUDE.md and the
canonical spec under `docs/adaptive-workflow/` win.

This skill governs *how to run a task* (state, handoff, memory hygiene). Two sibling
skills govern *how to write the code*: **`dart-solid-principles`** (Dart design/SOLID)
and **`flutter-ui-kit-component`** (the token-only rule, the default-with-override
pattern, testing/versioning for `Ui<Name>` widgets). Reach for those in Phase 2.

## Why this exists

Multi-session, AI-assisted development breaks down in four predictable ways:
docs grow stale because no session is forced to update them; handoff between
sessions is lost because a fresh session doesn't know what was in flight; large
tasks overflow a single session with no roadmap to chunk them; and historical
context drowns the agent if every session loads an ever-growing archive. This
workflow fixes each: **conditional** doc updates keep memory current without
bureaucracy, a single `plans/UNFINISHED.md` carries handoff, `ROADMAP.md` chunks
big goals, and history is fetched **on demand** via `grep`/`ls` — never a bloated
index.

The governing principle: *fixed invariants for safety; dynamic planning for
agility; roadmap for direction; filesystem for selective recall.*

## Phase 0 — Fixed invariants (always first)

These are defined authoritatively in [CLAUDE.md](../../../CLAUDE.md). Don't
re-explain them — **run** them. The "how" that isn't obvious from the Constitution:

- **F1 Git sync.** `git pull --rebase`; check for a dirty tree. If the remote is
  unreachable, report the error and ask the user how to proceed — never silently
  skip, because a stale base is how two sessions clobber each other.
- **F2 Environment.** Run `.ai/env_check.ps1` (PowerShell, Windows-native). It
  reports Flutter/Dart/Git readiness — a reporting pre-flight, not a gate; a
  `MISSING` line is information, not a stop. (SDK is managed by puro; the script
  falls back to the puro binary path if `flutter`/`dart` aren't on PATH.)
- **F3 Core docs.** Have `.ai/best_practices.md`, `.ai/naming_conventions.md`, and
  `docs/design-system-contract.md` in context. The SessionStart hook pre-injects
  summaries; request the full doc when a summary is too terse.
- **F4 Unfinished plan.** If `plans/UNFINISHED.md` exists, surface it to the user
  *before* anything else and ask: continue it, or archive it? Its very existence
  means a prior session left work mid-flight.

## Phase 1 — Meta-planning (before implementing)

Design a task-specific workflow instead of applying the same ceremony to
everything. Weigh six things: task **scope** (trivial fix → new component →
token/API change?), **multi-task potential** (does this span sessions?), **doc
impact** (does it change the design-system contract or conventions?),
**handoff/traceability** need, **validation rigor** (`flutter analyze`? `flutter
test`? a single test file?), and **retro value** (any repeatable mistake worth
recording?).

**Roadmap logic** — if the request is too large for one `UNFINISHED.md`:
1. Create/extend `ROADMAP.md` with epics and checkable sub-tasks.
2. Pick the next logical, unblocked task as the current piece of work.
3. Put *only that chunk* in `plans/UNFINISHED.md`, linked to the roadmap item.
4. Tell the user what you deferred to the roadmap and what you're doing now.

If `ROADMAP.md` already exists, place the request into an epic (or negotiate a new
one), then create `UNFINISHED.md` for the chosen chunk. End Phase 1 with a concrete
bullet plan plus acceptance criteria; present it briefly for confirmation when the
task is non-trivial.

Remember this repo's promotion rule (CLAUDE.md): app-specific screens/layouts stay
in the consuming app; a composite is only promoted into this kit once a **second**
app has an identical use case. Don't roadmap speculative composites as active work.

See [references/roadmap-and-archive.md](references/roadmap-and-archive.md) for the
exact `ROADMAP.md` format and chunking recipe.

## Phase 2 — Execute the plan

Work the plan bullet by bullet: implement, then immediately run the validations
that bullet warrants — `flutter analyze` (keep it at "No issues found") and
`flutter test` (every new/changed widget gets a mirrored test under `test/`). If an
obstacle appears, log it and propose an updated plan rather than silently improvising.
For the *code* itself, follow `flutter-ui-kit-component` (token-only rule, no
hardcoded colors/sizes; default-with-override via `UiTuning`) and
`dart-solid-principles`.

Apply the **conditional-update triggers** *during and after* execution. The full
table is in [CLAUDE.md](../../../CLAUDE.md); the discipline that matters:

- **Any change worth tracing → append to the weekly ledger `history/YYYY-Www.md`**
  (required). Substantial change → full `### [tag] path` + What/Why/Refs; minor change
  → one terse line. See [history/FORMAT.md](../../../history/FORMAT.md).
- New pattern/rule/gotcha → append to `.ai/best_practices.md` (with an example).
- New naming convention → `.ai/naming_conventions.md`.
- Token/API/contract change → update `docs/design-system-contract.md` (or the
  relevant `docs/*.md`) with a dated annotation; bump the version per CLAUDE.md's
  versioning rule and update `CHANGELOG.md`.
- Non-obvious decision → `plans/archive/<slug>/execution_log.md`.
- Task changes future work → update `ROADMAP.md`; epic finished → move it to
  `## Completed Epics`.
- **No impact on shared knowledge → do nothing** *for the shared docs above.* Note this
  does **not** exempt the ledger: the ledger logs everything (minor changes get a
  one-liner), because the failure it fixes was a *missing* trace. The don't-over-document
  rule still governs `best_practices`/`docs`/`execution_log` — noise is kept out of those
  by omission, but out of the ledger by *brevity*. The PostToolUse hook nudges once per
  session about both; treat it as a prompt to *decide*, not a command to write.

## Phase 3 — Closure (you are not done until this is complete)

A traced task ends only when:
1. `plans/UNFINISHED.md` is moved to `plans/archive/YYYY-MM-DD_<slug>/plan.md`,
   plus `references.md` / `execution_log.md` / `retro.md` when they carry value.
2. `plans/UNFINISHED.md` is **cleared** — it must not exist at rest, or the Stop
   hook will block every future session.
3. A **closure entry is appended to the current weekly ledger `history/YYYY-Www.md`**
   *before* the commit — mandatory. The Stop hook warns if source/doc changes were made
   this session without a ledger entry.
4. `ROADMAP.md` is updated if triggered; the completed item is checked off.
5. `git commit -m "Plan: <slug> — <summary>" && git push`. (Tag `vMAJOR.MINOR.PATCH`
   only once `flutter analyze` and `flutter test` are clean on `main`, per CLAUDE.md.)

If a session must end with work genuinely unfinished, leave `UNFINISHED.md` intact
and tell the user plainly that the plan is incomplete so the next session resumes
it. The Stop hook enforces this, but the discipline is yours — see
[references/roadmap-and-archive.md](references/roadmap-and-archive.md) for the
archive folder layout.

## Historical context retrieval (filesystem-native)

There is **no archive index** — by design, because an index grows without bound
and forces every session to load history it doesn't need. Two complementary views:

**Time-ordered — the change ledger (`history/`):** the chronological "what changed,
when, why" breadcrumb. `ls history/` lists the weeks; open a `YYYY-Www.md` week file to
read every change in it; `grep -rn "UiButton" history/` traces one topic over time.
This is the first stop for "what did we change recently / trace this widget."

**Task-depth — the archive (`plans/archive/`):** the deep per-task record.
- By keyword: `grep -r "tuning panel" plans/archive/`
- By date: `ls plans/archive/ | grep "2026-07"`
- By slug: `ls plans/archive/ | grep "dropdown"`

Then read only the specific file you need (`plan.md`, `execution_log.md`,
`retro.md`). Never load the whole archive — or the whole `history/` dir.

## The hooks that back this workflow

A single Python dispatcher (`.claude/hooks/adaptive_workflow_hook.py`) provides
ambient awareness — SessionStart context injection, the PostToolUse doc nudge, and
the Stop closure guard. It never replaces your judgement; it only reminds. Python is
dev-only tooling here and does **not** violate the kit's zero-package-dependency rule
(that rule governs the shipped Flutter package). If you touch the hooks or need the
exact, validated I/O schemas (and the two documented schema bugs to avoid), read
[references/hook-integration.md](references/hook-integration.md).

## Reference files

- [references/workflow-spec.md](references/workflow-spec.md) — the deep-dive: full
  v3.3 concept, phase definitions, and worked examples (the canonical spec minus
  the Constitution). Read it when you need the complete rationale or an edge case.
- [references/hook-integration.md](references/hook-integration.md) — validated hook
  event schemas, the corrected output contracts, and the reference implementations.
- [references/roadmap-and-archive.md](references/roadmap-and-archive.md) —
  `ROADMAP.md` format, the chunking process, the archive folder layout, and
  long-term memory hygiene.
