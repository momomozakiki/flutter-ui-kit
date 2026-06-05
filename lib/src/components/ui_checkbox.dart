import 'package:flutter/material.dart';

import '../theme/ui_spacing.dart';

/// A checkbox with a tappable trailing [label] (tapping the label toggles it
/// too). Pass `onChanged: null` to disable.
class UiCheckbox extends StatelessWidget {
  const UiCheckbox({
    required this.label,
    required this.value,
    required this.onChanged,
    super.key,
  });

  final String label;
  final bool value;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    final bool enabled = onChanged != null;
    return InkWell(
      onTap: enabled ? () => onChanged!(!value) : null,
      borderRadius: BorderRadius.circular(4),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: UiSpacing.xs),
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
  }
}
