# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.
It is also the **Constitution** for this repo's Adaptive Self-Correcting Workflow (v3.3): the
always-loaded, immutable core rules. The full process manual is the `adaptive-workflow` skill
(`.claude/skills/adaptive-workflow/SKILL.md`), loaded on demand; the canonical spec lives in
[`docs/adaptive-workflow/`](docs/adaptive-workflow/). When any of them disagree, this file and the
canonical spec win.

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
[`docs/design-system-contract.md`](docs/design-system-contract.md) — read it
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

---

# Adaptive Self-Correcting Workflow — Constitution

The immutable core of how tasks are run across sessions. The detailed process is the
`adaptive-workflow` skill; use it whenever you start real work here. Trivial one-shot Q&A that
touches no repo state is exempt.

- **Filesystem-native recall, no index.** Find past work with `ls history/` (the weekly change
  ledger) and `grep -r "keyword" plans/archive/` — never load the whole archive/ledger, never add a
  central index.
- **Conditional updates only.** Update shared docs *only* when a trigger below fires. No impact → do
  nothing. (The change ledger is the one exception — it logs everything at scaled detail.)

## Immutable Phase 0 Invariants (never skip)

1. **Git sync:** Run `git pull --rebase` before any code change; check for a dirty tree. If the
   remote is unreachable, report the error and ask the user how to proceed — do not silently skip.
2. **Environment:** Verify the toolchain is ready. Run `.ai/env_check.ps1` (PowerShell) if present —
   it reports Flutter/Dart/Git readiness (a report, not a gate).
3. **Core docs:** Have `.ai/best_practices.md`, `.ai/naming_conventions.md`, and
   `docs/design-system-contract.md` in context. (The SessionStart hook pre-injects summaries.)
4. **Unfinished plan:** If `plans/UNFINISHED.md` exists, surface it to the user immediately:
   *"You have an unfinished plan: [summary]. Continue it or archive it?"*

## Meta-Planning (before implementing)

- Assess: task scope, doc/contract impact, handoff need, validation rigor, retro value.
- If the task is part of a larger goal, consult `ROADMAP.md` (or create one). Break large tasks into
  roadmap chunks; put only the **next** chunk in `plans/UNFINISHED.md`.
- Produce a bullet plan with acceptance criteria before executing. For the code itself, follow the
  `flutter-ui-kit-component` and `dart-solid-principles` skills.

## Conditional Update Triggers (during & after execution)

| Trigger | Action |
|---------|--------|
| **Any change worth tracing later** (new component, token/API change, decision, config) | **Append a dated entry to the current weekly ledger `history/YYYY-Www.md`** (required, not optional) |
| New pattern / rule / gotcha | Append to `.ai/best_practices.md` (with example) |
| New naming convention | Append to `.ai/naming_conventions.md` |
| Token / API / contract change | Update `docs/design-system-contract.md` (or relevant `docs/*.md`) with a dated annotation; bump the version + `CHANGELOG.md` |
| Non-obvious technical decision | Write to `plans/archive/<slug>/execution_log.md` |
| Repeatable mistake | Add a warning to `.ai/best_practices.md` or `retro.md` |
| Task affects future roadmap items | Update `ROADMAP.md` |
| Epic completed | Move it to `## Completed Epics` in `ROADMAP.md` |
| No impact on shared knowledge | **Do nothing** (except the ledger) |

## Closure Discipline

- Move the completed plan from `plans/UNFINISHED.md` to `plans/archive/YYYY-MM-DD_<slug>/`
  (`plan.md`, plus `references.md` / `execution_log.md` / `retro.md` as warranted).
- Clear `plans/UNFINISHED.md` — it must **not** exist at rest (its presence blocks session closure).
- **Append a closure entry to the current weekly ledger `history/YYYY-Www.md`** *before* committing —
  mandatory, not optional.
- Update `ROADMAP.md` if triggered; check off the completed item.
- `git commit -m "Plan: <slug> — <summary>" && git push`. (Tag `vMAJOR.MINOR.PATCH` only when
  `flutter analyze` and `flutter test` are clean on `main`.)
- **You are not done until `plans/UNFINISHED.md` is cleared, the plan is archived, and the change
  ledger is updated.**

## Change History (required, non-optional)

- **Every** change to the repo is recorded in a weekly ledger `history/YYYY-Www.md` (one file per
  ISO week; `ls history/` is the time index). Substantial changes get a full **What / Why / Refs**
  entry; minor changes get a single terse line. This is the realized, **required** form of the v3.3
  spec's *optional* `changelogs/CHANGELOG.md`, and is separate from the repo-root `CHANGELOG.md`
  (which is the semver *release* record). Format spec: [history/FORMAT.md](history/FORMAT.md).

## Historical Context Retrieval

- **By time:** `ls history/` for the week-by-week ledger, then read the week file(s) you need — the
  chronological "what changed, when, why" view.
- **By task depth:** Do NOT load the entire archive. Use `grep -r "keyword" plans/archive/` to find
  relevant past tasks and `ls plans/archive/` to list them. Load only the specific file(s) needed.

## Creating skills

- Any new skill **must** be authored using the skill-creator skill. Skills are directories
  (`.claude/skills/<name>/SKILL.md`, `name:` == dir), kebab-case, with a "pushy", trigger-oriented
  `description`.
