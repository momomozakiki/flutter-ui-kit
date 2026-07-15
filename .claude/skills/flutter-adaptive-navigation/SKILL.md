---
name: flutter-adaptive-navigation
description: >-
  Use when building or reviewing adaptive/responsive **navigation** in flutter-ui-kit or a consuming
  Omni-family app — a top-level app shell that must switch between a bottom bar, a compact rail, and
  an extended rail as the window/pane resizes across phone / 7"/10" tablet / Windows desktop. Triggers
  on: "adaptive layout", "responsive navigation", "NavigationRail vs BottomNavigationBar", "nav shell",
  "adaptive scaffold", "should I use window_manager / flutter_adaptive_scaffold", "how do I switch nav
  by screen size", "make the app work on tablet and desktop", or porting an external adaptive-layout
  guide into this kit. Points to the kit-provided `UiAdaptiveNavShell` and the zero-dependency,
  width-not-platform rules that guide reject dependency-heavy external recipes.
---

# Adaptive navigation in flutter-ui-kit

This kit already ships the adaptive navigation shell — **don't hand-roll a `LayoutBuilder` +
`NavigationRail`/`NavigationBar` switch, and don't reach for `window_manager`,
`flutter_adaptive_scaffold`, or any adaptive-layout package.** Those violate the kit's zero-dependency
rule. Reach for the pieces below instead.

## 1. Pick the right tool

| You need… | Use | Where |
|---|---|---|
| A **top-level app shell** whose *navigation pattern* changes with width (bottom bar ↔ rail) | **`UiAdaptiveNavShell`** | `lib/src/organisms/ui_adaptive_nav_shell.dart` |
| To switch an **arbitrary layout** (stacked ↔ side-by-side, column count) by width | `UiResponsive` builder | `lib/src/molecules/ui_responsive.dart` |
| Raw width→tier classification inside your own widget | `UiBreakpoints.classify(width)` → `UiDeviceClass` | `lib/src/theme/ui_breakpoints.dart` |

`UiAdaptiveNavShell` is itself built on `UiBreakpoints` + a `LayoutBuilder`, so it composes on *pane*
width — it works embedded in a sub-pane, not just full-screen.

## 2. The tier → navigation mapping (don't reinvent the thresholds)

Classification is centralized in `UiBreakpoints` (`600 / 840 / 1200`). Never introduce a local `900`
or a per-widget threshold — that's the scatter the centralized tokens exist to prevent.

| `UiDeviceClass` | Width      | Navigation                | Rail state                               |
|-----------------|------------|---------------------------|------------------------------------------|
| `compact`       | `< 600`    | M3 `NavigationBar`        | N/A                                      |
| `medium`        | `600–839`  | `NavigationRail`          | `extended: false`, `labelType: selected` |
| `expanded`      | `840–1199` | `NavigationRail`          | `extended: true` (labels inline)         |
| `large`         | `>= 1200`  | `NavigationRail`          | `extended: true` (labels inline)         |

**Extended-rail gotcha:** when `extended: true`, Flutter *asserts* `labelType` must be `null` — the
extended rail already shows every label inline. "All labels visible" comes from `extended: true`, not
from `NavigationRailLabelType.all`.

## 3. Using `UiAdaptiveNavShell`

Selection is **controlled** — you own the index. Declare each destination once as `UiNavDestination`;
the shell renders it as a `NavigationDestination` or `NavigationRailDestination` per tier. Material
requires **at least two** destinations.

```dart
UiAdaptiveNavShell(
  selectedIndex: _index,
  onDestinationSelected: (i) => setState(() => _index = i),
  destinations: const [
    UiNavDestination(icon: Icons.home, label: 'Home'),
    UiNavDestination(icon: Icons.search, label: 'Search'),
    UiNavDestination(icon: Icons.person, label: 'Profile'),
  ],
  body: pages[_index],
  // optional: appBar, floatingActionButton, railLeading, railTrailing
);
```

## 4. What belongs in the consuming app, not the shell

The kit owns the *navigation shell*; the app owns the *chrome*. Keep these out of the kit — they vary
per app and would over-couple a shared widget:

- **Window sizing / minimum size** (`window_manager`, `Platform.isWindows` init in `main()`). The kit
  never sets a window size; hosts default their desktop window (see the adaptive spec §2.2, §6.1).
- **Keyboard shortcuts** (`Shortcuts`/`Actions`, `Ctrl+N`, `Alt+1…`). Wire these in the app around
  your shell; the external guide's snippet is an *app* recipe.
- **Route-state preservation** across resize (`go_router` `StatefulShellRoute.indexedStack`). The
  shell is router-agnostic on purpose.

## 5. Why these rules (so you can override them well)

These are load-bearing decisions, not arbitrary style — captured so a future change with a *better*
idea can override them deliberately (allowed) rather than by accident:

- **Width, never platform.** `Platform.isWindows`-driven layout breaks on resized windows, foldables,
  and split-screen. React to the space you're given.
- **Zero dependencies is inviolable.** It's what lets the kit embed in any consumer. This is why the
  external guide's `window_manager` / `flutter_adaptive_kit` / `universal_breakpoints` / `fluent_ui`
  were all rejected.
- **Material 3 only.** `NavigationBar`, never M2 `BottomNavigationBar`.
- **Additive API + promotion rule.** The shell stays minimal/all-optional so extensions (a permanent
  `NavigationDrawer` at `large`, a foldable `dualPane` mode, a `desktopNavType` param) can be added
  without breaking callers — but only once a *second real use case* appears. No speculative generality.

## References

- [`docs/flutter-adaptive-ui-design-specification.md`](../../docs/flutter-adaptive-ui-design-specification.md)
  §3.4 (shell recipe), §3.5 (reconciliation vs. the external guide), §9 (future extensibility).
- [`flutter-ui-kit-component`](../flutter-ui-kit-component/SKILL.md) — the general rules for adding or
  editing any component/token here (token-only rule, tiering, testing, versioning).
- [`lib/src/organisms/ui_adaptive_nav_shell.dart`](../../lib/src/organisms/ui_adaptive_nav_shell.dart)
  — the implementation, as a worked example.
