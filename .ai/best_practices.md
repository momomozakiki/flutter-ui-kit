# Best Practices (living document)

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

## Validation & versioning

- Keep `flutter analyze` at **"No issues found"** and `flutter test` green before
  committing. Every new/changed widget gets a mirrored test under `test/`.
- Consumer apps pin an **exact tag** (`ref: vX.Y.Z`), so a breaking token/API change
  bumps **MAJOR** and updates `CHANGELOG.md`. A change isn't seen by consumers until
  they deliberately bump the ref — versioning discipline is the contract.
