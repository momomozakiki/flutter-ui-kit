import 'package:flutter/material.dart';

import '../theme/ui_spacing.dart';
import '../theme/ui_tuning.dart';

/// One selectable entry in a [UiRadioGroup].
@immutable
class UiRadioItem<T> {
  const UiRadioItem({required this.value, required this.label, this.tooltip});

  final T value;
  final String label;

  /// Optional explanatory message shown on hover / long-press for this option.
  final String? tooltip;
}

/// A single radio button with a tappable trailing [label]. Must sit inside a
/// [UiRadioGroup] (or a Material `RadioGroup`) ancestor, which owns the selected
/// value and the change callback — this atom carries only its own [value]
/// (Flutter 3.32+ API; the old `groupValue`/`onChanged` on `Radio` is
/// deprecated).
///
/// Prefer [UiRadioGroup] with `items:` for the common case; reach for a bare
/// [UiRadio] only when you need a custom layout around each option.
class UiRadio<T> extends StatelessWidget {
  const UiRadio({
    required this.value,
    required this.label,
    this.height,
    this.tooltip,
    super.key,
  });

  final T value;
  final String label;

  /// Overrides the shared control height (default `null` reads
  /// `UiTuning.instance.radioHeight`, itself seeded from the shared
  /// `UiSizing.controlHeight` — see `UiTuning`).
  final double? height;

  /// Optional explanatory message shown on hover (desktop) / long-press (touch).
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    // Tapping either the radio or the label selects it; the ancestor RadioGroup
    // owns the actual state change, so we forward the label tap to its registry
    // rather than holding an onChanged of our own.
    final ValueChanged<T?>? groupOnChanged =
        RadioGroup.maybeOf<T>(context)?.onChanged;
    final Widget radio = SizedBox(
      // Fixed height so a radio row lines up with dropdowns / fields / buttons /
      // checkboxes in the same layout by default (see UiTuning.radioHeight).
      height: height ?? UiTuning.instance.radioHeight,
      child: InkWell(
        borderRadius: BorderRadius.circular(4),
        onTap: groupOnChanged == null ? null : () => groupOnChanged(value),
        child: Padding(
          padding: const EdgeInsets.only(right: UiSpacing.sm),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Radio<T>(
                value: value,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              UiSpacing.gapHXs,
              Text(label),
            ],
          ),
        ),
      ),
    );
    if (tooltip == null || tooltip!.isEmpty) return radio;
    return Tooltip(
      message: tooltip!,
      triggerMode: TooltipTriggerMode.longPress,
      child: radio,
    );
  }
}

/// A group of radio buttons sharing one selected [groupValue]. Owns the change
/// callback for every [UiRadio] beneath it via Material's `RadioGroup`. Pass
/// `onChanged: null` to disable the whole group.
///
/// This is the ergonomic API (mirrors `UiDropdown` with `items:`); the group is
/// stateless — the caller owns [groupValue] and updates it in [onChanged].
class UiRadioGroup<T> extends StatelessWidget {
  const UiRadioGroup({
    required this.groupValue,
    required this.items,
    required this.onChanged,
    this.axis = Axis.vertical,
    this.height,
    super.key,
  });

  final T? groupValue;
  final List<UiRadioItem<T>> items;
  final ValueChanged<T?>? onChanged;

  /// Lay the options out in a column (default) or a row.
  final Axis axis;

  /// Per-radio height override forwarded to each [UiRadio].
  final double? height;

  @override
  Widget build(BuildContext context) {
    final bool enabled = onChanged != null;
    final List<Widget> children = items
        .map((UiRadioItem<T> it) => UiRadio<T>(
              value: it.value,
              label: it.label,
              tooltip: it.tooltip,
              height: height,
            ))
        .toList();
    final Widget layout = axis == Axis.vertical
        ? Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: children,
          )
        : Row(mainAxisSize: MainAxisSize.min, children: children);

    // RadioGroup requires a non-null onChanged; when disabled, swallow the
    // callback and grey the options out via the ancestor's enabled flag.
    return RadioGroup<T>(
      groupValue: groupValue,
      onChanged: enabled ? onChanged! : (_) {},
      child: enabled
          ? layout
          : IgnorePointer(
              child: Opacity(opacity: 0.38, child: layout),
            ),
    );
  }
}
