/// Sizing tokens in logical pixels: touch targets, control heights, icon sizes,
/// and common field / panel widths. Tablet-first — interactive targets meet the
/// Material 48dp accessibility floor so the same UI is comfortable on a 7"/10"
/// tablet and on desktop.
abstract final class UiSizing {
  const UiSizing._();

  /// Minimum interactive target (Material accessibility floor).
  static const double touchTarget = 48;

  /// Default height for compact/dense controls (e.g. dense form fields).
  static const double controlHeight = 44;

  // Icon sizes.
  static const double iconSm = 18;
  static const double iconMd = 24;
  static const double iconLg = 40;

  // Common field widths.
  static const double fieldNarrow = 130;
  static const double fieldMedium = 200;
  static const double fieldWide = 320;

  // Generic side-panel widths (e.g. a settings panel or a log sidebar).
  static const double panelNarrow = 280;
  static const double panelWide = 320;
}
