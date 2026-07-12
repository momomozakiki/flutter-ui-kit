import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/ui_spacing.dart';
import '../theme/ui_tuning.dart';

// Tier: organism — owns local UI state (slider values via StatefulWidget); no
// business logic or data fetching.

/// Debug-only live sizing panel: one slider per [UiTuning] field, so control
/// height / spacing / font / per-component height / chip padding / nav rail
/// width can be dialed in while the app is running instead of iterated
/// blindly over screenshots. Shown inside a `UiTuningOverlay` (a movable,
/// non-modal floating panel) rather than a `Drawer`, so the app underneath
/// stays visible and interactive while tuning.
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
static const double chipPaddingH = ${t.chipPaddingH.toStringAsFixed(0)};
static const double navRailWidth = ${t.navRailWidth.toStringAsFixed(0)};

// ui_spacing.dart
static const double xs = ${t.spacingXs.toStringAsFixed(0)};
static const double sm = ${t.spacingSm.toStringAsFixed(0)};
static const double md = ${t.spacingMd.toStringAsFixed(0)};
static const double lg = ${t.spacingLg.toStringAsFixed(0)};

// ui_typography.dart
static const double fontScale = ${t.fontScale.toStringAsFixed(2)};
// font family: ${t.fontFamily ?? '(theme default)'}

// Per-component heights (UiTuning defaults — bake into the relevant call
// sites' `height:` params, or leave as UiTuning-driven if keeping them live)
// dropdownHeight        = ${t.dropdownHeight.toStringAsFixed(0)}
// textFieldHeight       = ${t.textFieldHeight.toStringAsFixed(0)}
// tokenGridFieldHeight  = ${t.tokenGridFieldHeight.toStringAsFixed(0)}
// buttonHeight          = ${t.buttonHeight.toStringAsFixed(0)}
// checkboxHeight        = ${t.checkboxHeight.toStringAsFixed(0)}
// chipHeight            = ${t.chipHeight.toStringAsFixed(0)}
''';
    Clipboard.setData(ClipboardData(text: snippet));
    ScaffoldMessenger.maybeOf(context)?.showSnackBar(
      const SnackBar(content: Text('Copied current values as code')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = UiTuning.instance;
    return ListView(
      padding: UiSpacing.allMd,
      children: [
        Text('Shared', style: Theme.of(context).textTheme.labelLarge),
        UiSpacing.gapVSm,
        _slider(
          label: 'Control height (shared default)',
          value: t.controlHeight,
          min: 24,
          max: 60,
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
          max: 24,
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
          label: 'Nav rail width',
          value: t.navRailWidth,
          min: 40,
          max: 96,
          onChanged: (v) => t.navRailWidth = v,
        ),
        UiSpacing.gapVMd,
        Text('Text', style: Theme.of(context).textTheme.labelLarge),
        UiSpacing.gapVSm,
        _slider(
          label: 'Font scale',
          value: t.fontScale,
          min: 0.7,
          max: 1.4,
          decimals: 2,
          onChanged: (v) => t.fontScale = v,
        ),
        Text('Font family', style: Theme.of(context).textTheme.bodyMedium),
        DropdownButton<String?>(
          isExpanded: true,
          value: t.fontFamily,
          items: [
            for (final f in UiTuning.fontFamilyChoices)
              DropdownMenuItem<String?>(
                value: f,
                child: Text(f ?? '(theme default)'),
              ),
          ],
          onChanged: (v) => t.fontFamily = v,
        ),
        UiSpacing.gapVMd,
        Text('Per component', style: Theme.of(context).textTheme.labelLarge),
        Text(
          'Each starts equal to Control height above; move one to diverge it.',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        UiSpacing.gapVSm,
        _slider(
          label: 'Dropdown height',
          value: t.dropdownHeight,
          min: 24,
          max: 60,
          onChanged: (v) => t.dropdownHeight = v,
        ),
        _slider(
          label: 'Text field height',
          value: t.textFieldHeight,
          min: 24,
          max: 60,
          onChanged: (v) => t.textFieldHeight = v,
        ),
        _slider(
          label: 'Token grid field height',
          value: t.tokenGridFieldHeight,
          min: 24,
          max: 60,
          onChanged: (v) => t.tokenGridFieldHeight = v,
        ),
        _slider(
          label: 'Button height',
          value: t.buttonHeight,
          min: 24,
          max: 60,
          onChanged: (v) => t.buttonHeight = v,
        ),
        _slider(
          label: 'Checkbox height',
          value: t.checkboxHeight,
          min: 24,
          max: 60,
          onChanged: (v) => t.checkboxHeight = v,
        ),
        _slider(
          label: 'Chip height',
          value: t.chipHeight,
          min: 24,
          max: 60,
          onChanged: (v) => t.chipHeight = v,
        ),
        _slider(
          label: 'Chip horizontal padding',
          value: t.chipPaddingH,
          min: 0,
          max: 20,
          onChanged: (v) => t.chipPaddingH = v,
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
    );
  }

  Widget _slider({
    required String label,
    required double value,
    required double min,
    required double max,
    required ValueChanged<double> onChanged,
    int decimals = 0,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$label: ${value.toStringAsFixed(decimals)}'),
        Slider(
          value: value.clamp(min, max),
          min: min,
          max: max,
          divisions: decimals == 0
              ? (max - min).round()
              : ((max - min) * 20).round(),
          onChanged: onChanged,
        ),
      ],
    );
  }
}
