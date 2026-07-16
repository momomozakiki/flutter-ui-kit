import 'package:flutter/material.dart';
import 'package:flutter_ui_kit/flutter_ui_kit.dart';

/// Interactive, multi-state demos for the component viewer, keyed by the
/// catalog descriptor's stable [UiComponentDescriptor.id].
///
/// This layer lives in the `example/` app *on purpose*: the shared
/// `uiComponentCatalog` in `lib/src/catalog/` intentionally returns one static
/// default instance per component (exactly what a form-designer palette drops on
/// a canvas), so it can't hold state. Here we mirror the pattern odb's real app
/// screens use — bind `value`/`onChanged` to `setState` — so switches, sliders,
/// checkboxes, dropdowns, radios and chips actually respond, and buttons show
/// their full range of variants/tones/states plus a live tap counter.
///
/// Returns the interactive demo for [id], or `null` when the component has no
/// richer demo (the caller then falls back to the catalog's static `sample`).
Widget? buildComponentDemo(String id) {
  final WidgetBuilder? builder = _demos[id];
  return builder == null ? null : Builder(builder: builder);
}

/// Registry of `id` → interactive demo builder. Absent ids fall back to the
/// catalog `sample` in the viewer.
final Map<String, WidgetBuilder> _demos = <String, WidgetBuilder>{
  'ui_button': (context) => const _ButtonDemo(),
  'ui_icon_button': (context) => const _IconButtonDemo(),
  'ui_text_field': (context) => const _TextFieldDemo(),
  'ui_dropdown': (context) => const _DropdownDemo(),
  'ui_slider': (context) => const _SliderDemo(),
  'ui_checkbox': (context) => const _CheckboxDemo(),
  'ui_radio': (context) => const _RadioDemo(),
  'ui_switch': (context) => const _SwitchDemo(),
  'ui_chip': (context) => const _ChipDemo(),
  'ui_text': (context) => const _TextDemo(),
  'ui_status_chip': (context) => const _StatusChipDemo(),
  'ui_banner': (context) => const _BannerDemo(),
  'ui_progress_indicator': (context) => const _ProgressDemo(),
  // Molecules / organisms (tiers beyond the shared atom catalog).
  'ui_responsive': (context) => const _ResponsiveDemo(),
  'ui_adaptive_nav_shell': (context) => const _AdaptiveNavShellDemo(),
};

/// A titled group of related states inside a demo, laid out vertically.
class _Section extends StatelessWidget {
  const _Section(this.title, this.children);

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        UiText.caption(title.toUpperCase()),
        UiSpacing.gapVXs,
        ...children,
        UiSpacing.gapVLg,
      ],
    );
  }
}

// --- Buttons ---

class _ButtonDemo extends StatefulWidget {
  const _ButtonDemo();

  @override
  State<_ButtonDemo> createState() => _ButtonDemoState();
}

class _ButtonDemoState extends State<_ButtonDemo> {
  int _taps = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _Section('Variants', <Widget>[
          Wrap(
            spacing: UiSpacing.sm,
            runSpacing: UiSpacing.sm,
            children: <Widget>[
              UiButton.primary(label: 'Primary', onPressed: () {}),
              UiButton.secondary(label: 'Secondary', onPressed: () {}),
              UiButton.text(label: 'Text', onPressed: () {}),
            ],
          ),
        ]),
        _Section('Tones', <Widget>[
          Wrap(
            spacing: UiSpacing.sm,
            runSpacing: UiSpacing.sm,
            children: <Widget>[
              UiButton.primary(
                  label: 'Success',
                  tone: UiButtonTone.success,
                  onPressed: () {}),
              UiButton.primary(
                  label: 'Danger',
                  tone: UiButtonTone.danger,
                  onPressed: () {}),
              UiButton.secondary(
                  label: 'Danger',
                  tone: UiButtonTone.danger,
                  onPressed: () {}),
            ],
          ),
        ]),
        _Section('Icon · compact · disabled', <Widget>[
          Wrap(
            spacing: UiSpacing.sm,
            runSpacing: UiSpacing.sm,
            children: <Widget>[
              UiButton.primary(
                  label: 'Save', icon: Icons.save, onPressed: () {}),
              UiButton.secondary(
                  label: 'Compact',
                  size: UiButtonSize.compact,
                  onPressed: () {}),
              const UiButton.primary(label: 'Disabled', onPressed: null),
            ],
          ),
        ]),
        _Section('Interactive', <Widget>[
          Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              UiButton.primary(
                label: 'Tap me',
                icon: Icons.touch_app,
                onPressed: () => setState(() => _taps++),
              ),
              UiSpacing.gapHMd,
              UiText('Tapped: $_taps times'),
            ],
          ),
        ]),
      ],
    );
  }
}

