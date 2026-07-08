import 'package:flutter/material.dart';

/// Typography tokens. The kit applies a single scale to the base Material text
/// theme so labels and data stay consistent without hand-authoring every text
/// style.
abstract final class UiTypography {
  const UiTypography._();

  /// Scale applied to the base [TextTheme]. Compact override: slightly below
  /// 1.0 so text reads a touch smaller alongside the reduced control sizes
  /// (down from the earlier 1.05 tablet nudge).
  static const double fontScale = 0.95;

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
