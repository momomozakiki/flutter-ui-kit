# Atomic Design in Flutter – The Definitive Enterprise Guide

Atomic Design decomposes interfaces into five hierarchical levels. Flutter’s widget composition model aligns naturally with this methodology, enabling teams to create structured, reusable, and scalable UI codebases. This guide combines Atomic Design theory with modern Flutter best practices, focusing on maintainability, testability, and long‑term growth.

> **Flutter version note:** This guide uses `WidgetStateProperty` / `WidgetState` (Flutter ≥3.19). If your project targets an older Flutter, replace with `MaterialStateProperty` / `MaterialState`.

---

## 1. Design System Principles (Guiding Foundation)

- **Consistency over convenience** – share tokens and components; avoid one‑off styles.
- **Composition over inheritance** – build UIs by combining small, focused widgets.
- **Token‑first styling** – every visual decision lives in design tokens, never hard‑coded.
- **Accessibility by default** – components are accessible out of the box.
- **Stateless by default** – atoms are pure UI leaves; state lives in controllers/blocs.
- **Material 3 as the foundation** – wrap M3 widgets instead of rebuilding their behaviour.
- **Favour extension over modification** – use native M3 theming and `ThemeExtension` when needed.
- **YAGNI** – abstract only when reuse is real, not speculative.

---

## 2. The Five Layers of Atomic Design

| Level        | Definition                                                       | Flutter Examples                                       |
|--------------|------------------------------------------------------------------|--------------------------------------------------------|
| **Atoms**    | Smallest, indivisible UI elements                                | `AtomText`, `AtomIcon`, `AtomButton`, `AtomInput`      |
| **Molecules**| Groups of atoms forming a functional unit                        | `SearchBar` (icon + input), `LabelledInput` (label + input) |
| **Organisms**| Independent, composite presentation blocks                       | `Navbar`, `ProductCard`, `LoginForm`                   |
| **Templates**| Page‑level skeletons; define structure, no real content          | `AuthTemplate`, `DashboardTemplate`                    |
| **Pages**    | Templates filled with real data, connected to state/controllers  | `LoginPage`, `HomePage`                                |

**Component boundaries and state rules:**
- Atoms **do not** contain other atoms (except forced by Material widget, e.g., `Icon` inside `FilledButton`). Atoms are always stateless, with **only ephemeral UI state** allowed: `AnimationController`, `FocusNode`, `TextEditingController` (if completely internal), `ScrollController` (unshared), hover/touch effects.
- Molecules compose atoms and are **always stateless** – they combine atoms but never manage application state.
- Organisms compose molecules and atoms. They **may own local UI state** (e.g., expanded accordion panel, selected tab, dropdown open/closed) but never business logic or data fetching.
- Templates and pages follow the state flow described in Section 6.

---

## 3. Project Architecture – Modular by Design

Keep the **design system** as its own top‑level layer, separate from application **infrastructure** (`core`) and **features**. This enables easy extraction into a package later.

```
lib/
├── design_system/                  # Reusable UI & tokens
│   ├── atoms/
│   ├── molecules/
│   ├── organisms/
│   ├── templates/
│   ├── tokens/                     # All design decisions
│   │   ├── colors.dart             # raw brand colours
│   │   ├── typography.dart         # raw text styles
│   │   ├── spacing.dart
│   │   ├── radius.dart
│   │   ├── breakpoints.dart
│   │   └── states.dart             # interaction state tokens
│   ├── themes/                     # ThemeData & ThemeExtensions
│   │   ├── app_theme.dart          # builds full ThemeData
│   │   └── theme_factory.dart      # builds M3 theme data & extensions
│
├── core/                           # App infrastructure (routing, DI, networking, logging)
│   ├── routing/
│   ├── services/
│   └── ...
│
├── features/                       # Feature modules
│   ├── authentication/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   │       ├── pages/
│   │       └── widgets/            # feature‑specific organisms/molecules
│   └── ...
│
└── main.dart
```

For multi‑app scenarios, move `design_system/` into a package:

```
packages/
  design_system/
    lib/
      atoms/
      ...
    pubspec.yaml
  app_one/
  app_two/
```

---

## 4. Design Tokens – Raw, Semantic & Responsive

