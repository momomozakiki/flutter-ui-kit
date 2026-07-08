import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_ui_kit/flutter_ui_kit.dart';

void main() {
  // UiTuning.instance is a global singleton; flutter test isolates each test
  // FILE in its own VM isolate (so this can't leak into other test files),
  // but multiple tests WITHIN this file share it — reset before/after each so
  // one test's mutation can't leak into the next.
  setUp(UiTuning.instance.reset);
  tearDown(UiTuning.instance.reset);

  test('defaults match the current committed consts', () {
    final t = UiTuning.instance;
    expect(t.controlHeight, UiSizing.controlHeight);
    expect(t.spacingXs, UiSpacing.xs);
    expect(t.spacingSm, UiSpacing.sm);
    expect(t.spacingMd, UiSpacing.md);
    expect(t.spacingLg, UiSpacing.lg);
    expect(t.chipPaddingH, UiSpacing.sm);
    expect(t.navRailWidth, 56);
  });

  test('a setter mutates the field and notifies listeners', () {
    final t = UiTuning.instance;
    var notified = 0;
    t.addListener(() => notified++);

    t.controlHeight = 44;

    expect(t.controlHeight, 44);
    expect(notified, 1);
  });

  test('reset restores every field to its seeded default', () {
    final t = UiTuning.instance;
    t.controlHeight = 44;
    t.spacingXs = 10;
    t.spacingSm = 12;
    t.spacingMd = 20;
    t.spacingLg = 24;
    t.chipPaddingH = 16;
    t.navRailWidth = 80;

    t.reset();

    expect(t.controlHeight, UiSizing.controlHeight);
    expect(t.spacingXs, UiSpacing.xs);
    expect(t.spacingSm, UiSpacing.sm);
    expect(t.spacingMd, UiSpacing.md);
    expect(t.spacingLg, UiSpacing.lg);
    expect(t.chipPaddingH, UiSpacing.sm);
    expect(t.navRailWidth, 56);
  });
}