class _IconButtonDemo extends StatefulWidget {
  const _IconButtonDemo();

  @override
  State<_IconButtonDemo> createState() => _IconButtonDemoState();
}

class _IconButtonDemoState extends State<_IconButtonDemo> {
  int _taps = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _Section('Variants', <Widget>[
          Wrap(
            spacing: UiSpacing.sm,
            children: <Widget>[
              UiIconButton(
                  icon: Icons.settings, onPressed: () {}, tooltip: 'Standard'),
              UiIconButton(
                  icon: Icons.add,
                  variant: UiIconButtonVariant.filled,
                  onPressed: () {},
                  tooltip: 'Filled'),
              UiIconButton(
                  icon: Icons.edit,
                  variant: UiIconButtonVariant.outlined,
                  onPressed: () {},
                  tooltip: 'Outlined'),
              const UiIconButton(
                  icon: Icons.block, onPressed: null, tooltip: 'Disabled'),
            ],
          ),
        ]),
        _Section('Interactive', <Widget>[
          Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              UiIconButton(
                icon: Icons.favorite,
                tone: UiTone.danger,
                onPressed: () => setState(() => _taps++),
                tooltip: 'Like',
              ),
              UiSpacing.gapHMd,
              UiText('Liked: $_taps times'),
            ],
          ),
        ]),
      ],
    );
  }
}

// --- Inputs ---

class _TextFieldDemo extends StatefulWidget {
  const _TextFieldDemo();

  @override
  State<_TextFieldDemo> createState() => _TextFieldDemoState();
}

class _TextFieldDemoState extends State<_TextFieldDemo> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _Section('Interactive', <Widget>[
          UiTextField(
            label: 'Your name',
            hintText: 'Type here…',
            controller: _controller,
            onChanged: (_) => setState(() {}),
          ),
          UiSpacing.gapVSm,
          UiText(_controller.text.isEmpty
              ? 'You typed: (nothing yet)'
              : 'You typed: ${_controller.text}'),
        ]),
        _Section('States', <Widget>[
          const UiTextField(label: 'Disabled', enabled: false, hintText: 'Read-only'),
          UiSpacing.gapVSm,
          const UiTextField(
              label: 'Password', obscureText: true, hintText: '••••••'),
        ]),
      ],
    );
  }
}

class _DropdownDemo extends StatefulWidget {
  const _DropdownDemo();

  @override
  State<_DropdownDemo> createState() => _DropdownDemoState();
}

class _DropdownDemoState extends State<_DropdownDemo> {
  String _value = 'apple';

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _Section('Interactive', <Widget>[
          UiDropdown<String>(
            label: 'Fruit',
            value: _value,
            items: const <UiDropdownItem<String>>[
              UiDropdownItem<String>(value: 'apple', label: 'Apple'),
              UiDropdownItem<String>(value: 'pear', label: 'Pear'),
              UiDropdownItem<String>(value: 'mango', label: 'Mango'),
              UiDropdownItem<String>(value: 'kiwi', label: 'Kiwi'),
            ],
            onChanged: (v) => setState(() => _value = v ?? _value),
          ),
          UiSpacing.gapVSm,
          UiText('Selected: $_value'),
        ]),
      ],
    );
  }
}

class _SliderDemo extends StatefulWidget {
  const _SliderDemo();

  @override
  State<_SliderDemo> createState() => _SliderDemoState();
}