Tokens are the single source of truth. We distinguish **raw** visual tokens (brand values) from **semantic** tokens (intent‑based), which feed into Flutter’s `ColorScheme` and `TextTheme`.

**Flow:**
```
Raw tokens → Semantic tokens (ThemeExtension) → ColorScheme / TextTheme → ThemeData (M3 widget themes) → Widgets
```

### 4.1 Raw Visual Tokens

```dart
// design_system/tokens/colors.dart
class ColorTokens {
  static const Color primary = Color(0xFF6750A4);
  static const Color primaryDark = Color(0xFF4F378B);
  static const Color surface = Color(0xFFFFFBFE);
  static const Color onSurface = Color(0xFF1C1B1F);
}

// design_system/tokens/typography.dart
class AppTypography {
  static const String fontFamily = 'Roboto';
  static const TextStyle displayLarge = TextStyle(fontSize: 57, fontWeight: FontWeight.w400, letterSpacing: -0.25);
  static const TextStyle headlineMedium = TextStyle(fontSize: 28, fontWeight: FontWeight.w400);
  static const TextStyle titleLarge = TextStyle(fontSize: 22, fontWeight: FontWeight.w500);
  static const TextStyle bodyMedium = TextStyle(fontSize: 16, fontWeight: FontWeight.w400);
  static const TextStyle labelSmall = TextStyle(fontSize: 11, fontWeight: FontWeight.w500);
}
```

### 4.2 Semantic Color Tokens (ThemeExtension)

`SemanticColorTokens` extends `ThemeExtension`, making it available via `Theme.of(context).extension<SemanticColorTokens>()`. All values are explicit solid colours per theme – never derived via opacity for surfaces. A correct `lerp` method enables smooth theme transitions.

```dart
// design_system/tokens/semantic_color_tokens.dart
import 'package:flutter/material.dart';

class SemanticColorTokens extends ThemeExtension<SemanticColorTokens> {
  final Color primary;
  final Color onPrimary;
  final Color surfacePrimary;
  final Color surfaceSecondary;
  final Color textPrimary;
  final Color textSecondary;
  final Color borderDefault;
  final Color borderFocused;
  final Color danger;
  final Color success;
  final Color warning;
  final Color info;

  const SemanticColorTokens({
    required this.primary,
    required this.onPrimary,
    required this.surfacePrimary,
    required this.surfaceSecondary,
    required this.textPrimary,
    required this.textSecondary,
    required this.borderDefault,
    required this.borderFocused,
    required this.danger,
    required this.success,
    required this.warning,
    required this.info,
  });

  factory SemanticColorTokens.light() => SemanticColorTokens(
    primary: ColorTokens.primary,
    onPrimary: const Color(0xFFFFFFFF),
    surfacePrimary: const Color(0xFFFFFBFE),
    surfaceSecondary: const Color(0xFFF0ECF4),
    textPrimary: ColorTokens.onSurface,
    textSecondary: const Color(0xFF49454F),
    borderDefault: const Color(0xFFE0E0E0),
    borderFocused: ColorTokens.primary,
    danger: const Color(0xFFBA1A1A),
    success: const Color(0xFF2E7D32),
    warning: const Color(0xFFFFA000),
    info: const Color(0xFF1565C0),
  );

  // factory SemanticColorTokens.dark() => ... (explicit dark values)

  @override
  SemanticColorTokens copyWith({
    Color? primary,
    Color? onPrimary,
    Color? surfacePrimary,
    Color? surfaceSecondary,
    Color? textPrimary,
    Color? textSecondary,
    Color? borderDefault,
    Color? borderFocused,
    Color? danger,
    Color? success,
    Color? warning,
    Color? info,
  }) {
    return SemanticColorTokens(
      primary: primary ?? this.primary,
      onPrimary: onPrimary ?? this.onPrimary,
      surfacePrimary: surfacePrimary ?? this.surfacePrimary,
      surfaceSecondary: surfaceSecondary ?? this.surfaceSecondary,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      borderDefault: borderDefault ?? this.borderDefault,
      borderFocused: borderFocused ?? this.borderFocused,
      danger: danger ?? this.danger,
      success: success ?? this.success,
      warning: warning ?? this.warning,
      info: info ?? this.info,
    );
  }

  @override
  SemanticColorTokens lerp(ThemeExtension<SemanticColorTokens>? other, double t) {
    if (other is! SemanticColorTokens) return this;
    return SemanticColorTokens(
      primary: Color.lerp(primary, other.primary, t)!,
      onPrimary: Color.lerp(onPrimary, other.onPrimary, t)!,
      surfacePrimary: Color.lerp(surfacePrimary, other.surfacePrimary, t)!,
      surfaceSecondary: Color.lerp(surfaceSecondary, other.surfaceSecondary, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      borderDefault: Color.lerp(borderDefault, other.borderDefault, t)!,
      borderFocused: Color.lerp(borderFocused, other.borderFocused, t)!,
      danger: Color.lerp(danger, other.danger, t)!,
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      info: Color.lerp(info, other.info, t)!,
    );
  }
}
```

