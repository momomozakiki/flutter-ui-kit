import 'package:flutter/material.dart';
import 'package:flutter_ui_kit/flutter_ui_kit.dart';

import 'component_demos.dart';

/// The component gallery: a master list of every entry in [uiComponentCatalog]
/// on the left and a live preview of the selected component on the right.
///
/// The layout adapts via the kit's own [UiResponsive]: side-by-side on wide
/// screens, and a list that pushes a full-screen preview on narrow ones. The app
/// bar opens the kit's [UiThemePicker] (color + light/dark/system, backed by
/// [UiThemeController]) and toggles the kit's live-token [UiTuningOverlay], so
/// every component recolors and resizes as the theme and tokens change.
class GalleryScreen extends StatefulWidget {
  const GalleryScreen({super.key});

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  int _selected = 0;

  void _openThemePicker() {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (BuildContext context) => const SafeArea(child: UiThemePicker()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('flutter_ui_kit — components'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.palette_outlined),
            tooltip: 'Theme color & appearance',
            onPressed: _openThemePicker,
          ),
          IconButton(
            icon: const Icon(Icons.tune),
            tooltip: 'Toggle live token tuning',
            onPressed: () => UiTuningOverlay.toggle(context),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: UiResponsive(
        builder: (context, deviceClass) {
          final bool wide = deviceClass == UiDeviceClass.expanded ||
              deviceClass == UiDeviceClass.large;
          if (wide) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                SizedBox(
                  width: 260,
                  child: _CatalogList(
                    selected: _selected,
                    onSelect: (i) => setState(() => _selected = i),
                  ),
                ),
                const VerticalDivider(width: 1),
                Expanded(
                  child: _PreviewPanel(uiComponentCatalog[_selected]),
                ),
              ],
            );
          }
          // Narrow: the list fills the screen; a tap opens the preview.
          return _CatalogList(
            selected: null,
            onSelect: (i) => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => Scaffold(
                  appBar: AppBar(title: Text(uiComponentCatalog[i].label)),
                  body: _PreviewPanel(uiComponentCatalog[i]),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// The selectable master list, grouped by [UiComponentDescriptor.category].
class _CatalogList extends StatelessWidget {
  const _CatalogList({required this.selected, required this.onSelect});

  /// Index of the highlighted row, or `null` when selection isn't shown
  /// (narrow layout, where tapping navigates instead).
  final int? selected;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    final List<Widget> rows = <Widget>[];
    String? lastCategory;
    for (int i = 0; i < uiComponentCatalog.length; i++) {
      final UiComponentDescriptor d = uiComponentCatalog[i];
      if (d.category != lastCategory) {
        lastCategory = d.category;
        rows.add(Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
          child: UiText.caption(d.category.toUpperCase()),
        ));
      }
      rows.add(ListTile(
        dense: true,
        selected: i == selected,
        title: Text(d.label),
        subtitle: Text(d.id),
        onTap: () => onSelect(i),
      ));
    }
    return ListView(children: rows);
  }
}

/// The live preview of a single component, centered on a neutral surface.
class _PreviewPanel extends StatelessWidget {
  const _PreviewPanel(this.descriptor);

  final UiComponentDescriptor descriptor;

  @override
  Widget build(BuildContext context) {
    // Prefer the example app's richer interactive demo; fall back to the shared
    // catalog's single static sample when a component has no dedicated demo.
    final Widget preview =
        buildComponentDemo(descriptor.id) ?? descriptor.sample(context);
    return Container(
      color: Theme.of(context).colorScheme.surfaceContainerLowest,
      padding: const EdgeInsets.all(24),
      alignment: Alignment.topCenter,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            UiText.title(descriptor.label),
            const SizedBox(height: 4),
            UiText.caption(descriptor.id),
            const SizedBox(height: 24),
            ConstrainedBox(
              // Multi-state demos are taller/wider than one control; give them
              // room while keeping a comfortable reading measure.
              constraints: const BoxConstraints(maxWidth: 520),
              child: UiCard(
                child: SizedBox(width: double.infinity, child: preview),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
