/// Sizing tokens in logical pixels: touch targets, control heights, icon sizes,
/// and common field / panel widths.
///
/// Compact override: the interactive floor is a deliberate 35 px (down from the
/// Material 48dp accessibility floor, and below the original 40 px compact
/// override) for a denser Console UI. This value was tuned live, on-screen,
/// via the debug-only `UiTuningPanel` (see `ui_tuning.dart`) rather than
/// guessed from a screenshot — the user visually confirmed both readability
/// and tap comfort before landing on it. It sits inside the ~32–36 px range
/// earlier notes flagged as a mis-tap risk zone; that risk was accepted
/// deliberately, not overlooked. Revisit (via the same panel) if field use
/// shows mis-taps.
abstract final class UiSizing {
  const UiSizing._();

  /// Minimum interactive target (compact floor — see the class note; below the
  /// Material 48dp accessibility floor by intent). Kept **equal to
  /// [controlHeight]** so buttons line up with the other form controls.
  static const double touchTarget = 35;

  /// THE shared form-control height. Every dropdown, text field, [UiButton],
  /// command chip, and checkbox renders at this height so a row of mixed
  /// controls aligns **by default** — each can now also be tuned
  /// independently via `UiTuning`'s per-component fields (dropdownHeight,
  /// textFieldHeight, etc.), which all seed from this value. Kept equal to
  /// [touchTarget]; change them together. Consumed by `inputDecorationTheme`
  /// (field/dropdown height), `UiButton` (via [touchTarget]), `UiCheckbox`,
  /// and the quick-command chips.
  static const double controlHeight = 35;

  /// Horizontal padding inside a quick-command chip pill. Tuned live via
  /// `UiTuningPanel`; seeds `UiTuning.chipPaddingH`.
  static const double chipPaddingH = 11;

  /// Width of the left icon-only navigation rail. Tuned live via
  /// `UiTuningPanel`; seeds `UiTuning.navRailWidth`.
  static const double navRailWidth = 45;

  /// Height for a compact button ([UiButtonSize.compact]) used for *secondary*
  /// actions in dense list rows. A further reduction from the [touchTarget]
  /// floor for a busy action row; stays above the ~32 px mis-tap threshold.
  /// Primary actions keep the full [touchTarget] height.
  static const double buttonCompactHeight = 32;

  // Icon sizes.
  static const double iconSm = 16;
  static const double iconMd = 20;
  static const double iconLg = 32;

  // Common field widths.
  static const double fieldNarrow = 104;
  static const double fieldMedium = 160;
  static const double fieldWide = 256;

  /// A compact, constant button width (e.g. a Connect/Connected toggle that
  /// must not resize between states) sized to fit a short verb + icon.
  static const double buttonCompact = 120;

  /// Min / max width for a compact "quick key" chip (e.g. W / Tare / Z / R) so a
  /// one-letter key stays tappable and a long label can't balloon.
  static const double quickKeyMinWidth = 48;
  static const double quickKeyMaxWidth = 100;

  /// Min / max width for a clustered action-row button (e.g. Save / Save As /
  /// Suggestions) so short labels stay comfortably tappable and the widest label
  /// ("Suggestions", plus i18n headroom) never clips — the button's `FittedBox`
  /// shrinks anything still tight at [buttonMaxWidth].
  static const double buttonMinWidth = 72;
  static const double buttonMaxWidth = 132;

  // Generic side-panel widths (e.g. a settings panel or a log sidebar).
  static const double panelNarrow = 224;
  static const double panelWide = 256;

  /// Max height for a secondary, content-sized form section that scrolls past
  /// this cap (e.g. the Alibi mapping block under the variables editor) so it
  /// never crowds out the primary content or pushes the action row off-screen.
  static const double formSectionMax = 260;
}
