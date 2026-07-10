# Adaptive Self‑Correcting Workflow for AI Coding Agents  
*Version 3.3 – Claude Code Edition with Filesystem‑Native Memory*

---

## 1. Concept, Design & Philosophy

### What
A disciplined yet flexible **meta‑framework** that guides an AI coding agent through every programming task. It combines:

- **Fixed operational invariants** – git sync, environment check, core document awareness.
- **Per‑task dynamic planning** – the agent designs a tailored workflow based on task impact.
- **Roadmap‑driven chunking** – large, multi‑task goals are broken into a high‑level roadmap; the agent works on exactly one concrete plan (`UNFINISHED.md`) at a time.
- **Conditional documentation & roadmap updates** – living project memory is updated only when a defined trigger is met.
- **Hook‑based automation** – Claude Code’s hook system injects essential context and provides gentle reminders, without replacing agent judgement.
- **Constitution + Skill architecture** – immutable core rules live in `CLAUDE.md` (always loaded); the detailed process lives in a skill (`.claude/skills/adaptive-workflow.md`).
- **Filesystem‑native memory retrieval** – historical context is found on demand via `grep`/`ls`, never by loading a bloated index.

### Why
Multi‑session, AI‑assisted development breaks down when:

1. **Documentation grows stale** – no session is forced to update it, so future sessions act on outdated assumptions.
2. **Handoff between sessions is broken** – a new session has no knowledge of unfinished work or recent decisions.
3. **Tasks are too large to fit one session** – without a clear roadmap, the agent either tries to do everything and fails, or loses track of the bigger picture.
4. **Historical context overwhelms the agent** – if every session loads an ever‑growing archive index, token budgets explode and irrelevant information crowds out what matters.

This workflow guarantees that after every task, the project’s shared memory – living docs, naming conventions, roadmap, and unfinished plans – is either up‑to‑date or consciously left untouched. Every new session starts with a minimal, current picture. Large goals are automatically split into manageable chunks. And historical context is fetched **only on demand**, via filesystem search, so the agent never drowns in old information it doesn't need.

### How – The Philosophy
**“Fixed invariants for safety; dynamic planning for agility; roadmap for direction; hooks for ambient awareness; filesystem for selective recall.”**

- **Invariant steps** are mandatory and encoded in `CLAUDE.md` – the agent sees them every session, no exceptions.
- **Meta‑planning** lets the agent design a custom workflow based on task size and impact. If the request is too large, the agent creates or updates a high‑level roadmap and selects the next logical chunk.
- **Roadmap** (`ROADMAP.md`) stores epics and milestones. It's updated after each task only if future items are affected. Completed epics move to a `## Completed Epics` section, keeping the active roadmap lean.
- **Hooks** silently inject context and reminders. The `SessionStart` hook provides a minimal summary (environment, doc abstracts, next roadmap item, unfinished‑plan status). The `PostToolUse` hook nudges about documentation and roadmap updates.
- **Conditional updates** eliminate bureaucracy. We document or adjust the roadmap only when something that matters has changed.
- **Filesystem‑native recall** – there is no archive index. When the agent needs historical context, it uses `grep -r "keyword" plans/archive/` or `ls plans/archive/` to find the exact past task, then loads only that folder. Zero unused context.
- **Self‑improvement loop** – the agent records obstacles and lessons, gradually refining best practices and even the roadmap itself.

---

## 2. File & Folder Structure (Chunked Memory)

