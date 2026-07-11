# Project Roadmap

High-level epics and milestones for **flutter-ui-kit**. The SessionStart hook
surfaces the first unchecked item of the first **active** epic (it stops scanning at
`## Completed Epics` / `## Backlog`). Keep this lean; move finished epics to
`## Completed Epics`, and park wait-conditions (not yet actionable) under
`## Backlog / Icebox` so they're never surfaced as "next".

Each bullet is a high-level task, not a detailed plan — detail for the one active
chunk lives in `plans/UNFINISHED.md`.

## Epic 1: Test coverage gaps
- [ ] Add a mirrored test for `ui_status_chip` (`test/ui_status_chip_test.dart`) — the only component in `lib/src/components/` without one
- [ ] Audit remaining `lib/src/composite/` widgets for test coverage (`ui_responsive`, `ui_tuning_panel`, `under_maintenance_page`) and add tests where behavior is untested

## Epic 2: Documentation & contract upkeep
- [ ] Reconcile the `docs/` set after the recent repo restructure (ONBOARDING, contract, adaptive-spec, layout guide) so cross-links resolve and there are no stale paths
- [ ] Confirm provenance of the two `official: unknown` design docs (`flutter-adaptive-ui-design-specification.md`, `flutter-layout-and-component-design.md`) and the `Atomic Design in Flutter.md` third-party article (fill its `.prov.md` source URL)
- [ ] Fold `docs/flutter-layout-and-component-design.md` (~9k tokens) into a folder per the Progressive Disclosure Guide (GUIDE §6.4) — exceeds the per-file token budget

## Epic 3: Workflow-core integration follow-ups
- [ ] Add `submodules: recursive` to flutter-ui-kit's own CI checkout so `.claude/workflow-core/` is present on fresh clones/CI (the submodule is dev-only; consumers via `flutter pub get` are unaffected)
- [ ] Propose the supplement hook's three features (living-doc injection, ROADMAP `- [ ]` scan, human-authored-UNFINISHED-in-Stop) upstream to `ai-self-correcting-workflow` (GUIDE §10), then retire them locally once merged. (F5 was the fourth candidate — now **merged upstream** as of submodule `5c2128d`: `workflow_hook.py` runs it and `config_schema.json` defines `workflow_update_check`; the local F5 was retired.)

## Backlog / Icebox
- [ ] Promote a shared composite into `lib/src/composite/` once a **second** app has a genuinely identical use case (promotion rule — wait-condition, not yet actionable)
- [ ] Dark-theme token pass / additional semantic color tiers, if a consumer needs them
- [ ] New atoms on demand (e.g. radio group, segmented control, tooltip) — add only when a consumer actually needs them, per the kit's "don't build speculatively" stance

## Completed Epics
- [x] Epic 0a: Core atoms — `ui_button`, `ui_text_field`, `ui_dropdown`, `ui_status_chip`, `ui_banner`, `ui_checkbox` (all implemented in `lib/src/components/`)
- [x] Epic 0b: Theme/token layer — `ui_colors`, `ui_spacing`, `ui_sizing`, `ui_radius`, `ui_typography`, `ui_breakpoints`, `ui_theme`, `ui_tuning` (`lib/src/theme/`)
- [x] Epic 0c: Debug live-tuning — `ui_tuning`, `ui_tuning_panel`, `ui_tuning_overlay` (floating design-tuning panel + font control)
- [x] Epic 0d: Starter-kit scaffolding — CLAUDE.md, design-system contract, CI, README; extracted from the `odb_library` monorepo (v0.1.0)
- [x] Epic 0e: Self-host the Adaptive Self-Correcting Workflow (v3.3) — hook, skill, `.ai/`, `ROADMAP.md`, `history/`, `plans/`, canonical spec (2026-07-10)
