import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_ui_kit/flutter_ui_kit.dart';

void main() {
  setUp(UiTuning.instance.reset);
  tearDown(UiTuning.instance.reset);

  Widget host(Widget child) =>
      MaterialApp(theme: buildUiTheme(), home: Scaffold(body: Center(child: child)));

  testWidgets('renders at the shared control height', (tester) async {
    await tester.pumpWidget(host(
      UiSwitch(label: 'Wifi', value: true, onChanged: (_) {}),
    ));
    final double height = tester.getSize(find.byType(UiSwitch)).height;
    expect(height, UiSizing.controlHeight);
  });

  testWidgets('height override renders at that height', (tester) async {
    await tester.pumpWidget(host(
      UiSwitch(label: 'Wifi', value: true, height: 50, onChanged: (_) {}),
    ));
    final double height = tester.getSize(find.byType(UiSwitch)).height;
    expect(height, 50);
  });

  testWidgets('tapping the label toggles; disabled when onChanged is null',
      (tester) async {
    bool? changed;
    await tester.pumpWidget(host(
      UiSwitch(label: 'Dark mode', value: false, onChanged: (v) => changed = v),
    ));
    await tester.tap(find.text('Dark mode'));
    expect(changed, isTrue);
  });
}
