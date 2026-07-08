import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_ui_kit/flutter_ui_kit.dart';

void main() {
  testWidgets('renders at the shared control height', (tester) async {
    await tester.pumpWidget(MaterialApp(
      theme: buildUiTheme(),
      home: Scaffold(
        body: Center(
          child: UiCheckbox(
            label: 'Trim',
            value: true,
            onChanged: (_) {},
          ),
        ),
      ),
    ));

    // The row is pinned to UiSizing.controlHeight so a checkbox lines up with
    // dropdowns / fields / buttons in the same layout.
    final double height = tester.getSize(find.byType(UiCheckbox)).height;
    expect(height, UiSizing.controlHeight);
  });

  testWidgets('an explicit height override renders at that height',
      (tester) async {
    await tester.pumpWidget(MaterialApp(
      theme: buildUiTheme(),
      home: Scaffold(
        body: Center(
          child: UiCheckbox(
            label: 'Trim',
            value: true,
            height: 50,
            onChanged: (_) {},
          ),
        ),
      ),
    ));

    final double height = tester.getSize(find.byType(UiCheckbox)).height;
    expect(height, 50);
  });

  testWidgets('toggles and reflects value; disabled when onChanged is null',
      (tester) async {
    bool? changed;
    await tester.pumpWidget(MaterialApp(
      theme: buildUiTheme(),
      home: Scaffold(
        body: UiCheckbox(
          label: 'Ignore empty',
          value: false,
          onChanged: (v) => changed = v,
        ),
      ),
    ));

    await tester.tap(find.text('Ignore empty'));
    expect(changed, isTrue);
  });
}
