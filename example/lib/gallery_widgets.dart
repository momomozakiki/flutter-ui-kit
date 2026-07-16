import 'package:flutter/material.dart';
import 'package:flutter_ui_kit/flutter_ui_kit.dart';

import 'component_demos.dart';

/// A selectable master list of [items], grouped by
/// [UiComponentDescriptor.category].
///
/// Extracted from the original single-screen gallery so both the tiered
/// [GalleryShell] and any other viewer render one identical list. Unlike the
/// original (which iterated the global `uiComponentCatalog`), this takes an
/// explicit [items] list so it can render any tier's descriptors.
class CatalogList extends StatelessWidget {
  const CatalogList({
    super.key,
    required this.items,
    required this.selected,
    required this.onSelect,
  });

  /// The descriptors to list, in display order.
  final List<UiComponentDescriptor> items;

  /// Index of the highlighted row, or `null` when selection isn't shown.
  final int? selected;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    final List<Widget> rows = <Widget>[];
    String? lastCategory;
    for (int i = 0; i < items.length; i++) {
      final UiComponentDescriptor d = items[i];
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
///
/// Prefers the example app's richer interactive demo
/// (`buildComponentDemo(id)`); falls back to the descriptor's static `sample`
/// when a component has no dedicated demo.
class PreviewPanel extends StatelessWidget {
  const PreviewPanel(this.descriptor, {super.key});

  final UiComponentDescriptor descriptor;

  @override
  Widget build(BuildContext context) {
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
