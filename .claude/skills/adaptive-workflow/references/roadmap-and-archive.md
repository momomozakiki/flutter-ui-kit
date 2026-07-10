# Roadmap, Archive & Long-Term Memory

Deep-dive for the roadmap format, task chunking, the archive layout, and memory
hygiene. Loaded on demand from [../SKILL.md](../SKILL.md). Canonical source:
`docs/adaptive-workflow/Adaptive Self‑Correcting Workflow.md` §7–§9.

## ROADMAP.md format

```markdown
# Project Roadmap

## Epic 1: Test coverage gaps
- [ ] Add mirrored test for ui_status_chip
- [ ] ...

## Backlog / Icebox
- [ ] Promote a shared composite once a 2nd app has an identical use case

## Completed Epics
- [x] Epic 0: Core atoms (button, text field, dropdown, status chip, banner, checkbox)
```

Rules that the tooling depends on:
- Each bullet is a **high-level** task, not a detailed plan. Detail lives in
  `plans/UNFINISHED.md` for the one active chunk.
- `[ ]` / `[x]` mark status.
- Finished epics move to `## Completed Epics` to keep the active roadmap focused.
- The SessionStart hook surfaces the **first unchecked item of the first active
  epic**. It stops scanning at `## Completed Epics` / `## Backlog`, so anything you
  park under those headings is never surfaced as "next". Order epics by priority,
  and keep only **immediately actionable** items in active epics — park
  wait-conditions (e.g. the promotion rule: "once a 2nd app needs it") under
  `## Backlog`, not as an active `[ ]`.

## Chunking a large goal

1. Ask clarifying questions to break the goal into epics and checkable tasks.
2. Write/update `ROADMAP.md` with all the pieces.
3. Select the next logical, **unblocked** task; create `plans/UNFINISHED.md` for
   just that chunk, linked to the roadmap item.
4. After finishing it, check the item off and pick the next unchecked one (or
   follow the user's re-prioritisation).

Update triggers: a completed task that changes future items → edit `ROADMAP.md`
(add/remove/reorder/adjust); an epic finished → move it to `## Completed Epics`;
the user re-prioritises → adjust.

## Archive folder layout

Completed plans live at `plans/archive/YYYY-MM-DD_<slug>/` (date-prefixed so the
filesystem sorts chronologically; `<slug>` is a short kebab-case descriptor):

```
plans/archive/2026-07-10_ui-status-chip-test/
├── plan.md            # original bullets + acceptance criteria
├── references.md      # (optional) doc sections consulted at plan time
├── execution_log.md   # (optional) obstacles, decisions, deviations
├── retro.md           # (optional) evaluation, mistakes, improvements
└── diff.patch         # (optional) the code changes
```

Only `plan.md` is mandatory; add the others when they carry real value. A trivial
task with no doc impact may not need an archive folder at all — the commit is the
record.

## Change-history ledger (`history/`)

Parallel to the archive, the repo keeps a **required** weekly change ledger — one file
per ISO week, `history/YYYY-Www.md` (e.g. `history/2026-W28.md`). It is the chronological
"what changed, when, why" record; the archive is the deep per-task record. They
complement, not duplicate.

```
history/
├── FORMAT.md        # the format spec (small, stable — not an index)
└── 2026-W28.md      # header: "# 2026-W28 (2026-07-06 – 2026-07-12)"
```

- **Log everything, scale the detail:** substantial changes get a `### [tag] path` block
  with What/Why/Refs; minor changes get a single terse line. Noise is controlled by
  brevity, not omission — the failure this ledger fixes was a *missing* trace.
- `ls history/` is the year-at-a-glance index (no central file). Full spec, tags, and
  the entry template live in [`history/FORMAT.md`](../../../../history/FORMAT.md).
- It realizes the canonical spec's *optional* `changelogs/CHANGELOG.md` (never
  implemented) and is separate from the semver `CHANGELOG.md` at the repo root (which
  records released versions per the kit's versioning rule). The ledger is the
  chronological work record; `CHANGELOG.md` is the release record.

## Filesystem-native recall (no index)

There is deliberately **no** central index file — for either the archive or the ledger.
Find past work with the shell:
- Time-ordered: `ls history/` then read the week file; `grep -rn "keyword" history/` to
  trace a topic across weeks.
- Task-depth: `grep -r "keyword" plans/archive/` — all files mentioning the keyword;
  `ls plans/archive/ | grep "2026-07"` by month; `ls plans/archive/ | grep "dropdown"` by slug.

Then load only the file you need. Retrieve when: the user asks "what did we do
about X?", you hit a problem you may have solved before, or you need a past
decision/retro. The rule: find the needle with `grep`/`ls`, read only the needle.

## Long-term memory hygiene

- **Archive:** folders named `YYYY-MM-DD_<slug>/`, no index. Quarterly, compress
  folders older than 6–12 months into `plans/archive/old/` (search still finds
  them).
- **Ledger:** weekly `history/YYYY-Www.md` files need no pruning — each is naturally
  bounded to one week. If a year accumulates, optionally fold old years into
  `history/old/` (search still finds them). Never consolidate into one giant file.
- **Living docs:** review `.ai/best_practices.md`, `.ai/naming_conventions.md`, and
  `docs/design-system-contract.md` every 3–6 months — remove stale rules, consolidate
  duplicates, move historical examples to an appendix. Can be a roadmap task or
  done organically when a file gets unwieldy.
- **Token budget:** the SessionStart hook injects summaries for docs over its
  cutoff (currently ~2000 chars) and never loads the archive listing. Keep the
  injection lean; request full docs on demand.
