import 'package:flutter/material.dart';

import '../theme/ui_spacing.dart';

/// A checkbox with a tappable trailing [label] (tapping the label toggles it
/// too). Pass `onChanged: null` to disable. Provide [tooltip] to surface an
/// explanatory message on hover (desktop) or long-press (touch).
class UiCheckbox extends StatelessWidget {
  const UiCheckbox({
    required this.label,
    required this.value,
    required this.onChanged,
    this.tooltip,
    super.key,
  });

  final String label;
  final bool value;
  final ValueChanged<bool>? onChanged;

  /// Optional explanatory message shown on hover (desktop) / long-press (touch).
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final bool enabled = onChanged != null;
    final Widget checkbox = InkWell(
      onTap: enabled ? () => onChanged!(!value) : null,
      borderRadius: BorderRadius.circular(4),
      child: Padding(
        // Trailing right padding so the label isn't flush against the
        // component edge (the checkbox's tap target already spaces the left).
        padding: const EdgeInsets.fromLTRB(
            0, UiSpacing.xs, UiSpacing.sm, UiSpacing.xs),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Checkbox(
              value: value,
              onChanged: enabled ? (bool? v) => onChanged!(v ?? false) : null,
            ),
            UiSpacing.gapHXs,
            Text(label),
          ],
        ),
      ),
    );
    if (tooltip == null || tooltip!.isEmpty) return checkbox;
    return Tooltip(
      message: tooltip!,
      triggerMode: TooltipTriggerMode.longPress,
      child: checkbox,
    );
  }
}
