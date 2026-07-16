# Project Roadmap

High-level epics and milestones for **flutter-ui-kit**. The SessionStart hook
surfaces the first unchecked item of the first **active** epic (it stops scanning at
`## Completed Epics` / `## Backlog`). Keep this lean; move finished epics to
`## Completed Epics`, and park wait-conditions (not yet actionable) under
`## Backlog / Icebox` so they're never surfaced as "next".

Each bullet is a high-level task, not a detailed plan — detail for the one active
chunk lives in `plans/UNFINISHED.md`.

## Epic 1: Test coverage gaps
- [x] Add a mirrored test for `ui_status_chip` (`test/ui_status_chip_test.dart`) — the only atom in `lib/src/atoms/` without one
- [x] Audit remaining `lib/src/molecules/` + `lib/src/organisms/` widgets for test coverage (`ui_responsive`, `ui_tuning_panel`, `ui_under_maintenance`) and add tests where behavior is untested

## Epic 2: Documentation & contract upkeep
- [x] **Align skill/living-doc folder paths with the v0.4.0 tiering** — done 2026-07-16: updated three skills (`flutter-ui-kit-component`, `dart-solid-principles`, `adaptive-workflow`), `.ai/best_practices.md`, and `templates/app-ui-component.SKILL.md.template` (found by pre-flight grep) from `lib/src/components/` + `lib/src/composite/` to `atoms/`/`molecules/`/`organisms/`. Historical records left as-is. See `plans/archive/2026-07-16_skill-doc-folder-alignment/`.
- [x] **Reconcile stale folder paths after the v0.4.0 restructure** — done 2026-07-16: `docs/` was already reconciled (cross-links resolve); fixed the real live stale refs outside it — `README.md` project-structure tree (full refresh to current `atoms/`/`molecules/`/`organisms/`/`catalog/` + 15 atoms), `.ai/best_practices.md:60` dangling `composite/` prose (v1.4→1.5), and the part-6 consumer example `composite/`→`screens/` (folder v1.1→1.2). See `plans/archive/2026-07-16_reconcile-v040-paths/`.
- [x] **Confirm provenance of the two `official: unknown` design docs** — done 2026-07-17: both were AI-distilled from online best-practice resources, then regenerated/reorganized in-repo → `official: false`, `source: agent-generated`. Updated `docs/golden-rule/flutter-adaptive-ui-design-specification.md` (v3.2→3.3, de-provisionalized to fully golden) and the folded `docs/flutter-layout-and-component-design/` (index v1.2→1.3 + CHANGELOG; stays canonical reference, not a rule authority), plus `docs/golden-rule/index.md` (v1.1→1.2). See `plans/archive/2026-07-17_confirm-doc-provenance/`.
- [ ] Fill the `Atomic Design in Flutter.md` third-party article's `.prov.md` source URL (still pending — needs the original article URL/attribution; it is a verbatim/lightly-adapted external article, unlike the two agent-generated docs above)
- [x] Fold `docs/flutter-layout-and-component-design.md` (~9k tokens) into a folder per the Progressive Disclosure Guide (GUIDE §6.4) — exceeds the per-file token budget *(done 2026-07-15: `docs/flutter-layout-and-component-design/` = index + 6 part files + CHANGELOG)*

## Epic 3: Workflow-core integration follow-ups
- [ ] Add `submodules: recursive` to flutter-ui-kit's own CI checkout so `.claude/workflow-core/` is present on fresh clones/CI (the submodule is dev-only; consumers via `flutter pub get` are unaffected)
- [ ] Propose the supplement hook's three features (living-doc injection, ROADMAP `- [ ]` scan, human-authored-UNFINISHED-in-Stop) upstream to `ai-self-correcting-workflow` (GUIDE §10), then retire them locally once merged. (F5 was the fourth candidate — now **merged upstream** as of submodule `5c2128d`: `workflow_hook.py` runs it and `config_schema.json` defines `workflow_update_check`; the local F5 was retired.)