class _SliderDemoState extends State<_SliderDemo> {
  double _value = 0.5;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _Section('Interactive', <Widget>[
          UiSlider(
            value: _value,
            showValue: true,
            onChanged: (v) => setState(() => _value = v),
          ),
          UiSpacing.gapVSm,
          UiText('Value: ${_value.toStringAsFixed(2)}'),
        ]),
      ],
    );
  }
}

// --- Selection ---

class _CheckboxDemo extends StatefulWidget {
  const _CheckboxDemo();

  @override
  State<_CheckboxDemo> createState() => _CheckboxDemoState();
}

class _CheckboxDemoState extends State<_CheckboxDemo> {
  bool _accepted = true;

  @override
  Widget build(BuildContext context) {
    return _Section('Interactive', <Widget>[
      UiCheckbox(
        label: 'Accept terms',
        value: _accepted,
        onChanged: (v) => setState(() => _accepted = v),
      ),
      UiSpacing.gapVSm,
      UiText(_accepted ? 'Terms accepted' : 'Terms not accepted'),
    ]);
  }
}

class _RadioDemo extends StatefulWidget {
  const _RadioDemo();

  @override
  State<_RadioDemo> createState() => _RadioDemoState();
}

class _RadioDemoState extends State<_RadioDemo> {
  String _value = 'a';

  @override
  Widget build(BuildContext context) {
    return _Section('Interactive', <Widget>[
      UiRadioGroup<String>(
        groupValue: _value,
        items: const <UiRadioItem<String>>[
          UiRadioItem<String>(value: 'a', label: 'Option A'),
          UiRadioItem<String>(value: 'b', label: 'Option B'),
          UiRadioItem<String>(value: 'c', label: 'Option C'),
        ],
        onChanged: (v) => setState(() => _value = v ?? _value),
      ),
      UiSpacing.gapVSm,
      UiText('Selected: $_value'),
    ]);
  }
}

class _SwitchDemo extends StatefulWidget {
  const _SwitchDemo();

  @override
  State<_SwitchDemo> createState() => _SwitchDemoState();
}

class _SwitchDemoState extends State<_SwitchDemo> {
  bool _on = true;

  @override
  Widget build(BuildContext context) {
    return _Section('Interactive', <Widget>[
      UiSwitch(
        label: 'Enabled',
        value: _on,
        onChanged: (v) => setState(() => _on = v),
      ),
      UiSpacing.gapVSm,
      UiText(_on ? 'Switched ON' : 'Switched OFF'),
    ]);
  }
}

class _ChipDemo extends StatefulWidget {
  const _ChipDemo();

  @override
  State<_ChipDemo> createState() => _ChipDemoState();
}

class _ChipDemoState extends State<_ChipDemo> {
  final Set<String> _selected = <String>{'Flutter'};

  @override
  Widget build(BuildContext context) {
    const List<String> filters = <String>['Flutter', 'Dart', 'Web', 'Mobile'];
    return _Section('Interactive · tap to toggle', <Widget>[
      Wrap(
        spacing: UiSpacing.sm,
        runSpacing: UiSpacing.sm,
        children: <Widget>[
          for (final String f in filters)
            UiChip(
              label: f,
              selected: _selected.contains(f),
              onSelected: (sel) => setState(() {
                if (sel) {
                  _selected.add(f);
                } else {
                  _selected.remove(f);
                }
              }),
            ),
        ],
      ),
      UiSpacing.gapVSm,
      UiText('Selected: ${_selected.isEmpty ? '(none)' : _selected.join(', ')}'),
    ]);
  }
}

// --- Display (static multi-variant showcases) ---

class _TextDemo extends StatelessWidget {
  const _TextDemo();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        UiText.title('Title role'),
        UiSpacing.gapVXs,
        UiText('Body role — default running text.'),
        UiSpacing.gapVXs,
        UiText.label('Label role'),
        UiSpacing.gapVXs,
        UiText.caption('Caption role — de-emphasised metadata.'),
        UiSpacing.gapVXs,
        UiText.mono('mono_role_1234'),
      ],
    );
  }
}

class _StatusChipDemo extends StatelessWidget {
  const _StatusChipDemo();

