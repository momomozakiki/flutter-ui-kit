# Next plan: align skill/living-doc folder paths with the v0.4.0 tiering

**Status:** not started (deferred from the 2026-07-15 adaptive-nav-shell task, at user request, to keep
that commit scoped). Tracked in ROADMAP Epic 2.

## Context

v0.4.0 (2026-07-12) reorganized `lib/src/` from `components/` + `composite/` into strict Atomic tiers
`atoms/` / `molecules/` / `organisms/`. The code, the design-system contract, `CLAUDE.md`, and
`naming_conventions.md` were updated — but several **live guidance** files still describe the old
layout, so they now misdirect anyone (human or agent) following them. This is stale guidance, not a
code bug, but it will cause new components to be described against folders that no longer exist.

**Do NOT touch historical records** — `CHANGELOG.md`, `history/*.md`, and `plans/archive/**` reference
the old paths *correctly* (they describe past states). Only fix present-tense guidance.

## Findings (files + what's stale)

1. **`.claude/skills/flutter-ui-kit-component/SKILL.md`** — the most stale, several spots:
   - Description frontmatter: `(lib/src/components/, lib/src/theme/, lib/src/composite/)` →
     `(lib/src/atoms/, lib/src/theme/, lib/src/molecules/, lib/src/organisms/)`.
   - §1 layer decision table (rows for "Core atom" `lib/src/components/`, "Generic composition"
     `lib/src/composite/`).
   - §1a atomic-design table: Atoms row `lib/src/components/`; Molecules and Organisms rows both
     `lib/src/composite/` → should be `molecules/` and `organisms/` respectively.
   - The "Molecule vs. organism (both share `composite/`…)" paragraph — they no longer share a folder;
     they're now separated by folder (align with the contract, which already says "live in separate
     folders and must not be conflated").
   - §7 layer-specific headers `### lib/src/components/` and `### lib/src/composite/`.
   - References section link `[lib/src/components/](../../lib/src/components/)`.
2. **`.claude/skills/dart-solid-principles/SKILL.md`** — lines ~31–32 (atoms `lib/src/components/`,
   compositions `lib/src/composite/`) and the reference link ~247 `lib/src/components/ui_button.dart`
   → `lib/src/atoms/ui_button.dart`.
3. **`.claude/skills/adaptive-workflow/SKILL.md`** — one line (~68) "promoted into `lib/src/composite/`"
   → the promotion target is now `lib/src/molecules/` or `lib/src/organisms/`.
4. **`.ai/best_practices.md`** — layer-rules bullet (~45–46) `lib/src/components/` + `lib/src/composite/`.

## Approach

- Map `components/` → `atoms/`; `composite/` → `molecules/` (stateless) **or** `organisms/` (local UI
  state), matching how the contract already frames it. Where a single "composite" mention must pick
  one, say "`molecules/` (stateless) or `organisms/` (local UI state)".
- Where the old text asserts molecules/organisms "share a folder" and only a reviewer can tell them
  apart, update to: they're in **separate folders** now (the folder path is the state boundary), and a
  reviewer still gates the molecule-vs-organism *judgment* for a new widget.
- Bump `best_practices.md` version + revision row; skills have no version field (two-field frontmatter).
- Docs/guidance-only — no Dart, no token/API change, no semver bump. Add a ledger entry.

## Verification

- `grep -rn "lib/src/components\|lib/src/composite" .claude/skills .ai` returns **only** intended
  historical quotes (ideally none in these four files).
- Spot-read each edited file to confirm the surrounding sentences still read correctly.
