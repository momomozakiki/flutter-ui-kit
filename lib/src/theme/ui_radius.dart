import 'package:flutter/widgets.dart';

/// Corner-radius tokens. Use the [BorderRadius] constants at call sites so
/// rounding stays consistent across components.
abstract final class UiRadius {
  const UiRadius._();

  static const double sm = 4;
  static const double md = 8;
  static const double lg = 12;

  static const BorderRadius brSm = BorderRadius.all(Radius.circular(sm));
  static const BorderRadius brMd = BorderRadius.all(Radius.circular(md));
  static const BorderRadius brLg = BorderRadius.all(Radius.circular(lg));
}
