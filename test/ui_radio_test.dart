import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_ui_kit/flutter_ui_kit.dart';

void main() {
  setUp(UiTuning.instance.reset);
  tearDown(UiTuning.instance.reset);

  Widget host(Widget child) =>
      MaterialApp(theme: buildUiTheme(), home: Scaffold(body: Center(child: child)));

  const items = <UiRadioItem<int>>[
    UiRadioItem(value: 1, label: 'One'),
    UiRadioItem(value: 2, label: 'Two'),
  ];

  testWidgets('each radio row renders at the shared control height',
      (tester) async {
    await tester.pumpWidget(host(
      UiRadioGroup<int>(groupValue: 1, items: items, onChanged: (_) {}),
    ));

    final double height = tester.getSize(find.byType(UiRadio<int>).first).height;
    expect(height, UiSizing.controlHeight);
  });

  testWidgets('height override renders each radio at that height',
      (tester) async {
    await tester.pumpWidget(host(
      UiRadioGroup<int>(
        groupValue: 1,
        items: items,
        height: 48,
        onChanged: (_) {},
      ),
    ));

    final double height = tester.getSize(find.byType(UiRadio<int>).first).height;
    expect(height, 48);
  });

  testWidgets('tapping a label selects that value', (tester) async {
    int? selected = 1;
    await tester.pumpWidget(host(
      UiRadioGroup<int>(
        groupValue: selected,
        items: items,
        onChanged: (v) => selected = v,
      ),
    ));

    await tester.tap(find.text('Two'));
    expect(selected, 2);
  });

  testWidgets('onChanged null disables the whole group', (tester) async {
    const int selected = 1;
    await tester.pumpWidget(host(
      const UiRadioGroup<int>(
        groupValue: selected,
        items: items,
        onChanged: null,
      ),
    ));

    await tester.tap(find.text('Two'), warnIfMissed: false);
    expect(selected, 1);
  });
}
