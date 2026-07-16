# flutter_ui_kit

The **single canonical Flutter design system** for the Omni-family apps. A reusable, domain-agnostic
component library: design tokens (color, spacing, sizing, radius, typography), tablet-first
breakpoints, and core widgets (button, text field, dropdown, status chip, banner, checkbox), plus
generic composites.

It depends only on the **Flutter SDK** — no transport, no ODB core, no platform plugins — so it
builds everywhere (Windows, Android, macOS, Linux, web) and can be dropped into any Flutter app.

This repo is the extracted, standalone home of what was previously `odb_library`'s
`packages/flutter_ui_kit` — now consumed by every Omni-family app as a pinned git dependency instead
of an in-tree path, so no app drifts from a different local copy of the design system. See
[`CLAUDE.md`](CLAUDE.md) for the repo-separation rules and
[`docs/golden-rule/design-system-contract.md`](docs/golden-rule/design-system-contract.md) for the full
contributor contract.

## Why

Before this package existed, UI code hardcoded colors (`Colors.red.shade700`) and sizes (`96.0`,
`280`) inline in each widget. That doesn't scale or travel across apps. `flutter_ui_kit` centralizes
those decisions as **tokens** and wraps common Material controls as **atoms** with one consistent
look, with defaults every app shares and documented override points for what shouldn't be shared.

## Layout

```
lib/
  flutter_ui_kit.dart        # public barrel
  src/
    theme/                   # reusable PROPERTIES (design tokens)
      ui_spacing.dart        # UiSpacing    — spacing scale + gap widgets
      ui_sizing.dart         # UiSizing     — control heights, icon/field/panel sizes
      ui_radius.dart         # UiRadius     — corner radii (+ BorderRadius consts)
      ui_typography.dart     # UiTypography — tablet-legible text-theme builder + mono style
      ui_colors.dart         # UiColors     — semantic colors as a ThemeExtension (context.uiColors)
      ui_breakpoints.dart    # UiBreakpoints / UiDeviceClass — 7"/10" tablet breakpoints
      ui_tuning.dart         # UiTuning     — debug-only live overrides, seeded from the consts above
      ui_tone.dart           # UiTone       — tonal-emphasis token (subtle/normal/strong)
      ui_theme.dart          # buildUiTheme() — assembles ThemeData (M3 + tokens)
      ui_theme_controller.dart # UiThemeController / UiThemePreset — user-selectable theme color
    atoms/                   # ATOMS — stateless primitives, one widget per file (Ui-prefixed)
      ui_button.dart         # UiButton (primary/secondary/text)
      ui_icon_button.dart    # UiIconButton
      ui_text_field.dart     # UiTextField (outlined, floating label)
      ui_dropdown.dart       # UiDropdown (label notches the border)
      ui_checkbox.dart       # UiCheckbox (tappable label)
      ui_radio.dart          # UiRadio / UiRadioGroup (M3 RadioGroup API)
      ui_switch.dart         # UiSwitch
      ui_slider.dart         # UiSlider
      ui_status_chip.dart    # UiStatusChip (success/warning/danger/info/neutral)
      ui_chip.dart           # UiChip (generic)
      ui_banner.dart         # UiBanner (info/warning/error/success)
      ui_card.dart           # UiCard
      ui_text.dart           # UiText
      ui_avatar.dart         # UiAvatar
      ui_progress_indicator.dart # UiProgressIndicator
    molecules/               # MOLECULES — stateless generic compositions
      ui_responsive.dart      # UiResponsive — builds against UiDeviceClass (LayoutBuilder)
    organisms/               # ORGANISMS — generic compositions with local UI state only
      ui_adaptive_nav_shell.dart # UiAdaptiveNavShell — width-adaptive nav (bar ↔ rail)
      ui_theme_picker.dart    # UiThemePicker — end-user theme-color settings control
      ui_tuning_panel.dart    # UiTuningPanel — debug slider UI for UiTuning
      ui_tuning_overlay.dart  # UiTuningOverlay — movable floating panel wrapper
      ui_under_maintenance.dart # UiUnderMaintenance — generic full-screen maintenance state
    catalog/                 # component registry (uiComponentCatalog / UiComponentDescriptor)
      ui_component_catalog.dart
```

## Usage

