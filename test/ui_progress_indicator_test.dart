import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_ui_kit/flutter_ui_kit.dart';

void main() {
  Widget host(Widget child) =>
      MaterialApp(theme: buildUiTheme(), home: Scaffold(body: Center(child: child)));

  testWidgets('circular shape renders a CircularProgressIndicator',
      (tester) async {
    await tester.pumpWidget(host(const UiProgressIndicator.circular(value: 0.5)));
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('circular honors an explicit size', (tester) async {
    await tester.pumpWidget(
      host(const UiProgressIndicator.circular(value: 0.5, size: 24)),
    );
    final Size size = tester.getSize(find.byType(CircularProgressIndicator));
    expect(size.width, 24);
    expect(size.height, 24);
  });

  testWidgets('linear shape renders a LinearProgressIndicator', (tester) async {
    await tester.pumpWidget(host(const UiProgressIndicator.linear()));
    expect(find.byType(LinearProgressIndicator), findsOneWidget);
  });

  testWidgets('null value is indeterminate', (tester) async {
    await tester.pumpWidget(host(const UiProgressIndicator.circular()));
    final CircularProgressIndicator indicator =
        tester.widget(find.byType(CircularProgressIndicator));
    expect(indicator.value, isNull);
  });
}
