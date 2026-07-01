import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_ui_kit/flutter_ui_kit.dart';

void main() {
  testWidgets('renders label and selecting an item fires onChanged',
      (tester) async {
    String? picked;
    await tester.pumpWidget(MaterialApp(
      theme: buildUiTheme(),
      home: Scaffold(
        body: Center(
          child: UiDropdown<String>(
            label: 'Font',
            value: 'Playfair Display',
            items: const [
              UiDropdownItem(value: 'Playfair Display', label: 'Playfair Display'),
              UiDropdownItem(value: 'Arial', label: 'Arial'),
            ],
            onChanged: (v) => picked = v,
          ),
        ),
      ),
    ));

    // The label is shown on the border.
    expect(find.text('Font'), findsOneWidget);

    // Open the menu and choose the second entry.
    await tester.tap(find.byType(DropdownButtonFormField<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Arial').last);
    await tester.pumpAndSettle();

    expect(picked, 'Arial');
  });

  testWidgets('disabled dropdown has a null handler', (tester) async {
    await tester.pumpWidget(MaterialApp(
      theme: buildUiTheme(),
      home: Scaffold(
        body: UiDropdown<int>(
          label: 'Baud',
          value: 9600,
          enabled: false,
          items: const [UiDropdownItem(value: 9600, label: '9600')],
          onChanged: (_) {},
        ),
      ),
    ));

    final DropdownButtonFormField<int> field =
        tester.widget(find.byType(DropdownButtonFormField<int>));
    expect(field.onChanged, isNull);
  });

  testWidgets('wraps in a Tooltip only when tooltip is provided',
      (tester) async {
    Widget build(String? tooltip) => MaterialApp(
          theme: buildUiTheme(),
          home: Scaffold(
            body: UiDropdown<String>(
              label: 'Split by',
              value: 'a',
              tooltip: tooltip,
              items: const [UiDropdownItem(value: 'a', label: 'A')],
              onChanged: (_) {},
            ),
          ),
        );

    await tester.pumpWidget(build(null));
    expect(find.byType(Tooltip), findsNothing);

    await tester.pumpWidget(build('Explains the split modes'));
    final Tooltip tip = tester.widget(find.byType(Tooltip));
    expect(tip.message, 'Explains the split modes');
    expect(tip.triggerMode, TooltipTriggerMode.longPress);
  });
}
