import 'package:flutter/material.dart';

import '../theme/ui_sizing.dart';

/// The shape of a [UiProgressIndicator].
enum UiProgressShape {
  /// A spinning ring — good for indeterminate work in a compact slot.
  circular,

  /// A horizontal bar — good for determinate progress or a full-width busy
  /// indicator.
  linear,
}

/// A busy / progress indicator with a [circular] or [linear] shape. Leave
/// [value] null for the indeterminate (animated) state, or pass 0.0–1.0 for
/// determinate progress. Colors come from the theme.
class UiProgressIndicator extends StatelessWidget {
  const UiProgressIndicator({
    this.shape = UiProgressShape.circular,
    this.value,
    this.size,
    super.key,
  });

  /// Circular spinner. Optionally sized (diameter defaults to [UiSizing.iconMd]).
  const UiProgressIndicator.circular({double? value, double? size, Key? key})
      : this(
          shape: UiProgressShape.circular,
          value: value,
          size: size,
          key: key,
        );

  /// Full-width linear bar.
  const UiProgressIndicator.linear({double? value, Key? key})
      : this(shape: UiProgressShape.linear, value: value, key: key);

  final UiProgressShape shape;

  /// `null` = indeterminate; `0.0`–`1.0` = determinate progress.
  final double? value;

  /// For [circular], the diameter (defaults to [UiSizing.iconMd]). Ignored for
  /// [linear], which fills its parent's width.
  final double? size;

  @override
  Widget build(BuildContext context) {
    switch (shape) {
      case UiProgressShape.circular:
        final double d = size ?? UiSizing.iconMd;
        return SizedBox(
          width: d,
          height: d,
          child: CircularProgressIndicator(value: value),
        );
      case UiProgressShape.linear:
        return LinearProgressIndicator(value: value);
    }
  }
}
