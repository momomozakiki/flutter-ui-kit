# Changelog

## 0.5.0 - Adaptive navigation shell

Additive only — no breaking changes to existing tokens or components.

### Added
- New organism **`UiAdaptiveNavShell`** (`lib/src/organisms/ui_adaptive_nav_shell.dart`): a top-level
  navigation scaffold that switches pattern by *available width* (via the kit's centralized
  `UiBreakpoints`, never by platform) — M3 `NavigationBar` for `compact` (`< 600`), a compact
  `NavigationRail` (`extended: false`, labels on selected) for `medium` (`600–839`), and an extended
  `NavigationRail` for `expanded`/`large` (`>= 840`). Selection is controlled (`selectedIndex` /
  `onDestinationSelected`); the API is all-optional beyond the core four so future options can be
  added without breaking callers. Zero added dependencies — window management, keyboard shortcuts,
  and route-state preservation stay in the consuming app.
- New value type **`UiNavDestination`** (`icon` / `selectedIcon` / `label`) so callers declare
  destinations once and the shell renders them as either a `NavigationDestination` or a
  `NavigationRailDestination`.
- Both exported from the barrel `lib/flutter_ui_kit.dart`. Reconciliation notes (what was harvested
  from, and rejected in, the external "Flutter Complete Adaptive Layout Guide") live in
  `docs/flutter-adaptive-ui-design-specification.md` (v3.1).

## 0.4.0 - Strict Atomic Design folder tiering

Structural reorganization — the kit's public symbol set is unchanged except for one rename (below).
Consumers import the barrel (`package:flutter_ui_kit/flutter_ui_kit.dart`), so internal folder moves
are transparent; nothing breaks until a consumer bumps its pinned tag.

### Changed
- `lib/src/` reorganized into strict Atomic Design tiers: `components/` → **`atoms/`**, and
  `composite/` split into **`molecules/`** (stateless) and **`organisms/`** (local UI state). Tokens
  stay in `theme/`, the registry in `catalog/`. Folder path now enforces each layer's state boundary.
  This kit's structure is now the canonical Atomic Design rule every Omni-family app mirrors.
- Each molecule/organism file carries a grep-friendly `// Tier: molecule|organism` comment.

### Breaking
- **`UnderMaintenancePage` → `UiUnderMaintenance`** (file `composite/under_maintenance_page.dart` →
  `organisms/ui_under_maintenance.dart`). Renamed to satisfy the `Ui<Name>` convention and the new
  rule that no `_page`-named widget lives in the kit (page/template widgets belong to consuming
  apps). A generic full-screen composition is modelled as an organism. Consumers on `UiUnderMaintenance`'s
  predecessor update the import symbol when they bump to `v0.4.0`.

## 0.3.0 - Component catalog + viewer

Additive only — no breaking changes to existing tokens or components.

### Added
- New **catalog layer** `lib/src/catalog/ui_component_catalog.dart`: `UiComponentDescriptor`
  (`id` / `label` / `category` / `sample`) and `uiComponentCatalog`, an unmodifiable
  `List<UiComponentDescriptor>` naming every `Ui*` component plus a default sample instance. Exported
  from the barrel. This is the single registry that surfaces components in the viewer and that a
  consuming app (e.g. a form designer's palette) can import directly.
- `example/` — a Flutter **web** component viewer (gallery) with a path dependency on the kit, so the
  kit stays zero-dependency. Dogfoods `UiResponsive` (master/detail layout) and `UiTuningOverlay`
  (live token tuning), with a light/dark toggle.
- `test/ui_component_catalog_test.dart` — builds every catalog `sample` under `buildUiTheme()` and
  asserts unique ids + non-empty label/category.

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
