import 'package:flutter/foundation.dart';

import 'ui_sizing.dart';
import 'ui_spacing.dart';

/// Live, in-app overrides for the handful of sizing tokens that are hardest to
/// judge from a screenshot — control height, the spacing scale, chip padding,
/// and the nav rail width. Seeded from the current [UiSizing]/[UiSpacing]
/// consts, so nothing visually changes until a value is actually touched.
///
/// Paired with `UiTuningPanel` (debug-only UI) so sizing can be dialed in live
/// while the app is running, then copied back into the permanent token files
/// once a value is settled on. `buildUiTheme()` and a couple of call sites
/// read this singleton directly; it is a single global instance by design —
/// there is exactly one running app to tune at a time.
class UiTuning extends ChangeNotifier {
  UiTuning._();

  static final UiTuning instance = UiTuning._();

  double _controlHeight = UiSizing.controlHeight;
  double _spacingXs = UiSpacing.xs;
  double _spacingSm = UiSpacing.sm;
  double _spacingMd = UiSpacing.md;
  double _spacingLg = UiSpacing.lg;
  double _chipPaddingH = UiSpacing.sm;
  double _navRailWidth = 56;

  double get controlHeight => _controlHeight;
  double get spacingXs => _spacingXs;
  double get spacingSm => _spacingSm;
  double get spacingMd => _spacingMd;
  double get spacingLg => _spacingLg;
  double get chipPaddingH => _chipPaddingH;
  double get navRailWidth => _navRailWidth;

  set controlHeight(double v) {
    _controlHeight = v;
    notifyListeners();
  }

  set spacingXs(double v) {
    _spacingXs = v;
    notifyListeners();
  }

  set spacingSm(double v) {
    _spacingSm = v;
    notifyListeners();
  }

  set spacingMd(double v) {
    _spacingMd = v;
    notifyListeners();
  }

  set spacingLg(double v) {
    _spacingLg = v;
    notifyListeners();
  }

  set chipPaddingH(double v) {
    _chipPaddingH = v;
    notifyListeners();
  }

  set navRailWidth(double v) {
    _navRailWidth = v;
    notifyListeners();
  }

  /// Restores every field to its seeded default (the current committed
  /// consts). Also the reset hook tests use in `setUp`/`tearDown` so mutating
  /// this singleton in one test can't leak into the next test in the same file.
  void reset() {
    _controlHeight = UiSizing.controlHeight;
    _spacingXs = UiSpacing.xs;
    _spacingSm = UiSpacing.sm;
    _spacingMd = UiSpacing.md;
    _spacingLg = UiSpacing.lg;
    _chipPaddingH = UiSpacing.sm;
    _navRailWidth = 56;
    notifyListeners();
  }
}
