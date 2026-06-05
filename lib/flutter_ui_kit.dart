/// flutter_ui_kit: a reusable, domain-agnostic Flutter design system and
/// component library.
///
/// Two layers, mirroring the folder structure:
/// * **theme/** — reusable *properties* (design tokens): [UiSpacing], [UiSizing],
///   [UiRadius], [UiTypography], [UiColors] (a [ThemeExtension]), [UiBreakpoints]
///   / [UiDeviceClass], and [buildUiTheme].
/// * **components/** — core atomic widgets ([UiButton], [UiTextField],
///   [UiDropdown], [UiStatusChip], [UiBanner], [UiCheckbox]).
/// * **composite/** — generic compositions ([UiResponsive]).
///
/// The package depends only on the Flutter SDK, so it carries no transport or
/// domain coupling and can be dropped into any Flutter project.
library;

// theme (design tokens)
export 'src/theme/ui_breakpoints.dart';
export 'src/theme/ui_colors.dart';
export 'src/theme/ui_radius.dart';
export 'src/theme/ui_sizing.dart';
export 'src/theme/ui_spacing.dart';
export 'src/theme/ui_theme.dart';
export 'src/theme/ui_typography.dart';

// components (core atoms)
export 'src/components/ui_banner.dart';
export 'src/components/ui_button.dart';
export 'src/components/ui_checkbox.dart';
export 'src/components/ui_dropdown.dart';
export 'src/components/ui_status_chip.dart';
export 'src/components/ui_text_field.dart';

// composite (generic compositions)
export 'src/composite/ui_responsive.dart';
