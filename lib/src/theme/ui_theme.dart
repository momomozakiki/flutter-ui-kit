import 'package:flutter/material.dart';

import 'ui_colors.dart';
import 'ui_radius.dart';
import 'ui_sizing.dart';
import 'ui_tuning.dart';
import 'ui_typography.dart';

/// Builds the app [ThemeData] for the kit: Material 3, seeded color scheme, the
/// [UiColors] semantic extension, tablet-legible typography, an outlined input
/// decoration (so text fields and dropdowns get the label-on-the-border look by
/// default), and buttons sized to the [UiSizing.touchTarget] floor.
///
/// Hosts should use this as their `MaterialApp.theme` so every kit component is
/// styled consistently.
ThemeData buildUiTheme({
  Brightness brightness = Brightness.light,
  Color seed = const Color(0xFF1565C0),
}) {
  final bool isDark = brightness == Brightness.dark;
  final ThemeData base = ThemeData(
    useMaterial3: true,
    brightness: brightness,
    colorSchemeSeed: seed,
  );
  final UiColors uiColors = isDark ? UiColors.dark : UiColors.light;

  // Buttons pin standard density so the global `visualDensity.compact` (below)
  // does NOT shrink their `minimumSize` floor — compact density adjusts the
  // floor itself, which would drop buttons below their intended 40 / 32 px and
  // into the mis-tap zone. This themed style is inherited by compact buttons
  // too (their per-button styleFrom leaves visualDensity null).
  //
  // minimumSize alone is only a FLOOR: a button's natural content (icon +
  // label + default Material padding) is free to push it taller, and that's
  // exactly what happened — buttons rendered taller than the 40px dropdowns/
  // chips next to them even though every "floor" test stayed green. `padding`
  // (horizontal only) removes the competing default vertical padding, and
  // `maximumSize` pins the ceiling so height is exactly 40, not merely >= 40.
  // `tapTargetSize: shrinkWrap` matters too: the default `padded` wraps an
  // already-40px button in invisible touch-target padding that reports an
  // inflated 48px *layout* size to the parent Row (even though the button
  // paints at 40) — that mismatch is what made the button's row look taller
  // than the dropdown/chips sitting in it. shrinkWrap makes reported size
  // match painted size.
  // Reads UiTuning.instance (not the raw consts) for the handful of values a
  // debug-only live tuning panel can override; both are seeded identically so
  // this is a no-op until a slider is actually touched. touchSized and
  // inputDecorationTheme can no longer be `const` because of this — they read
  // a runtime singleton, not a compile-time constant. Single code path in
  // both debug and release (no kDebugMode branch here) so what's tuned in
  // debug and what ships in release can never silently diverge.
  final double controlHeight = UiTuning.instance.controlHeight;
  final ButtonStyle touchSized = ButtonStyle(
    minimumSize: WidgetStatePropertyAll<Size>(Size(0, controlHeight)),
    maximumSize:
        WidgetStatePropertyAll<Size>(Size(double.infinity, controlHeight)),
    padding: WidgetStatePropertyAll<EdgeInsets>(
        EdgeInsets.symmetric(horizontal: UiTuning.instance.spacingMd)),
    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
    visualDensity: VisualDensity.standard,
  );

  // Font size and family are both live-tunable (UiTuning.fontScale/fontFamily)
  // — scale is applied by UiTypography.textTheme, family via TextTheme.apply
  // (a null family is a no-op, leaving the theme's own default untouched).
  final TextTheme textTheme = UiTypography.textTheme(
    base.textTheme,
    scale: UiTuning.instance.fontScale,
  ).apply(fontFamily: UiTuning.instance.fontFamily);

  return base.copyWith(
    textTheme: textTheme,
    extensions: <ThemeExtension<dynamic>>[uiColors],
    // Control height is driven HERE, not by the size tokens: `contentPadding`
    // sets the field/dropdown height and `visualDensity` densifies dropdown
    // menu rows, checkboxes, chips and list tiles. `constraints` is TIGHT
    // (min == max == controlHeight): a `minHeight`-only floor let
    // content-heavy fields (e.g. a floating label) render taller than 40 —
    // Flutter's box protocol guarantees a tight constraint forces exactly
    // that size regardless of what the field's content would otherwise want.
    inputDecorationTheme: InputDecorationTheme(
      isDense: true,
      contentPadding: EdgeInsets.symmetric(
          horizontal: UiTuning.instance.spacingMd,
          vertical: UiTuning.instance.spacingSm),
      constraints: BoxConstraints.tightFor(height: controlHeight),
      border: const OutlineInputBorder(borderRadius: UiRadius.brSm),
    ),
    // Compact density shrinks Material controls (menu rows, checkbox, chips,
    // tabs). Buttons are protected by their `minimumSize` floors (see
    // touchSized / UiButton), so they never drop below 40 / 32 px.
    visualDensity: VisualDensity.compact,
    filledButtonTheme: FilledButtonThemeData(style: touchSized),
    outlinedButtonTheme: OutlinedButtonThemeData(style: touchSized),
    textButtonTheme: TextButtonThemeData(style: touchSized),
  );
}
