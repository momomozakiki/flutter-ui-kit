import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_ui_kit/flutter_ui_kit.dart';

void main() {
  // UiThemePicker reads/writes the global UiThemeController singleton — reset so
  // one test's selection can't leak into the next.
  setUp(UiThemeController.instance.reset);
  tearDown(UiThemeController.instance.reset);

  Future<void> pumpPicker(WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      theme: buildUiTheme(),
      home: const Scaffold(body: UiThemePicker()),
    ));
  }

  testWidgets('tapping a swatch updates the controller seed', (tester) async {
    await pumpPicker(tester);

    await tester.tap(find.byTooltip('Emerald'));
    await tester.pump();

    expect(UiThemeController.instance.seed, const Color(0xFF16A34A));
  });

  testWidgets('selecting the Dark segment updates themeMode', (tester) async {
    await pumpPicker(tester);
    expect(UiThemeController.instance.themeMode, ThemeMode.system);

    await tester.tap(find.text('Dark'));
    await tester.pump();

    expect(UiThemeController.instance.themeMode, ThemeMode.dark);
  });

  testWidgets('exactly one swatch shows the selected check mark',
      (tester) async {
    await pumpPicker(tester);

    // Fresh state: the default seed (Ocean Blue, the first preset) is selected.
    expect(find.byIcon(Icons.check), findsOneWidget);

    await tester.tap(find.byTooltip('Teal'));
    await tester.pump();

    // Still exactly one selection indicator after switching.
    expect(find.byIcon(Icons.check), findsOneWidget);
  });
}
