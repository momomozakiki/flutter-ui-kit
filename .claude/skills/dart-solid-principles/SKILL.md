---
name: dart-solid-principles
description: >-
  Use when writing or reviewing Dart classes, interfaces, or the design of
  components/tokens in this kit, especially when the request mentions SOLID,
  single responsibility, open/closed, Liskov substitution, interface segregation,
  dependency inversion, code structure, composition patterns, or where a feature
  should live. Also use for everyday Dart practices — DRY, code reuse, modularity,
  file or class size, naming, immutability, testing, or "make this reusable".
  Scoped to Dart only. **This is an adapted copy of the ODB skill, using this
  kit's own code as examples — the two are not kept in sync automatically.**
---

# SOLID principles for Dart (flutter-ui-kit)

Apply these when shaping Dart code in this kit — deciding where a class lives, what it
depends on, and how it extends. The point isn't dogma: SOLID is the *reason* the kit's
architecture works (domain-free, zero runtime deps, embeddable in any app). The kit already
embodies all five principles, so use the real code below as the reference model rather than
inventing new abstractions.

> This skill is Dart-only. This is an adapted copy of the ODB repo's `dart-solid-principles`
> skill, using `flutter-ui-kit` code as examples. The two are not kept in sync automatically.

## S — Single Responsibility

A class should have one reason to change. The kit splits UI into three layers, so a change to one
never forces edits to the others:

- **tokens** — `lib/src/theme/`: properties only (`UiSpacing`, `UiSizing`, `UiRadius`, `UiColors`, `UiTypography`, `UiTuning`).
- **atoms** — `lib/src/components/`: primitive widgets wrapping Material controls with the kit's consistent look (`UiButton`, `UiDropdown`, `UiTextField`, etc.).
- **compositions** — `lib/src/composite/`: generic groupings of atoms (`UiResponsive`, `UiTuningPanel`, `UiTuningOverlay`).

**Smell:** a theme file that also renders a widget, or a component that defines its own token constants inline instead of reaching for an existing `UiSpacing` / `UiSizing` value. A file that does "properties *and* components" has two reasons to change.

## O — Open/Closed

Open for extension, closed for modification. You add a new semantic color by extending `UiColors` with a new field and registering it as a `ThemeExtension` variant — never by editing existing call sites. The pattern:

```dart
// In lib/src/theme/ui_colors.dart:
class UiColors extends ThemeExtension<UiColors> {
  final Color success, warning, danger, info, neutral; // neutral has no "on" pair
  final Color onSuccess, onWarning, onDanger, onInfo;
  // ... plus custom colors for specific semantic meanings

  const UiColors({
    required this.success,
    // ... all fields
  });

  // Two registered variants (light and dark):
  static final light = UiColors(
    success: Color(0x...), // define once
    // ...
  );

  static final dark = UiColors(
    success: Color(0x...), // define once
    // ...
  );

  @override
  UiColors copyWith({...}) { /* ... */ }

  @override
  UiColors lerp(UiColors? other, double t) { /* ... */ }
}

// Adding a new semantic color requires: (1) add the field, (2) define it in both `light` and `dark` variants.
// (3) Update any call site that switches on the color to handle the new meaning.
// Zero edits to existing components that don't use the new color — they keep working.
```

**Smell:** a component file with a `switch (isDark)` branch or `if (isLight)` tone-specific hardcode. That's modification at the call site. Instead, define the color in the kit's `UiColors` and reference it via `context.uiColors.<name>`.

## L — Liskov Substitution

Any subtype must be usable wherever the base type is expected — which means **honoring the contract (postconditions)**, not just matching the method signature. Every `ThemeExtension` (e.g., `UiColors`, any future extension) must faithfully implement `copyWith` and `lerp`.

```dart
ThemeData buildTheme({Color? seed}) {
  return ThemeData(
    useMaterial3: true,
    extensions: [
      UiColors.light, // or dark
    ],
  ).copyWith(
    // Material theme merging will call copyWith on all extensions
  );
}
```

A `UiColors` variant that broke `lerp`'s contract (e.g., returned `this` unconditionally instead of interpolating toward `other`) would silently break Flutter's theme animation system (used in brightness transitions), even though the code compiles. That is the LSP violation.

**Smell:** a `ThemeExtension` that throws or returns `null` where `lerp` should interpolate, or a `copyWith` that ignores provided parameters.

## I — Interface Segregation

No client should depend on methods it doesn't use. Instead of one fat `Widget` interface exposing every possible constructor parameter, the kit uses **enums and strategic use of optional parameters**. The `UiButton` pattern:

```dart
enum UiButtonTone { normal, success, danger }

class UiButton extends StatelessWidget {
  const UiButton({
    required this.label,
    required this.onPressed,
    this.tone = UiButtonTone.normal,  // semantic meaning, not a raw color
    this.height,                       // optional override
    super.key,
  });

  final String label;
  final VoidCallback onPressed;
  final UiButtonTone tone;
  final double? height;

  @override
  Widget build(BuildContext context) {
    final colors = context.uiColors;
    final bgColor = switch (tone) {
      UiButtonTone.normal => null,
      UiButtonTone.success => colors.success,
      UiButtonTone.danger => colors.danger,
    };
    // ... build with optional overrides
  }
}
```

