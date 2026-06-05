# flutter_ui_kit

A reusable, **domain-agnostic** Flutter design system and component library. It ships the
*properties* (design tokens) and the *core widgets* every screen is built from, so styling stays
consistent across this project and any future Flutter project.

It depends only on the **Flutter SDK** — no transport, no ODB core, no platform plugins — so it
builds everywhere (Windows, Android, macOS, Linux, web) and can be dropped into any app.

## Why

Before this package, the UI hardcoded colors (`Colors.red.shade700`) and sizes (`96.0`, `280`)
inline in each widget. That doesn't scale or travel. `flutter_ui_kit` centralizes those decisions
as **tokens** and wraps the common Material controls as **atoms** with one consistent look.

## Layout

```
lib/
  flutter_ui_kit.dart        # public barrel
  src/
    theme/                   # reusable PROPERTIES (design tokens)
      ui_spacing.dart        # UiSpacing  — 4/8/12/16/24/32 scale + gap widgets
      ui_sizing.dart         # UiSizing   — touch target (48), control heights, icon/field/panel sizes
      ui_radius.dart         # UiRadius   — 4/8/12 corner radii (+ BorderRadius consts)
      ui_typography.dart     # UiTypography — tablet-legible text-theme builder + mono style
      ui_colors.dart         # UiColors   — semantic colors as a ThemeExtension (context.uiColors)
      ui_breakpoints.dart    # UiBreakpoints / UiDeviceClass — 7"/10" tablet breakpoints
      ui_theme.dart          # buildUiTheme() — assembles ThemeData (M3 + tokens)
    components/              # CORE atoms (one widget per file, Ui-prefixed)
      ui_button.dart         # UiButton (primary/secondary/text)
      ui_text_field.dart     # UiTextField (outlined, floating label)
      ui_dropdown.dart       # UiDropdown (label notches the border — the "Font ▾" look)
      ui_status_chip.dart    # UiStatusChip (success/warning/danger/info/neutral)
      ui_banner.dart         # UiBanner (info/warning/error/success)
      ui_checkbox.dart       # UiCheckbox (tappable label)
    composite/              # GENERIC compositions
      ui_responsive.dart     # UiResponsive — builds against UiDeviceClass (LayoutBuilder)
```

## Usage

Add the dependency (path within this monorepo):

```yaml
dependencies:
  flutter_ui_kit:
    path: ../flutter_ui_kit
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

## Tablet-first

The kit targets 7" and 10" Android tablets:

| Class      | Width (logical px) | Example device                         |
|------------|--------------------|----------------------------------------|
| `compact`  | `< 600`            | phones / narrow panes                  |
| `medium`   | `600–839`          | 7" portrait                            |
| `expanded` | `840–1199`         | 7" landscape / small 10" (960×600 floor) |
| `large`    | `>= 1200`          | 10" landscape (1280×800 default)       |

Interactive atoms meet the **48dp** touch-target floor (`UiSizing.touchTarget`). Hosts should
default their desktop window to **1280×800** (10" landscape, 16:10) so behavior matches a tablet.

## Conventions

When adding a component, follow the project skill **`odb-ui-component`**: core atoms go in
`components/` (`Ui`-prefixed, one per file), generic compositions in `composite/`; never hardcode
colors/sizes (use `theme/` tokens or `Theme.of`); keep this package SDK-only; export from the
barrel and add a mirrored test under `test/`.

## Verify

```sh
cd packages/flutter_ui_kit
flutter pub get
flutter analyze
flutter test
```
