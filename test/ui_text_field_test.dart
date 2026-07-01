import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_ui_kit/flutter_ui_kit.dart';

void main() {
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
