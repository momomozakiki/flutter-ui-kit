import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_ui_kit/flutter_ui_kit.dart';

void main() {
  // UiThemeController.instance is a global singleton; flutter test isolates each
  // test FILE in its own VM isolate, but tests WITHIN this file share it — reset
  // before/after each so one test's mutation can't leak into the next.
  setUp(UiThemeController.instance.reset);
  tearDown(UiThemeController.instance.reset);

  test('defaults are the default seed and system mode', () {
    final UiThemeController c = UiThemeController.instance;
    expect(c.seed, UiThemeController.defaultSeed);
    expect(c.themeMode, ThemeMode.system);
  });

  test('the default seed matches the first curated preset', () {
    expect(kUiThemePresets.first.seed, UiThemeController.defaultSeed);
  });

  test('setting seed mutates and notifies', () {
    final UiThemeController c = UiThemeController.instance;
    var notified = 0;
    c.addListener(() => notified++);

    c.seed = const Color(0xFF16A34A);

    expect(c.seed, const Color(0xFF16A34A));
    expect(notified, 1);
  });

  test('setting the same seed does not notify', () {
    final UiThemeController c = UiThemeController.instance;
    var notified = 0;
    c.addListener(() => notified++);

    c.seed = UiThemeController.defaultSeed; // unchanged

    expect(notified, 0);
  });

  test('setting themeMode mutates and notifies', () {
    final UiThemeController c = UiThemeController.instance;
    var notified = 0;
    c.addListener(() => notified++);

    c.themeMode = ThemeMode.dark;

    expect(c.themeMode, ThemeMode.dark);
    expect(notified, 1);
  });

  test('selectPreset adopts the preset seed', () {
    final UiThemeController c = UiThemeController.instance;
    const UiThemePreset emerald = UiThemePreset(
      name: 'Emerald',
      seed: Color(0xFF16A34A),
    );

    c.selectPreset(emerald);

    expect(c.seed, emerald.seed);
  });

  test('reset restores the default seed and system mode', () {
    final UiThemeController c = UiThemeController.instance;
    c.seed = const Color(0xFF8B5CF6);
    c.themeMode = ThemeMode.dark;

    c.reset();

    expect(c.seed, UiThemeController.defaultSeed);
    expect(c.themeMode, ThemeMode.system);
  });
}
