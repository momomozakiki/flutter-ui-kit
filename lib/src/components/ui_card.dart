import 'package:flutter/material.dart';

import '../theme/ui_radius.dart';
import '../theme/ui_spacing.dart';

/// A surface container: a themed [Card] with consistent rounding
/// ([UiRadius.brMd]) and default inner [padding], optionally tappable via
/// [onTap]. Use instead of a raw `Card` so elevation, shape, and padding stay
/// uniform across apps.
class UiCard extends StatelessWidget {
  const UiCard({
    required this.child,
    this.padding = UiSpacing.allMd,
    this.onTap,
    super.key,
  });

  final Widget child;

  /// Inner padding around [child]. Defaults to [UiSpacing.allMd].
  final EdgeInsetsGeometry padding;

  /// When non-null, the whole card becomes tappable with an ink ripple.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final Widget padded = Padding(padding: padding, child: child);
    return Card(
      shape: const RoundedRectangleBorder(borderRadius: UiRadius.brMd),
      clipBehavior: Clip.antiAlias,
      child: onTap == null
          ? padded
          : InkWell(onTap: onTap, child: padded),
    );
  }
}
