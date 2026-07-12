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
}
