# Plan — Branch + PR merge-gate discipline for the Adaptive Workflow

## Context

Today the Adaptive Self-Correcting Workflow closes every plan by committing and pushing
**directly to `main`** (Phase 3: `git add -A && git commit && git push`). There is no
branch isolation and no verification gate before changes land on `main` — the branch that
consuming Omni-family apps pin their tags from. The user wants each plan to:

1. Be evaluated at the start for whether it warrants its **own branch**.
2. **Commit + push** on that branch at close (not straight to `main`).
3. Open a **PR** so the change can be verified before it merges to `main`.
4. Before starting a new plan, **check for any open PR/merge** and ask the user whether the
   previous PR is verified and mergeable — so no new work stacks on unverified changes and
   every fix lands clean.

The canonical Phase 0–3 manual lives in the **pinned `.claude/workflow-core/` submodule**,
which must not be edited locally (a `git submodule update` re-sync clobbers it, and it is
shared across repos). Per the Constitution, repo-specific overrides live **outside** that
managed content — in `CLAUDE.md`, the local `adaptive-workflow` skill, and `.ai/` docs — and
`CLAUDE.md` wins on disagreement. So this change is expressed purely as **flutter-ui-kit
bindings** that override the submodule's push-to-main default; the submodule is untouched.

This is a canonical-authority change (git workflow), so it goes through the `golden-rule`
reconcile-before-adopt procedure: the incumbent ("commit & push to `main`") is replaced by
"branch → PR → verified merge", the rationale is recorded, and the single authority
(`CLAUDE.md` Git-workflow section) is updated in the same change.

## Execution model — checklist-driven, select-what-applies

The workflow is expressed as a **master checklist**, not a rigid pipeline. For any task you
**select the applicable rows** rather than marching through every step — a generalization of
what the workflow already does with Phase 2's conditional-trigger table and Phase 1's
"task-specific checklist" instruction. Two tiers keep flexibility from eroding safety:

- **Mandatory gates (always fire — few):**
  - **G1** Git sync before editing (F1).
  - **G2** Branch / PR merge-gate — the new rule: no unverified code reaches `main`.
  - **G3** Ledger entry for any real (non-trivial) change.
  - **G4** No dangling `UNFINISHED.md` at rest.
- **Selectable checklist (pick per task, each with a "select when…" trigger):**
  branch-or-not · PR-or-not · doc frontmatter · roadmap update · provenance · retro ·
  `SCOPE.md` · test scope · version/`CHANGELOG` bump · env check.

**Phase 1 becomes:** look at the task → tick the applicable selectable rows → that (plus the
four mandatory gates) is your plan. Nothing is improperly "skipped" because every selectable
row carries its own trigger. This model will be documented alongside the phases so the
flexibility is explicit, not folklore.

## The new git flow (design)

The branch/PR gates map onto the tiers above (G2 is mandatory; branch-or-not / PR-or-not are
selectable per the pragmatic scope rule). A per-plan cycle:

- **Phase 0 — F6 PR/merge gate (new).** After F1 git sync, run `gh pr list --state open`.
  - If an open PR exists → surface it and ask the user: *"Is PR #N verified and ready to
    merge into `main`?"* On **yes** → `gh pr merge <n> --squash --delete-branch`, then
    `git checkout main && git pull`. On **no** → leave it; ask whether to keep working on
    that branch or branch fresh from `main`. Never silently start new work on top of an
    unverified PR.
  - If none → proceed.
