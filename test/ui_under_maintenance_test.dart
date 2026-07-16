import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_ui_kit/flutter_ui_kit.dart';

void main() {
  Widget host(Widget child) =>
      MaterialApp(theme: buildUiTheme(), home: Scaffold(body: child));

  testWidgets('renders the passed icon and title', (tester) async {
    await tester.pumpWidget(
      host(const UiUnderMaintenance(
        icon: Icons.print,
        title: 'Printer',
      )),
    );

    expect(find.byIcon(Icons.print), findsOneWidget);
    expect(find.text('Printer'), findsOneWidget);
  });

  testWidgets('subtitle defaults to "Under maintenance" when omitted',
      (tester) async {
    await tester.pumpWidget(
      host(const UiUnderMaintenance(icon: Icons.print, title: 'Printer')),
    );

    expect(find.text('Under maintenance'), findsOneWidget);
  });

  testWidgets('renders an explicit subtitle override', (tester) async {
    await tester.pumpWidget(
      host(const UiUnderMaintenance(
        icon: Icons.usb,
        title: 'Scanner',
        subtitle: 'Connect a device',
      )),
    );

    expect(find.text('Connect a device'), findsOneWidget);
    expect(find.text('Under maintenance'), findsNothing);
  });

  testWidgets('styles icon and subtitle with tokens (iconLg + disabledColor)',
      (tester) async {
    await tester.pumpWidget(
      host(const UiUnderMaintenance(
        icon: Icons.print,
        title: 'Printer',
        subtitle: 'Waiting',
      )),
    );

    final BuildContext context = tester.element(find.text('Printer'));
    final Color disabled = Theme.of(context).disabledColor;

    final Icon icon = tester.widget<Icon>(find.byIcon(Icons.print));
    expect(icon.size, UiSizing.iconLg);
    expect(icon.color, disabled);

    final Text subtitle = tester.widget<Text>(find.text('Waiting'));
    expect(subtitle.style?.color, disabled);
  });
}
