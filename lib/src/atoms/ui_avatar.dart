import 'package:flutter/material.dart';

import '../theme/ui_sizing.dart';

/// A circular avatar showing [initials] (e.g. "AB") or a fallback [icon], tinted
/// from the theme's `colorScheme` — never a hardcoded color. Pass an
/// [image] provider to show a picture instead (SDK-level, so no package
/// dependency is added).
///
/// Exactly one of [image] / [initials] / [icon] is used, in that priority; if
/// none is given, a person icon is shown.
class UiAvatar extends StatelessWidget {
  const UiAvatar({
    this.initials,
    this.icon,
    this.image,
    this.size = UiSizing.iconLg,
    super.key,
  });

  /// Short text (typically 1–2 letters) shown when there is no [image].
  final String? initials;

  /// Fallback glyph shown when there is neither [image] nor [initials].
  final IconData? icon;

  /// Optional picture; takes priority over [initials] / [icon].
  final ImageProvider? image;

  /// Diameter in logical pixels. Defaults to [UiSizing.iconLg].
  final double size;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final double radius = size / 2;
    if (image != null) {
      return CircleAvatar(radius: radius, backgroundImage: image);
    }
    final Widget content = initials != null && initials!.isNotEmpty
        ? Text(
            initials!,
            style: TextStyle(
              color: scheme.onPrimaryContainer,
              // Scale the glyph to the avatar so text fills it proportionally.
              fontSize: size * 0.4,
              fontWeight: FontWeight.w600,
            ),
          )
        : Icon(
            icon ?? Icons.person,
            size: size * 0.6,
            color: scheme.onPrimaryContainer,
          );
    return CircleAvatar(
      radius: radius,
      backgroundColor: scheme.primaryContainer,
      child: content,
    );
  }
}
