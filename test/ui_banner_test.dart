import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_ui_kit/flutter_ui_kit.dart';

void main() {
  Widget host(Widget child) =>
      MaterialApp(theme: buildUiTheme(), home: Scaffold(body: child));

  testWidgets('error banner shows message and default error icon',
      (tester) async {
    await tester.pumpWidget(host(const UiBanner.error('Connection failed')));

    expect(find.text('Connection failed'), findsOneWidget);
    expect(find.byIcon(Icons.error_outline), findsOneWidget);
  });

  testWidgets('severity selects the matching default icon', (tester) async {
    await tester.pumpWidget(host(const UiBanner.success('All good')));
    expect(find.byIcon(Icons.check_circle_outline), findsOneWidget);
  });
}
