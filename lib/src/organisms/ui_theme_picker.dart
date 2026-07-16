import 'package:flutter/material.dart';

import '../theme/ui_sizing.dart';
import '../theme/ui_spacing.dart';
import '../theme/ui_theme_controller.dart';

// Tier: organism — reads/writes the release-facing UiThemeController singleton
// and reflects its live state; no business logic or data fetching.

/// A drop-in settings control that lets an end user pick the UI's theme color
/// (from [presets]) and the light / dark / system [ThemeMode].
///
/// It reads and mutates [UiThemeController.instance] and rebuilds with it (via
/// a [ListenableBuilder]), so the current selection always shows correctly even
/// if the seed/mode is changed elsewhere. For the selection to actually recolor
/// the app, the host must wire `UiThemeController.instance` into its
/// `MaterialApp` — see the example app's `main.dart`.
///
/// Typically shown in a modal bottom sheet from an app-bar action, but it's a
/// plain widget and can be embedded anywhere.
class UiThemePicker extends StatelessWidget {
  const UiThemePicker({this.presets = kUiThemePresets, super.key});

  /// The color choices offered. Defaults to the kit's curated [kUiThemePresets];
  /// an app can pass its own list.
  final List<UiThemePreset> presets;

  @override
  Widget build(BuildContext context) {
    final UiThemeController controller = UiThemeController.instance;
    final TextTheme text = Theme.of(context).textTheme;
    return ListenableBuilder(
      listenable: controller,
      builder: (BuildContext context, _) {
        return Padding(
          padding: UiSpacing.allMd,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text('Theme color', style: text.labelLarge),
              UiSpacing.gapVSm,
              Wrap(
                spacing: UiSpacing.md,
                runSpacing: UiSpacing.md,
                children: <Widget>[
                  for (final UiThemePreset preset in presets)
                    _Swatch(
                      preset: preset,
                      selected: preset.seed == controller.seed,
                      onTap: () => controller.selectPreset(preset),
                    ),
                ],
              ),
              UiSpacing.gapVMd,
              Text('Appearance', style: text.labelLarge),
              UiSpacing.gapVSm,
              SegmentedButton<ThemeMode>(
                segments: const <ButtonSegment<ThemeMode>>[
                  ButtonSegment<ThemeMode>(
                    value: ThemeMode.light,
                    icon: Icon(Icons.light_mode),
                    label: Text('Light'),
                    tooltip: 'Light',
                  ),
                  ButtonSegment<ThemeMode>(
                    value: ThemeMode.dark,
                    icon: Icon(Icons.dark_mode),
                    label: Text('Dark'),
                    tooltip: 'Dark',
                  ),
                  ButtonSegment<ThemeMode>(
                    value: ThemeMode.system,
                    icon: Icon(Icons.brightness_auto),
                    label: Text('System'),
                    tooltip: 'Follow system',
                  ),
                ],
                selected: <ThemeMode>{controller.themeMode},
                showSelectedIcon: false,
                onSelectionChanged: (Set<ThemeMode> selection) =>
                    controller.themeMode = selection.first,
              ),
            ],
          ),
        );
      },
    );
  }
}

/// A single tappable color circle. Filled with the preset's own [seed] — the
/// one legitimate raw-`Color` use under the token-only rule, because here the
/// color IS the data being previewed, not a style value. The selection ring and
/// check mark come from the theme's `ColorScheme` (tokens), not hardcoded.
class _Swatch extends StatelessWidget {
  const _Swatch({
    required this.preset,
    required this.selected,
    required this.onTap,
  });

  final UiThemePreset preset;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return Tooltip(
      message: preset.name,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Container(
          width: UiSizing.iconLg,
          height: UiSizing.iconLg,
          decoration: BoxDecoration(
            color: preset.seed, // color-as-data; see class doc.
            shape: BoxShape.circle,
            border: Border.all(
              color: selected ? scheme.onSurface : scheme.outlineVariant,
              width: selected ? 3 : 1,
            ),
          ),
          child: selected
              ? Icon(
                  Icons.check,
                  size: UiSizing.iconSm,
                  color: scheme.onPrimary,
                )
              : null,
        ),
      ),
    );
  }
}