Add the dependency, pinned to a released tag (never `ref: main` — see
[`docs/golden-rule/design-system-contract.md`](docs/golden-rule/design-system-contract.md#versioning--releases)):

```yaml
dependencies:
  flutter_ui_kit:
    git:
      url: https://github.com/momomozakiki/flutter-ui-kit.git
      ref: v0.1.0
```

Use the theme so every component is styled consistently:

```dart
import 'package:flutter_ui_kit/flutter_ui_kit.dart';

MaterialApp(
  theme: buildUiTheme(seed: Colors.blue),
  home: ...,
);
```

Compose with tokens and atoms — no magic numbers, no raw `Colors.*`:

```dart
Padding(
  padding: UiSpacing.allMd,
  child: Column(
    children: [
      UiDropdown<String>(
        label: 'Font',
        value: font,
        items: const [
          UiDropdownItem(value: 'Playfair Display', label: 'Playfair Display'),
          UiDropdownItem(value: 'Arial', label: 'Arial'),
        ],
        onChanged: (v) => setState(() => font = v),
      ),
      UiSpacing.gapVMd,
      UiStatusChip(label: 'Connected', status: UiStatus.success),
      UiSpacing.gapVMd,
      const UiBanner.error('Connection failed'),
    ],
  ),
)
```

Adapt a layout to the available width:

```dart
UiResponsive(
  builder: (context, deviceClass) => switch (deviceClass) {
    UiDeviceClass.compact || UiDeviceClass.medium => Column(children: panes),
    _ => Row(children: panes),
  },
);
```

## For consuming apps

Building a new Flutter app against this kit? Don't just add the git dependency and start — follow [`ONBOARDING.md`](docs/ONBOARDING.md) for a structured setup. It points you to the `templates/` folder, which contains:

- [`templates/CONSUMER_CLAUDE_SNIPPET.md`](templates/CONSUMER_CLAUDE_SNIPPET.md) — a ready-to-paste block for your app's own `CLAUDE.md`, with git-dependency setup, local-dev overrides, and repo-separation rules.
- [`templates/app-ui-component.SKILL.md.template`](templates/app-ui-component.SKILL.md.template) — a starter Claude Code skill for your app's UI layer, with placeholders you fill in.
- [`templates/analysis_options.yaml`](templates/analysis_options.yaml) — the lint configuration your app should use.

These templates ensure every consuming app stays consistent with the design system and each other.

### Local development against a sibling clone

Iterating on both this kit and a consumer app at once? Use an override instead of re-tagging on
every change:

```yaml
dependency_overrides:
  flutter_ui_kit:
    path: ../flutter-ui-kit   # local sibling clone; remove before committing the consumer app
```

## Tablet-first

The kit targets 7" and 10" Android tablets:

| Class      | Width (logical px) | Example device                         |
|------------|--------------------|------------------------------------------|
| `compact`  | `< 600`            | phones / narrow panes                  |
| `medium`   | `600–839`          | 7" portrait                            |
| `expanded` | `840–1199`         | 7" landscape / small 10" (960×600 floor) |
| `large`    | `>= 1200`          | 10" landscape (1280×800 default)       |

Hosts should default their desktop window to **1280×800** (10" landscape, 16:10) so behavior matches
a tablet. See `docs/golden-rule/design-system-contract.md` and the code comments in
`lib/src/theme/ui_sizing.dart` for the current interactive-control-height floor and its rationale.

## Conventions

Before adding or changing anything, read the contributor contract and supporting guides:

- [`docs/golden-rule/design-system-contract.md`](docs/golden-rule/design-system-contract.md) — layer placement, component-vs-layout naming, token-only rule, default-with-override pattern, testing, versioning.
- [`docs/golden-rule/flutter-adaptive-ui-design-specification.md`](docs/golden-rule/flutter-adaptive-ui-design-specification.md) — tablet-first breakpoints, touch targets, and responsive layout patterns for Android 7"/10" and Windows.
- [`docs/flutter-layout-and-component-design/`](docs/flutter-layout-and-component-design/index.md) — core Flutter layout mechanics (constraints, Container, Row/Column, Stack, composition), component design patterns, and naming conventions (folded into a folder: index + 6 parts).

## Verify

```sh
flutter pub get
flutter analyze
flutter test
```
