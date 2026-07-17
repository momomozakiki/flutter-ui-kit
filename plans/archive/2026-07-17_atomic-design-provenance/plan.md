# Plan: Verify, adopt & consolidate provenance for "Atomic Design in Flutter.md"

## Context

`docs/Atomic Design in Flutter.md` is a ~24 KB canonical reference doc in the kit that
"appears to be a verbatim / lightly-adapted external article." Its origin URL was never
recovered, so its provenance sidecar `docs/Atomic Design in Flutter.md.prov.md` has sat at
`source: third-party article (URL pending)` / `official: unknown`, and ROADMAP.md:20 has
tracked "fill the source URL" as an open, blocked item for months.

User decision: stop waiting on an unrecoverable URL. Instead **verify the article's technical
content on its merits**, have Claude **vouch for and adopt it as a repo-owned reference**, and
**consolidate the sidecar into the doc's own frontmatter** (one file), matching how every other
markdown doc in the repo records provenance.

**Verification done this session** — content is technically sound and current for the repo's
Flutter 3.44:
- `WidgetState`/`WidgetStateProperty` replacing `MaterialState*` after 3.19 — confirmed
  ([breaking-changes/material-state](https://docs.flutter.dev/release/breaking-changes/material-state)).
- `withValues(alpha:)` replacing deprecated `withOpacity` in 3.27+ — confirmed
  ([wide-gamut-framework](https://docs.flutter.dev/release/breaking-changes/wide-gamut-framework)).
- Five-tier Atomic Design, `ThemeExtension` `lerp`/`copyWith`, `textScaler: TextScaler.linear(1.0)`
  goldens, 48×48 targets, 4.5:1 contrast, `NavigationBar→Rail→Drawer` — all accurate; the doc
  already carries a "How this repo applies it" mapping matching the design-system contract. No
  conflict with the golden-rule authorities.

## User-confirmed decisions
1. **Attribution:** honest — `source: agent-verified`; record that the original external URL was
   never recovered and that Claude (Opus 4.8, 2026-07-17) independently verified accuracy & owns
   upkeep. Not a literal "Claude authored this" claim.
2. **Frontmatter:** add standard in-body frontmatter to the article body.
3. **Consolidate:** fold sidecar content into the body and **delete** the `.prov.md`.

## Facts established (review clarifications resolved)
- **Canonical frontmatter shape** (from `design-system-contract.md`, `ONBOARDING.md`) is exactly:
  `title, version, last_validated, official, source, tags, applies_when, estimated_tokens`. There is
  **no `provenance:` field** in repo convention — provenance narrative lives in a body
  `## Revision History` table. Plan updated to match (no invented field).
- The article currently has **no frontmatter and no `provenance` field** → clean prepend, no merge.
- **No code/CI/build references** the `.prov.md` sidecar (grep). Remaining mentions are in
  `history/` and an archived plan (both immutable) → deleting it breaks nothing. One **stale
  cross-reference** found and added to scope: `docs/golden-rule/index.md:69`.
- Article-file *links* in `CLAUDE.md:53`, `flutter-ui-kit-component/SKILL.md:32`,
  `design-system-contract.md:83` stay valid (file not moving) — no edit needed.
- Ledger: append to **existing** `history/2026-W29.md`; format `### [doc] path` + What/Why/Refs.
- `version` frontmatter is the single source of truth (CHANGELOG.md is semver *releases* only).
- python 3.12 available for a YAML parse-check.

## Changes

### 1. `docs/Atomic Design in Flutter.md` — prepend frontmatter + Revision History
Prepend the canonical 8-field block above line 1 (`# Atomic Design in Flutter – …`):
```
---
title: Atomic Design in Flutter
version: 1.1
last_validated: 2026-07-17
official: false
source: agent-verified
tags: [atomic-design, reference, design-system, flutter, canonical-reference]
applies_when: "Understanding how Atomic Design maps onto flutter-ui-kit's tiers; onboarding to the kit's structure and state boundaries."
estimated_tokens: 5500
---
```
Then add a `## Revision History` section (matching `design-system-contract.md`'s idiom) directly
under the H1, carrying the provenance narrative folded out of the sidecar:

| Version | Date | Change |
|---|---|---|
| 1.0 | 2026-07-11 | Provenance sidecar created; lightly-adapted external article, original source URL pending. |
| 1.1 | 2026-07-17 | Original external URL deemed unrecoverable. Content independently verified for technical accuracy by **Claude (Opus 4.8)** against Flutter 3.44 / Material 3 (WidgetState ≥3.19, withValues ≥3.27, five-tier Atomic Design, ThemeExtension lerp/copyWith, adaptive NavigationBar→Rail→Drawer). Adopted as a repo-owned `agent-verified` canonical reference; sidecar `.prov.md` consolidated into this frontmatter. |

- `source: agent-verified` is a deliberate, honest distinction from the `agent-generated` used by
  docs Claude wrote from scratch (this one is externally-originated, agent-*verified*).
- Article body content otherwise **unchanged** (already accurate).

### 2. Delete `docs/Atomic Design in Flutter.md.prov.md`
Content now lives in the doc's frontmatter + Revision History. (Leave
`.claude/workflow_config.json.prov.md` — JSON can't carry frontmatter, so that sidecar stays.)

### 3. `docs/golden-rule/index.md:69` — refresh the stale note
Change "a verbatim third-party article (provenance pending)" → note that it's an `agent-verified`
repo-owned reference (provenance resolved 2026-07-17: origin URL unrecoverable, content verified &
adopted), mirroring the already-resolved wording used for `flutter-layout-and-component-design/`
two lines below. Keep it in the "Not golden (reference)" section — its status as reference-not-rule
is unchanged.

### 4. `ROADMAP.md:20` — close the item
Retire the open `- [ ]` line: mark done with a one-line note (URL unrecoverable → agent-verified &
adopted; provenance consolidated into the doc frontmatter).

### 5. Ledger `history/2026-W29.md` — append entry
`### [doc] docs/Atomic Design in Flutter.md (+ index.md, ROADMAP.md)` — What: verified article
accuracy online, adopted as agent-verified repo-owned reference, consolidated `.prov.md` into
in-body frontmatter + Revision History, refreshed index.md note, closed ROADMAP.md:20. Why:
unblock the long-pending provenance item without an unrecoverable URL. Refs: this plan + PR.

### 6. Memory `canonical-design-docs.md` — refresh
Update the "provenance pending" note → resolved (agent-verified, consolidated to frontmatter,
sidecar removed), so recall stays accurate.

## Governance / workflow
- **Branch:** `docs/atomic-design-provenance`. Now touches `docs/golden-rule/index.md` (a
  canonical-authority index) → clearly branch-worthy. Close via push + `gh pr create`; **no
  self-merge** — merge on the user's verification per the CLAUDE.md **Branch + PR merge-gate (G2)**.
- Not a golden-rule *adoption* (the doc is already integrated/reconciled) — this is provenance +
  verification only, so no fresh reconcile pass is required.

## Verification
1. `python -c "import sys,yaml,io; d=open('docs/Atomic Design in Flutter.md',encoding='utf-8').read(); fm=d.split('---',2)[1]; yaml.safe_load(fm); print('YAML OK')"`
   (fallback if PyYAML absent: `sed -n '1,10p'` visual check + confirm `---` fences balanced).
2. `sed -n '1,20p' "docs/Atomic Design in Flutter.md"` → frontmatter + Revision History present, H1
   and body intact below.
3. `ls "docs/Atomic Design in Flutter.md.prov.md"` → gone.
4. `grep -n "provenance pending\|verbatim third-party" docs/golden-rule/index.md` → no match left.
5. `grep -n "Atomic Design in Flutter" ROADMAP.md` → item retired, not an open `- [ ]`.
6. `tail -20 history/2026-W29.md` → ledger entry present.
7. `flutter analyze` clean (no code touched — sanity only; markdownlint intentionally skipped: not
   a repo dependency, zero-tooling-dep repo, GitHub renders frontmatter fine, YAML parse covers the
   real risk).
8. Push branch + `gh pr create`; hand the PR to the user to verify per the merge-gate.
