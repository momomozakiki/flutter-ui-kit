import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_ui_kit/flutter_ui_kit.dart';

void main() {
  Widget host(Widget child) =>
      MaterialApp(theme: buildUiTheme(), home: Scaffold(body: Center(child: child)));

  testWidgets('renders the label', (tester) async {
    await tester.pumpWidget(
      host(const UiStatusChip(label: 'Connected', status: UiStatus.success)),
    );

    expect(find.text('Connected'), findsOneWidget);
  });

  testWidgets('tints label and dot with the status color from UiColors',
      (tester) async {
    late Color expected;
    await tester.pumpWidget(
      host(Builder(builder: (context) {
        expected = context.uiColors.danger;
        return const UiStatusChip(label: 'Fault', status: UiStatus.danger);
      })),
    );

    // The label text is drawn in the semantic status color, never a hardcoded one.
    final Text label = tester.widget<Text>(find.text('Fault'));
    expect(label.style?.color, expected);

    // The leading dot is a Container tinted with the same status color.
    final Container dot = tester.widget<Container>(
      find
          .descendant(
            of: find.byType(UiStatusChip),
            matching: find.byType(Container),
          )
          .last,
    );
    final BoxDecoration decoration = dot.decoration! as BoxDecoration;
    expect(decoration.color, expected);
    expect(decoration.shape, BoxShape.circle);
  });

  testWidgets('each status maps to a distinct color', (tester) async {
    late UiColors colors;
    await tester.pumpWidget(
      host(Builder(builder: (context) {
        colors = context.uiColors;
        return const SizedBox.shrink();
      })),
    );

    final Set<Color> distinct = <Color>{
      colors.success,
      colors.warning,
      colors.danger,
      colors.info,
      colors.neutral,
    };
    // Five statuses, five distinct semantic colors.
    expect(distinct.length, 5);
  });
}
