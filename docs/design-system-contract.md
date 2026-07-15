---
title: Design System Contract
version: 1.5
last_validated: 2026-07-15
official: false
source: agent-generated
tags: [contract, design-system, contributor-guide, tokens, components]
applies_when: "Adding or changing any component, token, or composition in flutter-ui-kit; verifying the contributor rules."
estimated_tokens: 2600
---

# Design System Contract
**Version 1.5** — *the tech/language requirements and layer/token rules every change here must follow.*

## Revision History
| Version | Date       | Change   |
|---------|------------|----------|
| 1.0     | 2026-07-11 | Added Documentation Standard frontmatter. |
| 1.1     | 2026-07-11 | Documented atomic-design layer mapping + state boundaries. |
| 1.2     | 2026-07-12 | Noted the v0.2.0 common-atoms inventory under the atomic-design mapping. |
| 1.3     | 2026-07-12 | Documented the `catalog/` registry layer + the `example/` component viewer (v0.3.0). |
| 1.4     | 2026-07-12 | Adopted strict Atomic folder tiering (`atoms/` / `molecules/` / `organisms/`) as the canonical structure; added the no-`_page`-in-kit rule (v0.4.0). |
| 1.5     | 2026-07-15 | Added the `UiAdaptiveNavShell` organism to the atomic-design inventory (v0.5.0). |

This is the contributor contract for `flutter-ui-kit` — the tech/language requirements and rules
every change here must follow, so every consuming app (`odb_library`'s `omnidata_binding_ui` /
`omnidata_license_studio`, `scale_tech_insight`, and future Omni-family apps) stays visually and
structurally consistent, and safely compatible with each other.

## Language / SDK requirements

- Dart SDK: `^3.12.0`
- Flutter SDK: `>=3.0.0`
- Material 3 (`useMaterial3: true`) only — no Material 2 fallback paths.

## Dependency policy

**Zero runtime dependencies beyond the Flutter SDK.** This is the single most important rule: it's
what lets any consuming app — regardless of its own dependency tree — embed this kit without
version-conflict risk. Never add a `pub` package dependency to `pubspec.yaml`'s `dependencies:`
section. Dev-only tooling (`flutter_test`, `flutter_lints`) is fine under `dev_dependencies:`.

## Lints

`analysis_options.yaml` includes `package:flutter_lints/flutter.yaml` (`flutter_lints ^6.0.0`) plus
three extra rules mirrored from the Omni-family root lint config:

```yaml
include: package:flutter_lints/flutter.yaml
linter:
  rules:
    - prefer_final_locals
    - prefer_const_constructors
    - avoid_print
```

`flutter analyze` must be clean before any PR merges.

## Layer rules (where new code goes)

| Folder | Holds | Naming |
|---|---|---|
| `lib/src/theme/` | reusable **properties** (design tokens): `UiSpacing`, `UiSizing`, `UiRadius`, `UiTypography`, `UiColors`, `UiBreakpoints`, `UiTuning`, `buildUiTheme()` | descriptive, no `Ui` prefix required for non-widget classes |
| `lib/src/atoms/` | **atoms** — one widget per file, the generic Material control wrapped with the kit's consistent look; always stateless | `Ui<Name>` (e.g. `UiButton`, `UiDropdown`) |
| `lib/src/molecules/` | **molecules** — stateless, project-agnostic groupings of atoms (e.g. `UiResponsive`) | `Ui<Name>` |
| `lib/src/organisms/` | **organisms** — compositions that may own local UI state (e.g. the tuning panel/overlay, `UiUnderMaintenance`, `UiAdaptiveNavShell`) | `Ui<Name>` |
| `lib/src/catalog/` | **component registry** (metadata, not widgets) — `uiComponentCatalog`, a `List<UiComponentDescriptor>` of `{id, label, category, sample}` naming every atom + a default instance | descriptive |

The **catalog layer** is what makes a new component discoverable: it feeds the kit's own component
viewer (`example/`) and, because it ships in `lib/`, any consuming app's palette (e.g. a form
designer) can import the same list. Adding a component means adding **one** catalog entry — nothing
auto-discovers widget classes (Dart has no runtime reflection for that). Each `sample` reads the kit
theme, so callers must invoke `sample(context)` under a `buildUiTheme()`-themed `MaterialApp`.

**App-specific screens/layouts never live here.** They stay in the consuming app's own repo, in that
app's own `composite/`-equivalent folder, named however that app wants — see the naming rule below.

### Atomic-design mapping

This kit **is** an Atomic Design system, and — as the single canonical design system for the
Omni-family apps — its folder structure is the **golden rule every consuming app mirrors** (see
[`Atomic Design in Flutter.md`](Atomic%20Design%20in%20Flutter.md) for the theory). Each folder is a
canonical Atomic Design layer with its own **state boundary** every new UI must respect. The folder
path itself *enforces* the boundary: nothing in `atoms/` may be stateful, etc.

| Atomic Design layer | This repo | State boundary |
|---|---|---|
| Tokens | `lib/src/theme/` | const-only, no widgets |
| **Atoms** | `lib/src/atoms/` | always `StatelessWidget`; only ephemeral UI state (`FocusNode`, internal controllers, hover/press). No business logic, no data fetching, no `AppLocalizations` — accept raw `String`s. |
| **Molecules** | `lib/src/molecules/` | compose atoms; **always stateless** — delegate state/callbacks upward. |
| **Organisms** | `lib/src/organisms/` | may own **local UI state** (expanded panel, open/closed menu, selected tab) but never business logic or data fetching. |
| Templates / Pages | *consuming apps* | **out of scope here by design** — they live in the consuming app per the repo-separation rule, so this kit intentionally has only three widget layers. |

