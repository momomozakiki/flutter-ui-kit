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

  /// Height for a compact button ([UiButtonSize.compact]) used for *secondary*
  /// actions in dense list rows. A deliberate, documented reduction from the
  /// 48 px [touchTarget] floor: it stays comfortably tappable (above the
  /// ~32–36 px point where mis-taps spike) while keeping a busy action row from
  /// overflowing. Primary actions keep the full [touchTarget] height.
  static const double buttonCompactHeight = 40;

  // Icon sizes.
  static const double iconSm = 18;
  static const double iconMd = 24;
  static const double iconLg = 40;

  // Common field widths.
  static const double fieldNarrow = 130;
  static const double fieldMedium = 200;
  static const double fieldWide = 320;

  /// A compact, constant button width (e.g. a Connect/Connected toggle that
  /// must not resize between states) sized to fit a short verb + icon.
  static const double buttonCompact = 150;

  /// Min / max width for a compact "quick key" chip (e.g. W / Tare / Z / R) so a
  /// one-letter key stays tappable and a long label can't balloon.
  static const double quickKeyMinWidth = 56;
  static const double quickKeyMaxWidth = 120;

  // Generic side-panel widths (e.g. a settings panel or a log sidebar).
  static const double panelNarrow = 280;
  static const double panelWide = 320;
}
