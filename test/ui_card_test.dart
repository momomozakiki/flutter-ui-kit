import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_ui_kit/flutter_ui_kit.dart';

void main() {
  Widget host(Widget child) =>
      MaterialApp(theme: buildUiTheme(), home: Scaffold(body: Center(child: child)));

  testWidgets('renders its child', (tester) async {
    await tester.pumpWidget(host(const UiCard(child: Text('Body'))));
    expect(find.text('Body'), findsOneWidget);
  });

  testWidgets('onTap makes the card tappable', (tester) async {
    bool tapped = false;
    await tester.pumpWidget(host(
      UiCard(onTap: () => tapped = true, child: const Text('Tap me')),
    ));

    await tester.tap(find.text('Tap me'));
    expect(tapped, isTrue);
  });

  testWidgets('no InkWell when onTap is null', (tester) async {
    await tester.pumpWidget(host(const UiCard(child: Text('Static'))));
    expect(
      find.descendant(
        of: find.byType(UiCard),
        matching: find.byType(InkWell),
      ),
      findsNothing,
    );
  });
}
