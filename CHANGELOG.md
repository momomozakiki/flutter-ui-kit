# Changelog

## 0.2.0 - Common-atoms completion

Additive only — no breaking changes to existing tokens or components.

### Added
- New atoms in `lib/src/components/`: `UiIconButton`, `UiRadio` + `UiRadioGroup` (Material 3
  `RadioGroup` API), `UiSwitch`, `UiSlider`, `UiChip` (generic input/filter/choice chip, distinct
  from `UiStatusChip`), `UiCard`, `UiText`, `UiAvatar`, `UiProgressIndicator`.
- New token `UiTone` (`lib/src/theme/ui_tone.dart`) — a shared semantic tone (normal/success/danger)
  resolved from `UiColors`, so components express tone via the theme layer instead of importing
  another component's enum.
- `UiTuning` gained `radioHeight` / `switchHeight` (per-component height overrides, seeded from
  `UiSizing.controlHeight`).

### Changed
- `UnderMaintenancePage` now composes `UiCard` instead of a raw `Card` (single source of truth for
  the card surface).

## 0.1.0 - Initial extraction

- Extracted from the `odb_library` monorepo (`packages/flutter_ui_kit`) into its own repo, with
  commit history preserved via `git subtree split`.
- No functional changes — `theme/`, `components/`, and `composite/` layers ship exactly as they
  existed at extraction time.
