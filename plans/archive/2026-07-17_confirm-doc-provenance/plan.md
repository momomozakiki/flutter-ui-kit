# Plan: Confirm provenance of the two design docs + fix their stale golden-rule indexing

## Context

ROADMAP Epic 2 flagged two docs as `official: unknown` / `source: origin unknown`:
- `docs/golden-rule/flutter-adaptive-ui-design-specification.md` (the adaptive spec — a **golden** authority)
- `docs/flutter-layout-and-component-design/` (the layout & component design guide — canonical **reference**)

**They are not unknown-origin.** Per the user: both were **AI-distilled from online best-practice
resources, then regenerated/reorganized by Claude into smaller chunked docs for easier reference &
indexing.** So the correct provenance is `official: false`, `source: agent-generated` — matching the
contract and `.ai/best_practices.md`.

Two things also went wrong when the docs were reorganized (the folding + golden-rule move) and must be
corrected so these important docs aren't "forgotten" again:
1. **Stale path references** — [ROADMAP.md:19](ROADMAP.md#L19) names them by bare/old filenames
   (`flutter-adaptive-ui-design-specification.md` with no `golden-rule/` prefix; the pre-fold single
   file `flutter-layout-and-component-design.md`).
2. **Provisional/mis-filed status** — [golden-rule/index.md:50-53](docs/golden-rule/index.md#L50-L53)
   still labels the adaptive spec "**provisional golden / official: unknown**."

**User decisions (confirmed):** keep the layout guide as **canonical reference** (not promoted to a rule
authority — the contract stays the single rule authority); **save a memory** so both docs' canonical
role + correct paths are never lost again.

## Changes

### 1. `docs/golden-rule/flutter-adaptive-ui-design-specification.md` — confirm provenance
- Frontmatter: `official: unknown` → `official: false`; `source: origin unknown` → `source: agent-generated`;
  `version: 3.2` → `3.3`; `last_validated: 2026-07-17`.
- Provenance note (lines 15-16): rewrite from "origin not yet confirmed" → **confirmed**: distilled by
  AI from online adaptive-UI / responsive best-practice resources, then reorganized in-repo; canonical
  golden spec.
- H1 `(v3.2)` → `(v3.3)`; append a short `### Summary of v3.3 Adjustments` line (metadata/provenance
  confirmation only — no design change), consistent with the doc's existing version-summary convention.

### 2. `docs/flutter-layout-and-component-design/` — confirm provenance (stays canonical reference)
- `index.md` frontmatter: `official: unknown` → `official: false`; `source: origin unknown` →
  `source: agent-generated`; `version: 1.2` → `1.3`; `last_validated: 2026-07-17`.
- `index.md` provenance note (lines 16-18): rewrite to the confirmed origin.
- `index.md` Revision History + `CHANGELOG.md`: add a `1.3 — 2026-07-17` row/entry.

### 3. `docs/golden-rule/index.md` — de-provisionalize + correct classification
- Adaptive-spec entry (lines 50-53): drop the "provisional golden / `official: unknown` (ROADMAP Epic 2)"
  caveat; state provenance confirmed (`official: false`, agent-generated), fully canonical.
- "Not golden" section (line 70): keep the layout guide listed as canonical **reference/teaching** (per
  user), but note provenance is now confirmed (agent-generated), not pending.
- Bump index `version: 1.1` → `1.2` + Revision History row.

### 4. `ROADMAP.md:19` — tick the two docs with correct paths
Mark the two docs' provenance **done** (with correct paths: `docs/golden-rule/…` and the folded
`docs/flutter-layout-and-component-design/`). The `Atomic Design in Flutter.md` third-party article's
source **URL is still pending** (user did not supply it) — split it out so it stays open as its own item.

### 5. Content consistency review (light)
Skim both docs against the contract (the single rule authority) for any rule conflict (breakpoints,
token-only, M3-only). Record findings in the ledger; only edit if a genuine contradiction surfaces
(none expected — the adaptive spec already reconciled against the kit in §3.5).

### 6. Memory (user asked)
Write a `reference` memory recording: both docs' canonical role (adaptive spec = golden authority;
layout guide = canonical reference), their **correct paths**, and confirmed provenance (agent-generated,
distilled from online best practices + reorganized). Add the one-line pointer to `MEMORY.md`.

## Out of scope
- The `Atomic Design in Flutter.md` `.prov.md` URL (still genuinely pending — kept as an open ROADMAP item).
- Promoting the layout guide to a rule authority (user chose: keep as reference).
- No `lib/` code, tokens, API, or semver bump — docs/metadata only.

## Workflow / merge-gate
Touches **canonical guidance** (`docs/golden-rule/index.md` + a golden doc) → branch-worthy per the
pragmatic scope rule. Branch `docs/confirm-doc-provenance` → commit → push → `gh pr create`; **no
self-merge** (next-session F6 / on user verification). Ledger entry in `history/2026-W29.md` (G3).

## Verification
- `flutter analyze` + `flutter test` — must stay green (no code touched); confirms nothing broke.
- `grep -rn "official: unknown\|origin unknown" docs/golden-rule/ docs/flutter-layout-and-component-design/`
  → no hits (both resolved).
- Eyeball `golden-rule/index.md` — adaptive spec no longer "provisional"; both relative links resolve.
- Confirm the memory file exists and `MEMORY.md` has its pointer line.
