import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_ui_kit/flutter_ui_kit.dart';
import 'package:flutter_ui_kit_example/main.dart';

void main() {
  testWidgets('viewer boots and lists every catalog component', (tester) async {
    // A wide surface so the side-by-side master/detail layout renders.
    tester.view.physicalSize = const Size(1400, 1000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(const ViewerApp());
    await tester.pump();

    // Every component's label from the shared registry shows in the list.
    for (final UiComponentDescriptor d in uiComponentCatalog) {
      expect(find.text(d.label), findsWidgets, reason: '${d.id} missing');
    }
  });

  testWidgets('button demo responds to taps (interactive preview)',
      (tester) async {
    tester.view.physicalSize = const Size(1400, 1000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(const ViewerApp());
    await tester.pump();

    // ui_button is the first catalog entry, so its demo shows by default.
    expect(find.text('Tapped: 0 times'), findsOneWidget);

    await tester.tap(find.widgetWithText(FilledButton, 'Tap me'));
    await tester.pump();

    expect(find.text('Tapped: 1 times'), findsOneWidget);
    expect(find.text('Tapped: 0 times'), findsNothing);
  });

  testWidgets('switch demo toggles when tapped (stateful preview)',
      (tester) async {
    tester.view.physicalSize = const Size(1400, 1000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(const ViewerApp());
    await tester.pump();

    // Select the Switch entry in the master list.
    await tester.tap(find.text('Switch').first);
    await tester.pumpAndSettle();

    expect(find.text('Switched ON'), findsOneWidget);

    await tester.tap(find.byType(Switch));
    await tester.pumpAndSettle();

    expect(find.text('Switched OFF'), findsOneWidget);
  });
}
