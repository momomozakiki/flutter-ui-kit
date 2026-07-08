import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_ui_kit/flutter_ui_kit.dart';

void main() {
  const base = TextTheme(
    bodyMedium: TextStyle(fontSize: 20),
    titleLarge: TextStyle(fontSize: 40),
  );

  test('omitting scale preserves the current default behavior', () {
    final themed = UiTypography.textTheme(base);
    expect(themed.bodyMedium!.fontSize, 20 * UiTypography.fontScale);
    expect(themed.titleLarge!.fontSize, 40 * UiTypography.fontScale);
  });

  test('an explicit scale multiplies every defined font size', () {
    final themed = UiTypography.textTheme(base, scale: 2.0);
    expect(themed.bodyMedium!.fontSize, 40);
    expect(themed.titleLarge!.fontSize, 80);
  });

  test('a style with a null fontSize is left untouched', () {
    const withNullSize = TextTheme(labelSmall: TextStyle(color: Colors.red));
    final themed = UiTypography.textTheme(withNullSize, scale: 2.0);
    expect(themed.labelSmall!.fontSize, isNull);
    expect(themed.labelSmall!.color, Colors.red);
  });
}
