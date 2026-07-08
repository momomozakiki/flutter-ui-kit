import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_ui_kit/flutter_ui_kit.dart';

void main() {
  setUp(UiTuning.instance.reset);
  tearDown(() {
    UiTuningOverlay.hide();
    UiTuning.instance.reset();
  });

  testWidgets(
      'the app underneath stays visible and tappable while the panel is shown '
      '(no modal barrier, unlike a Drawer)', (tester) async {
    var tapped = 0;
    await tester.pumpWidget(MaterialApp(
      theme: buildUiTheme(),
      home: Scaffold(
        body: Builder(
          builder: (context) => Column(
            children: [
              ElevatedButton(
                onPressed: () => tapped++,
                child: const Text('Underneath'),
              ),
              ElevatedButton(
                onPressed: () => UiTuningOverlay.show(context),
                child: const Text('Open tuning'),
              ),
            ],
          ),
        ),
      ),
    ));

    await tester.tap(find.text('Open tuning'));
    await tester.pump();

    expect(UiTuningOverlay.isShown, isTrue);
    expect(find.text('Design Tuning (debug only)'), findsOneWidget);

    // The button underneath is still visible AND tappable — a Drawer's modal
    // barrier would have intercepted this tap.
    await tester.tap(find.text('Underneath'));
    await tester.pump();
    expect(tapped, 1);
  });

  testWidgets('toggle shows then hides the panel', (tester) async {
    await tester.pumpWidget(MaterialApp(
      theme: buildUiTheme(),
      home: Scaffold(
        body: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () => UiTuningOverlay.toggle(context),
            child: const Text('Toggle'),
          ),
        ),
      ),
    ));

    expect(UiTuningOverlay.isShown, isFalse);

    await tester.tap(find.text('Toggle'));
    await tester.pump();
    expect(UiTuningOverlay.isShown, isTrue);

    await tester.tap(find.text('Toggle'));
    await tester.pump();
    expect(UiTuningOverlay.isShown, isFalse);
  });

  testWidgets('the close button hides the panel', (tester) async {
    await tester.pumpWidget(MaterialApp(
      theme: buildUiTheme(),
      home: Scaffold(
        body: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () => UiTuningOverlay.show(context),
            child: const Text('Open'),
          ),
        ),
      ),
    ));

    await tester.tap(find.text('Open'));
    await tester.pump();
    expect(UiTuningOverlay.isShown, isTrue);

    await tester.tap(find.byTooltip('Close'));
    await tester.pump();
    expect(UiTuningOverlay.isShown, isFalse);
  });
}
