import 'package:flutter/material.dart';

import '../theme/ui_typography.dart';

/// The typographic role of a [UiText], mapped to a Material 3 [TextTheme] slot
/// (or the kit's monospace style). Keeps call sites from reaching into
/// `Theme.of(context).textTheme.*` by hand and picking inconsistent slots.
enum UiTextRole {
  /// Section / card heading — `titleMedium`.
  title,

  /// Default running text — `bodyMedium`.
  body,

  /// Dense metadata / form labels — `labelLarge`.
  label,

  /// De-emphasised caption — `bodySmall`, tinted with the theme's disabled color.
  caption,

  /// Tabular / raw-data readout — [UiTypography.mono] over `bodyMedium`.
  mono,
}

/// A thin typography atom: renders [data] in the [role]'s themed style. Prefer
/// this over a bare `Text` with a hand-picked `textTheme` slot so headings,
/// body, labels, and captions stay consistent across apps.
class UiText extends StatelessWidget {
  const UiText(
    this.data, {
    this.role = UiTextRole.body,
    this.color,
    this.maxLines,
    this.overflow,
    this.textAlign,
    super.key,
  });

  /// Section / card heading.
  const UiText.title(String data, {Key? key})
      : this(data, role: UiTextRole.title, key: key);

  /// De-emphasised caption.
  const UiText.caption(String data, {Key? key})
      : this(data, role: UiTextRole.caption, key: key);

  /// Dense metadata / form label.
  const UiText.label(String data, {Key? key})
      : this(data, role: UiTextRole.label, key: key);

  /// Tabular / raw-data readout in a monospace style.
  const UiText.mono(String data, {Key? key})
      : this(data, role: UiTextRole.mono, key: key);

  final String data;
  final UiTextRole role;

  /// Overrides the role's default color (`null` keeps the themed color).
  final Color? color;
  final int? maxLines;
  final TextOverflow? overflow;
  final TextAlign? textAlign;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final TextTheme t = theme.textTheme;
    final TextStyle? base = switch (role) {
      UiTextRole.title => t.titleMedium,
      UiTextRole.body => t.bodyMedium,
      UiTextRole.label => t.labelLarge,
      UiTextRole.caption =>
        t.bodySmall?.copyWith(color: theme.disabledColor),
      UiTextRole.mono => t.bodyMedium?.merge(UiTypography.mono),
    };
    return Text(
      data,
      style: color == null ? base : base?.copyWith(color: color),
      maxLines: maxLines,
      overflow: overflow,
      textAlign: textAlign,
    );
  }
}
