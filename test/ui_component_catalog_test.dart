import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_ui_kit/flutter_ui_kit.dart';

void main() {
  group('uiComponentCatalog', () {
    test('is non-empty', () {
      expect(uiComponentCatalog, isNotEmpty);
    });

    test('ids are unique', () {
      final Set<String> ids =
          uiComponentCatalog.map((d) => d.id).toSet();
      expect(ids.length, uiComponentCatalog.length,
          reason: 'duplicate id in uiComponentCatalog');
    });

    test('every entry has a non-empty label and category', () {
      for (final UiComponentDescriptor d in uiComponentCatalog) {
        expect(d.label, isNotEmpty, reason: '${d.id} has an empty label');
        expect(d.category, isNotEmpty, reason: '${d.id} has an empty category');
      }
    });

    test('is unmodifiable', () {
      expect(
        () => uiComponentCatalog.add(
          UiComponentDescriptor(
            id: 'x',
            label: 'x',
            category: 'x',
            sample: (_) => const SizedBox.shrink(),
          ),
        ),
        throwsUnsupportedError,
      );
    });

    // The load-bearing guarantee: a broken sample (wrong required arg, missing
    // theme dependency) would throw when built. Pumping each under the kit theme
    // proves the whole registry is renderable by the viewer / a consumer palette.
    for (final UiComponentDescriptor d in uiComponentCatalog) {
      testWidgets('${d.id} sample builds under buildUiTheme()', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            theme: buildUiTheme(),
            home: Scaffold(
              body: Center(
                child: SizedBox(width: 400, child: Builder(builder: d.sample)),
              ),
            ),
          ),
        );
        // Not pumpAndSettle: indeterminate indicators never settle.
        expect(tester.takeException(), isNull);
      });
    }
  });
}
