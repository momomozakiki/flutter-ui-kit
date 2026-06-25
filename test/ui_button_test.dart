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

  testWidgets('danger tone fills with the UiColors danger token', (tester) async {
    await tester.pumpWidget(host(
      UiButton.primary(
          label: 'Disconnect', onPressed: () {}, tone: UiButtonTone.danger),
    ));
    final FilledButton button = tester.widget(find.byType(FilledButton));
    final Color? bg = button.style?.backgroundColor?.resolve(<WidgetState>{});
    expect(bg, UiColors.light.danger);
    expect(bg, isNot(Colors.red));
  });

  testWidgets('success tone fills with the UiColors success token',
      (tester) async {
    await tester.pumpWidget(host(
      UiButton.primary(
          label: 'Connected', onPressed: () {}, tone: UiButtonTone.success),
    ));
    final FilledButton button = tester.widget(find.byType(FilledButton));
    final Color? bg = button.style?.backgroundColor?.resolve(<WidgetState>{});
    expect(bg, UiColors.light.success);
  });

  testWidgets('long label stays on one line and scales down to fit',
      (tester) async {
    await tester.pumpWidget(host(
      const SizedBox(
        width: 80,
        child: UiButton.secondary(label: 'Save As', onPressed: null),
      ),
    ));

    expect(find.byType(FittedBox), findsOneWidget);
    final Text text = tester.widget(find.text('Save As'));
    expect(text.maxLines, 1);
    expect(text.softWrap, isFalse);
  });

  testWidgets('normal tone leaves the theme default (no override)',
      (tester) async {
    await tester.pumpWidget(host(
      UiButton.primary(label: 'Connect', onPressed: () {}),
    ));
    final FilledButton button = tester.widget(find.byType(FilledButton));
    expect(button.style, isNull);
  });

  testWidgets('compact size renders below the 48 px touch-target floor',
      (tester) async {
    await tester.pumpWidget(host(
      UiButton.secondary(
        label: 'Re-issue',
        onPressed: () {},
        size: UiButtonSize.compact,
      ),
    ));
    final double height =
        tester.getSize(find.byType(OutlinedButton)).height;
    expect(height, lessThan(UiSizing.touchTarget));
    expect(height, closeTo(UiSizing.buttonCompactHeight, 0.01));
  });

  testWidgets('normal size keeps the theme 48 px floor', (tester) async {
    await tester.pumpWidget(host(
      UiButton.secondary(label: 'Re-issue', onPressed: () {}),
    ));
    final double height =
        tester.getSize(find.byType(OutlinedButton)).height;
    expect(height, greaterThanOrEqualTo(UiSizing.touchTarget));
  });
}