## Backlog / Icebox
- [ ] Wire `omni_form_design`'s component palette off the kit's `uiComponentCatalog` (follow-up **in that repo**, not here — it's a consumer of the catalog shipped in v0.3.0)
- [ ] Optional: a lint/test that flags exported components missing from `uiComponentCatalog` (Dart has no reflection, so it'd be brittle source-scanning — do only if drift becomes a real problem)
- [ ] Optional: per-component interactive "knobs" in the viewer (currently shows a representative default instance)
- [ ] Promote a shared composition into the right kit tier (`lib/src/molecules/` or `lib/src/organisms/`) once a **second** app has a genuinely identical use case (promotion rule — wait-condition, not yet actionable). Page/template-like widgets stay in consuming apps and are never promoted as `_page`-named into the kit — model a generic full-screen composition as an organism (see `UiUnderMaintenance`).
- [ ] Dark-theme token pass / additional semantic color tiers, if a consumer needs them
- [ ] Further atoms on demand (e.g. segmented control, standalone tooltip, badge) — add only when a consumer actually needs them, per the kit's "don't build speculatively" stance

## Completed Epics
- [x] Epic 7: Adaptive navigation shell (v0.5.0, 2026-07-15) — harvested an external "Flutter Complete Adaptive Layout Guide" into kit-conformant form. Added the `UiAdaptiveNavShell` organism + `UiNavDestination` (switches M3 `NavigationBar` ↔ compact/extended `NavigationRail` by pane width via centralized `UiBreakpoints`, zero deps), the `flutter-adaptive-navigation` skill, and extended the adaptive spec (v3.1, with a reconciliation table recording what was rejected from the guide and why). Window management / keyboard shortcuts / `go_router` state stay in the consuming app.
- [x] Epic 6: Strict Atomic Design folder tiering (v0.4.0, 2026-07-12) — reorganized `lib/src/` into literal `atoms/` / `molecules/` / `organisms/` tiers (from `components/` + merged `composite/`) so the folder path enforces each layer's state boundary and consuming apps have a 1:1 vocabulary to mirror; `flutter-ui-kit`'s structure is now the canonical golden Atomic Design rule. Kept `Ui<Name>` names; barrel-only imports made it non-breaking except the `UnderMaintenancePage` → `UiUnderMaintenance` rename (satisfies `Ui<Name>` + the new no-`_page`-in-kit rule). Added grep-friendly `// Tier:` comments and updated the contract (v1.4), the Atomic Design guide, CLAUDE.md, and naming conventions.
- [x] Epic 5: Component viewer + catalog (v0.3.0, 2026-07-12) — user-requested way to *see* the components. Added the `catalog/` registry layer (`uiComponentCatalog` / `UiComponentDescriptor`, exported from the barrel) and a `example/` Flutter web viewer that renders it as a gallery (dogfoods `UiResponsive` + `UiTuningOverlay`, light/dark). The catalog is the shared seam a form-designer palette can import directly (no drag-and-drop in the kit — see Backlog for the `omni_form_design` follow-up).
- [x] Epic 4: Common-atoms completion (v0.2.0, 2026-07-12) — user-requested build of the standard Material atom set on top of the six core atoms: `ui_icon_button`, `ui_radio` (`UiRadio`/`UiRadioGroup`, M3 `RadioGroup` API), `ui_switch`, `ui_slider`, `ui_chip` (generic), `ui_card`, `ui_text`, `ui_avatar`, `ui_progress_indicator`, plus the `UiTone` token. Deliberate override of the "don't build speculatively" stance (see the ledger); Icebox reworded to remaining niche atoms.
- [x] Epic 0a: Core atoms — `ui_button`, `ui_text_field`, `ui_dropdown`, `ui_status_chip`, `ui_banner`, `ui_checkbox` (all implemented in `lib/src/atoms/`)
- [x] Epic 0b: Theme/token layer — `ui_colors`, `ui_spacing`, `ui_sizing`, `ui_radius`, `ui_typography`, `ui_breakpoints`, `ui_theme`, `ui_tuning` (`lib/src/theme/`)
- [x] Epic 0c: Debug live-tuning — `ui_tuning`, `ui_tuning_panel`, `ui_tuning_overlay` (floating design-tuning panel + font control)
- [x] Epic 0d: Starter-kit scaffolding — CLAUDE.md, design-system contract, CI, README; extracted from the `odb_library` monorepo (v0.1.0)
- [x] Epic 0e: Self-host the Adaptive Self-Correcting Workflow (v3.3) — hook, skill, `.ai/`, `ROADMAP.md`, `history/`, `plans/`, canonical spec (2026-07-10)
