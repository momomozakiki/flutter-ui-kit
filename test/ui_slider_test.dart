import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_ui_kit/flutter_ui_kit.dart';

void main() {
  Widget host(Widget child) => MaterialApp(
        theme: buildUiTheme(),
        home: Scaffold(body: Padding(padding: const EdgeInsets.all(24), child: child)),
      );

  testWidgets('renders a Slider with the given value', (tester) async {
    await tester.pumpWidget(host(
      UiSlider(value: 0.5, onChanged: (_) {}),
    ));
    final Slider slider = tester.widget(find.byType(Slider));
    expect(slider.value, 0.5);
  });

  testWidgets('label and value readout appear when requested', (tester) async {
    await tester.pumpWidget(host(
      UiSlider(
        value: 0.25,
        min: 0,
        max: 1,
        label: 'Volume',
        showValue: true,
        onChanged: (_) {},
      ),
    ));
    expect(find.text('Volume'), findsOneWidget);
    expect(find.text('0.25'), findsOneWidget);
  });

  testWidgets('disabled when onChanged is null', (tester) async {
    await tester.pumpWidget(host(const UiSlider(value: 0.5, onChanged: null)));
    final Slider slider = tester.widget(find.byType(Slider));
    expect(slider.onChanged, isNull);
  });
}
