import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_ui_kit/flutter_ui_kit.dart';

void main() {
  testWidgets('renders at exactly the shared control height', (tester) async {
    await tester.pumpWidget(MaterialApp(
      theme: buildUiTheme(),
      home: const Scaffold(
        body: Center(child: UiTextField(label: 'Delimiter')),
      ),
    ));

    final double height = tester.getSize(find.byType(TextField)).height;
    // Exact, not a range: InputDecorationTheme.constraints is now TIGHT
    // (min == max == controlHeight), so this can never silently drift taller
    // than the button/chip/checkbox it lines up with in the same row.
    expect(height, UiSizing.controlHeight);
  });

  testWidgets('an explicit height override renders at that height',
      (tester) async {
    await tester.pumpWidget(MaterialApp(
      theme: buildUiTheme(),
      home: const Scaffold(
        body: Center(child: UiTextField(label: 'Delimiter', height: 50)),
      ),
    ));

    final double height = tester.getSize(find.byType(TextField)).height;
    expect(height, 50);
  });

  testWidgets('wraps in a Tooltip only when tooltip is provided',
      (tester) async {
    Widget build(String? tooltip) => MaterialApp(
          theme: buildUiTheme(),
          home: Scaffold(
            body: UiTextField(
              label: 'Delimiter',
              tooltip: tooltip,
            ),
          ),
        );

    await tester.pumpWidget(build(null));
    expect(find.byType(Tooltip), findsNothing);

    await tester.pumpWidget(build('The literal string to split each line on'));
    final Tooltip tip = tester.widget(find.byType(Tooltip));
    expect(tip.message, 'The literal string to split each line on');
    expect(tip.triggerMode, TooltipTriggerMode.longPress);
  });
}
