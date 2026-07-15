import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_ui_kit/flutter_ui_kit.dart';

void main() {
  const destinations = <UiNavDestination>[
    UiNavDestination(icon: Icons.home, label: 'Home'),
    UiNavDestination(icon: Icons.search, label: 'Search'),
    UiNavDestination(icon: Icons.person, label: 'Profile'),
  ];

  // Sizes the test surface to exactly [width] logical px (the shell fills it, so
  // its internal LayoutBuilder classifies against that width) and restores the
  // default surface afterwards. A plain SizedBox would be clamped to the 800px
  // default surface, so widths >= 800 must be driven through the surface size.
  Future<void> pumpAt(
    WidgetTester tester,
    double width, {
    ValueChanged<int>? onSelected,
    int index = 0,
  }) async {
    await tester.binding.setSurfaceSize(Size(width, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      MaterialApp(
        theme: buildUiTheme(),
        home: UiAdaptiveNavShell(
          destinations: destinations,
          selectedIndex: index,
          onDestinationSelected: onSelected ?? (_) {},
          body: const Center(child: Text('body')),
        ),
      ),
    );
  }

  testWidgets('compact (<600) shows a NavigationBar, no rail', (tester) async {
    await pumpAt(tester, 400);

    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.byType(NavigationRail), findsNothing);
  });

  testWidgets('medium (600–839) shows a compact NavigationRail', (tester) async {
    await pumpAt(tester, 700);

    expect(find.byType(NavigationRail), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);

    final NavigationRail rail = tester.widget(find.byType(NavigationRail));
    expect(rail.extended, isFalse);
    expect(rail.labelType, NavigationRailLabelType.selected);
  });

  testWidgets('expanded (>=840) shows an extended NavigationRail', (tester) async {
    await pumpAt(tester, 1000);

    final NavigationRail rail = tester.widget(find.byType(NavigationRail));
    expect(rail.extended, isTrue);
    // Extended rails render labels inline; labelType must be null (framework
    // assertion), not NavigationRailLabelType.all.
    expect(rail.labelType, isNull);
  });

  testWidgets('large (>=1200) also shows an extended NavigationRail', (tester) async {
    await pumpAt(tester, 1400);

    final NavigationRail rail = tester.widget(find.byType(NavigationRail));
    expect(rail.extended, isTrue);
  });

  testWidgets('tapping a bottom-bar destination reports its index', (tester) async {
    int? selected;
    await pumpAt(tester, 400, onSelected: (i) => selected = i);

    await tester.tap(find.text('Search'));
    await tester.pumpAndSettle();

    expect(selected, 1);
  });

  testWidgets('tapping a rail destination reports its index', (tester) async {
    int? selected;
    await pumpAt(tester, 1000, onSelected: (i) => selected = i);

    await tester.tap(find.text('Profile').first);
    await tester.pumpAndSettle();

    expect(selected, 2);
  });

  testWidgets('renders the provided body', (tester) async {
    await pumpAt(tester, 1000);
    expect(find.text('body'), findsOneWidget);
  });

  test('requires at least two destinations', () {
    expect(
      () => UiAdaptiveNavShell(
        destinations: const [UiNavDestination(icon: Icons.home, label: 'Home')],
        selectedIndex: 0,
        onDestinationSelected: (_) {},
        body: const SizedBox(),
      ),
      throwsAssertionError,
    );
  });
}
