import 'package:flutter/material.dart';

import '../theme/ui_spacing.dart';

/// A slider for choosing a numeric [value] in `[min, max]`. Pass `onChanged:
/// null` to disable. Optionally split the track into [divisions] discrete stops,
/// show a leading [label], and/or a trailing numeric readout ([showValue]).
///
/// Unlike the other form controls this atom does **not** take a `height`
/// override: a Material [Slider] reserves a ~48px thumb-overlay footprint, so
/// pinning it into the shorter shared control height would clip the overlay.
class UiSlider extends StatelessWidget {
  const UiSlider({
    required this.value,
    required this.onChanged,
    this.min = 0.0,
    this.max = 1.0,
    this.divisions,
    this.label,
    this.showValue = false,
    this.tooltip,
    super.key,
  });

  final double value;
  final ValueChanged<double>? onChanged;
  final double min;
  final double max;

  /// Number of discrete stops; `null` gives a continuous track.
  final int? divisions;

  /// Optional leading caption shown before the track.
  final String? label;

  /// When true, shows the current [value] as a trailing readout.
  final bool showValue;

  /// Optional explanatory message shown on hover (desktop) / long-press (touch).
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final Widget slider = Slider(
      value: value.clamp(min, max),
      min: min,
      max: max,
      divisions: divisions,
      // The value's own bubble when dragging a divided slider.
      label: divisions == null ? null : value.toStringAsFixed(0),
      onChanged: onChanged,
    );
    final List<Widget> row = <Widget>[
      if (label != null) ...[
        Text(label!, style: Theme.of(context).textTheme.labelLarge),
        UiSpacing.gapHSm,
      ],
      Expanded(child: slider),
      if (showValue) ...[
        UiSpacing.gapHSm,
        Text(value.toStringAsFixed(divisions == null ? 2 : 0)),
      ],
    ];
    final Widget content = row.length == 1
        ? slider
        : Row(mainAxisSize: MainAxisSize.min, children: row);
    if (tooltip == null || tooltip!.isEmpty) return content;
    return Tooltip(
      message: tooltip!,
      triggerMode: TooltipTriggerMode.longPress,
      child: content,
    );
  }
}
