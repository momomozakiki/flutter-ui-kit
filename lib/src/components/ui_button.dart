import 'package:flutter/material.dart';

/// Visual emphasis of a [UiButton].
enum UiButtonVariant {
  /// Filled, highest emphasis (primary action).
  primary,

  /// Outlined, medium emphasis (secondary action).
  secondary,

  /// Text-only, lowest emphasis.
  text,
}

/// A single button atom with three emphasis variants and an optional leading
/// [icon]. Pass `onPressed: null` to disable it.
///
/// Prefer this over reaching for `FilledButton` / `OutlinedButton` / `TextButton`
/// directly so emphasis stays consistent across the app.
class UiButton extends StatelessWidget {
  const UiButton({
    required this.label,
    required this.onPressed,
    this.icon,
    this.variant = UiButtonVariant.primary,
    super.key,
  });

  /// Filled, highest-emphasis button.
  const UiButton.primary({
    required String label,
    required VoidCallback? onPressed,
    IconData? icon,
    Key? key,
  }) : this(
          label: label,
          onPressed: onPressed,
          icon: icon,
          variant: UiButtonVariant.primary,
          key: key,
        );

  /// Outlined, medium-emphasis button.
  const UiButton.secondary({
    required String label,
    required VoidCallback? onPressed,
    IconData? icon,
    Key? key,
  }) : this(
          label: label,
          onPressed: onPressed,
          icon: icon,
          variant: UiButtonVariant.secondary,
          key: key,
        );

  /// Text-only, low-emphasis button.
  const UiButton.text({
    required String label,
    required VoidCallback? onPressed,
    IconData? icon,
    Key? key,
  }) : this(
          label: label,
          onPressed: onPressed,
          icon: icon,
          variant: UiButtonVariant.text,
          key: key,
        );

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final UiButtonVariant variant;

  @override
  Widget build(BuildContext context) {
    final Text labelWidget = Text(label);
    switch (variant) {
      case UiButtonVariant.primary:
        return icon == null
            ? FilledButton(onPressed: onPressed, child: labelWidget)
            : FilledButton.icon(
                onPressed: onPressed, icon: Icon(icon), label: labelWidget);
      case UiButtonVariant.secondary:
        return icon == null
            ? OutlinedButton(onPressed: onPressed, child: labelWidget)
            : OutlinedButton.icon(
                onPressed: onPressed, icon: Icon(icon), label: labelWidget);
      case UiButtonVariant.text:
        return icon == null
            ? TextButton(onPressed: onPressed, child: labelWidget)
            : TextButton.icon(
                onPressed: onPressed, icon: Icon(icon), label: labelWidget);
    }
  }
}
