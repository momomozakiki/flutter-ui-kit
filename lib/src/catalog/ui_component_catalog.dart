import 'package:flutter/material.dart';

import '../components/ui_avatar.dart';
import '../components/ui_banner.dart';
import '../components/ui_button.dart';
import '../components/ui_card.dart';
import '../components/ui_checkbox.dart';
import '../components/ui_chip.dart';
import '../components/ui_dropdown.dart';
import '../components/ui_icon_button.dart';
import '../components/ui_progress_indicator.dart';
import '../components/ui_radio.dart';
import '../components/ui_slider.dart';
import '../components/ui_status_chip.dart';
import '../components/ui_switch.dart';
import '../components/ui_text.dart';
import '../components/ui_text_field.dart';

/// A single entry in the [uiComponentCatalog]: the metadata needed to list a
/// `Ui*` component and render a representative instance of it.
///
/// This is the shared registry that both the kit's own component viewer
/// (`example/`) and any consuming app (e.g. a form designer's palette) read to
/// discover what components exist and how to build a default one. Adding a new
/// component means adding one entry here — nothing auto-discovers widget classes
/// (Dart has no runtime reflection for that).
///
/// **Theme requirement:** every [sample] reads the kit theme (e.g.
/// `context.uiColors`, themed control heights), so callers must invoke
/// `sample(context)` inside a `MaterialApp` themed with `buildUiTheme()` — or one
/// that otherwise registers the kit's `ThemeExtension`s.
@immutable
class UiComponentDescriptor {
  const UiComponentDescriptor({
    required this.id,
    required this.label,
    required this.category,
    required this.sample,
  });

  /// Stable, unique identifier — mirrors the component's source file stem
  /// (e.g. `ui_button`). Used as a list key.
  final String id;

  /// Human-readable name shown in the viewer (e.g. `Button`).
  final String label;

  /// Grouping bucket for the viewer's list (e.g. `Buttons`, `Inputs`).
  final String category;

  /// Builds a representative default instance of the component. Must be called
  /// under a kit-themed `MaterialApp` (see the class doc).
  final WidgetBuilder sample;
}

/// The canonical list of `Ui*` components exposed by this kit, in display order.
///
/// Wrapped in [List.unmodifiable] so consumers can't mutate the shared registry.
/// Every entry's [UiComponentDescriptor.sample] returns a sensible default
/// instance — exactly what a form-designer palette would drop onto a canvas.
final List<UiComponentDescriptor> uiComponentCatalog =
    List<UiComponentDescriptor>.unmodifiable(<UiComponentDescriptor>[
  // --- Buttons ---
  UiComponentDescriptor(
    id: 'ui_button',
    label: 'Button',
    category: 'Buttons',
    sample: (context) => UiButton.primary(label: 'Primary', onPressed: () {}),
  ),
  UiComponentDescriptor(
    id: 'ui_icon_button',
    label: 'Icon button',
    category: 'Buttons',
    sample: (context) =>
        UiIconButton(icon: Icons.favorite, onPressed: () {}, tooltip: 'Like'),
  ),

  // --- Inputs ---
  UiComponentDescriptor(
    id: 'ui_text_field',
    label: 'Text field',
    category: 'Inputs',
    sample: (context) =>
        const UiTextField(label: 'Label', hintText: 'Type here…'),
  ),
  UiComponentDescriptor(
    id: 'ui_dropdown',
    label: 'Dropdown',
    category: 'Inputs',
    sample: (context) => UiDropdown<String>(
      label: 'Fruit',
      value: 'apple',
      items: const <UiDropdownItem<String>>[
        UiDropdownItem<String>(value: 'apple', label: 'Apple'),
        UiDropdownItem<String>(value: 'pear', label: 'Pear'),
      ],
      onChanged: (_) {},
    ),
  ),
  UiComponentDescriptor(
    id: 'ui_slider',
    label: 'Slider',
    category: 'Inputs',
    sample: (context) =>
        UiSlider(value: 0.5, onChanged: (_) {}, showValue: true),
  ),

  // --- Selection ---
  UiComponentDescriptor(
    id: 'ui_checkbox',
    label: 'Checkbox',
    category: 'Selection',
    sample: (context) =>
        UiCheckbox(label: 'Accept terms', value: true, onChanged: (_) {}),
  ),
  UiComponentDescriptor(
    id: 'ui_radio',
    label: 'Radio group',
    category: 'Selection',
    sample: (context) => UiRadioGroup<String>(
      groupValue: 'a',
      items: const <UiRadioItem<String>>[
        UiRadioItem<String>(value: 'a', label: 'Option A'),
        UiRadioItem<String>(value: 'b', label: 'Option B'),
      ],
      onChanged: (_) {},
    ),
  ),
  UiComponentDescriptor(
    id: 'ui_switch',
    label: 'Switch',
    category: 'Selection',
    sample: (context) =>
        UiSwitch(label: 'Enabled', value: true, onChanged: (_) {}),
  ),
  UiComponentDescriptor(
    id: 'ui_chip',
    label: 'Chip',
    category: 'Selection',
    sample: (context) =>
        UiChip(label: 'Filter', selected: true, onSelected: (_) {}),
  ),

  // --- Display ---
  UiComponentDescriptor(
    id: 'ui_text',
    label: 'Text',
    category: 'Display',
    sample: (context) => const UiText.title('Heading'),
  ),
  UiComponentDescriptor(
    id: 'ui_avatar',
    label: 'Avatar',
    category: 'Display',
    sample: (context) => const UiAvatar(initials: 'AB'),
  ),
  UiComponentDescriptor(
    id: 'ui_card',
    label: 'Card',
    category: 'Display',
    sample: (context) => const UiCard(child: UiText('Card content')),
  ),
  UiComponentDescriptor(
    id: 'ui_status_chip',
    label: 'Status chip',
    category: 'Display',
    sample: (context) =>
        const UiStatusChip(label: 'Connected', status: UiStatus.success),
  ),

  // --- Feedback ---
  UiComponentDescriptor(
    id: 'ui_banner',
    label: 'Banner',
    category: 'Feedback',
    sample: (context) => const UiBanner.info('This is an informational banner.'),
  ),
  UiComponentDescriptor(
    id: 'ui_progress_indicator',
    label: 'Progress indicator',
    category: 'Feedback',
    sample: (context) => const UiProgressIndicator.circular(),
  ),
]);
