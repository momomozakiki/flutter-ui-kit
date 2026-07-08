import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/ui_spacing.dart';
import '../theme/ui_tuning.dart';

/// Debug-only live sizing panel: one slider per [UiTuning] field, so control
/// height / spacing / chip padding / nav rail width can be dialed in while the
/// app is running instead of iterated blindly over screenshots. Wrap the host
/// `MaterialApp` in an `AnimatedBuilder(animation: UiTuning.instance, ...)` so
/// dragging a slider here re-themes the whole app live.
///
/// Never wire this behind anything but a `kDebugMode` gate at the call site —
/// it is a development tool, not a user-facing settings screen.
class UiTuningPanel extends StatefulWidget {
  const UiTuningPanel({super.key});

  @override
  State<UiTuningPanel> createState() => _UiTuningPanelState();
}

class _UiTuningPanelState extends State<UiTuningPanel> {
  @override
  void initState() {
    super.initState();
    UiTuning.instance.addListener(_onTuningChanged);
  }

  @override
  void dispose() {
    UiTuning.instance.removeListener(_onTuningChanged);
    super.dispose();
  }

  void _onTuningChanged() => setState(() {});

  void _copyAsCode() {
    final t = UiTuning.instance;
    final snippet = '''
// ui_sizing.dart
static const double touchTarget = ${t.controlHeight.toStringAsFixed(0)};
static const double controlHeight = ${t.controlHeight.toStringAsFixed(0)};

// ui_spacing.dart
static const double xs = ${t.spacingXs.toStringAsFixed(0)};
static const double sm = ${t.spacingSm.toStringAsFixed(0)};
static const double md = ${t.spacingMd.toStringAsFixed(0)};
static const double lg = ${t.spacingLg.toStringAsFixed(0)};

// quick_command_bar.dart chip horizontal padding
${t.chipPaddingH.toStringAsFixed(0)}

// main.dart NavigationRail minWidth
${t.navRailWidth.toStringAsFixed(0)}
''';
    Clipboard.setData(ClipboardData(text: snippet));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Copied current values as code')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = UiTuning.instance;
    return Drawer(
      child: SafeArea(
        child: ListView(
          padding: UiSpacing.allMd,
          children: [
            Text('Design Tuning', style: Theme.of(context).textTheme.titleMedium),
            UiSpacing.gapVSm,
            Text(
              'Debug-only. Drag to adjust live; "Copy as code" once you like it.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            UiSpacing.gapVMd,
            _slider(
              label: 'Control height',
              value: t.controlHeight,
              min: 28,
              max: 56,
              onChanged: (v) => t.controlHeight = v,
            ),
            _slider(
              label: 'Spacing xs',
              value: t.spacingXs,
              min: 0,
              max: 16,
              onChanged: (v) => t.spacingXs = v,
            ),
            _slider(
              label: 'Spacing sm',
              value: t.spacingSm,
              min: 0,
              max: 20,
              onChanged: (v) => t.spacingSm = v,
            ),
            _slider(
              label: 'Spacing md',
              value: t.spacingMd,
              min: 0,
              max: 28,
              onChanged: (v) => t.spacingMd = v,
            ),
            _slider(
              label: 'Spacing lg',
              value: t.spacingLg,
              min: 0,
              max: 32,
              onChanged: (v) => t.spacingLg = v,
            ),
            _slider(
              label: 'Chip horizontal padding',
              value: t.chipPaddingH,
              min: 0,
              max: 20,
              onChanged: (v) => t.chipPaddingH = v,
            ),
            _slider(
              label: 'Nav rail width',
              value: t.navRailWidth,
              min: 40,
              max: 96,
              onChanged: (v) => t.navRailWidth = v,
            ),
            UiSpacing.gapVMd,
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: t.reset,
                    child: const Text('Reset'),
                  ),
                ),
                UiSpacing.gapHSm,
                Expanded(
                  child: FilledButton(
                    onPressed: _copyAsCode,
                    child: const Text('Copy as code'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _slider({
    required String label,
    required double value,
    required double min,
    required double max,
    required ValueChanged<double> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$label: ${value.toStringAsFixed(0)}'),
        Slider(
          value: value.clamp(min, max),
          min: min,
          max: max,
          divisions: (max - min).round(),
          onChanged: onChanged,
        ),
      ],
    );
  }
}
