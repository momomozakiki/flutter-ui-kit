---
name: flutter-ui-kit-component
description: >-
  Use when adding or editing a Flutter UI component, design token, or generic
  composition in the flutter-ui-kit repo itself (lib/src/components/, lib/src/theme/,
  lib/src/composite/). Enforces the token-only rule (no hardcoded colors/sizes), the
  default-with-override pattern via UiTuning, the shared control-height mechanism, the
  semantic-color pattern, and testing/versioning requirements. For consuming apps, use
  the app-specific UI component skill in that app's own repo.
---

# Contributing UI components and tokens to flutter-ui-kit

This kit is the **single canonical Flutter design system** for the Omni-family. Every change here
affects every consuming app, so quality and stability matter above all. Follow these rules
whenever you add or change a component, token, or composition in this repo.

## 1. Decide the layer (where the file goes)

| What you're building | Folder | Notes |
|----------------------|--------|-------|
| **Design token** — a reusable property (color, spacing, size, radius, typography, breakpoint) | `lib/src/theme/` | No widgets in theme files. Tokens are const-only. |
| **Core atom** — generic, domain-free widget (button, field, dropdown, chip, banner, checkbox…) | `lib/src/components/` | One widget per file, `Ui`-prefixed. No app-specific logic. |
| **Generic composition** — project-agnostic widget groupings built from atoms (responsive scaffold, tuning panel…) | `lib/src/composite/` | Still domain-free. Tuning/overlay widgets live here. |

**The test for "in the kit vs. in a consuming app":** could a totally unrelated Flutter app use
this widget/token unchanged, without knowing anything about any specific Omni product? If it mentions a product's domain, it belongs in the consuming app, not here.

## 1a. Atomic-design layers & state boundaries

This kit **is** an Atomic Design system — its folders map onto the canonical layers (see
[`docs/Atomic Design in Flutter.md`](../../docs/Atomic%20Design%20in%20Flutter.md) §2 and §6 for
the theory). Every new UI must land in the right layer **and** respect that layer's state boundary:

| Atomic Design layer | This repo | State boundary |
|---|---|---|
| Tokens | `lib/src/theme/` | const-only, no widgets |
| **Atoms** | `lib/src/components/` | always `StatelessWidget`; **only ephemeral UI state** (`FocusNode`, an internal `TextEditingController`/`ScrollController`, hover/press). No business logic, no data fetching, **no `AppLocalizations`** — accept raw `String`s; render validation *visuals* only (`errorText`), logic lives outside. |
| **Molecules** | `lib/src/composite/` | compose atoms; **always stateless** — delegate all state/callbacks upward. |
| **Organisms** | `lib/src/composite/` | may own **local UI state** (expanded panel, open/closed menu, selected tab) but **never** business logic or data fetching. |
| Templates / Pages | *consuming apps, not here* | out of scope by design (repo-separation rule). |

**Molecule vs. organism** (both share `composite/`, and no lint/test can tell them apart — a
reviewer is the only gate):

> If the widget only combines atoms and delegates all state/callbacks upward, it's a
> **molecule**. If it manages a self-contained UI behaviour (expandable panel, tab bar, local
> dropdown menu) without touching repositories or domain logic, it's an **organism**. If you
> can't decide, it's probably an organism — when in doubt, ask a reviewer.

Put a one-line role comment at the top of each composite widget stating whether it's a molecule
or an organism, so the intent is visible in the file itself.

## 2. Properties are tokens — never hardcode

Every color, size, spacing, or radius value comes from a token:

| Token | Where to find it | Rule |
|-------|------------------|------|
| `UiSpacing` | `lib/src/theme/ui_spacing.dart` | gap widgets, padding scales |
| `UiSizing` | `lib/src/theme/ui_sizing.dart` | control heights, icon/field/panel sizes |
| `UiRadius` | `lib/src/theme/ui_radius.dart` | corner radii (BorderRadius consts) |
| `UiColors` | `lib/src/theme/ui_colors.dart` | semantic colors as ThemeExtension |
| `UiTypography` | `lib/src/theme/ui_typography.dart` | text-theme builder + mono style |
| `UiTuning` | `lib/src/theme/ui_tuning.dart` | debug-only live overrides (seeded from consts) |
| `UiBreakpoints` | `lib/src/theme/ui_breakpoints.dart` | device-class breakpoints |

