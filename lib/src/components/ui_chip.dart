import 'package:flutter/material.dart';

import '../theme/ui_spacing.dart';
import '../theme/ui_tuning.dart';

/// A generic, interactive chip for input / filter / choice patterns — distinct
/// from [UiStatusChip] (a passive colored status pill). Supports selection
/// ([selected] + [onSelected]) and/or a delete affordance ([onDeleted]), with an
/// optional leading [avatar].
///
/// Height note: a Material chip has no direct height lever — wrapping it in a
/// `SizedBox(height:)` sizes the *slot*, not the pill. So this atom fixes the
/// height by sizing the chip's **label** to [UiTuning.chipHeight] and zeroing the
/// chip's vertical padding, with `shrinkWrap` tap-target sizing so the pill's
/// painted height equals that value.
class UiChip extends StatelessWidget {
  const UiChip({
    required this.label,
    this.selected = false,
    this.onSelected,
    this.onDeleted,
    this.avatar,
    this.height,
    this.tooltip,
    super.key,
  });

  final String label;
  final bool selected;
  final ValueChanged<bool>? onSelected;

  /// When non-null, shows a trailing delete "✕" and calls this on tap.
  final VoidCallback? onDeleted;

  /// Optional leading widget (e.g. a [UiAvatar] or an [Icon]).
  final Widget? avatar;

  /// Overrides the shared chip height (default `null` reads
  /// `UiTuning.instance.chipHeight`, seeded from `UiSizing.controlHeight`).
  final double? height;

  /// Optional explanatory message shown on hover / long-press.
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final double h = height ?? UiTuning.instance.chipHeight;
    // Fix the pill height by sizing the label, not by wrapping the chip.
    final Widget sizedLabel = SizedBox(
      height: h,
      child: Center(child: Text(label, maxLines: 1)),
    );
    return InputChip(
      label: sizedLabel,
      avatar: avatar,
      selected: selected,
      onSelected: onSelected,
      onDeleted: onDeleted,
      tooltip: tooltip,
      // Zero the chip's own vertical padding so the label's height drives the
      // pill; keep a little horizontal breathing room.
      padding: const EdgeInsets.symmetric(horizontal: UiSpacing.xs),
      labelPadding: const EdgeInsets.symmetric(horizontal: UiSpacing.xs),
      // shrinkWrap so the chip doesn't reserve the 48px padded tap target and
      // report an inflated layout height past the painted pill.
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }
}