- **Phase 1 — branch decision (new).** Evaluate whether the task warrants a branch using the
  **pragmatic scope rule**: branch when the plan makes a
  **substantive** change to `lib/` code, tokens, the version, or any **canonical guidance** —
  the contract/spec (`docs/golden-rule/`), the constitution (`CLAUDE.md`), or a skill
  (`.claude/skills/`). Trivial doc/ledger/typo-only edits (including a typo fix in a skill) may
  commit straight to `main`. If a branch is warranted, create `<type>/<slug>`
  (`feat|fix|docs|chore`, matching the repo's Conventional-Commit style) from up-to-date `main`
  **before** any Phase 2 edits.
- **Phase 2 — unchanged.** Implement → analyze/test → ledger + doc triggers, now on the branch.
- **Phase 3 — branch + PR instead of push-to-main.** Archive plan, final ledger entry,
  roadmap, then `git commit` on the branch, `git push -u origin <branch>`, and
  `gh pr create` (title = the plan summary; body = what/why + `flutter analyze`/`flutter
  test` results). **Do not merge in the same session** — merge is the *next* session's F6
  gate after the user verifies (or immediately if the user says it's verified now).
  Updated self-check: not done until branch pushed **and** PR opened (plus `UNFINISHED.md`
  cleared and ledger written).

Net effect: every session opens by resolving the prior PR and closes by opening the next —
`main` only ever advances through a verified, merged PR.

## Files to change (bindings only — submodule untouched)

1. **`CLAUDE.md`** — the authority. Update the **"Git workflow"** section (add branch-per-plan,
   PR-as-verification-gate, verified-merge-only rules) and the **"Workflow — flutter-ui-kit
   bindings"** section (add the checklist-driven model with the G1–G4 mandatory gates +
   selectable rows, F6/branch-decision/branch-PR-close overrides).
2. **`.claude/skills/adaptive-workflow/SKILL.md`** — add the same bindings + the master-checklist
   / select-what-applies model so the skill stays in sync with `CLAUDE.md`.
3. **`.ai/best_practices.md`** — add a distilled "branch + PR merge-gate" entry + a Revision
   History row + bump `version`/`last_validated`.
4. **`docs/golden-rule/index.md`** — note git-workflow authority = `CLAUDE.md`, and record the
   golden-rule reconciliation (incumbent → adopted, with reason) if the index tracks such
   decisions; otherwise record it in the ledger only.
5. **`history/2026-W29.md`** — ledger entry, `[workflow][doc]` tag, What/Why/Refs.
6. **`plans/UNFINISHED.md`** — created during execution, cleared at close (Phase 3 discipline).

No `lib/` code changes; no version tag (workflow/doc change, not a token/API change), so no
`CHANGELOG.md` semver bump — the ledger is the record.

## Risks & mitigations

| Risk | Likelihood | Impact | Mitigation |
|------|-----------|--------|------------|
| `gh` not authenticated | Low | Low | **Verify, don't assume:** run `gh auth status` before relying on it. If it fails, fall back to `git push -u origin <branch>` and hand the compare-URL to the user to open the PR manually. Document this fallback in the binding. |
| PR merge conflict at the F6 gate | Low | Medium | Merge is **stop-and-ask**, never auto-resolve: if `gh pr merge` reports a conflict, surface it and let the user choose rebase-on-`main` / manual resolution. The F6-first ordering (resolve the prior PR before new work) keeps conflicts rare. |
| Trivial change still gets branched | Low | Low | Pragmatic scope rule + explicit trivial escape hatch; the user can always override per task. |
| Submodule sync issue | Low | Low | Bindings-only change; `.claude/workflow-core/` is untouched, so a re-sync can't clobber it. |
| `--squash` collapses history unexpectedly | Very Low | Low | `--squash --delete-branch` is the intended, standard behavior; the squash commit preserves the Conventional-Commit message. |

## Commit message (on the plan's own branch)

```
chore(workflow): implement branch + PR merge-gate discipline

- Replaces direct commits to main with branch → PR → verified merge
- Adds F6 PR/merge gate at session start: check, verify, merge existing PRs
- Adds pragmatic scope rule: branch for lib/, canonical guidance, version bumps
- Phase 3: commit on branch, push, gh pr create (merge deferred to next session)
- Master-checklist model: mandatory gates (G1-G4) + selectable rows
- Updates CLAUDE.md, adaptive-workflow skill, best_practices.md, golden-rule/index
- Ledger entry [workflow][doc]

Workflow/docs change only — no lib/ code, no semver bump.
```

## Verification

- `flutter analyze` and `flutter test` stay green (no code touched, but run them as the gate).
- Run `gh auth status` to confirm auth before depending on `gh` (with the push-and-manual-PR
  fallback noted in Risks); confirm `gh pr list`, `gh pr create`, and
  `gh pr merge --squash --delete-branch` are the exact commands (`gh pr list` already returns
  cleanly).
- Re-read `CLAUDE.md` + the skill after editing to confirm the bindings are internally
  consistent (F6 numbering, Phase 3 self-check wording) and that no instruction still says
  "push to main".
- This very change is the first to exercise the flow end-to-end: it should itself land on a
  `docs/<slug>` (or `chore/<slug>`) branch and open a PR rather than pushing to `main`.

## Confirmed decisions

- **Branch scope: pragmatic.** Branch on a substantive change to `lib/`, tokens, the version,
  or any canonical guidance (`docs/golden-rule/`, `CLAUDE.md`, `.claude/skills/`); trivial
  doc/ledger/typo-only edits may commit straight to `main`.
- **Merge mechanism: assistant merges via `gh`.** After the user explicitly confirms a PR is
  verified, the assistant runs `gh pr merge <n> --squash --delete-branch` then pulls `main`.

## Note on this plan's own scope

By the pragmatic rule, this change edits `docs/golden-rule/index.md` (the contract/spec area),
so it **is** branch-worthy: it should land on a `docs/<slug>` (or `chore/<slug>`) branch and
open a PR — the first real exercise of the new flow.
