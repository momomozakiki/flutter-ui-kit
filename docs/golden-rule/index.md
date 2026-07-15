---
title: "Golden Rules: canonical authorities index"
version: 1.0
last_validated: 2026-07-15
official: false
source: agent-generated
tags: [golden-rule, governance, canonical, authority, index, contract]
applies_when: "Deciding whether a new rule/convention/pattern may be adopted; locating the one canonical authority for a design area; reconciling an external guide against this kit's rules."
estimated_tokens: 700
---

# Golden Rules — canonical authorities index

**Version 1.0** — *the single index of this kit's canonical rule authorities and the precedence that
governs them.*

## Revision History
| Version | Date       | Change   |
|---------|------------|----------|
| 1.0     | 2026-07-15 | Created the golden-rule folder + this index; moved the contract and adaptive spec in. |

This folder holds the repo's **golden rules** — the canonical, must-follow authorities every change is
measured against. It exists so there is exactly **one** place to find "what rules govern this kit" and
one precedence order, so alternative ideas can be *filtered* rather than silently adopted (the
[Canonical-guide rule](../../CLAUDE.md#canonical-guide-rule-one-authority-per-design-area) in CLAUDE.md).

> **How to use this:** before adopting any new rule, convention, or external guide, run the
> [`golden-rule` skill](../../.claude/skills/golden-rule/SKILL.md)'s procedure against the owning
> authority below. Adopt only if it *aligns*, or if it is *clearly better and proven not to break the
> code* (`flutter analyze` + `flutter test` green) — and update the owning authority in the **same
> change** so two authorities never disagree.

## Precedence (highest wins)

1. **`CLAUDE.md`** (repo root) — the Constitution: always-loaded, immutable core rules, and the
   Canonical-guide rule itself. Plus **`.claude/workflow-core/GUIDE.md`** for *process*. When anything
   below disagrees with these, CLAUDE.md and the GUIDE win.
2. **The canonical design docs** in this folder (below).
3. **The canonical design skills** (below) — they operationalize the docs; if a skill and its doc
   disagree, the doc wins and the skill is corrected in the same change.

## Canonical design-rule authorities

### Docs (in this folder)
- [`design-system-contract.md`](design-system-contract.md) — **the contributor contract**: SDK/language
  requirements, zero-dependency policy, layer rules, the [atomic-design mapping](design-system-contract.md#atomic-design-mapping),
  naming, token-only rule, default-with-override, testing, [versioning](design-system-contract.md#versioning--releases).
  (`official: false`, agent-generated for this repo.)
- [`flutter-adaptive-ui-design-specification.md`](flutter-adaptive-ui-design-specification.md) — the
  adaptive/responsive **spec**: breakpoints, window sizing, navigation patterns, Windows-desktop
  constraints, testing protocols. **Provisional golden** — its provenance is still `official: unknown`
  (ROADMAP Epic 2); its *content* is canonical but its origin needs confirming before it's fully blessed.

### Skills (in `.claude/skills/`, referenced not moved)
- [`flutter-ui-kit-component`](../../.claude/skills/flutter-ui-kit-component/SKILL.md) — how to add/edit
  a component, token, or composition (token-only rule, default-with-override, testing/versioning).
- [`dart-solid-principles`](../../.claude/skills/dart-solid-principles/SKILL.md) — SOLID + everyday Dart
  design practices, scoped to Dart.
- [`flutter-adaptive-navigation`](../../.claude/skills/flutter-adaptive-navigation/SKILL.md) — adaptive
  navigation via `UiAdaptiveNavShell`; the width-not-platform, zero-dependency rules.
- [`golden-rule`](../../.claude/skills/golden-rule/SKILL.md) — the safeguard procedure for adopting any
  new rule (this index's companion).

## Not golden (reference / how-to — kept in `docs/`, deliberately)

These inform but are **not** canonical rules, so they are not in this folder:
- `docs/Atomic Design in Flutter.md` — a verbatim third-party article (provenance pending). The kit's
  *actual* atomic-design rule lives in the contract's [atomic-design mapping](design-system-contract.md#atomic-design-mapping).
- `docs/flutter-layout-and-component-design/` — a teaching/reference guide.
- `docs/ONBOARDING.md` — a how-to for adding the kit to a consuming app.

## Process authority (separate track)

- [`adaptive-workflow`](../../.claude/skills/adaptive-workflow/SKILL.md) + `.claude/workflow-core/` —
  governs *how work is done* (phases, ledger, roadmap), not *design rules*. Active, but a different
  track from the design authorities above.
