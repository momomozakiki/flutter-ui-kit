import 'package:flutter/material.dart';

import '../theme/ui_colors.dart';
import '../theme/ui_sizing.dart';
import '../theme/ui_spacing.dart';

/// Visual emphasis of a [UiButton].
enum UiButtonVariant {
  /// Filled, highest emphasis (primary action).
  primary,

  /// Outlined, medium emphasis (secondary action).
  secondary,

  /// Text-only, lowest emphasis.
  text,
}

/// Semantic color tone of a [UiButton], layered on top of its [UiButtonVariant].
///
/// [normal] uses the theme's default (primary) color. [success] / [danger] pull
/// from the semantic [UiColors] extension (e.g. a green "Connected" or a red
/// "Disconnect" action) — never a hardcoded color.
enum UiButtonTone { normal, success, danger }

/// Sizing of a [UiButton].
///
/// [normal] uses the theme's [UiSizing.touchTarget] (40 px) floor. [compact]
/// trims horizontal padding and lowers the height to [UiSizing.buttonCompactHeight]
/// for *secondary* actions in dense list rows where a full-height button would
/// overflow — see that token's doc for the accessibility rationale.
enum UiButtonSize { normal, compact }

/// A single button atom with three emphasis variants, an optional semantic
/// [tone], and an optional leading [icon]. Pass `onPressed: null` to disable it.
///
/// Prefer this over reaching for `FilledButton` / `OutlinedButton` / `TextButton`
/// directly so emphasis and color stay consistent across the app.
class UiButton extends StatelessWidget {
  const UiButton({
    required this.label,
    required this.onPressed,
    this.icon,
    this.variant = UiButtonVariant.primary,
    this.tone = UiButtonTone.normal,
    this.size = UiButtonSize.normal,
    super.key,
  });

  /// Filled, highest-emphasis button.
  const UiButton.primary({
    required String label,
    required VoidCallback? onPressed,
    IconData? icon,
    UiButtonTone tone = UiButtonTone.normal,
    UiButtonSize size = UiButtonSize.normal,
    Key? key,
  }) : this(
          label: label,
          onPressed: onPressed,
          icon: icon,
          variant: UiButtonVariant.primary,
          tone: tone,
          size: size,
          key: key,
        );

  /// Outlined, medium-emphasis button.
  const UiButton.secondary({
    required String label,
    required VoidCallback? onPressed,
    IconData? icon,
    UiButtonTone tone = UiButtonTone.normal,
    UiButtonSize size = UiButtonSize.normal,
    Key? key,
  }) : this(
          label: label,
          onPressed: onPressed,
          icon: icon,
          variant: UiButtonVariant.secondary,
          tone: tone,
          size: size,
          key: key,
        );

  /// Text-only, low-emphasis button.
  const UiButton.text({
    required String label,
    required VoidCallback? onPressed,
    IconData? icon,
    UiButtonTone tone = UiButtonTone.normal,
    UiButtonSize size = UiButtonSize.normal,
    Key? key,
  }) : this(
          label: label,
          onPressed: onPressed,
          icon: icon,
          variant: UiButtonVariant.text,
          tone: tone,
          size: size,
          key: key,
        );

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final UiButtonVariant variant;
  final UiButtonTone tone;
  final UiButtonSize size;

  /// Background / foreground for a filled button in this [tone], or `null` for
  /// [UiButtonTone.normal] (let the theme decide).
  ({Color background, Color foreground})? _tonedFill(BuildContext context) {
    final colors = context.uiColors;
    return switch (tone) {
      UiButtonTone.normal => null,
      UiButtonTone.success =>
        (background: colors.success, foreground: colors.onSuccess),
      UiButtonTone.danger =>
        (background: colors.danger, foreground: colors.onDanger),
    };
  }

  /// Foreground (text/icon/outline) color for an outlined or text button in this
  /// [tone], or `null` for [UiButtonTone.normal].
  Color? _tonedForeground(BuildContext context) {
    final colors = context.uiColors;
    return switch (tone) {
      UiButtonTone.normal => null,
      UiButtonTone.success => colors.success,
      UiButtonTone.danger => colors.danger,
    };
  }

  @override
  Widget build(BuildContext context) {
    // Keep labels on a single line and shrink only when too wide for the
    // button's slot (e.g. "Save As…" in a narrow equal-width action row),
    // rather than wrapping to two lines.
    final Widget labelWidget = FittedBox(
      fit: BoxFit.scaleDown,
      child: Text(label, maxLines: 1, softWrap: false),
    );
    // Compact metrics for dense rows: trim horizontal padding (the real overflow
    // fix) and lower the height to [UiSizing.buttonCompactHeight], letting the
    // button shrink to it. `shrinkWrap` is required so the per-button minimumSize
    // actually overrides the theme-enforced 40 px touch-target floor. The theme
    // sets VisualDensity.compact globally, but the button themes pin
    // VisualDensity.standard (see buildUiTheme's touchSized), which this compact
    // style inherits — so density can't shrink the 32 px floor into the mis-tap
    // zone. All null when the size is normal, so styleFrom falls through to the
    // theme unchanged.
    final bool compact = size == UiButtonSize.compact;
    final Size? minSize =
        compact ? const Size(0, UiSizing.buttonCompactHeight) : null;
    final EdgeInsetsGeometry? padding =
        compact ? const EdgeInsets.symmetric(horizontal: UiSpacing.sm) : null;
    final MaterialTapTargetSize? tapTargetSize =
        compact ? MaterialTapTargetSize.shrinkWrap : null;
    switch (variant) {
      case UiButtonVariant.primary:
        final fill = _tonedFill(context);
        final style = (fill == null && !compact)
            ? null
            : FilledButton.styleFrom(
                backgroundColor: fill?.background,
                foregroundColor: fill?.foreground,
                minimumSize: minSize,
                padding: padding,
                tapTargetSize: tapTargetSize,
              );
        return icon == null
            ? FilledButton(
                onPressed: onPressed, style: style, child: labelWidget)
            : FilledButton.icon(
                onPressed: onPressed,
                style: style,
                icon: Icon(icon),
                label: labelWidget);
      case UiButtonVariant.secondary:
        final fg = _tonedForeground(context);
        final style = (fg == null && !compact)
            ? null
            : OutlinedButton.styleFrom(
                foregroundColor: fg,
                side: fg == null ? null : BorderSide(color: fg),
                minimumSize: minSize,
                padding: padding,
                tapTargetSize: tapTargetSize,
              );
        return icon == null
            ? OutlinedButton(
                onPressed: onPressed, style: style, child: labelWidget)
            : OutlinedButton.icon(
                onPressed: onPressed,
                style: style,
                icon: Icon(icon),
                label: labelWidget);
      case UiButtonVariant.text:
        final fg = _tonedForeground(context);
        final style = (fg == null && !compact)
            ? null
            : TextButton.styleFrom(
                foregroundColor: fg,
                minimumSize: minSize,
                padding: padding,
                tapTargetSize: tapTargetSize,
              );
        return icon == null
            ? TextButton(onPressed: onPressed, style: style, child: labelWidget)
            : TextButton.icon(
                onPressed: onPressed,
                style: style,
                icon: Icon(icon),
                label: labelWidget);
    }
  }
}
