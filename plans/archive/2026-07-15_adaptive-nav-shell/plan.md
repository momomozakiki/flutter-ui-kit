# Plan: Integrate the "Flutter Complete Adaptive Layout Guide" into flutter-ui-kit

## Context

The user shared an external **"Flutter Complete Adaptive Layout Guide"** (phone / 7″ / 10″ / Windows
desktop, single codebase) and asked how to integrate it into this repo, creating skills or docs as
needed. The user chose the **maximal scope**: reconcile it into **docs + a reusable component + a
skill**, with the doc **extending the existing adaptive spec** (not a new standalone guide).

The guide **cannot be adopted verbatim** — it conflicts with this kit's core rules:

| Guide says | This repo's rule | Resolution |
|---|---|---|
| Add `window_manager`, `flutter_adaptive_kit`, `universal_breakpoints`, `fluent_ui` | **Zero runtime deps beyond Flutter SDK** (the kit's single most important rule) | **Reject all packages.** Window management stays in consuming apps. |
| Breakpoints 600 / **900** / **1200** | Kit uses 600 / **840** / 1200 via `UiBreakpoints` | **Reuse `UiBreakpoints`/`UiDeviceClass`** — no new thresholds. |
| `BottomNavigationBar` (Material 2) for phones | Kit is **Material 3 only** | Use M3 **`NavigationBar`** for compact. |
| `Platform.isWindows` + `window_manager` init in `main()` | Window sizing left to consuming apps (hosts default 1280×800 / 960×600 floor) | Document as **consuming-app responsibility**, not kit code. |
| `Shortcuts`/`Actions` keyboard nav wired into the shell | — | Keep as a **consuming-app recipe**, not baked into the kit widget. |

The guide's four tiers map **cleanly** onto the kit's existing `UiDeviceClass`, so integration is a
harvest, not a rewrite:

| Guide tier | Width | Kit `UiDeviceClass` | Nav pattern |
|---|---|---|---|
| Phone | < 600 | `compact` | M3 `NavigationBar` (bottom) |
| 7″ tablet | 600–899 | `medium` (600–839) | `NavigationRail` compact (`extended: false`, labels on selected) |
| 10″ tablet | 900–1199 | `expanded` (840–1199) | `NavigationRail` extended (`extended: true`, all labels) |
| Windows / large | ≥ 1200 | `large` | `NavigationRail` extended (full) |

**Intended outcome:** the reusable ideas from the guide land as (1) a new kit organism that switches
navigation pattern by pane width, built entirely on existing tokens/deps; (2) an extension of the
adaptive spec documenting the reconciliation (including what was rejected and why); (3) a focused
skill so future adaptive-nav work follows the kit-conformant path instead of the external guide's
dependency-heavy one.

## Review outcome (accepted / rejected, with reasons)

A future-proofness review (external guide vs. this kit vs. 2025–2026 industry consensus) confirmed
the existing approach is already *superior* and best-practice-aligned. Dispositions:

| Suggestion | Disposition | Reason |
|---|---|---|
| Keep 600/840/1200, M3 `NavigationBar`, zero deps, window mgmt + keyboard in the app | ✅ Accept | Already the plan; matches M3 + the 2025 zero-dep-UI-kit consensus. |
| Clarify the mapping table with an explicit **label-mode** column | ✅ Accept | Removes ambiguity; folded into deliverable 1 + the doc. |
| Add a **"Future Extensibility"** section to the spec (foldable `dualPane`, permanent `NavigationDrawer` for `large`, `go_router`/`StatefulShellRoute` state preservation) | ✅ Accept (docs only) | Low-cost forward signal; documents *where* future growth goes without building it. |
| Add `desktopNavType` (rail\|drawer) + `breakpoints` params to the component **now** | ❌ Reject building now | (1) `UiBreakpoints? breakpoints` isn't instantiable — it's an `abstract final class` of statics; a per-instance breakpoint override also *contradicts* the centralized-breakpoints principle. (2) A drawer branch is **YAGNI** with no second use case and untestable against a real consumer — the kit's **promotion rule** forbids speculative generality. **Mitigation:** keep the API all-optional/additive so `desktopNavType` can be added later without breaking callers, and document it as a designed-for extension point. |

## What already exists (reuse, don't reinvent)

- `lib/src/theme/ui_breakpoints.dart` — `UiBreakpoints` (600/840/1200) + `UiDeviceClass` +
  `classify(width)` / `of(context)`. **The component classifies with this, no new breakpoints.**
- `lib/src/molecules/ui_responsive.dart` — `UiResponsive` width→builder (classifies on *pane* width
  via `LayoutBuilder`). The new shell follows the same `LayoutBuilder` + `UiBreakpoints.classify`
  pattern.
- `lib/src/organisms/ui_under_maintenance.dart` — reference for organism structure (tier comment,
  token-only, `Ui`-prefixed, doc comment).
- `docs/flutter-adaptive-ui-design-specification.md` (v3.0) — already prescribes NavigationRail ≥600,
  discourages bottom nav ≥600, Windows constraints, testing matrix. **Extend this, don't duplicate.**

## Deliverables

### 1. New organism — `UiAdaptiveNavShell`

- **File:** `lib/src/organisms/ui_adaptive_nav_shell.dart`, `// Tier: organism`.
- **A small value type** `UiNavDestination` (`IconData icon`, `IconData? selectedIcon`,
  `String label`) so callers declare destinations once and the shell renders them as either
  `NavigationDestination` (M3 NavigationBar) or `NavigationRailDestination`.
- **Controlled/stateless API** (delegates selection upward for composability + testability), and
  **all-optional/additive** so future options (`desktopNavType`, etc.) can be added without breaking
  callers: `destinations`, `selectedIndex`, `onDestinationSelected`, `body`, optional `appBar`,
  `floatingActionButton`, `railLeading`, `railTrailing`.
  - **Deliberately *not* added now** (documented as extension points, per review): `desktopNavType`
    (rail|drawer) and per-instance breakpoint overrides — YAGNI + would undercut centralized
    `UiBreakpoints`. Add only when a real second use case appears (promotion rule).
- **Behavior** via `UiBreakpoints.classify(constraints.maxWidth)` inside a `LayoutBuilder`:
  - `compact` → `Scaffold` with M3 `NavigationBar` at the bottom.
  - `medium` → `Row`[ `NavigationRail`(`extended: false`, `labelType: selected`), `VerticalDivider`,
    `Expanded(body)` ].
  - `expanded` / `large` → same `Row` but rail `extended: true`, `labelType: all`.
- **Token-only:** colors from `Theme`/`context.uiColors`; any padding/gap from `UiSpacing`; no raw
  `Color`/magic numbers. Material 3 widgets only (`NavigationBar`, **not** `BottomNavigationBar`).
- **Tier note (surface in review):** it's stateless/controlled, so by the kit's strict definition it
  leans "molecule", but a navigation shell is structurally an **organism** (major layout region).
  Placed in `organisms/` with a clear tier comment; a reviewer can reclassify to `molecules/` if
  preferred — this is the one open design point.

### 2. Test — `test/ui_adaptive_nav_shell_test.dart`

Mirror the widget. Pump the shell inside a width-constrained box (e.g. `MediaQuery` +
`SizedBox`/`ConstrainedBox`) at representative widths and assert:
- `< 600` → `find.byType(NavigationBar)` present, `NavigationRail` absent.
- `600–839` → `NavigationRail` present with `extended == false`.
- `≥ 840` (and `≥ 1200`) → `NavigationRail` present with `extended == true`.
- `onDestinationSelected` fires with the tapped index.
Follow existing test style in `test/ui_breakpoints_test.dart` / `test/ui_responsive_test.dart`.

### 3. Barrel + versioning

- Export `src/organisms/ui_adaptive_nav_shell.dart` from `lib/flutter_ui_kit.dart` and add it to the
  library doc-comment organisms list.
- `pubspec.yaml` **0.4.0 → 0.5.0** (additive public API → MINOR bump).
- `CHANGELOG.md` — new `0.5.0` entry describing `UiAdaptiveNavShell` + `UiNavDestination`.
- `docs/design-system-contract.md` — bump v1.4 → v1.5, add the new organism to the atomic-design
  inventory + a dated revision-history row.
- Consider whether to register in `catalog/ui_component_catalog.dart` / the `example/` viewer —
  **skip for now** (the catalog is documented as "listing every *atom*"; a nav shell needs live
  destinations/state a static sample can't supply). Note this decision in the ledger.

### 4. Doc — extend the adaptive spec (v3.0 → v3.1)

Edit `docs/flutter-adaptive-ui-design-specification.md`:
- Add a **"Navigation shell recipe (kit-provided)"** subsection under §3.3 documenting
  `UiAdaptiveNavShell`, the tier→nav mapping table above, and that it's built on
  `UiBreakpoints`/`UiResponsive` with zero added deps.
- Add a **"Reconciled from the external Adaptive Layout Guide"** note recording, explicitly, what was
  **rejected and why**: the four package deps (zero-dep rule), the 900 breakpoint (kit uses 840), M2
  `BottomNavigationBar` (kit is M3), and `window_manager`/`Platform.isWindows` init + keyboard
  `Shortcuts` (consuming-app responsibility — provide the guide's `Shortcuts`/`Actions` snippet there
  as an app recipe, not kit code).
- Add a **"Future Extensibility"** section (docs only, no code): (a) foldable/dual-screen — a future
  `dualPane` mode between `medium`/`expanded` driven by hinge/cutout data; (b) permanent
  `NavigationDrawer` as an alternative to the extended rail at `large` — the reason `UiAdaptiveNavShell`
  keeps an additive API; (c) `go_router` state preservation across resize via
  `StatefulShellRoute.indexedStack` (the `adaptive_scaffold_router` pattern), noted as a
  consuming-app concern.
- Bump frontmatter `version: 3.0 → 3.1`, refresh `last_validated`, adjust `estimated_tokens`, and add
  a one-line note to the summary. (This doc has no revision-history table; keep its existing shape.)

### 5. Skill — new repo-local adaptive-navigation skill

- **Authored via the `skill-creator` skill** (required by CLAUDE.md for any new skill).
- Location `.claude/skills/flutter-adaptive-navigation/SKILL.md`; two-field frontmatter (`name` ==
  dir, trigger-oriented `description`).
- Covers: when to reach for `UiAdaptiveNavShell` vs raw `UiResponsive`; the tier→nav mapping; the
  **rejected-patterns list** (no `window_manager`/adaptive packages, M3 `NavigationBar` not M2,
  window sizing + keyboard shortcuts belong in the consuming app); cross-links the adaptive spec and
  `flutter-ui-kit-component` skill.

## Design rationale — key concepts & why (record for the future)

These are the *load-bearing decisions* behind this design. Captured here, and to be written durably
during execution into the spec doc's reconciliation section **and** the weekly ledger (and a
`reference`/`project` memory), so a future contributor understands *why* — and can override any of
them if a genuinely better idea appears (that's allowed; this is the current best, not a permanent
ceiling).

1. **Layout is decided by available width, never by platform.** `LayoutBuilder` +
   `UiBreakpoints.classify(constraints.maxWidth)` — not `Platform.isWindows`. A resized desktop
   window, a foldable, or a split-screen tablet all "just work" because we react to space, not OS.
   This is why the guide's `Platform.isWindows`-driven layout was rejected.
2. **One centralized breakpoint source (`UiBreakpoints`, 600/840/1200).** No per-widget thresholds,
   no 900. Centralization is why we *rejected* a per-instance `breakpoints` override — it would
   reintroduce the scatter we deliberately removed. 840 (M3) over 900 (device-specific) because it
   generalizes past today's exact tablet sizes.
3. **Zero runtime dependencies is inviolable.** The kit is embeddable in *any* consumer regardless of
   its dep tree only because it adds none. This is why all four packages from the guide
   (`window_manager`, `flutter_adaptive_kit`, `universal_breakpoints`, `fluent_ui`) were rejected.
4. **Separation of concerns: the kit owns the *shell*, the app owns the *chrome*.** Window sizing
   (`window_manager`), keyboard `Shortcuts`/`Actions`, platform badges, and route-state preservation
   (`go_router`) are application-layer — they vary per app and would over-couple a shared widget.
5. **Material 3 only.** `NavigationBar`, never M2 `BottomNavigationBar`.
6. **Additive, controlled API + promotion rule.** Ship the minimal proven surface; keep it
   all-optional so extensions (`desktopNavType`, drawer, `dualPane`) can arrive later without
   breaking callers — but only once a *second real use case* justifies them. Speculative generality
   is rejected by policy, not by taste.

## Critical files

| Path | Change |
|---|---|
| `lib/src/organisms/ui_adaptive_nav_shell.dart` | **new** — the organism + `UiNavDestination` |
| `test/ui_adaptive_nav_shell_test.dart` | **new** — width-tier + selection tests |
| `lib/flutter_ui_kit.dart` | export + doc-comment list |
| `pubspec.yaml` | 0.4.0 → 0.5.0 |
| `CHANGELOG.md` | 0.5.0 entry |
| `docs/design-system-contract.md` | v1.4 → v1.5 inventory + revision row |
| `docs/flutter-adaptive-ui-design-specification.md` | v3.0 → v3.1 nav-shell recipe + reconciliation |
| `.claude/skills/flutter-adaptive-navigation/SKILL.md` | **new** (via skill-creator) |

## Workflow discipline (Phase 2/3)

- **Ledger:** record the change in `history/2026-W29.md` (What/Why/Refs) — non-optional.
- **Durable rationale:** persist the "Design rationale — key concepts & why" section into the spec
  doc's reconciliation note and a memory file (so future sessions inherit *why*, and know it's
  overridable if a better idea appears).
