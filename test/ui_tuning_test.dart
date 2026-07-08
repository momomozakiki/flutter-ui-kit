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
    expect(t.chipPaddingH, UiSizing.chipPaddingH);
    expect(t.navRailWidth, UiSizing.navRailWidth);
    expect(t.fontScale, UiTypography.fontScale);
    expect(t.fontFamily, isNull);
    // Per-component heights all seed equal to the shared controlHeight, so
    // every control still starts aligned by default.
    expect(t.dropdownHeight, UiSizing.controlHeight);
    expect(t.textFieldHeight, UiSizing.controlHeight);
    expect(t.tokenGridFieldHeight, UiSizing.controlHeight);
    expect(t.buttonHeight, UiSizing.controlHeight);
    expect(t.checkboxHeight, UiSizing.controlHeight);
    expect(t.chipHeight, UiSizing.controlHeight);
  });

  test('a setter mutates the field and notifies listeners', () {
    final t = UiTuning.instance;
    var notified = 0;
    t.addListener(() => notified++);

    t.controlHeight = 44;

    expect(t.controlHeight, 44);
    expect(notified, 1);
  });

  test('a per-component setter diverges independently of controlHeight', () {
    final t = UiTuning.instance;

    t.dropdownHeight = 50;

    expect(t.dropdownHeight, 50);
    // Every other control stays at its own (still shared) default.
    expect(t.controlHeight, UiSizing.controlHeight);
    expect(t.textFieldHeight, UiSizing.controlHeight);
    expect(t.buttonHeight, UiSizing.controlHeight);
  });

  test('fontFamily setter mutates and notifies', () {
    final t = UiTuning.instance;
    var notified = 0;
    t.addListener(() => notified++);

    t.fontFamily = 'Consolas';

    expect(t.fontFamily, 'Consolas');
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
    t.fontScale = 1.2;
    t.fontFamily = 'Arial';
    t.dropdownHeight = 50;
    t.textFieldHeight = 50;
    t.tokenGridFieldHeight = 50;
    t.buttonHeight = 50;
    t.checkboxHeight = 50;
    t.chipHeight = 50;

    t.reset();

    expect(t.controlHeight, UiSizing.controlHeight);
    expect(t.spacingXs, UiSpacing.xs);
    expect(t.spacingSm, UiSpacing.sm);
    expect(t.spacingMd, UiSpacing.md);
    expect(t.spacingLg, UiSpacing.lg);
    expect(t.chipPaddingH, UiSizing.chipPaddingH);
    expect(t.navRailWidth, UiSizing.navRailWidth);
    expect(t.fontScale, UiTypography.fontScale);
    expect(t.fontFamily, isNull);
    expect(t.dropdownHeight, UiSizing.controlHeight);
    expect(t.textFieldHeight, UiSizing.controlHeight);
    expect(t.tokenGridFieldHeight, UiSizing.controlHeight);
    expect(t.buttonHeight, UiSizing.controlHeight);
    expect(t.checkboxHeight, UiSizing.controlHeight);
    expect(t.chipHeight, UiSizing.controlHeight);
  });
}