### 4.3 Responsive Breakpoint Tokens

```dart
enum Breakpoint { mobile, tablet, desktop }

class ResponsiveTokens {
  static const Map<Breakpoint, double> minWidths = {
    Breakpoint.mobile: 0,
    Breakpoint.tablet: 600,
    Breakpoint.desktop: 1024,
  };
  static Breakpoint fromWidth(double width) { ... }
}
```

**Responsive guidance:**
- Prefer `LayoutBuilder` for component‑level responsiveness.
- Adapt navigation: `NavigationBar` → `NavigationRail` → `NavigationDrawer`.

---

## 5. Button Component – Using Native M3 Theming

We leverage Flutter’s built‑in M3 button themes (`FilledButtonTheme`, `OutlinedButtonTheme`, `TextButtonTheme`), eliminating the need for a custom `ThemeExtension` for buttons. Geometry (size, padding) is owned by the atom, not the theme factory.

### 5.1 Button Tokens (Geometry Only)

```dart
enum ButtonSize { small, medium, regular, large }

class ButtonTokens {
  static const Map<ButtonSize, double> heights = {
    ButtonSize.small: 36.0,
    ButtonSize.medium: 44.0,
    ButtonSize.regular: 52.0,
    ButtonSize.large: 60.0,
  };
  static const double borderRadius = 8.0;
  static const EdgeInsets padding = EdgeInsets.symmetric(horizontal: 16, vertical: 8);
}
```

### 5.2 ThemeFactory – Builds M3 Theme Data (Visual Identity Only)

```dart
class ThemeFactory {
  static FilledButtonThemeData buildFilledButtonTheme(SemanticColorTokens s) {
    return FilledButtonThemeData(
      style: _baseStyle(
        foregroundColor: s.onPrimary,
        backgroundColor: s.primary,
        overlayColor: s.primary.withValues(alpha: 0.12),
        borderColor: Colors.transparent,
        elevation: 2,
      ),
    );
  }

  static OutlinedButtonThemeData buildOutlinedButtonTheme(SemanticColorTokens s) {
    return OutlinedButtonThemeData(
      style: _baseStyle(
        foregroundColor: s.primary,
        backgroundColor: Colors.transparent,
        overlayColor: s.primary.withValues(alpha: 0.08),
        borderColor: s.primary,
        elevation: 0,
      ),
    );
  }

  static TextButtonThemeData buildTextButtonTheme(SemanticColorTokens s) {
    return TextButtonThemeData(
      style: _baseStyle(
        foregroundColor: s.primary,
        backgroundColor: Colors.transparent,
        overlayColor: s.primary.withValues(alpha: 0.08),
        borderColor: Colors.transparent,
        elevation: 0,
      ),
    );
  }

  static ButtonStyle _baseStyle({
    required Color foregroundColor,
    required Color backgroundColor,
    required Color overlayColor,
    required Color borderColor,
    required double elevation,
  }) {
    return ButtonStyle(
      foregroundColor: WidgetStateProperty.all(foregroundColor),
      backgroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) return Colors.grey.shade300;
        if (states.contains(WidgetState.pressed)) return backgroundColor.withValues(alpha: 0.8);
        if (states.contains(WidgetState.hovered)) return backgroundColor.withValues(alpha: 0.9);
        return backgroundColor;
      }),
      overlayColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.pressed)) return overlayColor.withValues(alpha: 0.2);
        if (states.contains(WidgetState.hovered)) return overlayColor.withValues(alpha: 0.1);
        return Colors.transparent;
      }),
      shape: WidgetStateProperty.all(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ButtonTokens.borderRadius),
          side: BorderSide(color: borderColor),
        ),
      ),
      textStyle: WidgetStateProperty.all(
        AppTypography.labelSmall.copyWith(color: foregroundColor),
      ),
    );
  }
}
```

