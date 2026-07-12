import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_ui_kit/flutter_ui_kit.dart';

void main() {
  Widget host(Widget child) =>
      MaterialApp(theme: buildUiTheme(), home: Scaffold(body: Center(child: child)));

  testWidgets('renders the icon and fires onPressed', (tester) async {
    bool pressed = false;
    await tester.pumpWidget(host(
      UiIconButton(icon: Icons.add, onPressed: () => pressed = true),
    ));
    expect(find.byIcon(Icons.add), findsOneWidget);
    await tester.tap(find.byIcon(Icons.add));
    expect(pressed, isTrue);
  });

  testWidgets('disabled when onPressed is null', (tester) async {
    await tester.pumpWidget(host(
      const UiIconButton(icon: Icons.delete, onPressed: null),
    ));
    final IconButton button = tester.widget(find.byType(IconButton));
    expect(button.onPressed, isNull);
  });

  testWidgets('danger tone colors the icon with the semantic danger token',
      (tester) async {
    late Color expected;
    await tester.pumpWidget(host(Builder(builder: (context) {
      expected = context.uiColors.danger;
      return UiIconButton(
        icon: Icons.delete,
        tone: UiTone.danger,
        onPressed: () {},
      );
    })));

    final IconButton button = tester.widget(find.byType(IconButton));
    expect(button.color, expected);
  });
}
