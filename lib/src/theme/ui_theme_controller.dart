import 'package:flutter/material.dart';

/// A named color seed a user (or app) can pick to recolor the whole UI.
///
/// The [seed] is fed to `buildUiTheme(seed: …)`, which regenerates the entire
/// Material 3 [ColorScheme] from it — so one color drives primary / secondary /
/// surface / etc. The kit's *semantic* accents ([UiColors] success / warning /
/// danger / info) are deliberately **not** re-tinted by the seed: they stay
/// brand-independent so a "success" green never turns purple just because the
/// brand seed did.
@immutable
class UiThemePreset {
  const UiThemePreset({required this.name, required this.seed});

  /// Human-readable label shown next to the swatch in `UiThemePicker`.
  final String name;

  /// The Material 3 seed color the whole scheme is generated from.
  final Color seed;
}

/// The curated set of theme colors the kit ships. Consuming apps can present
/// these in `UiThemePicker`, or supply their own list. The first entry matches
/// [UiThemeController]'s default seed so "Ocean Blue" reads as selected on a
/// fresh launch. Palette sourced from the 2026 modern-UI color research
/// (blue / green / teal / violet / cyan).
const List<UiThemePreset> kUiThemePresets = <UiThemePreset>[
  UiThemePreset(name: 'Ocean Blue', seed: Color(0xFF1565C0)),
  UiThemePreset(name: 'Emerald', seed: Color(0xFF16A34A)),
  UiThemePreset(name: 'Teal', seed: Color(0xFF14B8A6)),
  UiThemePreset(name: 'Violet', seed: Color(0xFF8B5CF6)),
  UiThemePreset(name: 'Cyan', seed: Color(0xFF0891B2)),
];

/// Runtime, user-facing theme selection: the chosen color [seed] and the
/// light / dark / system [themeMode]. A consuming app wraps its `MaterialApp`
/// in a `ListenableBuilder(listenable: UiThemeController.instance)` and passes
/// `theme` / `darkTheme` / `themeMode` from this controller, so a selection
/// change recolors the whole app live.
///
/// Mirrors the `UiTuning` shape on purpose — a single global [instance]
/// ([ChangeNotifier] + private constructor + [reset]) — because there is
/// exactly one running app whose theme is being chosen at a time. Unlike
/// `UiTuning` (a debug-only geometry-tuning tool), this is a **release-facing**
/// mechanism meant to back a real user setting.
///
/// **Persistence is the consuming app's job.** The kit stays zero-dependency,
/// so it deliberately does not save the choice (that would need a storage
/// package). An app can read its own saved value at startup and assign it here,
/// and add a listener to persist on change — [seed] and [themeMode] are both
/// public for exactly that.
class UiThemeController extends ChangeNotifier {
  UiThemeController._();

  static final UiThemeController instance = UiThemeController._();

  /// The default seed, kept equal to `buildUiTheme`'s own default so the theme
  /// looks identical whether or not the controller is wired up.
  static const Color defaultSeed = Color(0xFF1565C0);

  Color _seed = defaultSeed;
  ThemeMode _themeMode = ThemeMode.system;

  /// The Material 3 seed color the whole scheme derives from.
  Color get seed => _seed;

  /// Light / dark / system. `system` follows the OS brightness via
  /// `MaterialApp.themeMode` — no extra wiring needed in the app.
  ThemeMode get themeMode => _themeMode;

  set seed(Color value) {
    if (value == _seed) return;
    _seed = value;
    notifyListeners();
  }

  set themeMode(ThemeMode value) {
    if (value == _themeMode) return;
    _themeMode = value;
    notifyListeners();
  }

  /// Convenience: adopt a preset's [UiThemePreset.seed].
  void selectPreset(UiThemePreset preset) => seed = preset.seed;

  /// Restores the default seed + [ThemeMode.system]. Also the hook tests use in
  /// `setUp`/`tearDown` so a mutation in one test can't leak into the next
  /// (the singleton is shared within a test file).
  void reset() {
    _seed = defaultSeed;
    _themeMode = ThemeMode.system;
    notifyListeners();
  }
}
