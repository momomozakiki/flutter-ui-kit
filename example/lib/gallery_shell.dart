import 'package:flutter/material.dart';
import 'package:flutter_ui_kit/flutter_ui_kit.dart';

import 'gallery_widgets.dart';
import 'tier_registry.dart';

/// The Atomic-Design gallery: a manually-toggleable side nav whose tiers are
/// Atoms / Molecules / Organisms / Templates / Pages, with a master list of
/// that tier's components and a live preview of the selected one.
///
/// The nav is a plain [NavigationRail] — deliberately **not** the kit's
/// [UiAdaptiveNavShell], which switches icon-only vs icon+label purely by width.
/// A reviewer wants to *toggle* that themselves, so the hamburger flips
/// [_navExpanded] regardless of window size.
///
/// The app bar keeps the kit's [UiThemePicker] (color + light/dark/system) and
/// the live-token [UiTuningOverlay], so every component recolors and resizes as
/// the theme and tokens change.
class GalleryShell extends StatefulWidget {
  const GalleryShell({super.key});

  @override
  State<GalleryShell> createState() => _GalleryShellState();
}

class _GalleryShellState extends State<GalleryShell> {
  /// Selected nav tier (index into [galleryTiers]).
  int _tierIndex = 0;

  /// Manual rail toggle: expanded shows icon + label, collapsed shows icon only.
  bool _navExpanded = true;

  /// Remember the selected component per tier so switching tabs is sticky.
  final Map<int, int> _selectedByTier = <int, int>{};

  void _openThemePicker() {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (BuildContext context) => const SafeArea(child: UiThemePicker()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final GalleryTier tier = galleryTiers[_tierIndex];
    return Scaffold(
      appBar: AppBar(
        title: const Text('flutter_ui_kit — atomic gallery'),
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
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          NavigationRail(
            extended: _navExpanded,
            // `extended` labels render inline, so labelType must be null then.
            labelType:
                _navExpanded ? null : NavigationRailLabelType.none,
            leading: IconButton(
              icon: const Icon(Icons.menu),
              tooltip: _navExpanded ? 'Collapse navigation' : 'Expand navigation',
              onPressed: () => setState(() => _navExpanded = !_navExpanded),
            ),
            selectedIndex: _tierIndex,
            onDestinationSelected: (int i) => setState(() => _tierIndex = i),
            destinations: <NavigationRailDestination>[
              for (final GalleryTier t in galleryTiers)
                NavigationRailDestination(
                  icon: Icon(t.icon),
                  label: Text(t.label),
                ),
            ],
          ),
          const VerticalDivider(width: 1),
          Expanded(child: _tierBody(tier)),
        ],
      ),
    );
  }

  Widget _tierBody(GalleryTier tier) {
    // Templates / Pages: the kit has none by design — show the explainer.
    final WidgetBuilder? placeholder = tier.placeholder;
    if (placeholder != null) {
      return placeholder(context);
    }

    final int selected = _selectedByTier[_tierIndex] ?? 0;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        SizedBox(
          width: 260,
          child: CatalogList(
            items: tier.descriptors,
            selected: selected,
            onSelect: (int i) =>
                setState(() => _selectedByTier[_tierIndex] = i),
          ),
        ),
        const VerticalDivider(width: 1),
        Expanded(child: PreviewPanel(tier.descriptors[selected])),
      ],
    );
  }
}
