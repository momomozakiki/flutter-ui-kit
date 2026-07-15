/// flutter_ui_kit: a reusable, domain-agnostic Flutter design system and
/// component library.
///
/// Layers mirror the folder structure, following strict Atomic Design (this kit
/// is the canonical Atomic Design authority consuming apps mirror):
/// * **theme/** — design *tokens* (reusable properties): [UiSpacing], [UiSizing],
///   [UiRadius], [UiTypography], [UiColors] (a [ThemeExtension]), [UiBreakpoints]
///   / [UiDeviceClass], and [buildUiTheme].
/// * **atoms/** — indivisible stateless widgets ([UiButton], [UiIconButton],
///   [UiTextField], [UiDropdown], [UiCheckbox], [UiRadio] / [UiRadioGroup],
///   [UiSwitch], [UiSlider], [UiStatusChip], [UiChip], [UiBanner], [UiCard],
///   [UiText], [UiAvatar], [UiProgressIndicator]).
/// * **molecules/** — stateless compositions of atoms ([UiResponsive]).
/// * **organisms/** — compositions that may own local UI state
///   ([UiAdaptiveNavShell], [UiTuningPanel], [UiTuningOverlay],
///   [UiUnderMaintenance]).
/// * **catalog/** — the [uiComponentCatalog] registry ([UiComponentDescriptor])
///   listing every atom + a default sample, shared by the viewer and any
///   consumer palette.
///
/// Templates and pages are intentionally out of scope — they live in consuming
/// apps per the repo-separation rule. The package depends only on the Flutter
/// SDK, so it carries no transport or domain coupling and can be dropped into
/// any Flutter project.
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

// atoms (indivisible stateless widgets)
export 'src/atoms/ui_avatar.dart';
export 'src/atoms/ui_banner.dart';
export 'src/atoms/ui_button.dart';
export 'src/atoms/ui_card.dart';
export 'src/atoms/ui_checkbox.dart';
export 'src/atoms/ui_chip.dart';
export 'src/atoms/ui_dropdown.dart';
export 'src/atoms/ui_icon_button.dart';
export 'src/atoms/ui_progress_indicator.dart';
export 'src/atoms/ui_radio.dart';
export 'src/atoms/ui_slider.dart';
export 'src/atoms/ui_status_chip.dart';
export 'src/atoms/ui_switch.dart';
export 'src/atoms/ui_text.dart';
export 'src/atoms/ui_text_field.dart';

// catalog (component registry — shared by the viewer and consumer palettes)
export 'src/catalog/ui_component_catalog.dart';

// molecules (stateless compositions of atoms)
export 'src/molecules/ui_responsive.dart';

// organisms (compositions that may own local UI state)
export 'src/organisms/ui_adaptive_nav_shell.dart';
export 'src/organisms/ui_tuning_overlay.dart';
export 'src/organisms/ui_tuning_panel.dart';
export 'src/organisms/ui_under_maintenance.dart';