```
project/
├── CLAUDE.md                         # CONSTITUTION – immutable core rules, always loaded
│
├── .claude/                          # Claude Code configuration
│   ├── skills/
│   │   └── adaptive-workflow.md      # Detailed process manual (skill)
│   └── hooks/
│       └── adaptive_workflow_hook.py # Unified Python dispatcher for all three
│                                     #   events (SessionStart / PostToolUse / Stop),
│                                     #   branching on hook_event_name
│
├── .ai/                              # Agent’s global memory – always up‑to‑date
│   ├── best_practices.md             # Living language/tech best practices
│   ├── naming_conventions.md         # Per‑language naming rules
│   ├── env_check.sh                  # Pre‑flight script (optional)
│   └── workflow.md                   # This document (self‑reference)
│
├── docs/                             # Human + agent reference documentation
│   ├── architecture.md
│   ├── api_spec.md
│   └── ...                           # Any long‑lived document referenced in plans
│
├── ROADMAP.md                        # High‑level project direction (epics, milestones)
│
├── plans/                            # All planning artefacts (created on demand)
│   ├── UNFINISHED.md                 # Active concrete plan – exactly one at a time
│   └── archive/                      # Completed task records (only for traced tasks)
│       └── YYYY-MM-DD_<slug>/
│           ├── plan.md               # Original bullets + acceptance criteria
│           ├── references.md         # Docs sections used at plan time
│           ├── execution_log.md      # Obstacles, decisions, deviations
│           ├── retro.md              # Evaluation, mistakes, improvements
│           └── diff.patch            # (optional) code changes
│
├── changelogs/
│   └── CHANGELOG.md                  # High‑level entry per completed plan (optional)
│
├── src/                              # Source code
├── tests/
├── .git/
└── README.md
```

**Key structural decisions (v3.3 changes):**

| Element | Purpose | Why |
|---------|---------|-----|
| **`CLAUDE.md`** | Immutable core rules (Phase 0 invariants, conditional update triggers) | Always loaded by Claude Code – the agent cannot miss them. |
| **`.claude/skills/adaptive-workflow.md`** | Detailed process manual (phases, checklist, examples) | Loaded on demand or via slash command; too large for every session. |
| **`plans/archive/`** (no `index.md`) | Completed task folders, named by date and slug | Filesystem search (`grep`, `ls`) replaces a central index – zero maintenance, zero bloat. |
| **`ROADMAP.md`** | Epics with checkable tasks, completed epics moved to `## Completed Epics` | Keeps the active roadmap focused; the `SessionStart` hook only extracts the first unchecked item. |
| **`UNFINISHED.md`** | Exactly one active plan; cleared after archiving | The single source of truth for session handoff. |

---

## 3. `CLAUDE.md` – The Constitution (Always Loaded)

Claude Code automatically loads `CLAUDE.md` from the project root into every session. Place the **immutable, always‑needed rules** here. This file must be concise – under 2,000 tokens is ideal.

### Template `CLAUDE.md`

