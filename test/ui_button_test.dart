import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_ui_kit/flutter_ui_kit.dart';

void main() {
  Widget host(Widget child) =>
      MaterialApp(theme: buildUiTheme(), home: Scaffold(body: Center(child: child)));

  testWidgets('primary button renders label and fires onPressed', (tester) async {
    var taps = 0;
    await tester.pumpWidget(host(
      UiButton.primary(label: 'Connect', onPressed: () => taps++),
    ));

    expect(find.text('Connect'), findsOneWidget);
    expect(find.byType(FilledButton), findsOneWidget);

    await tester.tap(find.byType(FilledButton));
    expect(taps, 1);
  });

  testWidgets('secondary variant renders an OutlinedButton', (tester) async {
    await tester.pumpWidget(host(
      UiButton.secondary(label: 'Disconnect', onPressed: () {}, icon: Icons.stop),
    ));
    expect(find.byType(OutlinedButton), findsOneWidget);
    expect(find.text('Disconnect'), findsOneWidget);
  });

  testWidgets('null onPressed disables the button', (tester) async {
    await tester.pumpWidget(host(
      const UiButton.primary(label: 'Disabled', onPressed: null),
    ));
    final FilledButton button = tester.widget(find.byType(FilledButton));
    expect(button.onPressed, isNull);
  });
}
