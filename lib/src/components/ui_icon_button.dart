import 'package:flutter/material.dart';

import '../theme/ui_sizing.dart';
import '../theme/ui_tone.dart';

/// Visual emphasis of a [UiIconButton], mirroring Material's icon-button styles.
enum UiIconButtonVariant {
  /// Transparent, low emphasis (the default toolbar icon).
  standard,

  /// Filled background, high emphasis.
  filled,

  /// Outlined, medium emphasis.
  outlined,
}

/// An icon-only button atom with three emphasis [variant]s and an optional
/// semantic [tone] (success / danger) pulled from the theme tokens — never a
/// hardcoded color. Pass `onPressed: null` to disable.
///
/// Prefer this over a raw `IconButton` so emphasis and tone stay consistent.
class UiIconButton extends StatelessWidget {
  const UiIconButton({
    required this.icon,
    required this.onPressed,
    this.tooltip,
    this.variant = UiIconButtonVariant.standard,
    this.tone = UiTone.normal,
    this.size,
    super.key,
  });

  final IconData icon;
  final VoidCallback? onPressed;

  /// Explanatory message shown on hover / long-press (also the a11y label).
  final String? tooltip;

  final UiIconButtonVariant variant;
  final UiTone tone;

  /// Icon size in logical pixels. Defaults to [UiSizing.iconMd].
  final double? size;

  @override
  Widget build(BuildContext context) {
    final Color? fg = tone.foreground(context);
    final Widget iconWidget = Icon(icon, size: size ?? UiSizing.iconMd);
    // A toned filled button needs the background tinted too; standard/outlined
    // just recolor the foreground.
    final ButtonStyle? style = fg == null
        ? null
        : (variant == UiIconButtonVariant.filled
            ? IconButton.styleFrom(backgroundColor: fg, foregroundColor: null)
            : IconButton.styleFrom(foregroundColor: fg));
    switch (variant) {
      case UiIconButtonVariant.standard:
        return IconButton(
          icon: iconWidget,
          onPressed: onPressed,
          tooltip: tooltip,
          color: fg,
        );
      case UiIconButtonVariant.filled:
        return IconButton.filled(
          icon: iconWidget,
          onPressed: onPressed,
          tooltip: tooltip,
          style: style,
        );
      case UiIconButtonVariant.outlined:
        return IconButton.outlined(
          icon: iconWidget,
          onPressed: onPressed,
          tooltip: tooltip,
          style: style,
        );
    }
  }
}
