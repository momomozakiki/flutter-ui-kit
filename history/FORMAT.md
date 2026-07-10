# Change-History Ledger — Format

The `history/` directory is this repo's **required chronological change ledger** — the
realized, rotated form of the v3.3 spec's optional `changelogs/CHANGELOG.md` (which the
spec left optional, and whose absence in a sibling repo is exactly why a design artifact
once evolved with no traceable record). It answers *"what changed, when, and why?"* by
reading, not by `grep` archaeology.

It is **separate** from the repo-root `CHANGELOG.md`: that file is the semver *release*
record (one entry per published `vX.Y.Z` tag, per the kit's versioning rule); this ledger
is the chronological *work* record (every session's changes, released or not).

This file is the format spec only. It is small and stable — **not** a growing index.

## File naming — one file per ISO week

```
history/YYYY-Www.md      e.g. history/2026-W28.md
```

- `Www` is the **ISO week number** (`date +%G-W%V`). Deterministic, unique across years,
  sorts perfectly under `ls`.
- `ls history/` is therefore the year-at-a-glance time index. There is **no** central
  index file (consistent with the workflow's filesystem-native, no-index principle).
- All of a week's entries — major *and* minor — accumulate in that **single** week file.
  No per-change file sprawl.

## Entry format

Each week file opens with a header naming the ISO week and its Mon–Sun date range, then
entries grouped by day (newest day at the bottom — append chronologically):

```markdown
# 2026-W28  (2026-07-06 – 2026-07-12)

## 2026-07-10
### [workflow] .claude/ + .ai/ + ROADMAP.md + history/ + plans/
- **What:** Self-hosted the Adaptive Self-Correcting Workflow (v3.3): unified Python
  hook, adaptive-workflow skill, living docs, roadmap, weekly ledger, archive scaffold.
- **Why:** Bring multi-session state/handoff discipline (ported from scale_tech_insight)
  to flutter-ui-kit.
- **Refs:** plan 2026-07-10_adaptive-workflow-port · commit <hash>

### [code] lib/src/components/ui_status_chip.dart — one-line minor note is fine too
```

### Tags
`[design]` `[doc]` `[code]` `[workflow]` `[config]` `[decision]` `[data]`
(Extend the vocabulary if a genuinely new category appears — keep it short.)

## When to log — log everything, scale the detail

Completeness is the point: the failure this ledger fixes was a **missing** trace, so
nothing is skipped. Detail scales with significance:

- **Substantial** change (a new component, a token/API change, a real decision) →
  full `### [tag] path` + **What / Why / Refs**.
- **Minor** change (small tweak, routine fix, config nudge) → a **single terse line**
  under that day's `##` heading. One line is enough.

Noise is controlled by *brevity*, not by *omission*.

### Relationship to other records (no duplication)
- **`history/`** — lightweight chronological breadcrumb across *all* work; exists even
  when there is no formal plan. **This is the required record.**
- **`plans/archive/<slug>/execution_log.md`** — deep per-task decisions; task-keyed.
- **`docs/*.md` dated annotations** — in-place authority for the design-system contract.
- **`CHANGELOG.md`** (repo root) — semver release record, one entry per `vX.Y.Z` tag.

The ledger *complements* those; it does not replace them.

## Recall

- Timeline: `ls history/` then open the week you care about.
- Trace a widget/topic over time: `grep -rn "UiButton" history/`.
- Read only the week file(s) you need — never load the whole directory blindly.

## Maintenance

Weekly files need no pruning. If a year's worth accumulates, optionally fold old years
into `history/old/` (search still finds them). Do not consolidate into one giant file —
that's the anti-pattern this format exists to prevent.
