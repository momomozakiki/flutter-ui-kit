# Plan: Reconcile docs/paths after v0.4.0 Atomic restructure

## Context

Roadmap Epic 2 ([ROADMAP.md:18](ROADMAP.md#L18)) calls to "reconcile the `docs/` set after
the recent repo restructure … so cross-links resolve and there are no stale paths." The v0.4.0
restructure replaced `lib/src/components/` + `lib/src/composite/` with `atoms/` / `molecules/` /
`organisms/`, and renamed `UnderMaintenancePage` → `UiUnderMaintenance`
(`lib/src/organisms/ui_under_maintenance.dart`).

**Exploration finding:** the `docs/` set is *already* reconciled — all relative cross-links
resolve (no broken links), the contract/adaptive-spec/Atomic-doc/layout-guide already use the new
tiering, and the only remaining `components/`/`composite/` strings inside `docs/` describe a
*consuming app's* own folders (intentional). The genuine stale references survive **outside**
`docs/`, in the top-level docs the roadmap item is really about:

1. `README.md` "Project structure" tree — fully pre-v0.4.0.
2. `.ai/best_practices.md:60` — one dangling `composite/` prose reference.

This closes the roadmap item's real intent (docs paths resolve to reality after the restructure).

## Changes

### 1. `README.md` — fix the "Project structure" tree ([README.md:40-51](README.md#L40-L51))
- Line 40: `components/` → `atoms/` (comment: CORE atoms — one widget per file, Ui-prefixed).
- Line 47: `composite/  # GENERIC compositions` → split into the two real tiers:
  - `molecules/  # GENERIC stateless compositions` → `ui_responsive.dart` (`UiResponsive`).
  - `organisms/  # GENERIC compositions w/ local UI state` → `ui_tuning_panel.dart`,
    `ui_tuning_overlay.dart`, `ui_under_maintenance.dart` (`UiUnderMaintenance`),
    plus `ui_adaptive_nav_shell.dart` and `ui_theme_picker.dart` (added since the tree was written).
- Line 51: `under_maintenance_page.dart` → `ui_under_maintenance.dart`.
- **Full refresh (decided):** also update the atoms list (currently 6 of 15) to match `lib/src/`
  today — all 15 atoms, and add the `catalog/` layer (`ui_component_catalog.dart`). End state: the
  tree mirrors `ls lib/src/*/` exactly, not merely un-stale.

### 2. `.ai/best_practices.md:60` — fix dangling `composite/` prose
Change "promoted into this kit's `composite/` layer" → "promoted into the right kit tier
(`molecules/` or `organisms/`)", matching the already-corrected layer-rules bullet above it
(lines 48-51) and the ROADMAP promotion-rule wording. Bump the living-doc frontmatter version
(1.4 → 1.5) + Revision History row per the Documentation Standard.

### 3. (Decided: yes) `docs/.../part-6-naming-conventions.md:34`
Rename the consumer-app example folder `composite/` → `screens/` so it no longer collides with the
retired kit layer name. It's a valid consumer example (not stale), so this is a clarity edit only.
Bump that folder's `CHANGELOG.md` if it tracks one. `docs/golden-rule/design-system-contract.md:77`
("app's own `composite/`-equivalent folder") is correct as-is — leave it.

## Out of scope (leave as-is)
Historical records that intentionally preserve old paths: `CHANGELOG.md`, `ROADMAP.md` (lines 17/36),
`history/*`, `plans/archive/*`, `templates/CONSUMER_CLAUDE_SNIPPET.md`.

## Workflow / merge-gate (per CLAUDE.md)
This touches docs (README + a living doc) but **not** `lib/`, tokens, version, or canonical
guidance in `docs/golden-rule/`. Per the pragmatic branch-scope rule this is borderline — the
`.ai/` living doc edit + README are doc/ledger-class. **Recommendation:** small `docs/` branch +
PR (`docs/reconcile-v040-paths`) to stay safe with the merge-gate, since it edits a versioned
living doc. Close: commit on branch → `git push -u origin` → `gh pr create`; **do not self-merge**
(merges after user verification). Write a `history/2026-W29.md` ledger entry (G3, mandatory).

## Verification
- `flutter analyze` + `flutter test` — should stay green (no code touched); confirms nothing broke.
- Manual: re-grep for stale kit-layer paths outside historical dirs —
  `grep -rn "lib/src/components\|lib/src/composite\|under_maintenance_page" README.md .ai/ docs/`
  should return no live (non-consumer, non-historical) hits.
- Eyeball the `README.md` tree against `ls lib/src/*/` to confirm it matches reality.
