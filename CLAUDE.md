# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.
It is also the **Constitution** for this repo's Adaptive Self-Correcting Workflow (v4.4): the
always-loaded, immutable core rules. The workflow itself is vendored as a git submodule at
[`.claude/workflow-core/`](.claude/workflow-core/) (pinned to a reviewed commit) — its
[`GUIDE.md`](.claude/workflow-core/GUIDE.md) is the canonical spec and its
[`skills/adaptive-workflow/SKILL.md`](.claude/workflow-core/skills/adaptive-workflow/SKILL.md) the full
process manual. The repo-local [`adaptive-workflow` skill](.claude/skills/adaptive-workflow/SKILL.md)
is a thin pointer that adds this repo's flutter-specific bindings. When any of them disagree, this
file and the workflow-core GUIDE win.

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
- **Atomic Design.** The kit follows Atomic Design: `theme/` = tokens, `components/` = **atoms**
  (stateless), `composite/` = **molecules** (stateless) / **organisms** (local UI state only);
  templates/pages stay in consuming apps. Full mapping + state boundaries live in the
  [design-system contract](docs/design-system-contract.md#atomic-design-mapping) and the
  [`Atomic Design in Flutter`](<docs/Atomic Design in Flutter.md>) guide.
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

<!-- ==================================================================== -->
<!-- BEGIN adaptive-workflow fragment (managed by .claude/workflow-core)   -->
<!-- Included verbatim; project-specific notes go OUTSIDE this block.      -->
<!-- ==================================================================== -->

## Adaptive Self-Correcting Workflow

This project follows the Adaptive Self-Correcting Workflow. The full reference
lives in `.claude/workflow-core/GUIDE.md`; the agent operating manual is the
`adaptive-workflow` skill (`.claude/workflow-core/skills/adaptive-workflow/SKILL.md`).
Hooks provide ambient reminders — treat them as helpful nudges, not blockers.

### Fixed invariants — always do first (Phase 0)
- **F1 Git sync:** `git fetch && git pull --rebase`. If the tree is dirty, ask
  the user how to proceed before changing anything.
- **F2 Environment:** verify the tools in `workflow_config.json → env_check`.
- **F3 Living docs:** load configured docs; flag any missing doc frontmatter
  (provenance + version).
- **F4 Unfinished plan / roadmap:** if `plans/UNFINISHED.md` exists, surface it
  immediately; note the next unchecked roadmap item.
- **F5 Daily workflow update check:** once per day, check `.claude/workflow-core`
  for upstream updates.

### Per-task discipline
- **Plan (Phase 1):** design a task-specific checklist covering tests, doc
  updates, ledger entries, provenance, and roadmap impact.
- **Execute (Phase 2):** implement → run linter/tests → apply conditional
  triggers. **Log every intentional change** to the weekly ledger
  `history/YYYY-Www.md` (skip only trivial typo/whitespace-only edits). Add doc
  frontmatter (provenance + version) to any new or updated document.
- **Close (Phase 3):** archive the plan, write the final ledger entry, update
  the roadmap, then commit & push. You are **not done** until `UNFINISHED.md`
  is cleared, the ledger entry is written, and the commit is pushed.

<!-- END adaptive-workflow fragment -->

## Workflow — flutter-ui-kit bindings

Project-specific bindings the generic fragment above doesn't know (these live
*outside* the managed block so a `git submodule update` re-sync never clobbers
them). The [`adaptive-workflow` skill](.claude/skills/adaptive-workflow/SKILL.md)
carries the same bindings in more detail.

- **Config:** [`.claude/workflow_config.json`](.claude/workflow_config.json) maps the
  generic concepts here → `source_directories: ["lib"]`,
  `documentation_directories: ["docs", ".ai"]`, `roadmap_file: ROADMAP.md`,
  `ledger.directory: history`, `main_branch: main`.
- **Two chained hooks.** `.claude/workflow-core/hooks/workflow_hook.py` (canonical:
  git status, doc nudge, ledger/dirty Stop reminders, the **F5 daily workflow-update
  check**, and the Stop **auto-breadcrumb** that records an interrupted Phase 3 to
  `plans/UNFINISHED.md`) runs alongside the local `.claude/hooks/supplement.py`,
  which adds this repo's `.ai/env_check.ps1` output (F2, puro-aware), the living-doc
  summaries (F3), and the next `ROADMAP.md` `- [ ]` item (F4). F5 is owned by the
  upstream hook and is enabled for this repo via the `workflow_update_check` config
  block (`enabled: true` — fetches the submodule once/day and notes if behind; the
  actual `git submodule update` stays user-approved). The supplement's Stop handler
  only blocks on a *human-authored* `plans/UNFINISHED.md` — it skips the upstream
  auto-breadcrumb (which the upstream hook re-surfaces next SessionStart via F4).
  `env_check.tool_paths` is intentionally empty in the config so the supplement owns
  the environment check.
- **F1 detail:** never silently skip on an unreachable remote or a dirty tree — a
  stale base is how two sessions clobber each other.
- **Ledger (required, non-optional).** Every change is recorded in a weekly ledger
  `history/YYYY-Www.md` (`ls history/` is the time index); substantial → What/Why/Refs,
  minor → one terse line. Format: [history/FORMAT.md](history/FORMAT.md). This is
  separate from the repo-root `CHANGELOG.md` (the semver *release* record).
- **Versioning:** a token/API/contract change updates
  [`docs/design-system-contract.md`](docs/design-system-contract.md) dated, bumps the
  semver + `CHANGELOG.md`; tag `vMAJOR.MINOR.PATCH` only once `flutter analyze` and
  `flutter test` are clean on `main`.
- **Filesystem-native recall, no index:** `ls history/` + `grep -r "keyword" plans/archive/`;
  never load the whole archive/ledger.
- **Creating skills:** any new skill must be authored with the skill-creator skill
  (`.claude/skills/<name>/SKILL.md`, `name:` == dir, kebab-case, trigger-oriented
  `description`).
