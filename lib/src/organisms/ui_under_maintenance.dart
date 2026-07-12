import 'package:flutter/material.dart';

import '../atoms/ui_card.dart';
import '../theme/ui_sizing.dart';
import '../theme/ui_spacing.dart';

// Tier: organism — a full-screen composition (stateless here). Named without a
// `_page` suffix because page/template widgets live in consuming apps, not the kit.

/// Full-screen placeholder centered card: a feature icon, a [title], and a
/// caption ([subtitle]). The caption defaults to "Under maintenance" for the
/// not-yet-available case (printer / scanner / camera tabs, unimplemented
/// preview panels), but can be overridden to convey a different non-error state
/// — e.g. a feature that is ready but waiting on a precondition ("connect a
/// device").
///
/// Domain-free and token-based (no hardcoded colors/sizes), so it is reusable
/// across projects.
class UiUnderMaintenance extends StatelessWidget {
  const UiUnderMaintenance({
    required this.icon,
    required this.title,
    this.subtitle = 'Under maintenance',
    super.key,
  });

  final IconData icon;
  final String title;

  /// Caption under the [title]. Defaults to "Under maintenance".
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(UiSpacing.xl),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 360),
          child: UiCard(
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
                  subtitle,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: theme.disabledColor),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
