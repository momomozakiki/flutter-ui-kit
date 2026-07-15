---
name: golden-rule
description: >-
  Use BEFORE adopting, adding, or changing any rule, convention, pattern, or standard in flutter-ui-kit
  — and whenever weighing an external guide, a package's convention, a Stack Overflow pattern, or a
  subagent's suggestion against how this kit already does things. Triggers on: "should we adopt/follow
  this", "add a new rule/convention", "change the rule for X", "is this the right pattern", "reconcile
  this guide", "does this align with our standards", editing a canonical doc (the design-system contract
  or adaptive spec) or a canonical skill, or resolving two conflicting approaches. Enforces the
  reconcile-before-adopt procedure so the repo keeps ONE authority per design area and doesn't drift into
  competing patterns. Advisory (it guides the decision; `flutter test` is the real breakage gate).
---

# Golden-rule safeguard — reconcile before you adopt

This skill operationalizes CLAUDE.md's **Canonical-guide rule**: for any recurring design area this repo
keeps **exactly one** canonical authority, so alternatives get *filtered*, not silently absorbed. The
canonical authorities are indexed in
[`docs/golden-rule/index.md`](../../docs/golden-rule/index.md) — start there.

**Why this exists:** without a single authority, every external guide / package convention / clever
one-off quietly adds a competing pattern, and the codebase fractures (two breakpoint systems, two nav
patterns, two color rules…). The kit's whole value is *one* consistent system every consuming app
mirrors. A new idea earns its place only by *aligning* with the incumbent or *clearly beating it* — not
by merely being different or newer.

**What this skill is and isn't:** it is an **advisory procedure** — it structures the judgment and makes
the reasoning auditable. It does **not** mechanically verify that a rule is semantically consistent (no
tool can), and it cannot block an edit (only hooks/permissions can). The **real "doesn't break the code"
gate is `flutter analyze` + `flutter test`.**

## The procedure

When a new/alternative rule, convention, or pattern shows up:

### 1. Locate the owning authority
Find which canonical authority governs this area, via
[`docs/golden-rule/index.md`](../../docs/golden-rule/index.md):
- design/token/layer/naming/versioning rules → the **design-system contract**.
- adaptive/responsive/navigation/breakpoint rules → the **adaptive spec** + `flutter-adaptive-navigation`.
- Dart class/SOLID/reuse design → `dart-solid-principles`.
- component/token authoring mechanics → `flutter-ui-kit-component`.
- *how work is done* (phases/ledger/roadmap) → `adaptive-workflow` (process track, separate).

If genuinely no authority covers it, that's a *new* area — the new rule may become the first authority;
record it in the right doc and link it from the index.

### 2. Check alignment
Compare the proposal against the incumbent rule:
- **Aligns / is a special case of it** → adopt: fold it into the owning authority (add the nuance,
  example, or clarification) **in the same change**. Don't create a parallel note elsewhere.
- **Contradicts it** → go to step 3.
- **Neither adds nor contradicts** (just different phrasing) → the incumbent wins on purpose; reject and
  optionally record the "why not" so it isn't re-litigated.

### 3. If it contradicts: it may only REPLACE, never coexist
A contradicting rule can win only if **all** hold:
1. It is **clearly, substantially better** (not marginal) — articulate the concrete benefit.
2. It is **proven not to break the codebase**: `flutter analyze` clean **and** `flutter test` green
   after applying it (plus any migration).
3. The **owning authority is updated in the same change** so the old rule is *removed*, not left to
   disagree — there must never be two authorities saying different things.
4. The reasoning (what was rejected/replaced and why) is **recorded**, e.g. a reconciliation table like
   the adaptive spec's §3.5 or a ledger entry.

If any of these fails, keep the incumbent.

### 4. Respect precedence
Per the index: **CLAUDE.md (Constitution) + workflow-core GUIDE win** over any doc/skill; a **doc wins
over a skill** that operationalizes it (fix the skill in the same change). Never let a lower authority
override a higher one.

## Worked precedent

The external "Flutter Complete Adaptive Layout Guide" was **harvested, not copied**: aligned ideas
became `UiAdaptiveNavShell` + the `flutter-adaptive-navigation` skill + the adaptive spec; everything
rejected (dependency-heavy packages, `Platform`-based layout, M2 widgets, mismatched breakpoints) is
recorded with reasons in the spec's reconciliation table (§3.5). That is the shape every
"should we follow this other guide?" decision should take.

## Self-check

- Did I identify the **one** owning authority before deciding?
- If I adopted something, did I update **that** authority in the **same change** (no second source of
  truth)?
- If I replaced a rule, are `flutter analyze` + `flutter test` green, and is the old rule *gone*?
- Is the decision recorded so it won't be re-argued?

## References

- [`docs/golden-rule/index.md`](../../docs/golden-rule/index.md) — the canonical-authorities index.
- [`CLAUDE.md`](../../CLAUDE.md) — the Canonical-guide rule + Constitution precedence.
- [`flutter-ui-kit-component`](../flutter-ui-kit-component/SKILL.md), [`dart-solid-principles`](../dart-solid-principles/SKILL.md),
  [`flutter-adaptive-navigation`](../flutter-adaptive-navigation/SKILL.md) — the design authorities this guards.
