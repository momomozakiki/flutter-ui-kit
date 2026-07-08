import 'package:flutter/material.dart';

import 'ui_colors.dart';
import 'ui_radius.dart';
import 'ui_sizing.dart';
import 'ui_spacing.dart';
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
  const ButtonStyle touchSized = ButtonStyle(
    minimumSize: WidgetStatePropertyAll<Size>(Size(0, UiSizing.touchTarget)),
    visualDensity: VisualDensity.standard,
  );

  return base.copyWith(
    textTheme: UiTypography.textTheme(base.textTheme),
    extensions: <ThemeExtension<dynamic>>[uiColors],
    // Control height is driven HERE, not by the size tokens: `contentPadding`
    // sets the field/dropdown height and `visualDensity` densifies dropdown
    // menu rows, checkboxes, chips and list tiles. `minHeight` pins a
    // predictable floor (and finally consumes [UiSizing.controlHeight]).
    inputDecorationTheme: const InputDecorationTheme(
      isDense: true,
      contentPadding:
          EdgeInsets.symmetric(horizontal: UiSpacing.md, vertical: UiSpacing.sm),
      constraints: BoxConstraints(minHeight: UiSizing.controlHeight),
      border: OutlineInputBorder(borderRadius: UiRadius.brSm),
    ),
    // Compact density shrinks Material controls (menu rows, checkbox, chips,
    // tabs). Buttons are protected by their `minimumSize` floors (see
    // touchSized / UiButton), so they never drop below 40 / 32 px.
    visualDensity: VisualDensity.compact,
    filledButtonTheme: const FilledButtonThemeData(style: touchSized),
    outlinedButtonTheme: const OutlinedButtonThemeData(style: touchSized),
    textButtonTheme: const TextButtonThemeData(style: touchSized),
  );
}
