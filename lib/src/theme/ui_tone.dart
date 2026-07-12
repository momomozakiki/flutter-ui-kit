import 'package:flutter/material.dart';

import 'ui_colors.dart';

/// A shared semantic color tone that any component can layer on top of its own
/// variant, resolved from the semantic [UiColors] extension rather than a
/// hardcoded color.
///
/// Lives in `theme/` (a token) rather than inside any one component so multiple
/// components (e.g. `UiIconButton`) can express tone by depending on the theme
/// layer — never on another component. [UiButton]'s own `UiButtonTone` predates
/// this and is kept for API stability; new components should use [UiTone].
enum UiTone {
  /// The theme's default (primary) color — no semantic tint.
  normal,

  /// A positive / connected / success tint from [UiColors.success].
  success,

  /// A destructive / error tint from [UiColors.danger].
  danger,
}

/// Resolves a [UiTone] to its foreground color, or `null` for [UiTone.normal]
/// (let the widget's theme default stand).
extension UiToneX on UiTone {
  Color? foreground(BuildContext context) {
    final UiColors colors = context.uiColors;
    return switch (this) {
      UiTone.normal => null,
      UiTone.success => colors.success,
      UiTone.danger => colors.danger,
    };
  }
}
