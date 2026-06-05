import 'package:flutter/material.dart';

/// Typography tokens. The kit nudges the base Material text theme slightly
/// larger so labels and data read comfortably at tablet arm's-length, without
/// hand-authoring every text style.
abstract final class UiTypography {
  const UiTypography._();

  /// Scale applied to the base [TextTheme] for tablet legibility.
  static const double fontScale = 1.05;

  /// Returns [base] with every defined font size multiplied by [fontScale].
  ///
  /// Scales per-style (rather than `TextTheme.apply(fontSizeFactor:)`) because
  /// that helper asserts when any style has a null `fontSize`. Wired into
  /// [buildUiTheme].
  static TextTheme textTheme(TextTheme base) {
    TextStyle? scale(TextStyle? s) => (s == null || s.fontSize == null)
        ? s
        : s.copyWith(fontSize: s.fontSize! * fontScale);
    return base.copyWith(
      displayLarge: scale(base.displayLarge),
      displayMedium: scale(base.displayMedium),
      displaySmall: scale(base.displaySmall),
      headlineLarge: scale(base.headlineLarge),
      headlineMedium: scale(base.headlineMedium),
      headlineSmall: scale(base.headlineSmall),
      titleLarge: scale(base.titleLarge),
      titleMedium: scale(base.titleMedium),
      titleSmall: scale(base.titleSmall),
      bodyLarge: scale(base.bodyLarge),
      bodyMedium: scale(base.bodyMedium),
      bodySmall: scale(base.bodySmall),
      labelLarge: scale(base.labelLarge),
      labelMedium: scale(base.labelMedium),
      labelSmall: scale(base.labelSmall),
    );
  }

  /// A monospace style for tabular / raw-data readouts.
  static const TextStyle mono = TextStyle(
    fontFamily: 'monospace',
    fontFeatures: [FontFeature.tabularFigures()],
  );
}
