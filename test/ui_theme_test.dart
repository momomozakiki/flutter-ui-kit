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
