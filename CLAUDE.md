# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

`flutter-ui-kit` is the **single canonical Flutter design system** for the Omni-family apps: shared
design tokens (color, spacing, sizing, radius, typography), tablet-first breakpoints, and core/atom
widgets (button, text field, dropdown, status chip, banner, checkbox), plus generic (project-agnostic)
composites. It is the **frontend-only** counterpart to the `odb_library` monorepo — the two are
deliberately separate repositories, cloned as siblings on disk, each with its own `CLAUDE.md` and
memory scope. **Never nest one inside the other's working tree, and never edit this repo from an
`odb_library` session or vice versa.**

This repo is **consumed by** app repos (`odb_library`'s `omnidata_binding_ui` / `omnidata_license_studio`,
`scale_tech_insight`, and any future Omni-family app) via a pinned git dependency. It must never
depend on any of them — no ODB core, no transport/hub code, no app-specific business logic. If a
change would require importing anything outside the Flutter SDK, it does not belong here.

## Ask before modifying, if ambiguous

If a request could plausibly target either this repo or an app repo (e.g. "change the button color",
"the dropdown looks wrong on the Console page"), **ask the user which repo it targets before making
any change**, unless the request is unambiguous from context (a session already opened in this
repo's directory, a token/primitive name explicitly named, etc.). Don't guess and edit the wrong
repo — see "Repo separation" below for why this matters to the user.

## Repo separation

- **Components** (`Ui<Name>` in `lib/src/components/`) — one identical name and behavior across
  every consuming app. A component's *default* values live here; app-specific tuning happens through
  optional constructor overrides or theme-level overrides in the consuming app, never by forking the
  component.
- **Layouts/screens** — app-specific compositions (e.g. a Console's connection panel, a license
  studio's registration screen) stay in the *consuming app's own repo*, named however that app wants.
  They are not expected to be shared across apps, since apps don't share screens — only the
  primitives and tokens they're built from. A layout is only promoted into this kit's `composite/`
  layer (with a shared `Ui<Name>`) once a **second** app has a genuinely identical use case
  ("promotion rule").
- **Default-with-override pattern.** Every tunable value ships as a const default; per-instance
  overrides are optional named constructor parameters (`null` = inherit the shared default) — see
  `UiButton`/`UiTextField`/`UiDropdown`'s `height` parameter, and `UiTuning` (the debug-only live
  tuning singleton, seeded from the same consts used in release) as the reference implementations.
  New tunables should follow this pattern so consumer apps can adjust for their own area/purpose
  without forking the kit.

## Commands

Dart/Flutter SDK is managed by [puro](https://puro.dev) at `~/.puro/envs/stable/flutter`. On Windows,
puro's bash shims can be unreliable — prefer calling the `flutter`/`dart` binaries directly via
PowerShell or the direct path (`~/.puro/envs/stable/flutter/bin/flutter.bat`) if the `flutter` command
isn't on PATH.

```sh
flutter pub get
flutter analyze          # lint (flutter_lints ^6.0.0 + 3 extra rules, see analysis_options.yaml)
flutter test              # all tests
flutter test test/ui_button_test.dart   # single file
```

## Conventions (the contributor contract)

The full contract lives in
[`Documentations/design-system-contract.md`](Documentations/design-system-contract.md) — read it
before adding or changing anything. Summary:

- **Zero dependencies beyond the Flutter SDK.** This is what makes the kit safely embeddable in any
  consumer app regardless of that app's own dependency tree. Never add a package dependency here.
- **Layer rules:** `lib/src/theme/` = tokens only (no widgets); `lib/src/components/` = one-widget-
  per-file primitives named `Ui<Name>`; `lib/src/composite/` = generic (project-agnostic)
  compositions only.
- **Token-only rule:** no widget hardcodes a `Color`, size, or spacing value — always read from
  `UiSpacing`/`UiSizing`/`UiRadius`/`UiTypography`, `context.uiColors`, or
  `Theme.of(context).colorScheme`.
- **Testing:** every new/changed widget gets a mirrored test under `test/`.
- **Versioning:** semantic version tags (`vMAJOR.MINOR.PATCH`) + `CHANGELOG.md`. A breaking
  token/API change bumps MAJOR, since consumer apps pin an exact tag and won't see a change until
  they deliberately bump it.
- Export every new public symbol from the barrel `lib/flutter_ui_kit.dart`.

## Git workflow

- **Remote:** `origin` → https://github.com/momomozakiki/flutter-ui-kit.git
- **Default branch:** `main`. Tag releases `vMAJOR.MINOR.PATCH` once `flutter analyze` and
  `flutter test` are clean on `main`.
- Consumer apps pin an exact tag (`ref: vX.Y.Z` in their `pubspec.yaml` git dependency) — never
  `ref: main`, so an in-progress change here can never silently break a consumer.
