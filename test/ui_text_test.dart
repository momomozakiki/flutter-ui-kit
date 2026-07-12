import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_ui_kit/flutter_ui_kit.dart';

void main() {
  Widget host(Widget child) =>
      MaterialApp(theme: buildUiTheme(), home: Scaffold(body: Center(child: child)));

  testWidgets('renders the data', (tester) async {
    await tester.pumpWidget(host(const UiText('Hello')));
    expect(find.text('Hello'), findsOneWidget);
  });

  testWidgets('title role uses the titleMedium style', (tester) async {
    late TextStyle expected;
    await tester.pumpWidget(host(Builder(builder: (context) {
      expected = Theme.of(context).textTheme.titleMedium!;
      return const UiText.title('Heading');
    })));

    final Text text = tester.widget<Text>(find.text('Heading'));
    expect(text.style?.fontSize, expected.fontSize);
  });

  testWidgets('color override wins over the themed color', (tester) async {
    await tester.pumpWidget(
      host(const UiText('Tinted', color: Color(0xFF123456))),
    );
    final Text text = tester.widget<Text>(find.text('Tinted'));
    expect(text.style?.color, const Color(0xFF123456));
  });

  testWidgets('mono role applies the monospace family', (tester) async {
    await tester.pumpWidget(host(const UiText.mono('1234')));
    final Text text = tester.widget<Text>(find.text('1234'));
    expect(text.style?.fontFamily, 'monospace');
  });
}
