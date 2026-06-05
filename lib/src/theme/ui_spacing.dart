import 'package:flutter/widgets.dart';

/// Spacing scale in logical pixels. Use these instead of magic numbers so
/// spacing stays consistent across the whole app and any future project.
///
/// The scale is tablet-first: the steps are generous enough for comfortable
/// touch layouts on 7" and 10" tablets while still reading well on desktop.
abstract final class UiSpacing {
  const UiSpacing._();

  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;

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
}
