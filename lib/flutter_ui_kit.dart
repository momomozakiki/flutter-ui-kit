/// flutter_ui_kit: a reusable, domain-agnostic Flutter design system and
/// component library.
///
/// Two layers, mirroring the folder structure:
/// * **theme/** — reusable *properties* (design tokens): [UiSpacing], [UiSizing],
///   [UiRadius], [UiTypography], [UiColors] (a [ThemeExtension]), [UiBreakpoints]
///   / [UiDeviceClass], and [buildUiTheme].
/// * **components/** — core atomic widgets ([UiButton], [UiIconButton],
///   [UiTextField], [UiDropdown], [UiCheckbox], [UiRadio] / [UiRadioGroup],
///   [UiSwitch], [UiSlider], [UiStatusChip], [UiChip], [UiBanner], [UiCard],
///   [UiText], [UiAvatar], [UiProgressIndicator]).
/// * **composite/** — generic compositions ([UiResponsive]).
/// * **catalog/** — the [uiComponentCatalog] registry ([UiComponentDescriptor])
///   listing every component + a default sample, shared by the viewer and any
///   consumer palette.
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
export 'src/theme/ui_tone.dart';
export 'src/theme/ui_tuning.dart';
export 'src/theme/ui_typography.dart';

// components (core atoms)
export 'src/components/ui_avatar.dart';
export 'src/components/ui_banner.dart';
export 'src/components/ui_button.dart';
export 'src/components/ui_card.dart';
export 'src/components/ui_checkbox.dart';
export 'src/components/ui_chip.dart';
export 'src/components/ui_dropdown.dart';
export 'src/components/ui_icon_button.dart';
export 'src/components/ui_progress_indicator.dart';
export 'src/components/ui_radio.dart';
export 'src/components/ui_slider.dart';
export 'src/components/ui_status_chip.dart';
export 'src/components/ui_switch.dart';
export 'src/components/ui_text.dart';
export 'src/components/ui_text_field.dart';

// catalog (component registry — shared by the viewer and consumer palettes)
export 'src/catalog/ui_component_catalog.dart';

// composite (generic compositions)
export 'src/composite/ui_responsive.dart';
export 'src/composite/ui_tuning_overlay.dart';
export 'src/composite/ui_tuning_panel.dart';
export 'src/composite/under_maintenance_page.dart';
