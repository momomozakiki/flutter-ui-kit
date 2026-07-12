import 'package:flutter/material.dart';

import '../theme/ui_spacing.dart';
import '../theme/ui_tuning.dart';

/// A switch (toggle) with a tappable trailing [label] (tapping the label toggles
/// it too). Pass `onChanged: null` to disable. Provide [tooltip] to surface an
/// explanatory message on hover (desktop) or long-press (touch).
///
/// The row mirrors [UiCheckbox] so a switch lines up with checkboxes, fields,
/// and buttons in the same layout by default.
class UiSwitch extends StatelessWidget {
  const UiSwitch({
    required this.label,
    required this.value,
    required this.onChanged,
    this.height,
    this.tooltip,
    super.key,
  });

  final String label;
  final bool value;
  final ValueChanged<bool>? onChanged;

  /// Overrides the shared control height (default `null` reads
  /// `UiTuning.instance.switchHeight`, itself seeded from the shared
  /// `UiSizing.controlHeight` — see `UiTuning`).
  final double? height;

  /// Optional explanatory message shown on hover (desktop) / long-press (touch).
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final bool enabled = onChanged != null;
    final Widget row = SizedBox(
      // Fixed height so a switch row lines up with dropdowns / fields / buttons /
      // checkboxes in the same layout by default (see UiTuning.switchHeight).
      height: height ?? UiTuning.instance.switchHeight,
      child: InkWell(
        onTap: enabled ? () => onChanged!(!value) : null,
        borderRadius: BorderRadius.circular(4),
        child: Padding(
          padding: const EdgeInsets.only(right: UiSpacing.sm),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Switch(
                value: value,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                onChanged: enabled ? onChanged : null,
              ),
              UiSpacing.gapHXs,
              Text(label),
            ],
          ),
        ),
      ),
    );
    if (tooltip == null || tooltip!.isEmpty) return row;
    return Tooltip(
      message: tooltip!,
      triggerMode: TooltipTriggerMode.longPress,
      child: row,
    );
  }
}
