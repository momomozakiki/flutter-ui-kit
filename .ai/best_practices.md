---
title: Best Practices
version: 1.0
last_validated: 2026-07-11
official: false
source: agent-generated
tags: [best-practices, living-doc, conventions, gotchas]
applies_when: "Working in flutter-ui-kit — checking or recording repo conventions, patterns, and gotchas."
estimated_tokens: 900
---

# Best Practices (living document)
**Version 1.1** — *distilled conventions and gotchas for flutter-ui-kit (pointer to the contract + skills).*

## Revision History
| Version | Date       | Change   |
|---------|------------|----------|
| 1.0     | 2026-07-11 | Added Documentation Standard frontmatter. |
| 1.1     | 2026-07-12 | Added the puro `flutter run -d chrome` web-SDK gotcha + static-serve workaround. |

Hard-won conventions and gotchas for working in **flutter-ui-kit**. Append here
whenever a new pattern, rule, or repeatable mistake surfaces (see the trigger table
in [CLAUDE.md](../CLAUDE.md)). Keep entries concrete — pair each rule with a short
example or reason.

> **This file is a lean pointer, not a second copy.** The authoritative, detailed
> rules live in [`docs/design-system-contract.md`](../docs/design-system-contract.md)
> (the contributor contract) and in the `flutter-ui-kit-component` and
> `dart-solid-principles` skills. Record here only the *distilled* rules and the
> gotchas those don't already cover.

## Core rules (distilled — full text in the contract)

- **Zero dependencies beyond the Flutter SDK.** Never add a package to
  `pubspec.yaml`. This is what makes the kit safely embeddable in any consumer app.
  (Dev-only tooling like the Python workflow hook is *not* a package dependency and
  doesn't count.)
- **Token-only rule.** No widget hardcodes a `Color`, size, spacing, or radius —
  always read from `UiSpacing`/`UiSizing`/`UiRadius`/`UiTypography`,
  `context.uiColors`, or `Theme.of(context).colorScheme`.
- **Default-with-override pattern.** Every tunable value ships as a `const` default;
  per-instance overrides are optional named params (`null` = inherit). `UiTuning`
  (the debug-only live tuning singleton) is seeded from the same consts used in
  release. Follow this for new tunables instead of forking a component.
- **Layer rules.** `lib/src/theme/` = tokens only (no widgets); `lib/src/components/`
  = one-widget-per-file primitives named `Ui<Name>`; `lib/src/composite/` = generic
  (project-agnostic) compositions only.
- **Export** every new public symbol from the barrel `lib/flutter_ui_kit.dart`.

## Repo-separation gotchas

- This kit is **consumed by** app repos via a pinned git dependency; it must never
  depend on any of them (no ODB core, no app business logic). If a change would need
  an import outside the Flutter SDK, it doesn't belong here.
- App-specific screens/layouts stay in the consuming app. A composite is promoted
  into this kit's `composite/` layer only once a **second** app has a genuinely
  identical use case (the promotion rule).
- Don't edit this repo from an `odb_library`/consuming-app session or vice versa —
  separate repos, separate memory scope.

## Tooling gotchas (puro / Windows)

- **`flutter run -d chrome` fails under puro** with `Error: SDK root directory not
  found: ../../../.puro/envs/stable/flutter/bin/cache/flutter_web_sdk/.` — the debug
  service resolves the web SDK by a *relative* path that doesn't hold. The SDK is
  present and **`flutter build web` works fine**. To *see* the `example/` viewer, build
  and serve the static output instead of live-running:
  ```sh
  cd example && flutter build web
  cd build/web && python -m http.server 8080   # open http://localhost:8080
  ```
  No hot reload, but faithful for a visual check. (Only affects live web dev runs on
  this puro setup — not CI, not the app, not desktop runs.)

## Validation & versioning

- Keep `flutter analyze` at **"No issues found"** and `flutter test` green before
  committing. Every new/changed widget gets a mirrored test under `test/`.
- Consumer apps pin an **exact tag** (`ref: vX.Y.Z`), so a breaking token/API change
  bumps **MAJOR** and updates `CHANGELOG.md`. A change isn't seen by consumers until
  they deliberately bump the ref — versioning discipline is the contract.
