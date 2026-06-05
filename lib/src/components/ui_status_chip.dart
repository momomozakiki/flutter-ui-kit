import 'package:flutter/material.dart';

import '../theme/ui_colors.dart';
import '../theme/ui_radius.dart';
import '../theme/ui_spacing.dart';

/// Semantic meaning of a [UiStatusChip], mapped to [UiColors].
enum UiStatus { success, warning, danger, info, neutral }

/// A compact status pill: a colored dot plus a label, tinted by [status] from
/// the semantic [UiColors] tokens (no hardcoded greens/oranges at call sites).
class UiStatusChip extends StatelessWidget {
  const UiStatusChip({required this.label, required this.status, super.key});

  final String label;
  final UiStatus status;

  @override
  Widget build(BuildContext context) {
    final UiColors colors = context.uiColors;
    final Color color = switch (status) {
      UiStatus.success => colors.success,
      UiStatus.warning => colors.warning,
      UiStatus.danger => colors.danger,
      UiStatus.info => colors.info,
      UiStatus.neutral => colors.neutral,
    };

    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: UiSpacing.md, vertical: UiSpacing.xs),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: UiRadius.brLg,
        border: Border.all(color: color.withValues(alpha: 0.40)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          UiSpacing.gapHSm,
          Text(
            label,
            style:
                Theme.of(context).textTheme.labelLarge?.copyWith(color: color),
          ),
        ],
      ),
    );
  }
}