- **Provenance frontmatter:** the spec doc keeps its frontmatter (bump version); the new skill uses
  the two-field SKILL.md frontmatter.
- **Roadmap:** no adaptive/nav epic exists — add a `ROADMAP.md` item (e.g. under Epic 2 or a new
  "Adaptive navigation" line) capturing this net-new scope, and check it off on close.
- **Close:** archive this plan under `plans/archive/2026-07-15_adaptive-nav-shell/`, clear any
  `UNFINISHED.md` breadcrumb, then commit — the ledger + push are what make it "done". Commit message:
  ```
  feat(organisms): add UiAdaptiveNavShell (v0.5.0)

  - Adds UiAdaptiveNavShell organism with NavigationBar/NavigationRail switching
  - Adds UiNavDestination value type for destination definitions
  - Extends adaptive spec with navigation-shell recipe and reconciliation notes
  - Adds flutter-adaptive-navigation skill
  - Bumps version to 0.5.0
  ```
- **Aside (optional, out of scope):** `flutter-ui-kit-component/SKILL.md` still references the old
  `lib/src/components/` / `lib/src/composite/` folders — worth a follow-up cleanup, not part of this
  task.

## Verification

1. `flutter analyze` — clean (no hardcoded colors/sizes; run the skill's grep self-check on the new
   file).
2. `flutter test` — all green, including the new `ui_adaptive_nav_shell_test.dart`.
3. **Drive it end-to-end** (the `/run` or `verify` path): mount `UiAdaptiveNavShell` in the
   `example/` app (or a throwaway harness), resize the window across 400 → 700 → 1000 → 1400 dp, and
   confirm the nav switches NavigationBar → compact rail → extended rail live, and that tapping a
   destination changes `selectedIndex`. This proves the width-tier behavior, not just the constants.
