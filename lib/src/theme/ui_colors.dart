import 'package:flutter/material.dart';

/// Semantic color tokens, delivered as a [ThemeExtension] so call sites read
/// `context.uiColors.danger` instead of hardcoding `Colors.red.shade700`.
///
/// These cover meanings the Material [ColorScheme] does not name directly
/// (success / warning / info / a muted neutral). Wired into the theme by
/// `buildUiTheme`.
@immutable
class UiColors extends ThemeExtension<UiColors> {
  const UiColors({
    required this.success,
    required this.onSuccess,
    required this.warning,
    required this.onWarning,
    required this.danger,
    required this.onDanger,
    required this.info,
    required this.onInfo,
    required this.neutral,
  });

  final Color success;
  final Color onSuccess;
  final Color warning;
  final Color onWarning;
  final Color danger;
  final Color onDanger;
  final Color info;
  final Color onInfo;

  /// A muted tone for idle / disconnected / placeholder states.
  final Color neutral;

  static const UiColors light = UiColors(
    success: Color(0xFF2E7D32),
    onSuccess: Color(0xFFFFFFFF),
    warning: Color(0xFFED6C02),
    onWarning: Color(0xFFFFFFFF),
    danger: Color(0xFFC62828),
    onDanger: Color(0xFFFFFFFF),
    info: Color(0xFF0277BD),
    onInfo: Color(0xFFFFFFFF),
    neutral: Color(0xFF757575),
  );

  static const UiColors dark = UiColors(
    success: Color(0xFF66BB6A),
    onSuccess: Color(0xFF00210B),
    warning: Color(0xFFFFB74D),
    onWarning: Color(0xFF3E2500),
    danger: Color(0xFFEF5350),
    onDanger: Color(0xFF330000),
    info: Color(0xFF4FC3F7),
    onInfo: Color(0xFF002335),
    neutral: Color(0xFFBDBDBD),
  );

  @override
  UiColors copyWith({
    Color? success,
    Color? onSuccess,
    Color? warning,
    Color? onWarning,
    Color? danger,
    Color? onDanger,
    Color? info,
    Color? onInfo,
    Color? neutral,
  }) {
    return UiColors(
      success: success ?? this.success,
      onSuccess: onSuccess ?? this.onSuccess,
      warning: warning ?? this.warning,
      onWarning: onWarning ?? this.onWarning,
      danger: danger ?? this.danger,
      onDanger: onDanger ?? this.onDanger,
      info: info ?? this.info,
      onInfo: onInfo ?? this.onInfo,
      neutral: neutral ?? this.neutral,
    );
  }

  @override
  UiColors lerp(UiColors? other, double t) {
    if (other == null) return this;
    return UiColors(
      success: Color.lerp(success, other.success, t)!,
      onSuccess: Color.lerp(onSuccess, other.onSuccess, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      onWarning: Color.lerp(onWarning, other.onWarning, t)!,
      danger: Color.lerp(danger, other.danger, t)!,
      onDanger: Color.lerp(onDanger, other.onDanger, t)!,
      info: Color.lerp(info, other.info, t)!,
      onInfo: Color.lerp(onInfo, other.onInfo, t)!,
      neutral: Color.lerp(neutral, other.neutral, t)!,
    );
  }
}

/// Convenience accessor: `context.uiColors`. Falls back to [UiColors.light] if
/// the extension is not installed (e.g. a bare `MaterialApp` with no theme).
extension UiColorsX on BuildContext {
  UiColors get uiColors =>
      Theme.of(this).extension<UiColors>() ?? UiColors.light;
}
