import 'package:flutter/material.dart';

import 'ui_colors.dart';
import 'ui_radius.dart';
import 'ui_sizing.dart';
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

  const ButtonStyle touchSized = ButtonStyle(
    minimumSize: WidgetStatePropertyAll<Size>(Size(0, UiSizing.touchTarget)),
  );

  return base.copyWith(
    textTheme: UiTypography.textTheme(base.textTheme),
    extensions: <ThemeExtension<dynamic>>[uiColors],
    inputDecorationTheme: const InputDecorationTheme(
      isDense: true,
      border: OutlineInputBorder(borderRadius: UiRadius.brSm),
    ),
    filledButtonTheme: const FilledButtonThemeData(style: touchSized),
    outlinedButtonTheme: const OutlinedButtonThemeData(style: touchSized),
    textButtonTheme: const TextButtonThemeData(style: touchSized),
  );
}