  @override
  Widget build(BuildContext context) {
    return const _Section('All statuses', <Widget>[
      Wrap(
        spacing: UiSpacing.sm,
        runSpacing: UiSpacing.sm,
        children: <Widget>[
          UiStatusChip(label: 'Connected', status: UiStatus.success),
          UiStatusChip(label: 'Warning', status: UiStatus.warning),
          UiStatusChip(label: 'Error', status: UiStatus.danger),
          UiStatusChip(label: 'Info', status: UiStatus.info),
          UiStatusChip(label: 'Idle', status: UiStatus.neutral),
        ],
      ),
    ]);
  }
}

class _BannerDemo extends StatelessWidget {
  const _BannerDemo();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        UiBanner.info('This is an informational banner.'),
        UiSpacing.gapVSm,
        UiBanner.success('Saved successfully.'),
        UiSpacing.gapVSm,
        UiBanner.warning('Double-check your input.'),
        UiSpacing.gapVSm,
        UiBanner.error('Something went wrong.'),
      ],
    );
  }
}

class _ProgressDemo extends StatelessWidget {
  const _ProgressDemo();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _Section('Indeterminate', <Widget>[
          UiProgressIndicator.circular(),
          UiSpacing.gapVSm,
          UiProgressIndicator.linear(),
        ]),
        _Section('Determinate (65%)', <Widget>[
          UiProgressIndicator.circular(value: 0.65),
          UiSpacing.gapVSm,
          UiProgressIndicator.linear(value: 0.65),
        ]),
      ],
    );
  }
}

// --- Molecules ---

/// Shows how [UiResponsive] rebuilds its subtree against the available width's
/// [UiDeviceClass] — stacked when narrow, side-by-side when wide. Resize the
/// window (or drag the divider) to watch it flip.
class _ResponsiveDemo extends StatelessWidget {
  const _ResponsiveDemo();

  @override
  Widget build(BuildContext context) {
    return _Section('Reflows by available width', <Widget>[
      UiResponsive(
        builder: (BuildContext context, UiDeviceClass deviceClass) {
          final bool wide = deviceClass == UiDeviceClass.expanded ||
              deviceClass == UiDeviceClass.large;
          final List<Widget> boxes = <Widget>[
            const Expanded(child: UiCard(child: UiText('Pane A'))),
            const Expanded(child: UiCard(child: UiText('Pane B'))),
          ];
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              UiStatusChip(
                label: 'device class: ${deviceClass.name}'
                    '  ·  ${wide ? 'row' : 'stacked'}',
                status: UiStatus.info,
              ),
              UiSpacing.gapVSm,
              if (wide)
                Row(children: boxes)
              else
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    UiCard(child: UiText('Pane A')),
                    SizedBox(height: 8),
                    UiCard(child: UiText('Pane B')),
                  ],
                ),
            ],
          );
        },
      ),
    ]);
  }
}

// --- Organisms ---

/// A bounded, interactive [UiAdaptiveNavShell]: selecting a rail/bar
/// destination swaps the body. It renders a bottom bar / rail / extended rail
/// purely from the width it's given — shrink the preview to see it adapt.
class _AdaptiveNavShellDemo extends StatefulWidget {
  const _AdaptiveNavShellDemo();

  @override
  State<_AdaptiveNavShellDemo> createState() => _AdaptiveNavShellDemoState();
}

class _AdaptiveNavShellDemoState extends State<_AdaptiveNavShellDemo> {
  int _index = 0;

  static const List<UiNavDestination> _destinations = <UiNavDestination>[
    UiNavDestination(icon: Icons.home_outlined, label: 'Home'),
    UiNavDestination(icon: Icons.search_outlined, label: 'Search'),
    UiNavDestination(icon: Icons.settings_outlined, label: 'Settings'),
  ];

  @override
  Widget build(BuildContext context) {
    return _Section('Width-driven navigation', <Widget>[
      SizedBox(
        height: 360,
        child: UiAdaptiveNavShell(
          selectedIndex: _index,
          onDestinationSelected: (int i) => setState(() => _index = i),
          destinations: _destinations,
          body: Center(
            child: UiText.title(_destinations[_index].label),
          ),
        ),
      ),
    ]);
  }
}
