import 'package:flutter/widgets.dart';

/// Width-based device classes, aligned with Material's window size classes and
/// tuned for this project's tablet targets:
///
/// * [compact]  `< 600`     — phones / very narrow panes.
/// * [medium]   `600–839`   — 7" tablet portrait-ish.
/// * [expanded] `840–1199`  — 7" landscape / small 10".
/// * [large]    `>= 1200`   — 10" tablet landscape (the desktop default of
///   1280×800 lands here).
enum UiDeviceClass { compact, medium, expanded, large }

/// Breakpoint thresholds (logical px) and helpers to classify a width.
abstract final class UiBreakpoints {
  const UiBreakpoints._();

  static const double medium = 600;
  static const double expanded = 840;
  static const double large = 1200;

  /// Classifies a raw [width] (logical px) into a [UiDeviceClass].
  static UiDeviceClass classify(double width) {
    if (width < medium) return UiDeviceClass.compact;
    if (width < expanded) return UiDeviceClass.medium;
    if (width < large) return UiDeviceClass.expanded;
    return UiDeviceClass.large;
  }

  /// Classifies using the nearest [MediaQuery] width. Prefer [classify] with a
  /// `LayoutBuilder`'s constraints when sizing an embedded sub-tree.
  static UiDeviceClass of(BuildContext context) =>
      classify(MediaQuery.sizeOf(context).width);
}