### 5.3 Wiring into ThemeData + Registering SemanticColorTokens

```dart
// design_system/themes/app_theme.dart
ThemeData buildLightTheme() {
  final semantic = SemanticColorTokens.light();
  return ThemeData(
    colorScheme: ColorScheme.light(
      primary: semantic.primary,
      onPrimary: semantic.onPrimary,
      surface: semantic.surfacePrimary,
      onSurface: semantic.textPrimary,
      error: semantic.danger,
      outline: semantic.borderDefault,  // map where possible
    ),
    textTheme: TextTheme(
      displayLarge: AppTypography.displayLarge,
      // ... map all styles
    ),
    filledButtonTheme: ThemeFactory.buildFilledButtonTheme(semantic),
    outlinedButtonTheme: ThemeFactory.buildOutlinedButtonTheme(semantic),
    textButtonTheme: ThemeFactory.buildTextButtonTheme(semantic),
    extensions: [semantic],  // <-- register the extension
  );
}
```

### 5.4 AtomButton – Clean, No Custom Theme Lookup

```dart
class AtomButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String label;
  final Widget? icon;
  final ButtonSize size;
  final ButtonVariant variant;
  final bool isLoading;
  final bool isFullWidth;

  const AtomButton({...}) : ... ;

  @override
  Widget build(BuildContext context) {
    // Geometry from size, no theme dependency
    final ButtonStyle sizeStyle = ButtonStyle(
      minimumSize: WidgetStateProperty.all(
        Size.fromHeight(ButtonTokens.heights[size]!),
      ),
      padding: WidgetStateProperty.all(ButtonTokens.padding),
    );

    final Widget child = isLoading
        ? SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: _resolveForegroundColor(context),
            ),
          )
        : Text(label);

    Widget button;

    switch (variant) {
      case ButtonVariant.primary:
        button = icon != null
            ? FilledButton.icon(
                onPressed: isLoading ? null : onPressed,
                style: sizeStyle,
                icon: icon!,
                label: child,
              )
            : FilledButton(
                onPressed: isLoading ? null : onPressed,
                style: sizeStyle,
                child: child,
              );
        break;
      case ButtonVariant.secondary:
        button = icon != null
            ? OutlinedButton.icon(
                onPressed: isLoading ? null : onPressed,
                style: sizeStyle,
                icon: icon!,
                label: child,
              )
            : OutlinedButton(
                onPressed: isLoading ? null : onPressed,
                style: sizeStyle,
                child: child,
              );
        break;
      case ButtonVariant.text:
        button = icon != null
            ? TextButton.icon(
                onPressed: isLoading ? null : onPressed,
                style: sizeStyle,
                icon: icon!,
                label: child,
              )
            : TextButton(
                onPressed: isLoading ? null : onPressed,
                style: sizeStyle,
                child: child,
              );
        break;
    }

    return isFullWidth ? SizedBox(width: double.infinity, child: button) : button;
  }

  Color? _resolveForegroundColor(BuildContext context) {
    final ButtonStyle? style;
    switch (variant) {
      case ButtonVariant.primary:
        style = Theme.of(context).filledButtonTheme.style ?? FilledButton.defaultStyleOf(context);
        break;
      case ButtonVariant.secondary:
        style = Theme.of(context).outlinedButtonTheme.style ?? OutlinedButton.defaultStyleOf(context);
        break;
      case ButtonVariant.text:
        style = Theme.of(context).textButtonTheme.style ?? TextButton.defaultStyleOf(context);
        break;
    }
    return style?.foregroundColor?.resolve({});
  }
}
```

**Atom rules (explicit):**
- Always `StatelessWidget` (except allowed ephemeral state).
- **No API calls, repositories, business logic, or feature state.**
- **Localization:** Atoms accept raw `String` text, never call `AppLocalizations.of(context)`. The Organism/Page performs translation.
- **Validation:** Atoms render error visuals (e.g., red border, error text) but logic lives outside.

---

## 6. State Management & Validation Patterns

### 6.1 State Flow

