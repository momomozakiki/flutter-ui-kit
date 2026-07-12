import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_ui_kit/flutter_ui_kit.dart';

void main() {
  Widget host(Widget child) =>
      MaterialApp(theme: buildUiTheme(), home: Scaffold(body: Center(child: child)));

  testWidgets('shows initials when provided', (tester) async {
    await tester.pumpWidget(host(const UiAvatar(initials: 'AB')));
    expect(find.text('AB'), findsOneWidget);
  });

  testWidgets('falls back to the person icon when nothing is provided',
      (tester) async {
    await tester.pumpWidget(host(const UiAvatar()));
    expect(find.byIcon(Icons.person), findsOneWidget);
  });

  testWidgets('honors the size (diameter) parameter', (tester) async {
    await tester.pumpWidget(host(const UiAvatar(initials: 'AB', size: 40)));
    final Size size = tester.getSize(find.byType(CircleAvatar));
    expect(size.width, 40);
    expect(size.height, 40);
  });
}