A caller using a success tone depends only on the tone variants it needs (normal, success, danger), not on a fat interface exposing every theoretical color. Adding a new tone (e.g., `warning`) doesn't break existing call sites — they still use their subset of tones.

**Smell:** a component with ten boolean flags or a dozen color parameters, where most call sites ignore most of them. That's a fat interface. Instead, expose a smaller semantic enum or split into specialized subclasses.

## D — Dependency Inversion

Depend on abstractions; inject concretions. **The kit depends only on the Flutter SDK** — never on a consuming app's code, never on transport/plugin packages. Consuming apps depend on the kit's abstractions (`Ui<Name>` components, design tokens), never the reverse.

This mirrors a consuming app's decoupling rule: an app can import the kit's barrel (`package:flutter_ui_kit/flutter_ui_kit.dart`) to get components and tokens; the kit never imports from that app. The dependency graph points inward: app → kit, never kit → app.

```dart
// Valid (app imports kit):
import 'package:flutter_ui_kit/flutter_ui_kit.dart';

class MyAppButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return UiButton(label: 'Press me', onPressed: () {});
  }
}

// INVALID (kit importing from app):
// DO NOT WRITE THIS IN THE KIT:
// import 'package:my_app/screens/home_screen.dart';
```

**Smell:** any `import 'package:my_app/...'` or platform-plugin import inside `lib/src/`. The kit's barrel should be the only public import; everything else is internal.

## Error types & Dart 3 patterns

Use **sealed types** and **final classes** (Dart 3.2+) to enforce exhaustiveness and preclude unexpected subtypes:

```dart
sealed class UiInput {
  // No subclasses outside this file
}

final class RawString extends UiInput {
  final String value;
  RawString(this.value);
}

final class RawJson extends UiInput {
  final Map<String, dynamic> json;
  RawJson(this.json);
}

// Callers must handle all variants:
switch (input) {
  RawString(:final value) => print(value),
  RawJson(:final json) => print(json),
}
```

## Applying this — PR litmus test

Run down this checklist when reviewing or writing a class. SOLID here serves the kit's architecture (domain-free, zero runtime deps), not the other way around:

- ✅ Does this class have only one reason to change?
- ✅ Can I extend behavior by adding a new token/component and registering it, without editing existing call sites?
- ✅ Can I replace any `ThemeExtension` variant without breaking the caller (same `copyWith` / `lerp` contract)?
- ✅ Do clients depend only on the subset of parameters/meanings they actually use?
- ✅ Does the kit import only the Flutter SDK, never a consuming app or platform plugin?

## Practices — applying SOLID in everyday Dart

SOLID is the *why*; these are the daily habits that keep code modular, reusable, and DRY. They are
not new rules — they name what the kit already does, so new code matches it. (The lint set and
file conventions in `CLAUDE.md` are assumed, not restated here.)

### DRY & reuse-before-build

Prefer reusing an existing primitive or seam over writing a new one; a near-duplicate is a smell.

- **Reuse tokens.** The spacing scale (`UiSpacing.xs`, `.sm`, etc.), sizing constants (`UiSizing.controlHeight`, `.iconMd`), and semantic colors (`UiColors`) already exist — build on them.
- **Reuse components.** Instead of writing a custom button, extend `UiButton`'s `tone` or `height` parameter.
- **Extract a private helper** when logic is duplicated or a function grows past ~30 lines (e.g., `_buildLabel`, `_toneColor` in `ui_button.dart`). Keep it private in the same file until a *second* file needs it — then promote it (a new component or a shared utility).

### File & class size

Small, single-purpose files (aim ≤200 lines; ≤300 for a complex component). If you'd describe a class with "*and*" (renders a button *and* applies semantic color logic), it has two responsibilities — split it or extract a helper.

### Immutability & `copyWith`

Model/token types take `const` constructors and stay immutable. `ThemeExtension` subclasses implement `copyWith` to allow non-mutating updates. A `final class` with `const` constructor + immutable fields + `copyWith` is the reference pattern:

```dart
final class UiThing {
  const UiThing({required this.size, required this.color});
  final double size;
  final Color color;

  UiThing copyWith({double? size, Color? color}) =>
    UiThing(
      size: size ?? this.size,
      color: color ?? this.color,
    );
}
```

### Naming & visibility

- Public APIs: `PascalCase` for classes, `camelCase` for constants and properties.
- Private helpers: `_privateClass`, `_privateVariable`.
- Names carry intent — a reader should not need the body to know what a function does. `_toneColor` is better than `_color`.

### Test-mirroring & determinism

One test file per source file, **mirroring its name** (e.g., `ui_button.dart` → `test/ui_button_test.dart`). Cover happy + edge + error paths. Make logic testable without hardware or a clock — inject those dependencies where needed (e.g., if a component ever needs to poll time, inject a `Clock`).

## References

- [`docs/golden-rule/design-system-contract.md`](../../docs/golden-rule/design-system-contract.md) — the full kit contract.
- `lib/src/` — the kit's actual structure, organized by the S, O, L, I, D principles above.
- [`lib/src/theme/ui_colors.dart`](../../lib/src/theme/ui_colors.dart) (Open/Closed and Liskov examples).
- [`lib/src/components/ui_button.dart`](../../lib/src/components/ui_button.dart) (Interface Segregation and semantic color example).
