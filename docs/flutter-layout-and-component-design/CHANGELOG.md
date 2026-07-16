---
title: "CHANGELOG — Flutter Layout & Component Design guide"
exclude_from_ai: true
tags: [changelog, history]
---

# CHANGELOG — Flutter Layout & Component Design guide

Full revision history for this folded document (Episodic memory — not loaded into AI context; see the
Progressive Disclosure Guide §9). The lean current-state history lives in [`index.md`](index.md).

## 1.3 — 2026-07-17
- **Provenance confirmed.** Frontmatter `official: unknown` → `official: false`, `source: origin unknown`
  → `source: agent-generated`. The guide's content was AI-distilled from online layout/component
  best-practice resources, then regenerated and reorganized in-repo (folded into this chunked folder).
  It stays **canonical reference/teaching material** — not promoted to a rule authority; the contract
  remains the single rule authority. Resolves the ROADMAP Epic 2 provenance item for this doc.

## 1.2 — 2026-07-16
- **Part 6 (Naming Conventions).** Renamed the consumer-app example folder `composite/` → `screens/` in
  the "File Organization" tree. The `composite/` name was a valid consumer example when written, but it
  now collides with the kit's retired pre-v0.4.0 layer name; `screens/` is a neutral, unambiguous label.
  Content-only clarity edit — no rule change.

## 1.1 — 2026-07-15
- **Folded** the single ~9,000-token file `docs/flutter-layout-and-component-design.md` into this folder
  (`index.md` + `part-1-core-layout.md` … `part-6-naming-conventions.md` + this CHANGELOG), per
  `.claude/workflow-core/GUIDE.md` §6.4 — the single file exceeded the Progressive Disclosure Semantic
  per-file token budget (≤5,000). Content preserved verbatim, only split by topic and given per-child
  `parent:` back-links. `README.md` updated to point at `index.md`.

## 1.0 — 2026-07-11
- Added Documentation-Standard frontmatter (`title/version/last_validated/official/source/tags/
  applies_when/estimated_tokens`) to the then-single-file guide. Origin flagged `official: unknown`
  (provenance still to be confirmed — ROADMAP Epic 2).