```markdown
# Project Constitution – Adaptive Workflow Core Rules

## Immutable Phase 0 Invariants (never skip)
1. **Git sync:** `git fetch && git pull --rebase` before any code change. Check for dirty tree.
2. **Environment:** Verify toolchain (runtimes, linters, formatters) are ready.
3. **Core docs:** Know the latest `.ai/best_practices.md`, `.ai/naming_conventions.md`, and `docs/architecture.md`.
4. **Unfinished plan:** If `plans/UNFINISHED.md` exists, surface it to the user immediately.

## Meta‑Planning (before implementing)
- Assess task scope, doc impact, handoff need, validation rigor, retro value.
- If the task is part of a larger goal, consult `ROADMAP.md` or create one.
- Break large tasks into roadmap chunks; put only the next chunk in `UNFINISHED.md`.
- Produce a bullet plan with acceptance criteria.

## Conditional Update Triggers (apply during & after execution)
| Trigger | Action |
|---------|--------|
| New pattern/rule/gotcha | Append to `.ai/best_practices.md` |
| New naming convention | Append to `.ai/naming_conventions.md` |
| API/architecture/data‑flow change | Update `docs/*.md` with dated annotation |
| Non‑obvious technical decision | Write to `plans/archive/<slug>/execution_log.md` |
| Repeatable mistake | Add to `.ai/best_practices.md` or `retro.md` |
| Task affects future roadmap items | Update `ROADMAP.md` |
| Epic completed | Move to `## Completed Epics` in `ROADMAP.md` |
| No impact on shared knowledge | **Do nothing** |

## Closure Discipline
- Move completed plan from `UNFINISHED.md` to `plans/archive/YYYY-MM-DD_<slug>/`.
- Clear `UNFINISHED.md`.
- Update `ROADMAP.md` if triggered.
- `git commit -m "Plan: <slug> – <summary>" && git push`.
- **You are not done until UNFINISHED.md is cleared and the plan is archived.**

## Historical Context Retrieval
- Do NOT load the entire archive. Use filesystem search:
  - `grep -r "keyword" plans/archive/` to find relevant past tasks.
  - `ls plans/archive/` to list all archived tasks.
- Load only the specific file(s) needed (e.g., `plan.md`, `retro.md`).
```

---

## 4. The Skill (`.claude/skills/adaptive-workflow.md`)

The skill file contains the **full, detailed process** – all phases, the complete checklist, examples, and edge cases. It is too long for every session, so the agent loads it **on demand**:

- When the user invokes a slash command (e.g., `/adaptive-workflow`).
- When the agent needs a refresher on exact phase definitions.
- During initial onboarding or when the workflow is updated.

The skill file is essentially this entire document, minus Section 3 (the Constitution, which lives in `CLAUDE.md`). For brevity, we reference it here; in practice, copy the full v3.3 document into `.claude/skills/adaptive-workflow.md`, excluding Section 3.

---

## 5. The Core Workflow (Agent Discipline)

This is the full process – the Constitution (`CLAUDE.md`) contains the immutable subset; the Skill contains this complete version.

### 🔒 Phase 0 – Fixed Invariants (Always Executed First)

| Step | Action | Agent’s Responsibility |
|------|--------|------------------------|
| **F1** | `git fetch && git pull --rebase` and check for a dirty working tree. | Agent must run this as its first tool call. It must not proceed if the tree is dirty without user approval. |
| **F2** | Run environment pre‑flight. | Agent executes `.ai/env_check.sh` (if it exists) or verifies the required runtimes, linters, and formatters manually. |
| **F3** | Absorb core living documents. | The agent must have read `.ai/best_practices.md`, `.ai/naming_conventions.md`, and `docs/architecture.md` (if present) into its context. *(A `SessionStart` hook will pre‑load summaries; see Section 6.)* |
| **F4** | Surface any unfinished plan & roadmap status. | Agent checks for `plans/UNFINISHED.md`. If present, it **immediately** tells the user: *“You have an unfinished plan: [summary]. Should we continue it or archive it?”* The `SessionStart` hook will have already injected this prompt; the agent must act on it. |

### 🧠 Phase 1 – Meta‑Planning (With Roadmap Logic)

The agent **designs a task‑specific workflow** by evaluating the user’s request against these decision points:

1. **Task scope** – trivial fix, feature, refactor, or architectural change? How many files/systems?
2. **Multi‑task potential** – is this part of a larger goal that spans multiple sessions?
3. **Documentation impact** – will the change alter any shared knowledge?
4. **Traceability & handoff** – is a multi‑session plan likely? Are there non‑obvious decisions?
5. **Validation rigor** – linting, unit tests, or full integration suite?
6. **Retrospective value** – any repeatable mistake or new gotcha?

**Roadmap handling:**

- If the request is **too large for a single `UNFINISHED.md`** (e.g., “build the whole dashboard”), the agent will:
  - Create or update `ROADMAP.md` with high‑level epics and sub‑tasks.
  - Select the **next logical, unblocked task** as the current piece of work.
  - Create `UNFINISHED.md` linked to that roadmap item.
  - Inform the user: *“I’ve outlined the rest in the roadmap. We’ll work on ‘X’ now, then update the roadmap.”*

- If a `ROADMAP.md` already exists, the agent will:
  - Identify which epic/item the new request belongs to.
  - If it’s a new, unlisted task, negotiate with the user: add to roadmap or treat as a one‑off.
  - If it’s the next task from the roadmap, simply create `UNFINISHED.md` linked to it.

The agent then **produces a concrete bullet plan** with acceptance criteria, including only the necessary process modules (lint, test, doc update, decision log, retro, archive). It may briefly present this plan to the user for confirmation.

### 🛠️ Phase 2 – Execute the Dynamic Plan

The agent follows the plan step‑by‑step. For each bullet:
- Implement the change.
- Immediately run required validations (linter, tests).
- If an obstacle arises, log it and propose an updated plan.

**Conditional documentation & roadmap update triggers** – applied *during and after* execution:

| Trigger | Action |
|---------|--------|
| New pattern, rule, or gotcha introduced | Append to `.ai/best_practices.md` (with example) |
| New naming convention agreed | Append to `.ai/naming_conventions.md` |
| Change to public API, architecture, or data flow | Update the corresponding `docs/*.md` file with a dated annotation |
| Non‑obvious technical decision | Write decision log in `plans/archive/<slug>/execution_log.md` |
| Mistake that could be repeated | Add warning to best practices or retro note |
| Completed task affects future roadmap items (new dependency, simpler approach, blocked item) | Update `ROADMAP.md` accordingly (add, remove, reorder, adjust descriptions) |
| Completed task finishes an epic | Mark the epic as completed; move to `## Completed Epics` in `ROADMAP.md` |
| **No impact on shared knowledge or roadmap** | **Do nothing** – code and commit message are sufficient |

### 🏁 Phase 3 – Closure

- **Archive the plan:** move `UNFINISHED.md` content to `plans/archive/YYYY-MM-DD_<slug>/plan.md`, along with any logs, retro, and diff. Clear `UNFINISHED.md`.
- **Update roadmap:** check the roadmap trigger conditions above. Modify `ROADMAP.md` if the task changed future direction. Mark the current item as `[x]` completed. Move entire epics to `## Completed Epics` if finished.
- **Commit & push:** `git commit -m "Plan: <slug> – <summary>" && git push`.

**Critical discipline:** The agent must **never** end a traced task without clearing `UNFINISHED.md` and archiving. If a session must end with an unfinished plan, the agent leaves `UNFINISHED.md` intact and clearly states that the plan is incomplete, so the next session can resume.

---

## 6. Enhancing the Workflow with Claude Code Hooks

Hooks automate ambient awareness, reducing the chance of forgotten checks. They never replace agent discipline.

### 6.1 Hook I/O Contract (Important)

Claude Code hooks communicate via **JSON over stdin/stdout**:

- **Input:** The hook receives a JSON payload on `stdin` containing event metadata (`hook_event_name`, `session_id`, `cwd`, `tool_name`, `tool_input`, etc.).
- **Output:** The hook must write a JSON object to `stdout` with the appropriate response fields.

For `SessionStart` and `PostToolUse`:
```json
{
  "decision": "approve",
  "additionalContext": "Your injected context text here..."
}
```

For `Stop` (if blocking):
```json
{
  "decision": "block",
  "reason": "Unfinished plan remains. Please archive or update the plan."
}
```

Ensure your hook script parses `stdin`, performs its logic, and writes valid JSON to `stdout`. A bare `print()` will not work unless it emits proper JSON (use `print(json.dumps(payload))`).

### 6.2 `SessionStart` Hook – Minimal Context Injection

**Purpose:** At session start, inject only what the agent absolutely needs: environment status, core doc summaries, unfinished‑plan alert, and the single next roadmap item.

**Implementation outline** (`handle_session_start` in `adaptive_workflow_hook.py`):
1. Execute `.ai/env_check.ps1` (if present) or run built‑in checks. Capture a one‑line status: *“Environment: OK (Python 3.12)”* or *“Environment: MISSING Python”*.
2. Read `.ai/best_practices.md`, `.ai/naming_conventions.md`, and `docs/architecture.md` (if present).  
   - **Token optimisation:** Inject only a **summary** (first 2–3 paragraphs or a structured abstract) for each. Include a note: *“Full document available upon request.”*  
   - If a document is under ~2,000 characters, the full text may be injected directly.
3. Check for `plans/UNFINISHED.md`. If present, extract its first heading/summary and inject: *“⚠️ Unfinished plan: [summary]. Continue or archive?”*
4. If `ROADMAP.md` exists, extract the **first unchecked item** from the first active (non‑completed) epic and inject: *“[Roadmap] Next: Implement login endpoint (Epic 1).”*
5. Do **not** load the archive listing. The agent uses filesystem search if it needs history.

**Example `additionalContext` output:**
```
[Environment] OK (Python 3.12.2)

[Best Practices Summary] Use async/await for all I/O; prefer functional components in React; error handling: try/catch with custom error classes... (full doc available on request)

[Naming Conventions Summary] Python: snake_case, PascalCase for classes; JavaScript: camelCase; files: kebab-case... (full doc available on request)

[Architecture Summary] Microservices behind API gateway; PostgreSQL for primary data; Redis for caching... (full doc available on request)

⚠️ No unfinished plan.

[Roadmap] Next: Implement login endpoint (Epic 1: User Authentication)
```

### 6.3 `PostToolUse` Reminder Hook – Doc & Roadmap Nudge

**Purpose:** After file‑writing/editing, gently remind the agent to consider updating documentation and the roadmap.

**Logic** (`handle_post_tool_use` in `adaptive_workflow_hook.py`):
- Parse the incoming JSON on `stdin` to get `tool_name` and `tool_input`.
- Trigger on tool names: `Write`, `Edit`, `MultiEdit`, or any equivalent that modifies files.
- For each modified file, check:
  - If the file is under `src/` (or `lib/`, etc.) **and** no file in `docs/` was touched in the same tool call → set a reminder flag for docs.
  - If a file path appears as a dependency in `ROADMAP.md` (simple string match) → set a reminder flag for roadmap.
- If any flag is set, inject a concise `additionalContext` message. Example: *“🔄 Source changed. Consider updating docs if this affects the public API, architecture, or conventions. Also check ROADMAP.md if this affects future tasks.”*
- All reminders are **advisory**; the agent decides.

### 6.4 `Stop` Hook (Optional/Experimental) – Unfinished Plan Guard

**Purpose:** Warn or block if an unfinished plan remains at session end.

**Logic** (`handle_stop` in `adaptive_workflow_hook.py`):
- On `Stop` event, check for `plans/UNFINISHED.md`.
- If present, return `{ "decision": "block", "reason": "Unfinished plan remains. Please archive or update the plan before ending." }`

**Critical caveat:** The `Stop` hook’s ability to truly block session termination depends on the Claude Code version. Treat it as a **loud warning**. The true safety net is the next session’s `SessionStart` hook, which will surface the unfinished plan.

---

## 7. Historical Context Retrieval (Filesystem‑Native)

There is **no archive index file**. Instead, the agent uses standard CLI tools to find past information on demand:

### 7.1 Finding a Past Task

- **By keyword:** `grep -r "authentication" plans/archive/`  
  Returns all files mentioning "authentication" across all archived plans.
- **By date:** `ls plans/archive/ | grep "2026-07"`  
  Lists all tasks archived in July 2026.
- **By slug:** `ls plans/archive/ | grep "login"`  
  Finds all tasks with "login" in the slug.

### 7.2 Loading Specific Context

Once the relevant archive folder is identified, the agent reads only the file(s) it needs:
- `plan.md` – to see what was done.
- `execution_log.md` – to understand decisions and obstacles.
- `retro.md` – to review mistakes and learnings.

### 7.3 When to Retrieve

- The user asks: *“What did we do about authentication last month?”*
- The agent encounters a similar problem and wants to recall a past solution.
- A retro or decision log from a past task is needed for context.

**Key principle:** The agent **never** loads the entire archive. It uses `grep`/`ls` to find the needle, then reads only that needle.

---

## 8. Roadmap Specification

### 8.1 `ROADMAP.md` Format

```markdown
# Project Roadmap

## Epic 1: User Authentication
- [x] Set up database schema for users
- [x] Implement registration endpoint
- [ ] Implement login endpoint
- [ ] Add password reset flow

## Epic 2: Dashboard
- [ ] Design dashboard layout
- [ ] Implement real‑time data feed

## Backlog / Icebox
- [ ] Performance optimisation of search
- [ ] Multi‑language support

## Completed Epics
- [x] Epic 0: Project Setup
```

- Each bullet is a high‑level task, not a detailed plan.
- `[ ]` / `[x]` indicate status.
- Completed epics are moved to `## Completed Epics` to keep the active roadmap focused.
- The `SessionStart` hook extracts only the **first unchecked item** from the first active epic.

### 8.2 Chunking Process

1. Agent asks clarifying questions to break a large goal into epics and tasks.
2. Agent writes/updates `ROADMAP.md` with all pieces.
3. Agent selects the next logical, unblocked task and creates `UNFINISHED.md` linked to it.
4. After finishing that task, the agent picks the next unchecked item (or follows user’s choice).

### 8.3 Roadmap Update Triggers

- Completed task changes future items → modify `ROADMAP.md`.
- Epic finished → move to `## Completed Epics`.
- User reprioritises → adjust accordingly.

---

## 9. Long‑Term Memory Management

### 9.1 Archive Hygiene

- Archive folders are named `YYYY-MM-DD_<slug>/` for easy filesystem sorting and search.
- **No central index** – use `grep` and `ls` as described in Section 7.
- **Periodic cleanup (quarterly):** Compress archive folders older than 6–12 months into `plans/archive/old/` or a `.zip` file. Filesystem search can still find them if needed.

### 9.2 Living Document Pruning

- `.ai/best_practices.md`, `.ai/naming_conventions.md`, and `docs/architecture.md` should be reviewed every 3–6 months:
  - Remove outdated rules.
  - Consolidate similar entries.
  - Move historical examples to an appendix or link to archive entries.
- This can be a roadmap task or handled organically when a file becomes unwieldy.

### 9.3 Session Token Budget

- The `SessionStart` hook monitors core document sizes. If a file exceeds ~2,000 characters, it injects only a summary. The agent explicitly requests the full text when needed.
- The hook does **not** load any archive listing. Historical context is always on demand.

---

## 10. Implementation & Testing Notes

1. **Create `CLAUDE.md`:** Place the immutable rules (Section 3 template) in the project root. This is your Constitution – keep it concise.
2. **Create the skill file:** Copy the full workflow (this document, minus Section 3) into `.claude/skills/adaptive-workflow.md`. Register it as a skill in Claude Code if slash‑command invocation is desired.
3. **Validate hook I/O contract:** Consult the official Claude Code hooks documentation for the exact JSON schemas. Ensure your scripts parse `stdin` and write valid JSON to `stdout`.
4. **Develop the hook** (one `adaptive_workflow_hook.py` dispatcher, branching on `hook_event_name`):
   - `handle_session_start`: Implement the minimal injection logic from Section 6.2. Test that the agent sees the context.
   - `handle_post_tool_use`: Implement the nudge logic from Section 6.3. Verify it fires after `Write`/`Edit` calls.
   - `handle_stop` (optional): Test blocking behaviour; if unreliable, keep as a soft warning.
5. **Pen‑test the full loop:**
   - *Trivial task:* No archive, no doc update, quick commit.
   - *Single‑session feature with doc impact:* Archive created, docs updated, roadmap checked.
   - *Multi‑session epic:* Roadmap created, first task archived, roadmap updated, second task becomes new `UNFINISHED.md`. Next session picks up automatically via `SessionStart` hook.
   - *Historical retrieval:* After several tasks are archived, ask the agent a question that requires past context and verify it uses `grep`/`ls` correctly.
6. **Monitor token usage:** Ensure the `SessionStart` hook’s injection stays under ~1,000 tokens. Adjust size thresholds as needed.

---

## 11. FAQ & Quick Reference

**Q: What’s the difference between `CLAUDE.md` and the skill file?**  
A: `CLAUDE.md` is the Constitution – short, immutable, always loaded. The skill (`.claude/skills/adaptive-workflow.md`) is the full detailed manual, loaded on demand.

**Q: Why no archive index?**  
A: An index grows endlessly and forces the agent to load irrelevant history. Filesystem search (`grep`, `ls`) finds exactly what’s needed with zero bloat.

**Q: How does the agent know where to look for past tasks?**  
A: It’s trained to use `grep -r "keyword" plans/archive/` and `ls plans/archive/`. These are standard CLI tools.

**Q: What if the agent forgets to archive?**  
A: The `Stop` hook warns. Even if it fails, the next session’s `SessionStart` hook surfaces the `UNFINISHED.md`. The system is resilient.

**Q: Can I use this workflow without a roadmap?**  
A: Yes. Roadmap is optional. Without it, the workflow handles one task at a time.

**Q: How do I update the workflow itself?**  
A: The retro step can suggest improvements to `CLAUDE.md` or the skill file. Since they’re versioned in git, changes are tracked and reviewed.

---

## Addendum — Local Extension: Change-History Ledger (2026-07-08)

*This addendum is a local extension adopted by the `scale_tech_insight` repo. It is
recorded here so the spec, `CLAUDE.md`, and the `adaptive-workflow` skill stay
consistent (per CLAUDE.md's "when they disagree, the spec wins" rule). Base workflow
version unchanged; local designation: **v3.3 + change-history ledger**.*

**Motivation.** The directory tree above lists `changelogs/CHANGELOG.md` as *optional*.
Because it was optional, this repo never implemented it — and a design artifact
(`docs/artifact/Scale Indicator.dc.html`) subsequently evolved across sessions with no
chronological record of what changed or why. The archive (`plans/archive/`) is keyed by
task slug and only exists once a plan is formally closed, so it could not answer "trace
this artifact over time." The optional feature's absence was the gap.

**The extension.** `changelogs/CHANGELOG.md` is **superseded** by a **required**,
weekly-rotated ledger:

- One file per ISO week: `history/YYYY-Www.md` (e.g. `history/2026-W28.md`).
  `ls history/` is the time index; there is no central index file (same no-index
  principle as the archive).
- **Log everything, scale the detail:** substantial changes get a `### [tag] <path>`
  block with **What / Why / Refs**; minor changes get a single terse line. Noise is
  controlled by brevity, not omission.
- It **complements** `plans/archive/<slug>/execution_log.md` (deep per-task decisions)
  and in-place `docs/*.md` dated annotations (architecture/API authority); it does not
  replace them. It **replaces** the optional `changelogs/CHANGELOG.md` — one chronological
  record, not two.
- **Enforcement:** mandatory in `CLAUDE.md` (a conditional-update trigger *and* a closure
  step). The `Stop` hook warns if source/doc files changed this session without a ledger
  entry (tracked via a `ledger_entry_written` session-state flag, mirroring
  `doc_nudge_emitted`).

Format spec: `history/FORMAT.md`.

---

*End of document. Version 3.3 – Adaptive Self‑Correcting Workflow with Filesystem‑Native Memory. (Local extension: change-history ledger, 2026-07-08.)*