import 'package:flutter/widgets.dart';

/// Spacing scale in logical pixels. Use these instead of magic numbers so
/// spacing stays consistent across the whole app and any future project.
///
/// The scale is compact (a deliberate ~20% reduction from the earlier
/// tablet-first steps) for a denser Console UI; it still reads on 7"/10"
/// tablets and desktop. See the compact-override note in the Adaptive UI spec.
abstract final class UiSpacing {
  const UiSpacing._();

  static const double xs = 4;
  static const double sm = 6;
  static const double md = 10;
  static const double lg = 13;
  static const double xl = 20;
  static const double xxl = 26;

  /// Common symmetric paddings.
  static const EdgeInsets allSm = EdgeInsets.all(sm);
  static const EdgeInsets allMd = EdgeInsets.all(md);
  static const EdgeInsets allLg = EdgeInsets.all(lg);

  /// Vertical / horizontal gap widgets for use between children.
  static const SizedBox gapVXs = SizedBox(height: xs);
  static const SizedBox gapVSm = SizedBox(height: sm);
  static const SizedBox gapVMd = SizedBox(height: md);
  static const SizedBox gapVLg = SizedBox(height: lg);
  static const SizedBox gapHXs = SizedBox(width: xs);
  static const SizedBox gapHSm = SizedBox(width: sm);
  static const SizedBox gapHMd = SizedBox(width: md);
  static const SizedBox gapHLg = SizedBox(width: lg);
  static const SizedBox gapHXl = SizedBox(width: xl);
}
