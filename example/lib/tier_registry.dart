import 'package:flutter/material.dart';
import 'package:flutter_ui_kit/flutter_ui_kit.dart';

/// One nav tier in the [GalleryShell]: its rail label + icon, and either the
/// component descriptors to browse (Atoms / Molecules / Organisms) or a
/// [placeholder] shown when the kit intentionally has nothing at that tier
/// (Templates / Pages live in consuming apps, not the shared kit).
///
/// This mapping lives in `example/` **on purpose** — it keeps the shared
/// `uiComponentCatalog` in `lib/src/catalog/` (which lists only atoms) untouched
/// and free of viewer-specific tiering.
@immutable
class GalleryTier {
  const GalleryTier({
    required this.label,
    required this.icon,
    this.descriptors = const <UiComponentDescriptor>[],
    this.placeholder,
  });

  /// Rail label, e.g. `Atoms`.
  final String label;

  /// Rail icon.
  final IconData icon;

  /// Components shown in this tier, in display order. Empty for placeholder
  /// tiers (see [placeholder]).
  final List<UiComponentDescriptor> descriptors;

  /// Non-null for tiers the kit has no components for (Templates / Pages).
  /// When set, the shell renders this instead of a master/detail list.
  final WidgetBuilder? placeholder;
}

/// The five Atomic-Design tiers shown in the gallery's side nav.
///
/// Not `const`: the Atoms tier reuses the kit's runtime `uiComponentCatalog`.
final List<GalleryTier> galleryTiers = <GalleryTier>[
  GalleryTier(
    label: 'Atoms',
    icon: Icons.category,
    // The kit's shared catalog is entirely atoms today — reuse it verbatim.
    descriptors: uiComponentCatalog,
  ),
  GalleryTier(
    label: 'Molecules',
    icon: Icons.widgets,
    descriptors: _molecules,
  ),
  GalleryTier(
    label: 'Organisms',
    icon: Icons.dashboard,
    descriptors: _organisms,
  ),
  GalleryTier(
    label: 'Templates',
    icon: Icons.view_quilt,
    placeholder: (context) => const _TierNotice(
      title: 'Templates',
      message: 'Templates are app-specific compositions of atoms, molecules '
          'and organisms — a screen skeleton with placeholder content. This '
          'kit provides the building blocks; your app builds the templates.',
    ),
  ),
  GalleryTier(
    label: 'Pages',
    icon: Icons.web,
    placeholder: (context) => const _TierNotice(
      title: 'Pages',
      message: 'Pages are concrete screens wired to real data and routing. '
          'They live in the consuming app, not in the shared kit.',
    ),
  ),
];

/// The kit's generic, stateless compositions (molecules).
final List<UiComponentDescriptor> _molecules = <UiComponentDescriptor>[
  UiComponentDescriptor(
    id: 'ui_responsive',
    label: 'Responsive',
    category: 'Layout',
    sample: (context) => UiResponsive(
      builder: (context, deviceClass) =>
          UiText('Current device class: ${deviceClass.name}'),
    ),
  ),
];

/// The kit's generic compositions with local UI state (organisms).
final List<UiComponentDescriptor> _organisms = <UiComponentDescriptor>[
  UiComponentDescriptor(
    id: 'ui_theme_picker',
    label: 'Theme picker',
    category: 'Theming',
    sample: (context) => const UiThemePicker(),
  ),
  UiComponentDescriptor(
    id: 'ui_under_maintenance',
    label: 'Under maintenance',
    category: 'Placeholders',
    // Bounded height: the widget centers in a full screen; give it room inside
    // the preview card.
    sample: (context) => const SizedBox(
      height: 320,
      child: UiUnderMaintenance(
        icon: Icons.construction,
        title: 'Feature name',
      ),
    ),
  ),
  UiComponentDescriptor(
    id: 'ui_adaptive_nav_shell',
    label: 'Adaptive nav shell',
    category: 'Navigation',
    // Static fallback; `buildComponentDemo('ui_adaptive_nav_shell')` supplies
    // the interactive version in the viewer. Not `const`: the shell asserts on
    // `destinations.length`, which isn't const-evaluable.
    sample: (context) => SizedBox(
      height: 360,
      child: UiAdaptiveNavShell(
        selectedIndex: 0,
        onDestinationSelected: _noop,
        destinations: const <UiNavDestination>[
          UiNavDestination(icon: Icons.home_outlined, label: 'Home'),
          UiNavDestination(icon: Icons.settings_outlined, label: 'Settings'),
        ],
        body: const Center(child: UiText('Body')),
      ),
    ),
  ),
];

void _noop(int _) {}

/// The centered explainer shown for the Templates / Pages tiers.
class _TierNotice extends StatelessWidget {
  const _TierNotice({required this.title, required this.message});

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.surfaceContainerLowest,
      alignment: Alignment.topCenter,
      padding: const EdgeInsets.all(24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            UiText.title(title),
            UiSpacing.gapVMd,
            UiBanner.info(message),
          ],
        ),
      ),
    );
  }
}
