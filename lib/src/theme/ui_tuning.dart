import 'package:flutter/foundation.dart';

import 'ui_sizing.dart';
import 'ui_spacing.dart';
import 'ui_typography.dart';

/// Live, in-app overrides for the sizing/typography tokens that are hardest to
/// judge from a screenshot — control height, the spacing scale, font size and
/// family, and (per component) the height of each control type. Seeded from
/// the current [UiSizing]/[UiSpacing]/[UiTypography] consts, so nothing
/// visually changes until a value is actually touched.
///
/// Paired with `UiTuningPanel` (debug-only UI, shown in a non-modal floating
/// `UiTuningOverlay`) so sizing can be dialed in live while the app is
/// running, then copied back into the permanent token files once a value is
/// settled on. `buildUiTheme()` and a handful of call sites read this
/// singleton directly; it is a single global instance by design — there is
/// exactly one running app to tune at a time.
///
/// The per-component height fields (`dropdownHeight`, `textFieldHeight`, etc.)
/// all seed from [controlHeight], so every control still starts equal/aligned
/// by default — a control only diverges from the others if a slider for it is
/// deliberately moved.
class UiTuning extends ChangeNotifier {
  UiTuning._();

  static final UiTuning instance = UiTuning._();

  /// Curated, best-effort font family choices. These are common Windows
  /// system font names, not bundled assets — Flutter's desktop text renderer
  /// falls back to the OS-installed font by name, so nothing needs shipping
  /// with the app. Reliable only on a machine that has the family installed;
  /// `null` (the default) leaves the theme's own default family untouched.
  static const List<String?> fontFamilyChoices = <String?>[
    null, // theme default
    'Segoe UI',
    'Consolas',
    'Calibri',
    'Arial',
  ];

  double _controlHeight = UiSizing.controlHeight;
  double _spacingXs = UiSpacing.xs;
  double _spacingSm = UiSpacing.sm;
  double _spacingMd = UiSpacing.md;
  double _spacingLg = UiSpacing.lg;
  double _chipPaddingH = UiSizing.chipPaddingH;
  double _navRailWidth = UiSizing.navRailWidth;
  double _fontScale = UiTypography.fontScale;
  String? _fontFamily;
  double _dropdownHeight = UiSizing.controlHeight;
  double _textFieldHeight = UiSizing.controlHeight;
  double _tokenGridFieldHeight = UiSizing.controlHeight;
  double _buttonHeight = UiSizing.controlHeight;
  double _checkboxHeight = UiSizing.controlHeight;
  double _chipHeight = UiSizing.controlHeight;

  double get controlHeight => _controlHeight;
  double get spacingXs => _spacingXs;
  double get spacingSm => _spacingSm;
  double get spacingMd => _spacingMd;
  double get spacingLg => _spacingLg;
  double get chipPaddingH => _chipPaddingH;
  double get navRailWidth => _navRailWidth;
  double get fontScale => _fontScale;
  String? get fontFamily => _fontFamily;
  double get dropdownHeight => _dropdownHeight;
  double get textFieldHeight => _textFieldHeight;
  double get tokenGridFieldHeight => _tokenGridFieldHeight;
  double get buttonHeight => _buttonHeight;
  double get checkboxHeight => _checkboxHeight;
  double get chipHeight => _chipHeight;

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

  set fontScale(double v) {
    _fontScale = v;
    notifyListeners();
  }

  set fontFamily(String? v) {
    _fontFamily = v;
    notifyListeners();
  }

  set dropdownHeight(double v) {
    _dropdownHeight = v;
    notifyListeners();
  }

  set textFieldHeight(double v) {
    _textFieldHeight = v;
    notifyListeners();
  }

  set tokenGridFieldHeight(double v) {
    _tokenGridFieldHeight = v;
    notifyListeners();
  }

  set buttonHeight(double v) {
    _buttonHeight = v;
    notifyListeners();
  }

  set checkboxHeight(double v) {
    _checkboxHeight = v;
    notifyListeners();
  }

  set chipHeight(double v) {
    _chipHeight = v;
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
    _chipPaddingH = UiSizing.chipPaddingH;
    _navRailWidth = UiSizing.navRailWidth;
    _fontScale = UiTypography.fontScale;
    _fontFamily = null;
    _dropdownHeight = UiSizing.controlHeight;
    _textFieldHeight = UiSizing.controlHeight;
    _tokenGridFieldHeight = UiSizing.controlHeight;
    _buttonHeight = UiSizing.controlHeight;
    _checkboxHeight = UiSizing.controlHeight;
    _chipHeight = UiSizing.controlHeight;
    notifyListeners();
  }
}