Rules at the call site:
- **Sizes / spacing / radius:** a token, never a magic number.
- **Colors in components:** use `context.uiColors.<semantic>` (e.g., `context.uiColors.success`), never `Colors.red` or a raw `Color(0x…)`.
- **Text:** `Theme.of(context).textTheme.*` or `UiTypography.mono` for tabular/raw data.

### Gotcha: control height ≠ size tokens

The **rendered height** of Material controls — `TextField`, `Dropdown`, `Checkbox`, menu rows, list tiles — is **not** driven by size tokens.
It is set by `buildUiTheme()`'s `InputDecorationTheme.contentPadding` (+ `constraints`) for inputs, and `ThemeData.visualDensity` for menu rows/checkboxes/chips/tabs.

**To shrink/grow a control, change the theme config, not a token.** The kit's theme is built in `lib/src/theme/ui_theme.dart`; add tuning knobs there, not in call sites.

- **Verify the rendered result, not the constant.** A clean `flutter analyze` plus an edited token is *not* evidence the UI changed. Prove it: a `pumpWidget` + `tester.getSize(...)` height assertion or an eyeball in `flutter run`.
- **No dead sizing tokens.** Every value in `ui_sizing.dart` must be consumed somewhere — grep it. A token nothing reads is a false lever.
- **One shared control height.** All form controls — dropdown, text field, `UiButton`, command chip, checkbox — must render at **`UiSizing.controlHeight`** so a row of mixed controls lines up. Inputs get it from `InputDecorationTheme.contentPadding` (with `tightFor(height:)`), buttons from `minimumSize`, but chips and checkboxes have no intrinsic height lever — they size to content + `visualDensity`.
  - **Pin both ends.** `minimumSize` / `minHeight` alone guarantee "at least" the height, but content padding can push it taller. Use `tightFor(height: controlHeight)` (not just `minHeight:`), and `maximumSize` for buttons. Add `tapTargetSize: MaterialTapTargetSize.shrinkWrap` on button styles to prevent invisible padding from inflating the reported layout size.
  - **Test the exact height, not a floor.** Assert `expect(height, controlHeight)`, not `greaterThanOrEqualTo` — a floor-only assertion let past bugs before.
  - **Don't wrap in SizedBox.** Wrapping a `Chip`/`Checkbox` in `SizedBox(height: controlHeight)` sizes the *slot*, not the pill — the pill still floats short. Instead, size the pill itself (e.g., a `SizedBox(height: controlHeight)` around the chip's `label`), and zero the chip's vertical padding.

### Semantic color the right way

Don't hardcode a color. Define an enum and resolve it through `context.uiColors`, so the meaning is themeable and dark-mode-safe. This is exactly how `UiButton`'s `tone` works:

```dart
enum UiButtonTone { normal, success, danger }

Color? _toneColor(BuildContext context) {
  final colors = context.uiColors;
  return switch (tone) {
    UiButtonTone.normal => null, // let the theme decide
    UiButtonTone.success => colors.success,
    UiButtonTone.danger => colors.danger,
  };
}
```

## 3. Default-with-override pattern

Every tunable value ships as a `const` default. Per-instance overrides are optional named constructor parameters where `null` means "inherit the shared theme default". This keeps existing call sites unaffected when a new override is added. Reference implementations:

```dart
// UiButton accepts an optional height override:
UiButton(
  label: 'Save',
  onPressed: onSave,
  height: 48, // overrides the shared UiSizing.controlHeight default for just this instance
)
```

`UiTuning` is the debug-only live-tuning singleton: every field is seeded from the same const used in release, so nothing changes until a slider is actually touched. There is a single code path in both debug and release builds (no `kDebugMode` branch inside `buildUiTheme()` itself) — this guards against debug-tuned values silently diverging from what ships. New tunables should follow this same pattern rather than inventing a parallel mechanism.

## 4. Testing

Every new or changed widget/token gets a mirrored test under `test/` (e.g. `ui_button.dart` → `test/ui_button_test.dart`). Cover happy + partial/edge + error paths. `flutter test` must be clean before merge.

## 5. Versioning & releases

