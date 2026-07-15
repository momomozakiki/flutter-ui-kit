import 'package:flutter/material.dart';

import '../theme/ui_breakpoints.dart';

// Tier: organism — a top-level navigation scaffold. It owns no business logic
// and no data fetching; selection state is delegated upward (see the controlled
// `selectedIndex` / `onDestinationSelected` pair), so it is stateless here.
// Named without a `_page` suffix because page/template widgets live in
// consuming apps, not the kit.

/// A single navigation destination for [UiAdaptiveNavShell].
///
/// Declared once and rendered by the shell as either a [NavigationDestination]
/// (Material 3 [NavigationBar], compact) or a [NavigationRailDestination]
/// ([NavigationRail], medium and wider) — the caller never picks the widget.
@immutable
class UiNavDestination {
  const UiNavDestination({
    required this.icon,
    required this.label,
    this.selectedIcon,
  });

  /// Icon shown when the destination is unselected (and, if [selectedIcon] is
  /// null, when selected too).
  final IconData icon;

  /// Optional icon shown only while this destination is selected. Falls back to
  /// [icon] when null.
  final IconData? selectedIcon;

  /// Text label. Shown inline on the extended rail / bottom bar, and per
  /// [NavigationRailLabelType] on the compact rail.
  final String label;
}

/// An adaptive navigation scaffold that switches its navigation pattern by the
/// *available width* — never by platform (`Platform.isX`) — so a resized desktop
/// window, a split-screen tablet, or a foldable all resolve correctly from the
/// space they're actually given.
///
/// Width is classified with the kit's centralized [UiBreakpoints]; there are no
/// per-widget thresholds here:
///
/// | [UiDeviceClass] | Width      | Navigation                                   |
/// |-----------------|------------|----------------------------------------------|
/// | `compact`       | `< 600`    | M3 [NavigationBar] (bottom)                  |
/// | `medium`        | `600–839`  | [NavigationRail], `extended: false`, labels on selected |
/// | `expanded`      | `840–1199` | [NavigationRail], `extended: true` (all labels inline)  |
/// | `large`         | `>= 1200`  | [NavigationRail], `extended: true` (all labels inline)  |
///
/// Selection is **controlled**: pass [selectedIndex] and handle
/// [onDestinationSelected] in the caller. The API is intentionally minimal and
/// all-optional beyond the core four, so future options (e.g. a permanent
/// `NavigationDrawer` at `large`) can be added without breaking existing calls.
///
/// Kit boundaries: window sizing (`window_manager`), keyboard `Shortcuts`, and
/// route state preservation (`go_router`) are the consuming app's concern — the
/// shell deliberately owns none of them. Material 3 only.
///
/// Material requires **at least two** [destinations] for both [NavigationBar]
/// and [NavigationRail].
///
/// ```dart
/// UiAdaptiveNavShell(
///   selectedIndex: _index,
///   onDestinationSelected: (i) => setState(() => _index = i),
///   destinations: const [
///     UiNavDestination(icon: Icons.home, label: 'Home'),
///     UiNavDestination(icon: Icons.search, label: 'Search'),
///     UiNavDestination(icon: Icons.person, label: 'Profile'),
///   ],
///   body: pages[_index],
/// );
/// ```
class UiAdaptiveNavShell extends StatelessWidget {
  const UiAdaptiveNavShell({
    required this.destinations,
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.body,
    this.appBar,
    this.floatingActionButton,
    this.railLeading,
    this.railTrailing,
    super.key,
  }) : assert(destinations.length >= 2,
            'NavigationBar/NavigationRail require at least two destinations.');

  /// The navigation destinations, in order. Must contain at least two.
  final List<UiNavDestination> destinations;

  /// Index of the currently selected destination.
  final int selectedIndex;

  /// Called with the tapped destination's index.
  final ValueChanged<int> onDestinationSelected;

  /// The main content area shown beside (rail) or above (bottom bar) the nav.
  final Widget body;

  /// Optional app bar for the underlying [Scaffold].
  final PreferredSizeWidget? appBar;

  /// Optional floating action button for the underlying [Scaffold].
  final Widget? floatingActionButton;

  /// Optional widget above the rail's destinations (e.g. a logo or menu button).
  /// Ignored in the compact ([NavigationBar]) layout.
  final Widget? railLeading;

  /// Optional widget below the rail's destinations. Ignored in the compact
  /// ([NavigationBar]) layout.
  final Widget? railTrailing;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double width = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : MediaQuery.sizeOf(context).width;
        final UiDeviceClass deviceClass = UiBreakpoints.classify(width);

        if (deviceClass == UiDeviceClass.compact) {
          return Scaffold(
            appBar: appBar,
            floatingActionButton: floatingActionButton,
            body: body,
            bottomNavigationBar: NavigationBar(
              selectedIndex: selectedIndex,
              onDestinationSelected: onDestinationSelected,
              destinations: <Widget>[
                for (final UiNavDestination d in destinations)
                  NavigationDestination(
                    icon: Icon(d.icon),
                    selectedIcon:
                        d.selectedIcon == null ? null : Icon(d.selectedIcon),
                    label: d.label,
                  ),
              ],
            ),
          );
        }

        // medium → compact rail; expanded/large → extended rail. When extended,
        // NavigationRail asserts labelType must be null (labels render inline).
        final bool extended = deviceClass == UiDeviceClass.expanded ||
            deviceClass == UiDeviceClass.large;

        return Scaffold(
          appBar: appBar,
          floatingActionButton: floatingActionButton,
          body: Row(
            children: <Widget>[
              NavigationRail(
                selectedIndex: selectedIndex,
                onDestinationSelected: onDestinationSelected,
                extended: extended,
                labelType:
                    extended ? null : NavigationRailLabelType.selected,
                leading: railLeading,
                trailing: railTrailing,
                destinations: <NavigationRailDestination>[
                  for (final UiNavDestination d in destinations)
                    NavigationRailDestination(
                      icon: Icon(d.icon),
                      selectedIcon:
                          d.selectedIcon == null ? null : Icon(d.selectedIcon),
                      label: Text(d.label),
                    ),
                ],
              ),
              const VerticalDivider(width: 1, thickness: 1),
              Expanded(child: body),
            ],
          ),
        );
      },
    );
  }
}
