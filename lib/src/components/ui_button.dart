import 'package:flutter/material.dart';

import '../theme/ui_colors.dart';

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
    super.key,
  });

  /// Filled, highest-emphasis button.
  const UiButton.primary({
    required String label,
    required VoidCallback? onPressed,
    IconData? icon,
    UiButtonTone tone = UiButtonTone.normal,
    Key? key,
  }) : this(
          label: label,
          onPressed: onPressed,
          icon: icon,
          variant: UiButtonVariant.primary,
          tone: tone,
          key: key,
        );

  /// Outlined, medium-emphasis button.
  const UiButton.secondary({
    required String label,
    required VoidCallback? onPressed,
    IconData? icon,
    UiButtonTone tone = UiButtonTone.normal,
    Key? key,
  }) : this(
          label: label,
          onPressed: onPressed,
          icon: icon,
          variant: UiButtonVariant.secondary,
          tone: tone,
          key: key,
        );

  /// Text-only, low-emphasis button.
  const UiButton.text({
    required String label,
    required VoidCallback? onPressed,
    IconData? icon,
    UiButtonTone tone = UiButtonTone.normal,
    Key? key,
  }) : this(
          label: label,
          onPressed: onPressed,
          icon: icon,
          variant: UiButtonVariant.text,
          tone: tone,
          key: key,
        );

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final UiButtonVariant variant;
  final UiButtonTone tone;

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
    final Text labelWidget = Text(label);
    switch (variant) {
      case UiButtonVariant.primary:
        final fill = _tonedFill(context);
        final style = fill == null
            ? null
            : FilledButton.styleFrom(
                backgroundColor: fill.background,
                foregroundColor: fill.foreground,
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
        final style = fg == null
            ? null
            : OutlinedButton.styleFrom(
                foregroundColor: fg, side: BorderSide(color: fg));
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
        final style =
            fg == null ? null : TextButton.styleFrom(foregroundColor: fg);
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