- Semantic version tags: `vMAJOR.MINOR.PATCH`.
- `CHANGELOG.md` gets an entry for every release — required for any change to the public API or token values.
- A breaking change to a token value or component API bumps **MAJOR**. Consuming apps pin an exact tag in their `pubspec.yaml` git dependency (`ref: vX.Y.Z`, never `ref: main`), so nothing breaks them until they deliberately bump the pinned tag.
- Tag only after `flutter analyze` and `flutter test` are clean on `main`.

## 6. Dependency purity

**Zero runtime dependencies beyond the Flutter SDK.** This is non-negotiable. It's what lets any consuming app — regardless of its own dependency tree — embed this kit safely. Never add a `pub` package dependency to `pubspec.yaml`'s `dependencies:` section. Dev-only tooling (`flutter_test`, `flutter_lints`) is fine under `dev_dependencies:`.

## 7. Layer-specific rules

### `lib/src/theme/` (tokens only)

- No widgets.
- Re-export all public tokens from `lib/flutter_ui_kit.dart`.
- `UiTuning` is debug-only; gate it with `kDebugMode` at the entry point, never inside `buildUiTheme()`.
- Every token file is a constant inventory (no logic). Logic lives in `buildUiTheme()` (using those consts).

### `lib/src/components/` (core atoms)

- One widget per file, `Ui`-prefixed name (e.g., `UiButton`, `UiDropdown`).
- No domain-specific logic. A widget that imports or references product concepts has no business here.
- Re-export from `lib/flutter_ui_kit.dart`.
- Imports only the Flutter SDK and tokens from this kit's `theme/` folder — never another component, never a concrete transport/plugin.

### `lib/src/composite/` (generic compositions)

- Project-agnostic groupings of atoms (e.g., `UiResponsive`, `UiTuningPanel`, `UiTuningOverlay`).
- `Ui`-prefixed names (e.g., `UiResponsive`).
- Re-export from `lib/flutter_ui_kit.dart`.
- Imports only the Flutter SDK, tokens, and components from this kit — never app-specific logic.

## 8. Promotion rule

A widget / composition is promoted *into* the kit only once a **second, genuinely identical use case** appears in another app. Don't move something here speculatively — "reusable" does not mean "used once but written generically". An app requests a component be promoted → evaluate whether a second real use case justifies adding it to the shared kit, then open a PR on this repo.

## Wire it up, then verify

1. **Export** every new public symbol from the barrel `lib/flutter_ui_kit.dart`.
2. **Test:** add a mirrored test (e.g. `ui_button.dart` → `test/ui_button_test.dart`).
3. **Analyze + test** — both clean before committing:
   ```sh
   flutter analyze
   flutter test
   ```

### Self-check before you call it done

Grep your new/changed files for the leaks the rules above forbid:

```sh
# raw colors (should be empty — use context.uiColors / colorScheme)
grep -nE "Colors\.[a-zA-Z]|Color\(0x" <files>
# bare BorderRadius / EdgeInsets numbers (prefer UiRadius.* / UiSpacing.*)
grep -nE "BorderRadius\.circular\(|EdgeInsets\.all\([0-9]" <files>
```

A surviving hit needs a reason (e.g., you're *defining* a token in `theme/`). Otherwise replace it with the matching token.

Also confirm the atomic layer & state boundary (see §1a):
- Is it in the right folder — atom (`components/`), molecule/organism (`composite/`), token (`theme/`)?
- Is the widget clearly a **molecule** (stateless) or an **organism** (local UI state only)? If the distinction is unclear, re-examine state ownership. An atom must be a `StatelessWidget` with no business logic.

## Component template (core atom)

```dart
import 'package:flutter/material.dart';

import '../theme/ui_spacing.dart';
// import '../theme/ui_colors.dart'; // for context.uiColors

/// One-line purpose. Document the API and any variants.
class UiThing extends StatelessWidget {
  const UiThing({required this.label, this.onTap, super.key});

  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: UiSpacing.allMd, // tokens, not magic numbers
      child: Text(label),       // colors via context.uiColors / colorScheme
    );
  }
}
```

## References

- [`docs/golden-rule/design-system-contract.md`](../../docs/golden-rule/design-system-contract.md) — the full contract (layer rules, naming, token-only rule, default-with-override, testing, versioning).
- [`lib/src/theme/ui_theme.dart`](../../lib/src/theme/ui_theme.dart) — how `buildUiTheme()` assembles the Material theme and integrates `UiTuning`.
- [`lib/src/components/`](../../lib/src/components/) — existing components as worked examples.