```
Page (reads reactive state)
  ↓
ViewModel/Controller (business logic)
  ↓
Organism (local UI state allowed, e.g., expanded panel)
  ↓
Molecule (strictly stateless)
  ↓
Atom (pure UI leaf)
```

### 6.2 Validation State Example (AtomInput)

```dart
class AtomInput extends StatelessWidget {
  final String? errorText;
  // ...

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<SemanticColorTokens>()!;
    return TextField(
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderSide: BorderSide(color: semantic.borderDefault),
        ),
        errorBorder: OutlineInputBorder(
          borderSide: BorderSide(color: semantic.danger),
        ),
        errorText: errorText,
        errorStyle: AppTypography.labelSmall.copyWith(color: semantic.danger),
      ),
    );
  }
}
```

The Organism/Page handles the logic:
```dart
OrganismLoginForm(
  emailError: state.emailError,
  onEmailChanged: (v) => ref.read(loginProvider.notifier).validateEmail(v),
)
```

---

## 7. Accessibility

- `Semantics` labels on interactive atoms.
- Minimum touch target 48×48 dp.
- Color contrast ≥ 4.5:1 (text), 3:1 (large text/icons).
- `WidgetState` communicates disabled/focused/pressed.
- Run accessibility checks with `meetsGuideline` in widget tests.

---

## 8. Testing Strategy

### Testing Pyramid (correct orientation)

```
          /\
         /  \  Integration Tests (few, critical flows)
        /____\
       /      \ Golden Tests (some, visual regression)
      /________\
     /          \ Widget Tests (many, component behaviour)
    /____________\
   /              \ Unit Tests (most, logic & tokens)
```

**Best practices for design system testing:**

- **Widget tests:** every atom/molecule – all variants, loading, disabled, error states.
- **Golden tests:** pump under both light and dark themes, using `textScaler: TextScaler.linear(1.0)`. Append `_light.png` / `_dark.png` to golden file names. Use a helper:

  ```dart
  Future<void> pumpGolden(WidgetTester tester, Widget widget, {required bool dark}) async {
    await tester.pumpWidget(
      MediaQuery(
        data: MediaQueryData().copyWith(textScaler: TextScaler.linear(1.0)),
        child: Theme(
          data: dark ? appDarkTheme : appLightTheme,
          child: MaterialApp(home: widget),
        ),
      ),
    );
  }
  ```

- **Accessibility tests:** verify labels, contrast, tap target sizes.
- **Interaction state tests:** simulate hover/press and check overlay changes.

---

## 9. Widgetbook Documentation

Maintain a Widgetbook showing every component in all sizes, variants, states, and themes.

---

## 10. Performance Guidance

- Use `const` constructors.
- Keep atoms lightweight; avoid `setState` in build.
- Prefer immutable data; use keys only when needed.

---

## 11. Implementation Checklist

- [ ] `design_system/` is a top‑level directory, separate from `core/` and `features/`.
- [ ] Raw tokens and semantic tokens defined; semantic tokens are explicit solid colours.
- [ ] `SemanticColorTokens` extends `ThemeExtension` and is registered in `ThemeData.extensions`.
- [ ] `ThemeData` uses native M3 theming (`FilledButtonTheme`, etc.) built by `ThemeFactory`.
- [ ] Geometry (size, padding) lives in atoms, not in the theme factory.
- [ ] Atoms wrap correct M3 widget per variant; no custom `ThemeExtension` needed for buttons.
- [ ] Atoms never call `AppLocalizations`; raw strings passed down.
- [ ] Validation visuals built into atoms via `errorText` / props; logic handled by organisms/pages.
- [ ] Organisms may hold local UI state; molecules and atoms are stateless.
- [ ] Testing covers unit, widget, golden (light+dark, textScaler 1.0), accessibility.
- [ ] Widgetbook catalogues the full system.
- [ ] Dark/light themes generated from the same token set.
- [ ] Performance: const, lightweight atoms, `ListView.builder` with keys.

---

## 12. Summary

Atomic Design gives us a vocabulary; Flutter’s composability gives us the engine. By using semantic tokens (as `ThemeExtension`), native M3 theming, strict state boundaries, and a modular architecture, you create a design system that is consistent, accessible, testable, and brandable. Start small, enforce the rules, and let the system grow with your app.