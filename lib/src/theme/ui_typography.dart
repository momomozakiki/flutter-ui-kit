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

  /// Returns [base] with every defined font size multiplied by [scale]
  /// (defaults to [fontScale], so existing callers/tests are unaffected).
  ///
  /// Scales per-style (rather than `TextTheme.apply(fontSizeFactor:)`) because
  /// that helper asserts when any style has a null `fontSize`. Wired into
  /// [buildUiTheme], which passes `UiTuning.instance.fontScale` so text size
  /// can be tuned live via the debug-only `UiTuningPanel`.
  static TextTheme textTheme(TextTheme base, {double scale = fontScale}) {
    TextStyle? scaleStyle(TextStyle? s) => (s == null || s.fontSize == null)
        ? s
        : s.copyWith(fontSize: s.fontSize! * scale);
    return base.copyWith(
      displayLarge: scaleStyle(base.displayLarge),
      displayMedium: scaleStyle(base.displayMedium),
      displaySmall: scaleStyle(base.displaySmall),
      headlineLarge: scaleStyle(base.headlineLarge),
      headlineMedium: scaleStyle(base.headlineMedium),
      headlineSmall: scaleStyle(base.headlineSmall),
      titleLarge: scaleStyle(base.titleLarge),
      titleMedium: scaleStyle(base.titleMedium),
      titleSmall: scaleStyle(base.titleSmall),
      bodyLarge: scaleStyle(base.bodyLarge),
      bodyMedium: scaleStyle(base.bodyMedium),
      bodySmall: scaleStyle(base.bodySmall),
      labelLarge: scaleStyle(base.labelLarge),
      labelMedium: scaleStyle(base.labelMedium),
      labelSmall: scaleStyle(base.labelSmall),
    );
  }

  /// A monospace style for tabular / raw-data readouts.
  static const TextStyle mono = TextStyle(
    fontFamily: 'monospace',
    fontFeatures: [FontFeature.tabularFigures()],
  );
}
