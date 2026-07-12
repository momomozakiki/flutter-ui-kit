# Plan: Complete the common-atoms set for flutter-ui-kit

> **STATUS: implementation complete & green** (`flutter analyze` clean, 75 tests pass).
> Remaining step is the Phase-3 commit — see **Commit (Phase 3 close-out)** immediately below.

## Commit (Phase 3 close-out)

**Decision: one single commit** (not split per chunk). The nine atoms are one cohesive additive
release (`v0.2.0`) verified green as a whole; the release metadata (CHANGELOG, pubspec bump, contract
v1.2, barrel doc-comment) describes the whole batch and was written once at the end. Per-chunk commits
would each be non-releasable (version/CHANGELOG/barrel out of sync with code mid-way), and consumers
pin tags, so per-commit bisectability adds little. Chunking was review discipline, not a ship boundary.

- **Branch:** commit directly to `main` — this repo's established convention (Phase 3 "commit & push";
  every recent commit is on `main`; consumers pin exact `vX.Y.Z` tags so `main` moving can't break
  them). Not branching-first here despite the generic default, because the repo's tag-pinned model is
  explicit in `CLAUDE.md`.

- **Ordered steps (do exactly this, in order):**
  1. **Archive the plan** (GUIDE Phase 3 mandate, and the ledger entry already cites this slug): copy
     `~/.claude/plans/base-on-atomic-rule-floofy-bentley.md` → `plans/archive/2026-07-12_common-atoms/plan.md`.
     (The live plan lives outside the repo tree, so this is a copy-in, not a `git mv`. `plans/archive/`
     currently holds only `.gitkeep` — this is the first archived plan; following GUIDE-strict rather
     than perpetuating the un-archived deviation, since the ledger references the slug for recall.)
  2. **Delete the breadcrumb** `plans/UNFINISHED.md` (`<!-- workflow-hook: auto-breadcrumb -->` — the
     hook's disposable Stop artifact). **Do this before staging** — it is untracked and *not*
     gitignored, so a bare `git add -A` would otherwise capture it.
  3. **Stage** everything now present: 8 modified + 10 new lib files (9 components + `ui_tone.dart`) +
     10 new tests + the archived `plans/archive/2026-07-12_common-atoms/plan.md`. After step 2, `git add -A`
     is safe (breadcrumb gone). Confirm `git status` shows no `UNFINISHED.md`.
  4. **Commit** (one commit; `feat`; ends with the Co-Authored-By trailer; includes a `Verified:` line
     to match this repo's recent commit-body style):
     ```
     feat(components): add common-atoms set (v0.2.0)

     Add the standard Material atom set on top of the six core atoms:
     UiIconButton, UiRadio/UiRadioGroup (M3 RadioGroup API), UiSwitch,
     UiSlider, UiChip, UiCard, UiText, UiAvatar, UiProgressIndicator, plus
     the shared UiTone token and UiTuning radio/switch heights. Refactor
     UnderMaintenancePage onto UiCard. Add the missing UiStatusChip test.

     Additive only (MINOR); consumers pinned to v0.1.0 are unaffected.

     Verified: flutter analyze clean; flutter test 75/75 pass.

     Co-Authored-By: Claude Opus 4.8 <noreply@anthropic.com>
     ```
  5. **Push** to `origin/main` (clean fast-forward — tree is in sync now).
- **Do NOT tag `v0.2.0` in this step** — the `docs/design-system-contract.md` edit still wants a human
  sign-off (the contract's own review gate). Tag once that's confirmed.
- **Verify after:** `git show --stat HEAD` lists exactly the intended files incl. the archived plan and
  **no** `UNFINISHED.md`; `git status` clean; `git log --oneline -1` is the new commit.
- **Superseded text:** the lower "Build order" section's "commit each chunk green" line no longer
  applies — all work sits uncommitted in one tree, so this is a single commit. Disregard it.

## Context

The user asked to "design the most common atoms UI first — button, text box, dropdown, and so on,"
following Atomic Design. Exploration shows the kit **already ships 6 atoms** (`UiButton`,
`UiTextField`, `UiDropdown`, `UiCheckbox`, `UiStatusChip`, `UiBanner`), all built on the token layer
with the default-with-override height pattern. So button / text field / dropdown already exist.

The real gap is the rest of the standard Material atom set. The user chose to build **all** of the
following in one pass:

- **Form-input core:** `UiRadio` (+ `UiRadioGroup`), `UiSwitch`, `UiSlider`
- `UiIconButton` (icon-only button atom)
- `UiCard` + `UiText`
- **Feedback atoms:** `UiProgressIndicator`, `UiAvatar`, generic `UiChip`

Outcome: a consuming Omni-family app can build forms, toolbars, and feedback surfaces entirely from
`Ui*` atoms without dropping to raw Material widgets, keeping every app visually consistent.

This is a workflow-governed change: follow the Adaptive Self-Correcting Workflow (Phase 0 git sync
already clean; ledger entry + doc updates required in Phase 2/3).

**Deliberate override of the "don't build speculatively" stance.** `ROADMAP.md`'s Icebox names
"radio group / segmented control / tooltip — add only when a consumer actually needs them," and the
contract echoes this. Building these ahead of a named consumer contradicts that stance. We proceed
because the **user explicitly requested the common-atoms set be built now** — but the plan must
*reconcile the roadmap*, not silently violate it: move these atoms out of Icebox into a real,
checked-off epic (e.g. "Epic 2: Common-atoms completion") so the roadmap stays self-consistent.

## Non-negotiable conventions (verified against existing atoms)

Every new atom MUST follow the patterns already in the codebase:

- **Zero new dependencies.** Flutter SDK only.
- **Token-only:** no hardcoded `Color`/size/spacing/radius. Read from `UiSpacing`, `UiSizing`,
  `UiRadius`, `UiTypography`, `context.uiColors`, or `Theme.of(context).colorScheme`.
  (`UiStatusChip` is the model for semantic color + `withValues(alpha:)` tinting.)
- **One widget per file**, `Ui<Name>` in `lib/src/components/`, file `ui_<name>.dart`.
- **StatelessWidget only** (atoms hold no state — value + `onChanged` come from the caller, exactly
  like `UiCheckbox`/`UiDropdown`).
- **Default-with-override height:** controls that sit in a form row expose `double? height` that
  falls back to a `UiTuning.instance.<name>Height` field seeded from `UiSizing.controlHeight`
  (model: `UiCheckbox` lines 23-26, 37).
- **Optional `tooltip`** on interactive atoms, wrapped exactly like `UiCheckbox` lines 62-67.
- **Disabled = `onChanged: null`** (model: `UiButton`, `UiCheckbox`).
- Export every new symbol from the barrel `lib/flutter_ui_kit.dart`.
- Mirrored test `test/ui_<name>_test.dart` for each (model: `test/ui_checkbox_test.dart` — assert
  render, height override, and interaction).

## Files to create

### Form-input core
- `lib/src/components/ui_radio.dart` — **Flutter 3.44 API (confirmed installed).** `Radio.groupValue`
  / `Radio.onChanged` are **deprecated** since 3.32 in favor of an ancestor `RadioGroup<T>` that owns
  `groupValue` + `onChanged`; each `Radio<T>` carries only `value`. So:
  - `UiRadioGroup<T>` wraps Material `RadioGroup<T>` (owns `groupValue`, `onChanged`, `List<UiRadioItem<T>>`
    items, `axis` vertical/horizontal). This is the primary API — mirror `UiDropdown<T>`/`UiDropdownItem<T>`
    for the generic-`T` item shape and `UiCheckbox` for the row/label/height/tooltip mechanics.
  - `UiRadio<T>` exposes only `value` + `label` (+ height/tooltip) and **must be used inside a
    `UiRadioGroup`** — do NOT give it a deprecated `groupValue`/`onChanged` pair (that would emit
    `deprecated_member_use` under `flutter analyze`).
- `lib/src/components/ui_switch.dart` — `UiSwitch` (`label`, `value`, `onChanged`, `height?`,
  `tooltip?`). Same row layout as `UiCheckbox`, swapping `Checkbox` → `Switch`.
- `lib/src/components/ui_slider.dart` — `UiSlider` (`value`, `onChanged`, `min`, `max`, `divisions?`,
  `label?`, optional numeric readout, `tooltip?`). Wraps Material `Slider`; colors from theme.
  **No `height` override / no `sliderHeight` tuning field** — a Material `Slider` has a ~48px thumb
  overlay footprint; pinning it into a 35px `controlHeight` row via `SizedBox` clips the overlay. Let
  it size naturally.

### Buttons
- `lib/src/components/ui_icon_button.dart` — `UiIconButton` (`icon`, `onPressed`, `tooltip?`,
  `variant` standard/filled/outlined via `IconButton`/`.filled`/`.outlined`, `tone`,
  `size?` from `UiSizing.iconSm/Md/Lg`). **Tone must NOT import `UiButtonTone` from `ui_button.dart`**
  — a component importing another component violates the layer rule (`flutter-ui-kit-component`
  SKILL §"components import only SDK + theme tokens"). Decision (see below): promote a shared
  `UiTone` enum into `lib/src/theme/ui_tone.dart` (a token) and have `UiIconButton` read
  `context.uiColors` directly for tone, exactly like `UiStatusChip` does its switch.

### Layout / text
- `lib/src/components/ui_card.dart` — `UiCard` (`child`, `padding?` default `UiSpacing.allMd`,
  optional `onTap`). Surface + `UiRadius.brMd`; refactor `UnderMaintenancePage`'s raw `Card` to use it
  (optional, note in plan — keeps one source of truth).
- `lib/src/components/ui_text.dart` — `UiText` with named ctors mapping to the M3 text roles this kit
  uses (`.title`, `.body`, `.label`, `.caption`, `.mono`) reading `Theme.of(context).textTheme` +
  `UiTypography.mono`. Optional `color`, `maxLines`, `overflow`, `textAlign`.

### Feedback
- `lib/src/components/ui_progress_indicator.dart` — `UiProgressIndicator` with `.circular` /
  `.linear` named ctors, optional `value` (null = indeterminate), size from `UiSizing`.
- `lib/src/components/ui_avatar.dart` — `UiAvatar` (`initials` or `icon`, `size?` from `UiSizing`,
  background from `context.uiColors`/colorScheme). No network image (zero-dep, but `ImageProvider`
  param is fine since it's SDK-level).
- `lib/src/components/ui_chip.dart` — generic `UiChip` distinct from `UiStatusChip`: interactive
  input/filter/choice chip (`label`, `selected`, `onSelected?`, `onDeleted?`, `avatar?`). Wraps
  Material `FilterChip`/`InputChip`. **Height trap (per `flutter-ui-kit-component` SKILL):** a chip
  has no intrinsic height lever — wrapping it in `SizedBox(height:)` sizes the *slot*, not the pill.
  Size the chip's **label** and zero the chip's `labelPadding`/`padding` vertical instead, driving off
  `UiTuning.instance.chipHeight` (the existing field). Test the **exact** height, not a floor.

### Tests (one per atom)
`test/ui_radio_test.dart`, `ui_switch_test.dart`, `ui_slider_test.dart`, `ui_icon_button_test.dart`,
`ui_card_test.dart`, `ui_text_test.dart`, `ui_progress_indicator_test.dart`, `ui_avatar_test.dart`,
`ui_chip_test.dart`. Each asserts: renders under `buildUiTheme()`; height override (where
applicable); interaction callback fires; disabled when `onChanged`/`onPressed` is null.

### New token file
- `lib/src/theme/ui_tone.dart` — a shared `UiTone` enum (`normal`/`success`/`danger`, matching the
  existing `UiButtonTone` values) so `UiIconButton` (and any future component) can express semantic
  tone by depending on the **theme layer**, not on `ui_button.dart`. Export from the barrel. Leave the
  existing `UiButtonTone` in `ui_button.dart` untouched for now (renaming it would be a breaking API
  change for consumers pinned to a tag) — a later chunk may alias/migrate it.

## Files to modify

- `lib/flutter_ui_kit.dart` — add an `export` line for each of the 9 new component files + the new
  `ui_tone.dart` token; update the `components/` doc-comment list (lines 8-9).
- `lib/src/theme/ui_tuning.dart` — add per-component height fields **only for row-aligned controls**
  (`switchHeight`, `radioHeight`). **No `sliderHeight`** (see slider note above). Follow the exact
  triple pattern: private field seeded from `UiSizing.controlHeight` (lines 51-56), getter (67-72),
  notifying setter (119-147), and a line in `reset()` (162-167). `UiChip` reuses the existing
  `chipHeight`.
- `docs/design-system-contract.md` — under the atomic-design mapping, note the expanded atom
  inventory; bump the doc `version` + `last_validated` + Revision History row (frontmatter present).
  **Contract edits require a human review before tagging** (per the contract's own gate) — flag this
  in the close-out.
- `CHANGELOG.md` + `pubspec.yaml` version — this is additive (new public API), so a **MINOR** bump
  (0.1.0 → 0.2.0). Do NOT tag until `flutter analyze` + `flutter test` are clean on `main`.
- `history/2026-W28.md` (weekly ledger — **already exists**, ISO week 28; just append) — What/Why/Refs
  entry for the atom batch (required by workflow).
- `ROADMAP.md` — (a) clear Epic 1's `test/ui_status_chip_test.dart` item by writing that test in this
  batch; (b) move the "radio group / segmented control / tooltip" Icebox line into a new **Epic 2:
  Common-atoms completion** listing the 9 atoms, so the roadmap reflects the override rather than
  contradicting it. Also honor Epic 1's second bullet: add a mirrored test for any composite touched
  (`UnderMaintenancePage`, if refactored onto `UiCard`).

## Design notes / decisions

- **`UiRadio` / `UiRadioGroup`:** `UiRadioGroup` is the primary, ergonomic API wrapping M3
  `RadioGroup<T>`; `UiRadio<T>` is value-only and lives inside it (Flutter 3.44 API — the deprecated
  `groupValue`/`onChanged`-on-`Radio` shape is intentionally NOT used).
- **Shared tone via `theme/ui_tone.dart`**, not by importing `UiButtonTone` across components —
  preserves the component→theme-only import boundary (`flutter-ui-kit-component` + `dart-solid-principles`).
- **`UiText`** is a thin typography atom, not a `Text` replacement everywhere; it exists so call sites
  stop reaching into `Theme.of(context).textTheme.*` by hand. Keep it minimal. `UiCard`/`UiText`/
  `UiAvatar`/`UiProgressIndicator`/`UiIconButton` do **not** take a `controlHeight` override (they
  don't sit in aligned form rows).
- Material `Slider`/`Switch`/`Chip` already read the M3 theme, so most coloring is automatic — only
  add explicit token reads where the default diverges from this kit's semantic palette.

## Build order (chunked, per the workflow's one-active-chunk discipline)

Building 9 atoms + 10 tests in one commit fights Phase-1 chunking. Sequence, committing each chunk
green (analyze + test) before the next; keep `plans/UNFINISHED.md` as the breadcrumb between chunks:

1. **Chunk 0 — status-chip test.** `test/ui_status_chip_test.dart`. Independent, clears Epic 1's open
   item, no new API. Quick win.
2. **Chunk 1 — settle the two design decisions in code:** the `theme/ui_tone.dart` token and the
   `UiRadioGroup`/`UiRadio` RadioGroup shape. `UiIconButton` and the radios can't be written correctly
   until these land.
3. **Chunk 2 — independent atoms:** `UiText`, `UiCard`, `UiAvatar`, `UiProgressIndicator` (no
   dependencies, no tuning fields).
4. **Chunk 3 — form-row atoms:** `UiSwitch`, `UiSlider`, `UiChip` (+ `UiTuning` `switchHeight`/
   `radioHeight`), then `UiRadio`/`UiRadioGroup` and `UiIconButton` from Chunk 1's decisions.
5. **Close-out chunk:** barrel exports (batched or per-chunk), contract doc, CHANGELOG, version bump,
   ledger, roadmap.

Only hard dependencies: `UiRadioGroup` → `UiRadio` + RadioGroup decision; `UiIconButton` → `ui_tone.dart`;
`UiChip` → chip-height mechanism.

## Verification

1. `flutter pub get`
2. `flutter analyze` — must be clean (flutter_lints ^6.0.0 + `prefer_final_locals`,
   `prefer_const_constructors`, `avoid_print`).
3. `flutter test` — all pass, including the 9 new mirrored tests + the added status-chip test.
4. Spot-check alignment: build a `Row`/`Column` mixing `UiButton`, `UiTextField`, `UiSwitch`,
   `UiRadio`, `UiCheckbox` and confirm they share `UiSizing.controlHeight` by default (a widget test
   asserting equal `.height` like `ui_checkbox_test.dart` lines 21-24).
5. Optional live check via `UiTuningOverlay` if a running example app is available.

## Close-out (Phase 3)

Archive this plan, clear any `plans/UNFINISHED.md` breadcrumb, write the final ledger entry, update
`ROADMAP.md` (clear Epic 1 status-chip test + add Epic 2) + `CHANGELOG.md`, bump `pubspec.yaml` to
0.2.0, then commit & push. **The `docs/design-system-contract.md` edit needs human review before the
tag** (contract gate). Tag `v0.2.0` only after analyze + test are green on `main` and the contract
change is signed off.
