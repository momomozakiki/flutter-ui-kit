import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_ui_kit/flutter_ui_kit.dart';

void main() {
  // UiResponsive classifies against the *available width* (its LayoutBuilder's
  // constraints), so driving the surface size is what changes the resolved
  // class. A plain SizedBox would be clamped to the 800px default surface, so
  // widths >= 800 must be driven through the surface size.
  Future<UiDeviceClass> classAt(WidgetTester tester, double width) async {
    await tester.binding.setSurfaceSize(Size(width, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    late UiDeviceClass resolved;
    await tester.pumpWidget(
      MaterialApp(
        theme: buildUiTheme(),
        home: Scaffold(
          body: UiResponsive(
            builder: (context, deviceClass) {
              resolved = deviceClass;
              return Text(deviceClass.name);
            },
          ),
        ),
      ),
    );
    return resolved;
  }

  testWidgets('classifies compact / medium / expanded / large at '
      'representative widths', (tester) async {
    expect(await classAt(tester, 400), UiDeviceClass.compact);
    expect(find.text('compact'), findsOneWidget);
    expect(await classAt(tester, 700), UiDeviceClass.medium);
    expect(await classAt(tester, 1000), UiDeviceClass.expanded);
    expect(await classAt(tester, 1400), UiDeviceClass.large);
  });

  testWidgets('flips class exactly at the compact/medium boundary (599 vs 600)',
      (tester) async {
    expect(await classAt(tester, 599), UiDeviceClass.compact);
    expect(await classAt(tester, 600), UiDeviceClass.medium);
  });

  testWidgets('flips class exactly at the medium/expanded boundary (839 vs 840)',
      (tester) async {
    expect(await classAt(tester, 839), UiDeviceClass.medium);
    expect(await classAt(tester, 840), UiDeviceClass.expanded);
  });

  testWidgets('flips class exactly at the expanded/large boundary (1199 vs 1200)',
      (tester) async {
    expect(await classAt(tester, 1199), UiDeviceClass.expanded);
    expect(await classAt(tester, 1200), UiDeviceClass.large);
  });

  testWidgets('falls back to MediaQuery width when the available width is '
      'unbounded', (tester) async {
    // A horizontal scroll view hands its child maxWidth: infinity, so the
    // LayoutBuilder constraint is non-finite and the widget must fall back to
    // MediaQuery.sizeOf. Drive MediaQuery explicitly (a MaterialApp would
    // rebuild it from the test view) at 400 -> it should read compact rather
    // than throwing on the infinite constraint.
    late UiDeviceClass resolved;
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: MediaQuery(
          data: const MediaQueryData(size: Size(400, 800)),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: UiResponsive(
              builder: (context, deviceClass) {
                resolved = deviceClass;
                return Text(deviceClass.name);
              },
            ),
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
    expect(resolved, UiDeviceClass.compact);
  });
}
