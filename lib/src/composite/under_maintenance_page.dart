import 'package:flutter/material.dart';

import '../theme/ui_sizing.dart';
import '../theme/ui_spacing.dart';

/// Full-page placeholder for a feature that is planned but not yet available
/// (e.g. printer / scanner / camera tabs, or an unimplemented preview panel).
/// Renders a centered card with the feature icon, its title, and an
/// "Under maintenance" caption.
///
/// Domain-free and token-based (no hardcoded colors/sizes), so it is reusable
/// across projects.
class UnderMaintenancePage extends StatelessWidget {
  const UnderMaintenancePage({
    required this.icon,
    required this.title,
    super.key,
  });

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(UiSpacing.xl),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 360),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(UiSpacing.xl),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Icon(icon, size: UiSizing.iconLg, color: theme.disabledColor),
                  UiSpacing.gapVMd,
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleMedium,
                  ),
                  UiSpacing.gapVXs,
                  Text(
                    'Under maintenance',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodySmall
                        ?.copyWith(color: theme.disabledColor),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
