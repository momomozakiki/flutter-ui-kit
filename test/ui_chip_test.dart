import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_ui_kit/flutter_ui_kit.dart';

void main() {
  setUp(UiTuning.instance.reset);
  tearDown(UiTuning.instance.reset);

  Widget host(Widget child) =>
      MaterialApp(theme: buildUiTheme(), home: Scaffold(body: Center(child: child)));

  testWidgets('renders the label', (tester) async {
    await tester.pumpWidget(host(const UiChip(label: 'Draft')));
    expect(find.text('Draft'), findsOneWidget);
  });

  testWidgets('label is sized to the exact chip height', (tester) async {
    await tester.pumpWidget(host(const UiChip(label: 'Draft')));
    // The height mechanism sizes the label, not a SizedBox around the chip.
    final Size labelSlot = tester.getSize(
      find.ancestor(of: find.text('Draft'), matching: find.byType(SizedBox)).first,
    );
    expect(labelSlot.height, UiSizing.controlHeight);
  });

  testWidgets('height override sizes the label slot', (tester) async {
    await tester.pumpWidget(host(const UiChip(label: 'Draft', height: 28)));
    final Size labelSlot = tester.getSize(
      find.ancestor(of: find.text('Draft'), matching: find.byType(SizedBox)).first,
    );
    expect(labelSlot.height, 28);
  });

  testWidgets('onSelected fires with the new selection state', (tester) async {
    bool? value;
    await tester.pumpWidget(host(
      UiChip(label: 'Filter', selected: false, onSelected: (v) => value = v),
    ));
    await tester.tap(find.text('Filter'));
    expect(value, isTrue);
  });

  testWidgets('onDeleted shows a delete affordance wired to the callback',
      (tester) async {
    bool deleted = false;
    await tester.pumpWidget(host(
      UiChip(label: 'Tag', onDeleted: () => deleted = true),
    ));
    // The delete affordance is wired through to the caller's callback.
    final InputChip chip = tester.widget(find.byType(InputChip));
    expect(chip.onDeleted, isNotNull);
    chip.onDeleted!();
    expect(deleted, isTrue);
  });
}