The three widget layers are complemented by two non-widget artifacts: the token layer (`theme/`)
and the **catalog layer** (`catalog/`, a registry over the atoms — see the Layer-rules table). A
runnable **component viewer** lives in `example/` (a standard Flutter web app with a path dependency
on the kit, so the kit itself stays zero-dependency); it renders `uiComponentCatalog` as a gallery.

The atom layer (`lib/src/atoms/`) currently ships: `UiButton`, `UiIconButton`, `UiTextField`,
`UiDropdown`, `UiCheckbox`, `UiRadio` / `UiRadioGroup`, `UiSwitch`, `UiSlider`, `UiStatusChip`,
`UiChip`, `UiBanner`, `UiCard`, `UiText`, `UiAvatar`, `UiProgressIndicator`. New atoms are added on
demand per the "don't build speculatively" stance (the v0.2.0 common-atoms batch was an explicit,
user-requested exception — see `ROADMAP.md` Epic 4 and the `history/` ledger).

Molecules and organisms live in **separate folders** and must not be conflated: if a widget only
combines atoms and delegates all state upward it is a **molecule** (`molecules/`); if it manages a
self-contained UI behaviour (expandable panel, tab bar, local menu, floating overlay) without
touching repositories or domain logic it is an **organism** (`organisms/`) (when in doubt, treat it
as an organism and ask a reviewer). **Every molecule/organism file must carry a grep-friendly tier
comment near the top — `// Tier: molecule` or `// Tier: organism`** — so intent is visible in the
file itself and auditable across the tree.

**No `_page`-named widgets in the kit.** A widget whose file name (or class) reads as a *page* or
*template* belongs in a consuming app, not here (repo-separation rule). A full-screen composition
that is genuinely generic is modelled as an **organism** without the `_page` suffix — e.g.
`UiUnderMaintenance` (`organisms/ui_under_maintenance.dart`), not `under_maintenance_page`.

## Naming rule: components vs. layouts

- **Components** (this repo's `atoms/`, `molecules/`, and `organisms/` layers): **one identical name
  across every consuming app.** A `UiButton` is `UiButton` everywhere. Consumer apps must never
  locally rename, shadow, or fork a kit component — if it needs different behavior, that's either a
  constructor override (see below) or a signal the component itself needs to change here.
- **Layouts** (an app's page/screen composition — e.g. how the Console page arranges its panels):
  app-specific, named however that app wants, since apps don't share screens. A layout is promoted
  into the appropriate kit tier (`molecules/` or `organisms/`) — taking on a shared `Ui<Name>` —
  **only** once a second, genuinely identical use case exists in another app. Until then, keep it
  local to that app (the existing "promotion rule": don't move something here speculatively).

## Token-only rule

No widget hardcodes a `Color`, size, or spacing value. Always read from:
- `UiSpacing` / `UiSizing` / `UiRadius` for sizes and spacing,
- `context.uiColors` (the kit's semantic `ThemeExtension`) or `Theme.of(context).colorScheme` for
  color.

Never write `Colors.red.shade700` or a bare `16.0` in a widget body.

## Default-with-override pattern

Every tunable value ships as a `const` default. Per-instance overrides are optional named
constructor parameters where `null` means "inherit the shared theme default" — existing call sites
are unaffected when a new override param is added. Reference implementations:

```dart
// UiButton (and UiTextField, UiDropdown) accept an optional height override:
UiButton(
  label: 'Save',
  onPressed: onSave,
  height: 48, // overrides the shared UiSizing.controlHeight default for just this instance
)
```

`UiTuning` is the debug-only live-tuning singleton: every field is seeded from the same const used
in release, so nothing changes until a slider is actually touched, and there is a single code path
in both debug and release builds (no `kDebugMode` branch inside `buildUiTheme()` itself) — this
guards against debug-tuned values silently diverging from what ships. New tunables should follow
this same pattern rather than inventing a parallel mechanism.

## Testing

Every new or changed widget/token gets a mirrored test under `test/` (e.g. `ui_button.dart` →
`test/ui_button_test.dart`). `flutter test` must be clean before merge.

## Versioning & releases

- Semantic version tags: `vMAJOR.MINOR.PATCH`.
- `CHANGELOG.md` gets an entry for every release — required for any change to the public API or
  token values, not just optional documentation.
- A breaking change to a token value or component API bumps **MAJOR**. Consumer apps pin an exact
  tag in their `pubspec.yaml` git dependency (`ref: vX.Y.Z`, never `ref: main`), so nothing breaks
  them until they deliberately bump the pinned tag.
- Tag only after `flutter analyze` and `flutter test` are clean on `main`, and — for changes to this
  contract document itself — after a human has actually read the update (this document defines rules
  the whole org relies on; don't let it drift unreviewed).

## Local development against this kit

When actively iterating on both this kit and a consumer app at once, use a `dependency_overrides` in
the consumer's `pubspec.yaml` pointing at a local sibling clone instead of the pinned git tag:

```yaml
dependency_overrides:
  flutter_ui_kit:
    path: ../flutter-ui-kit   # local sibling clone; remove before committing/releasing the consumer
```

Remove the override before committing — it must never ship in a consumer app's committed pubspec.
