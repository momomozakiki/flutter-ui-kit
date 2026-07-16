import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_ui_kit/flutter_ui_kit.dart';

void main() {
  test('buildUiTheme installs the UiColors extension', () {
    final ThemeData light = buildUiTheme();
    expect(light.extension<UiColors>(), isNotNull);
    expect(light.useMaterial3, isTrue);

    final ThemeData dark = buildUiTheme(brightness: Brightness.dark);
    expect(dark.extension<UiColors>(), same(UiColors.dark));
  });

  test('UiColors.lerp returns a blended instance', () {
    final UiColors mid = UiColors.light.lerp(UiColors.dark, 0.5);
    expect(mid.danger, isNot(UiColors.light.danger));
  });

  test('a custom seed regenerates the ColorScheme primary', () {
    final ThemeData defaultSeed = buildUiTheme();
    final ThemeData emeraldSeed = buildUiTheme(seed: const Color(0xFF16A34A));
    // The seed drives the whole M3 scheme, so a different seed must yield a
    // different primary — this is the lever UiThemeController exposes at runtime.
    expect(emeraldSeed.colorScheme.primary,
        isNot(defaultSeed.colorScheme.primary));
  });

  test('the semantic UiColors extension is seed-independent', () {
    // Semantic accents stay brand-independent: changing the seed must NOT
    // change success/danger/etc.
    final ThemeData a = buildUiTheme(seed: const Color(0xFF16A34A));
    final ThemeData b = buildUiTheme(seed: const Color(0xFF8B5CF6));
    expect(a.extension<UiColors>(), same(UiColors.light));
    expect(b.extension<UiColors>(), same(UiColors.light));
  });

  testWidgets('context.uiColors resolves the themed extension', (tester) async {
    late UiColors resolved;
    await tester.pumpWidget(MaterialApp(
      theme: buildUiTheme(),
      home: Builder(builder: (context) {
        resolved = context.uiColors;
        return const SizedBox();
      }),
    ));
    expect(resolved, same(UiColors.light));
  });
}
