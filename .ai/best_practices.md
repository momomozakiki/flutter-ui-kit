---
title: Best Practices
version: 1.4
last_validated: 2026-07-16
official: false
source: agent-generated
tags: [best-practices, living-doc, conventions, gotchas]
applies_when: "Working in flutter-ui-kit — checking or recording repo conventions, patterns, and gotchas."
estimated_tokens: 950
---

# Best Practices (living document)
**Version 1.4** — *distilled conventions and gotchas for flutter-ui-kit (pointer to the contract + skills).*

## Revision History
| Version | Date       | Change   |
|---------|------------|----------|
| 1.0     | 2026-07-11 | Added Documentation Standard frontmatter. |
| 1.1     | 2026-07-12 | Added the puro `flutter run -d chrome` web-SDK gotcha + static-serve workaround. |
| 1.2     | 2026-07-16 | Aligned the layer-rules bullet with the v0.4.0 Atomic tiering (`atoms/` / `molecules/` / `organisms/`, replacing `components/` + `composite/`). |
| 1.3     | 2026-07-16 | Added the Windows desktop review target (`flutter run -d windows` with hot reload) as the primary preview path given the broken `-d chrome` under puro. |
| 1.4     | 2026-07-16 | Added the branch + PR merge-gate discipline (`main` advances only through a verified, merged PR) + the checklist-driven select-what-applies note. |

Hard-won conventions and gotchas for working in **flutter-ui-kit**. Append here
whenever a new pattern, rule, or repeatable mistake surfaces (see the trigger table
in [CLAUDE.md](../CLAUDE.md)). Keep entries concrete — pair each rule with a short
example or reason.

> **This file is a lean pointer, not a second copy.** The authoritative, detailed
> rules live in [`docs/golden-rule/design-system-contract.md`](../docs/golden-rule/design-system-contract.md)
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
- **Layer rules.** `lib/src/theme/` = tokens only (no widgets); `lib/src/atoms/`
  = one-widget-per-file primitives named `Ui<Name>`; `lib/src/molecules/` = generic
  (project-agnostic) **stateless** compositions; `lib/src/organisms/` = generic
  compositions that own **local UI state** only.
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

- **Preferred review target: Windows desktop with hot reload.** Because live web runs
  are broken under puro (below), the fastest faithful preview is the `example/` viewer
  as a desktop app:
  ```sh
  cd example && flutter run -d windows   # then press r = hot reload, R = hot restart
  ```
  Its window opens at **1280×800** (a 10″ tablet's landscape pixel size, set in
  `example/windows/runner/main.cpp`) and is resizable, so UI/UX eyeballed here
  translates faithfully to a real tablet — and edits show **without an Android APK
  rebuild/reinstall**. The kit renders the same tree on desktop, web, and Android.
- **`flutter run -d chrome` fails under puro** with `Error: SDK root directory not
  found: ../../../.puro/envs/stable/flutter/bin/cache/flutter_web_sdk/.` — the debug
  service resolves the web SDK by a *relative* path that doesn't hold. The SDK is
  present and **`flutter build web` works fine**. To *see* the `example/` viewer on web,
  build and serve the static output instead of live-running:
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

## Git workflow — branch + PR merge-gate (distilled; full rules in CLAUDE.md)

- **`main` advances only through a verified, merged PR** — never a direct push. Consumer
  apps tag off `main`, so an unverified change landing there is how a consumer silently
  breaks. Full authority: [CLAUDE.md → Git workflow](../CLAUDE.md).
- **Branch when it's substantive** (pragmatic scope rule): a change to `lib/`, tokens, the
  version, or canonical guidance (`docs/golden-rule/`, `CLAUDE.md`, `.claude/skills/`).
  Trivial doc/ledger/typo edits may commit straight to `main`. Branch name `<type>/<slug>`,
  `type` ∈ `feat | fix | docs | chore`.
- **Close by opening a PR, not merging** — Phase 3 pushes the branch and runs `gh pr create`;
  the merge (`gh pr merge <n> --squash --delete-branch`) happens only after the user confirms
  the PR is verified. On a merge conflict, stop and ask. If `gh` isn't authenticated, push the
  branch and hand over the compare-URL.
- **Start of session:** `gh pr list --state open` — resolve/verify any open PR before stacking
  new work on it.
- **The workflow is a checklist, not a pipeline** — for a task, *select the applicable steps*
  over the four always-on gates (git sync · branch/PR gate · ledger entry · no dangling
  `UNFINISHED.md`); the rest (branch/PR/docs/roadmap/version bump/…) are picked per task.
