import 'package:flutter/material.dart';

import '../theme/ui_colors.dart';
import '../theme/ui_radius.dart';
import '../theme/ui_spacing.dart';

/// Severity of a [UiBanner], mapped to [UiColors] and a default icon.
enum UiBannerSeverity { info, warning, error, success }

/// A full-width inline message block (icon + text) tinted by [severity] from
/// the semantic [UiColors] tokens. Use for non-modal status/error messaging.
class UiBanner extends StatelessWidget {
  const UiBanner({
    required this.message,
    this.severity = UiBannerSeverity.info,
    this.icon,
    super.key,
  });

  const UiBanner.info(this.message, {this.icon, super.key})
      : severity = UiBannerSeverity.info;
  const UiBanner.warning(this.message, {this.icon, super.key})
      : severity = UiBannerSeverity.warning;
  const UiBanner.error(this.message, {this.icon, super.key})
      : severity = UiBannerSeverity.error;
  const UiBanner.success(this.message, {this.icon, super.key})
      : severity = UiBannerSeverity.success;

  final String message;
  final UiBannerSeverity severity;

  /// Overrides the default icon for the [severity].
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final UiColors colors = context.uiColors;
    final (Color color, IconData defaultIcon) = switch (severity) {
      UiBannerSeverity.info => (colors.info, Icons.info_outline),
      UiBannerSeverity.warning => (colors.warning, Icons.warning_amber_outlined),
      UiBannerSeverity.error => (colors.danger, Icons.error_outline),
      UiBannerSeverity.success => (colors.success, Icons.check_circle_outline),
    };

    return Container(
      width: double.infinity,
      padding: UiSpacing.allMd,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: UiRadius.brMd,
        border: Border.all(color: color.withValues(alpha: 0.40)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon ?? defaultIcon, color: color, size: 20),
          UiSpacing.gapHSm,
          Expanded(
            child: Text(
              message,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: color),
            ),
          ),
        ],
      ),
    );
  }
}
