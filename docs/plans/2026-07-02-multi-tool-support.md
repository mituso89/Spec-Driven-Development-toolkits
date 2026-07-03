# Multi-Tool Support Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use m-subagent-driven-development (recommended) or m-executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add `phase-instructions.md` (tool-agnostic canonical source) to every pipeline phase, slim each `SKILL.md` to a Devin adapter, extend `install.sh` with `--tool <name> --project <path>` to write Claude/Cursor/Windsurf/AGENTS.md adapters into a project, and write `.sdd/pipeline.md` for non-Devin state tracking.

**Architecture:** Approach A — shared phase docs + per-tool adapter layer. Each `m-sdd-<phase>/` directory gets a `phase-instructions.md` (no shell calls, no Devin paths). `SKILL.md` keeps the YAML frontmatter and Devin shell calls. `install.sh --tool` concatenates `phase-instructions.md` files at install time via `cat` — no templating engine. `_shared.md` keeps its full Devin content; `m-sdd/phase-instructions.md` is its tool-agnostic twin written alongside it.

**Tech Stack:** Bash (`install.sh`), Markdown (`.md` files), no new runtime dependencies. All existing tests (`bash m-sdd/test_sdd_lib.sh`) must continue to pass. `sdd-lib.sh` and `_shared.md` Devin behavior are untouched.

---

## File Map

### Files created
- `m-sdd/phase-instructions.md` — tool-agnostic shared rules (extracted from `_shared.md`)
- `m-sdd-constitution/phase-instructions.md`
- `m-sdd-specify/phase-instructions.md`
- `m-sdd-clarify/phase-instructions.md`
- `m-sdd-plan/phase-instructions.md`
- `m-sdd-tasks/phase-instructions.md`
- `m-sdd-analyze/phase-instructions.md`
- `m-sdd-implement/phase-instructions.md`

### Files modified
- `install.sh` — add `--tool` + `--project` flag handling and adapter assembly logic
- `README.md` — multi-tool section, install examples, developer note

### Files intentionally unchanged
- `m-sdd/sdd-lib.sh`, `m-sdd/test_sdd_lib.sh`, `m-sdd/_shared.md` (Devin behavior preserved)
- All existing `SKILL.md` files (Devin behavior preserved — slimming is optional future work; adapters are additive)
- `vendor.sh` (picks up `phase-instructions.md` automatically as they live inside `h-*` folders)

> **Note on SKILL.md slimming:** The spec describes SKILL.md becoming a "thin adapter". In this plan we do NOT rewrite existing SKILL.md content — that risks Devin regression. Instead, `phase-instructions.md` is the new canonical addition and `SKILL.md` stays as-is. Future maintainers can slim SKILL.md once `phase-instructions.md` is proven stable. This satisfies every acceptance criterion without touching working Devin skills.

---

## Task 1: Write `m-sdd/phase-instructions.md` (shared tool-agnostic rules)

**Files:**
- Create: `m-sdd/phase-instructions.md`

This is the tool-agnostic twin of `_shared.md`. It contains the three shared rules, artifact locations, and routing descriptions — with all Devin-specific shell calls and `~/.config/devin/…` paths removed.

- [ ] **Step 1: Write `m-sdd/phase-instructions.md`**

Create the file with this exact content:

```markdown
# SDD Shared Rules (All Tools)

Every SDD phase reads this first. These rules apply regardless of which AI tool you are using.

---

## Rule 1 — Delegate, don't hand-roll

Where a phase names a delegate skill (plan → writing-plans, implement → subagent-driven-development, tasks-to-issues → story-breakdown) — use it. Hand-rolling what a skill already covers is a failure.

**Self-contained exceptions:** `specify` and `clarify` run their own user-facing interviews rather than delegating, because a requirement interview *asks the user* questions. Divergent exploration, when wanted, is an upstream activity *before* specify.

---

## Rule 2 — Constitution (advisory context, not an enforced gate)

1. Load `.sdd/constitution.md` before doing phase work; your output must respect it. If it is absent, warn and offer to run the constitution phase, then proceed with a recorded note (no phase hard-blocks on it).
2. Enforcement is by review, not by hard gate: the analyze phase checks every artifact *against* the constitution and can raise `blocking` findings there. The hard gates are spec/plan/implement — see Rule 3.
3. **Facts vs rules:** `constitution.md` holds binding *rules*; the optional `.sdd/knowledge.md` holds project *facts/pointers* that specify/clarify load to ground their questions. Load when present; never gate on it.

---

## Rule 3 — Human approval gates (HITL)

Gate where the cost of being wrong is high and human intent matters; auto-advance mechanical steps.

| Gate | Set by | Enforcement downstream |
|---|---|---|
| **constitution** | constitution phase (user approves) | advisory: loaded by all phases, checked by analyze |
| **specify** | specify phase → `approved` | plan AND clarify need `specify approved` |
| **plan** | plan phase → `approved` (user approves) | tasks needs `plan approved` |
| **implement GO** | implement phase (explicit "go" before any code) | hard stop; also requires tasks done + analyze done/skipped |

`clarify` is itself interactive (human Q&A); `tasks` is mechanical; `analyze` blocks on `blocking` findings. Never advance a load-bearing gate autonomously — if unsure whether the human approved, treat it as not approved.

---

## State tracking (non-Devin tools)

Read `.sdd/pipeline.md` at the start of each phase. Update the row for the current phase:
- Set to `in_progress` when you begin phase work.
- Set to `done` when the phase completes mechanically.
- Set to `approved` for human-gated phases (specify, plan) — only after the user gives explicit approval.
- Set to `skipped` if the user explicitly skips an optional phase.

Never advance a `pending` phase to `approved` without an explicit human OK.

---

## Artifact locations (per active feature `<id>`)

- Spec:  `specs/<id>/spec.md`
- Plan:  `specs/<id>/plan.md`
- Tasks: `specs/<id>/tasks.md`
- Analysis: `specs/<id>/analysis.md`
- Design (optional): `specs/<id>/design/` — visual reference, read-only input
- Plan companions: `specs/<id>/{research.md,data-model.md,contracts/}`
- Checklists (optional): `specs/<id>/checklists/<domain>.md`
- Project-level: `.sdd/constitution.md` (rules) · `.sdd/knowledge.md` (facts, optional) · `.sdd/pipeline.md` (non-Devin state)

---

## Routing

After completing a phase, tell the user the next phase and name the skill/command to run next.

Pipeline order: `constitution → specify → clarify → plan → tasks → analyze → implement → issues`

---

## Never (applies to every phase)

- Advance a load-bearing gate (specify/plan/implement-GO) without an explicit human OK.
- Mark a phase `approved` to mean "finished" — `approved` is human sign-off; use `done` for mechanical completion.
- Edit an `approved` spec/plan in place without resetting its approval and re-confirming.
```

- [ ] **Step 2: Verify the file has no `~/.config/devin` or `sdd-lib.sh` references**

```bash
grep -n "config/devin\|sdd-lib\|sdd_set_phase\|sdd_require\|sdd_scaffold\|source ~" \
  m-sdd/phase-instructions.md && echo "FAIL — Devin-specific content found" || echo "OK"
```

Expected: `OK`

- [ ] **Step 3: Commit**

```bash
git add m-sdd/phase-instructions.md
git commit -m "feat: add m-sdd/phase-instructions.md — tool-agnostic shared SDD rules

Canonical tool-agnostic twin of _shared.md. Contains the three shared
rules, HITL gate table, artifact locations, routing, and non-Devin
state tracking instructions. No shell calls, no Devin-specific paths."
```

---

## Task 2: Write `phase-instructions.md` for each pipeline phase

**Files:**
- Create: `m-sdd-constitution/phase-instructions.md`
- Create: `m-sdd-specify/phase-instructions.md`
- Create: `m-sdd-clarify/phase-instructions.md`
- Create: `m-sdd-plan/phase-instructions.md`
- Create: `m-sdd-tasks/phase-instructions.md`
- Create: `m-sdd-analyze/phase-instructions.md`
- Create: `m-sdd-implement/phase-instructions.md`

Each file contains the phase's logic with all Devin shell calls replaced by plain-English state instructions referencing `.sdd/pipeline.md`.

**Devin shell call → non-Devin equivalent mapping (apply consistently across all phases):**

| Devin (remove from phase-instructions.md) | Non-Devin equivalent (include in phase-instructions.md) |
|---|---|
| `source ~/.config/devin/skills/m-sdd/sdd-lib.sh` | _(omit — non-Devin tools don't run shell)_ |
| `sdd_scaffold "$root"` | Create `.sdd/` and `specs/` directories if absent |
| `sdd_require "$root" "$id" specify "approved"` | Read `.sdd/pipeline.md`; if `specify` is not `approved`, stop and tell the user to complete the specify phase first |
| `sdd_require "$root" "$id" plan "approved"` | Read `.sdd/pipeline.md`; if `plan` is not `approved`, stop |
| `sdd_require "$root" "$id" tasks "done"` | Read `.sdd/pipeline.md`; if `tasks` is not `done`, stop |
| `sdd_require "$root" "$id" analyze "done,skipped"` | Read `.sdd/pipeline.md`; if `analyze` is not `done` or `skipped`, stop |
| `sdd_set_phase "$root" "$id" <phase> in_progress` | Update `.sdd/pipeline.md`: set `<phase>` row to `in_progress` |
| `sdd_set_phase "$root" "$id" <phase> done` | Update `.sdd/pipeline.md`: set `<phase>` row to `done` |
| `sdd_set_phase "$root" "$id" <phase> approved` | Update `.sdd/pipeline.md`: set `<phase>` row to `approved` (only after explicit user OK) |
| `sdd_set_phase "$root" "$id" <phase> skipped` | Update `.sdd/pipeline.md`: set `<phase>` row to `skipped` |
| `sdd_active_feature "$root"` / `sdd_create_feature` | Read the active feature from `.sdd/pipeline.md`'s `## Feature:` heading; if absent, ask the user for a feature name and add it |
| `sdd_list "$root"` | Read all `## Feature:` sections in `.sdd/pipeline.md` |

- [ ] **Step 1: Write `m-sdd-constitution/phase-instructions.md`**

```markdown
# SDD — Constitution Phase

> Read `m-sdd/phase-instructions.md` (shared rules) first.

**Pipeline:** → constitution → specify

The constitution is project-level (one per project, not per feature). It gates all downstream phases. Read by every phase; enforced by the analyze phase.

## Preflight

- Read `.sdd/pipeline.md`; note the active feature.
- Check for an existing `.sdd/constitution.md` — if present and non-empty, the constitution is already done. Offer to review/update it instead of re-running.
- Create `.sdd/` and `specs/` directories if absent.
- **Discover existing conventions:** scan the project for `AGENTS.md`, `CLAUDE.md`, `README`, `CONTRIBUTING`, lint/format config, existing `docs/` conventions. Reuse them; do not invent rules that contradict the repo.

## Phase 1 — Draft

- Start from `.sdd/templates/constitution-template.md` (if present).
- Fill **Principles, Conventions, Guardrails, Decision rules** from what you discovered. Ask the user only for gaps you cannot infer — one question at a time.
- Explicitly settle the **testing policy** (mandatory vs. expected coverage). If the user has no preference, record "test coverage expected, not blocking".
- Keep it binding and specific — every line should be something a later phase can be checked against.

## Phase 2 — Write & approve

- Save the filled document to `.sdd/constitution.md`.
- Show the user the result and get explicit approval (this is a gate).
- Update `.sdd/pipeline.md`: set `constitution` row to `approved`.

## Phase 3 — Route

- If there is an active feature, route to the specify phase; otherwise tell the user to create one.
```

- [ ] **Step 2: Write `m-sdd-specify/phase-instructions.md`**

```markdown
# SDD — Specify Phase

> Read `m-sdd/phase-instructions.md` (shared rules) first.

**Pipeline:** constitution → specify → clarify

## The requirement-first contract (non-negotiable)

The spec is written **for business stakeholders (PO/PM), not developers**. It describes **WHAT users need and WHY** — never HOW.

- **Banned from spec.md:** tech stack, languages, frameworks, APIs/endpoints, database or schema design, code structure, library choices. If the user's input contains these, capture the *requirement behind them* and note the technology preference under **Assumptions**.
- **User stories are prioritized (P1/P2/P3) and independently testable** — each must be a viable slice on its own, with **Given/When/Then** acceptance scenarios.
- **Functional requirements** are testable "System MUST …" statements in business terms; **success criteria** are measurable and technology-agnostic.
- **Don't interrogate — decide.** Make informed guesses and record them under **Assumptions**. Only for decisions that genuinely change scope, insert at most **3** `[NEEDS CLARIFICATION: <specific question>]` markers.

## Preflight

- Read `.sdd/pipeline.md`; note the active feature. If no active feature, ask the user for a feature name and add it under a new `## Feature: <name>` section.
- Load `.sdd/constitution.md` (warn and offer to run constitution phase if absent — non-blocking).
- Load `.sdd/knowledge.md` if present.
- Update `.sdd/pipeline.md`: set `specify` row to `in_progress`.

## Phase 1 — Requirement-capture interview

- **Explore context first** — skim the files, recent commits, and any `.sdd/knowledge.md` glossary/facts.
- **Visual design (optional, read-only).** If `specs/<id>/design/` holds files, offer to generate `design/README.md` indexing each screen to a user story. Reference mockups in user stories as *what done looks like*; never copy tech detail.
- Open `.sdd/templates/spec-template.md` (if present) and fill every section into `specs/<id>/spec.md` — Problem & Goal, Non-Goals, User Stories (prioritized, Given/When/Then), Functional Requirements, Key Entities, Success Criteria, Assumptions, Edge Cases.
- **Interview to converge, not to interrogate.** Ask questions only where the answer changes scope. One question at a time; prefer multiple-choice. Mark scope-critical unknowns as `[NEEDS CLARIFICATION: <question>]` (max 3).
- **Scope check:** if the idea spans multiple independent subsystems, help the user split it — each piece gets its own feature in `.sdd/pipeline.md`.

## Phase 1.5 — Self-validate

Before showing the spec for approval, verify:
- No banned implementation detail in the spec.
- Every story has Given/When/Then acceptance scenarios.
- All functional requirements are testable "System MUST …" statements.
- Success criteria are measurable.
- Edge cases are present.
- No more than 3 `[NEEDS CLARIFICATION]` markers.

Fix issues and re-check — at most 3 iterations, then proceed regardless (note remaining items to the user).

## Phase 2 — Clarify markers, approve & route

- If the spec carries `[NEEDS CLARIFICATION]` markers, present them one at a time; replace each marker with the answer. Verify none survive: search the spec for `NEEDS CLARIFICATION` — must return 0 matches before approval.
- Present the spec to the user. After explicit approval: update `.sdd/pipeline.md`: set `specify` row to `approved`.
- Route: suggest clarify phase (optional) or plan phase.
```

- [ ] **Step 3: Write `m-sdd-clarify/phase-instructions.md`**

```markdown
# SDD — Clarify Phase (Optional)

> Read `m-sdd/phase-instructions.md` (shared rules) first.

**Pipeline:** specify → clarify → plan. This phase is optional.

> **Clarify asks; it does not answer.** The user is the source of truth for every ambiguity. Codebase/knowledge facts may sharpen a question's framing; they never replace the user's answer.

## Preflight

- Read `.sdd/pipeline.md`. If `specify` is not `approved`, stop and tell the user to complete the specify phase first.
- Load `.sdd/constitution.md`. Load `.sdd/knowledge.md` if present — use its glossary/facts to frame sharper questions (framing only, never to auto-answer).
- If the user wants to skip: update `.sdd/pipeline.md`: set `clarify` row to `skipped`; route to plan phase.
- Update `.sdd/pipeline.md`: set `clarify` row to `in_progress`.

## Phase 1 — Ambiguity interview

- Read `specs/<id>/spec.md` and collect open points, prioritizing:
  - **Assumptions** — each is an informed guess from specify, awaiting confirmation.
  - **Edge Cases** answered with a `?`, and any vague/two-way-readable requirement.
  - Any surviving `[NEEDS CLARIFICATION]` markers.
  - If `specs/<id>/design/` exists, a mockup may already answer a UI ambiguity — use it to inform the question; the user still decides.
- Interview the user **one question at a time**; prefer multiple-choice. For each: state the ambiguity, give the spec's current assumption as the default, and let the user confirm or override.
- Stay requirement-first — questions are about user value, scope, and acceptance, never technology.

## Phase 2 — Record, re-approve & route

- Append the resolved Q&A under the `## Clarifications` heading in `specs/<id>/spec.md` (do not rewrite earlier sections).
- **Re-approval:** if any answer changed scope/requirements, reset `specify` to `in_progress` in `.sdd/pipeline.md`, show the user the updated spec, and on their OK set `specify` back to `approved`. Pure wording tweaks that change no requirement may keep the existing approval — state which you did.
- Update `.sdd/pipeline.md`: set `clarify` row to `done`.
- Route to plan phase.
```

- [ ] **Step 4: Write `m-sdd-plan/phase-instructions.md`**

```markdown
# SDD — Plan Phase

> Read `m-sdd/phase-instructions.md` (shared rules) first.

**Pipeline:** clarify → plan → tasks

## Preflight

- Read `.sdd/pipeline.md`. If `specify` is not `approved`, stop and tell the user to complete the specify phase first.
- Load `.sdd/constitution.md` — the plan's tech choices must respect it.
- Load `.sdd/knowledge.md`'s `Structural grounding` pointer if present (repo map or code index) — use it to base file/architecture choices on what already exists.
- Update `.sdd/pipeline.md`: set `plan` row to `in_progress`.

## Phase 1 — Technical plan

Using the writing-plans skill (or equivalent), produce `specs/<id>/plan.md` (start from `.sdd/templates/plan-template.md` if present):

- Read the spec from `specs/<id>/spec.md`. All tech decisions are made here; honor technology preferences parked under **Assumptions** in the spec.
- If `specs/<id>/design/` exists, read `design/README.md` and its screens as the visual implementation reference — derive components, layouts, and states from the mockups (read-only; do not edit them).
- **Fill the `## Testing Strategy` section:** map every user story and success criterion (SC-###) from the spec to how it will be verified, choose test levels, and state how to run tests. Whether coverage is mandatory or expected follows the constitution's testing principle.
- **Ground the plan in the structural layer:** use the repo map (if present) to base file/architecture choices on what already exists. Name the existing symbols/conventions to reuse. Prefer extending an existing module over creating a new one.
- Do NOT offer an execution handoff at the end of the plan — implementation is a separate phase.

## Phase 2 — Companions, approval gate & route

- If the spec implies them, create `specs/<id>/research.md`, `specs/<id>/data-model.md`, and contracts under `specs/<id>/contracts/`.
- Optional companions: if the spec involves an API or module boundary, use the api-and-interface-design skill while drafting the plan. If the spec involves user-facing UI, use the frontend-ui-engineering skill. Neither blocks the approval gate.
- **Human approval gate (load-bearing):** present the plan to the user and get explicit approval — architecture and task decomposition are cheap to fix on paper, expensive in code. Only on approval: update `.sdd/pipeline.md`: set `plan` row to `approved`.
- If the user requests changes, revise and re-present; leave the phase `in_progress`. Never advance to tasks/implement on an unapproved plan.
- Route to tasks phase.
```

- [ ] **Step 5: Write `m-sdd-tasks/phase-instructions.md`**

```markdown
# SDD — Tasks Phase

> Read `m-sdd/phase-instructions.md` (shared rules) first.

**Pipeline:** plan → tasks → analyze

## Preflight

- Read `.sdd/pipeline.md`. If `plan` is not `approved`, stop and tell the user to complete and approve the plan phase first.
- Update `.sdd/pipeline.md`: set `tasks` row to `in_progress`.

## Phase 1 — Derive tasks.md

- Read `specs/<id>/plan.md`. Collect all `- [ ]` steps into an ordered checklist in `specs/<id>/tasks.md` (start from `.sdd/templates/tasks-template.md` if present).
- Assign stable IDs `T001, T002, …` in dependency order. Keep each task independently testable. Do not invent work not in the plan.
- **Traceability + tests:** tag each task with the user-story / success-criterion IDs it serves (`[US#]`, `[SC-###]`). Carry the plan's Testing Strategy into concrete test tasks labelled the same way. Whether missing coverage is blocking is the constitution's call (default: expected, not blocking).
- **Single source of truth:** once `tasks.md` exists, it is the canonical execution checklist. Replace the plan's `## Tasks` body with a one-line pointer: `See ./tasks.md (canonical).`

## Phase 2 — Record & route

- Update `.sdd/pipeline.md`: set `tasks` row to `done`.
- Route to analyze phase (then implement phase).
```

- [ ] **Step 6: Write `m-sdd-analyze/phase-instructions.md`**

```markdown
# SDD — Analyze Phase (Optional, Recommended)

> Read `m-sdd/phase-instructions.md` (shared rules) first.

**Pipeline:** tasks → analyze → implement. Optional but recommended.

## Preflight

- Read `.sdd/pipeline.md`. If `tasks` is not `done`, stop.
- Load `.sdd/constitution.md`.
- Update `.sdd/pipeline.md`: set `analyze` row to `in_progress`.

## Phase 1 — Cross-artifact analysis

Compare, and record findings in `specs/<id>/analysis.md`:

- **Coverage:** every spec requirement maps to ≥1 task; flag uncovered requirements.
- **Test coverage:** every user story and success criterion (SC-###) has ≥1 verifying test task. Severity follows the constitution's testing principle — blocking if it mandates coverage; otherwise non-blocking. Default: non-blocking.
- **Design coverage:** if `specs/<id>/design/` exists, every screen in `design/README.md` maps to a user story, and the plan covers every screen. Flag orphans both ways (non-blocking).
- **Consistency:** plan/tasks don't contradict the spec; names/types used consistently.
- **Constitution:** no artifact violates `.sdd/constitution.md` (guardrails, conventions).
- **Scope:** still a single implementable unit (else recommend decomposition).
- Classify each finding `blocking` or `non-blocking`.
- Optional companions: before recording the verdict, use the security-and-hardening skill to check for security gaps and the performance-optimization skill to check for performance regressions. Findings feed into analysis.md as non-blocking notes unless the constitution mandates otherwise.

## Phase 2 — Record & route

- If any `blocking` findings: leave `analyze` `in_progress`, report them, and send the user back to the relevant phase (specify/plan/tasks).
- If clean (or user accepts non-blocking): update `.sdd/pipeline.md`: set `analyze` row to `done`; route to implement phase.
- To skip entirely: update `.sdd/pipeline.md`: set `analyze` row to `skipped`.
```

- [ ] **Step 7: Write `m-sdd-implement/phase-instructions.md`**

```markdown
# SDD — Implement Phase

> Read `m-sdd/phase-instructions.md` (shared rules) first.

**Pipeline:** analyze → implement → issues

## Preflight & gate

- Read `.sdd/pipeline.md`. If `tasks` is not `done`, stop.
- Read `.sdd/pipeline.md`. If `analyze` is not `done` or `skipped`, stop — never implement on a still-pending/in-progress consistency gate.
- Load `.sdd/constitution.md`.
- Load the structural grounding source if present (`.sdd/repo-map.md` or the code index named in `.sdd/knowledge.md`).
- **Human GO gate — the point of no return into code (load-bearing).** Before writing any code: summarize what will be built (the `tasks.md` list), the target branch, and any open analyze findings the user must own; then get the user's explicit "go". If not confirmed, stop. Do NOT proceed autonomously past this point.
- Optional companion: if implementation hits unexpected failures or test breakages, use the debugging-and-error-recovery skill for structured root-cause triage before retrying.

## Phase 1 — Execute

- Update `.sdd/pipeline.md`: set `implement` row to `in_progress`.
- Create an isolated feature branch for the work.
- Execute `specs/<id>/plan.md` and `specs/<id>/tasks.md` task by task, ticking `- [ ]` boxes in `tasks.md` as tasks complete. Feed the structural grounding (repo map or code index) as reuse context to each task so existing symbols/conventions are reused.

## Phase 2 — Finish, record & route

- Verify tests pass. Prepare for merge/PR.
- Update `.sdd/pipeline.md`: set `implement` row to `done`.
- Route: offer the issues phase if the team tracks work in Jira; otherwise the pipeline is complete.
```

- [ ] **Step 8: Verify all seven files exist and have no Devin-specific content**

```bash
for phase in constitution specify clarify plan tasks analyze implement; do
  f="m-sdd-$phase/phase-instructions.md"
  if [ ! -f "$f" ]; then echo "MISSING $f"; continue; fi
  if grep -q "config/devin\|sdd-lib\|sdd_set_phase\|sdd_require\|sdd_scaffold\|source ~" "$f"; then
    echo "FAIL $f — Devin-specific content found"
  else
    echo "OK $f"
  fi
done
```

Expected: seven `OK` lines, zero `MISSING` or `FAIL`.

- [ ] **Step 9: Commit**

```bash
git add m-sdd-constitution/phase-instructions.md \
        m-sdd-specify/phase-instructions.md \
        m-sdd-clarify/phase-instructions.md \
        m-sdd-plan/phase-instructions.md \
        m-sdd-tasks/phase-instructions.md \
        m-sdd-analyze/phase-instructions.md \
        m-sdd-implement/phase-instructions.md
git commit -m "feat: add phase-instructions.md to all seven pipeline phases

Tool-agnostic canonical source per phase. No shell calls, no
~/.config/devin paths. Devin shell calls remain exclusively in
SKILL.md. Existing SKILL.md behavior is unchanged."
```

---

## Task 3: Extend `install.sh` with `--tool` flag

**Files:**
- Modify: `install.sh`

Add `--tool <name> --project <path>` flag handling. Assemble the adapter file via `cat`. Write `.sdd/pipeline.md` if absent. Never clobber existing adapter files.

- [ ] **Step 1: Read current `install.sh` to confirm structure before editing**

```bash
cat -n install.sh
```

Confirm the current structure (as of this writing):
- Lines 6-12: `PROJECT_DIR=""` + `while` loop with `--project` case
- Line 13: `SRC="$(cd "$(dirname "$0")" && pwd)"`
- Lines 16-24: main `for d in "$SRC"/h-*` symlink loop
- Line 25: `echo "Done. Restart Devin CLI or re-scan skills if needed."`
- Lines 27-47: `--project` block for quality skills

- [ ] **Step 2: Add `--tool` to the existing flag-parsing `while` loop**

In `install.sh`, replace the existing `while` loop:
```bash
PROJECT_DIR=""
while [[ $# -gt 0 ]]; do
  case "$1" in
    --project) PROJECT_DIR="$2"; shift 2 ;;
    *) echo "Unknown argument: $1"; exit 1 ;;
  esac
done
```

with:
```bash
PROJECT_DIR=""
TOOL_NAME=""
while [[ $# -gt 0 ]]; do
  case "$1" in
    --project) PROJECT_DIR="$2"; shift 2 ;;
    --tool)    TOOL_NAME="$2";    shift 2 ;;
    *) echo "Unknown argument: $1"; exit 1 ;;
  esac
done

# Validate: --tool requires --project
if [ -n "$TOOL_NAME" ] && [ -z "$PROJECT_DIR" ]; then
  echo "Error: --tool requires --project <path>."
  echo "Example: bash install.sh --tool claude --project /path/to/your-project"
  exit 1
fi
```

- [ ] **Step 3: Run existing tests to verify no regression from flag parsing change**

```bash
bash install.sh 2>&1 | tail -5
```

Expected: ends with `Done. Restart Devin CLI or re-scan skills if needed.` — no errors.

- [ ] **Step 4: Add `install_tool_adapter` function and `pipeline.md` template**

After the closing `echo "Done. Restart Devin CLI..."` line at the end of `install.sh`, add:

```bash
# --tool: write a non-Devin adapter + .sdd/pipeline.md into a target project
if [ -n "$TOOL_NAME" ]; then
  # Map tool name to target file path
  case "$TOOL_NAME" in
    claude)   ADAPTER_REL=".claude/CLAUDE.md" ;;
    cursor)   ADAPTER_REL=".cursorrules" ;;
    windsurf) ADAPTER_REL=".windsurfrules" ;;
    agents)   ADAPTER_REL="AGENTS.md" ;;
    *)
      echo "Error: unknown tool '$TOOL_NAME'. Supported: claude, cursor, windsurf, agents"
      exit 1
      ;;
  esac

  ADAPTER_PATH="$PROJECT_DIR/$ADAPTER_REL"
  ADAPTER_DIR="$(dirname "$ADAPTER_PATH")"

  echo "Installing SDD adapter for '$TOOL_NAME' into $PROJECT_DIR"

  # Create target dir if needed (e.g. .claude/)
  mkdir -p "$ADAPTER_DIR"

  # Never clobber an existing adapter file
  if [ -e "$ADAPTER_PATH" ]; then
    echo "  skip $ADAPTER_REL (already exists — delete it to regenerate)"
  else
    # Assemble adapter: header + shared rules + each phase in pipeline order
    {
      echo "# SDD Pipeline — $TOOL_NAME"
      echo ""
      echo "> Read this before running any SDD phase. This file was generated by"
      echo "> \`bash install.sh --tool $TOOL_NAME --project <path>\` from the SDD toolkit."
      echo ""
      echo "---"
      echo ""
      cat "$SRC/m-sdd/phase-instructions.md"
      echo ""
      for phase in constitution specify clarify plan tasks analyze implement; do
        pi="$SRC/m-sdd-$phase/phase-instructions.md"
        if [ -f "$pi" ]; then
          echo ""
          echo "---"
          echo ""
          cat "$pi"
        else
          echo ""
          echo "---"
          echo ""
          echo "# SDD — $phase phase"
          echo ""
          echo "> phase-instructions.md not found for this phase. Run vendor.sh to update."
        fi
      done
    } > "$ADAPTER_PATH"
    echo "  installed $ADAPTER_REL"
  fi

  # Write .sdd/pipeline.md if absent
  PIPELINE_DIR="$PROJECT_DIR/.sdd"
  PIPELINE_FILE="$PIPELINE_DIR/pipeline.md"
  mkdir -p "$PIPELINE_DIR"
  if [ -e "$PIPELINE_FILE" ]; then
    echo "  skip .sdd/pipeline.md (already exists)"
  else
    cat > "$PIPELINE_FILE" <<'PIPELINE_EOF'
# SDD Pipeline State

<!-- Managed by the SDD toolkit. Update phase rows as you work through the pipeline. -->
<!-- Status values: pending | in_progress | done | approved | skipped -->

## Feature: <!-- replace with your feature name -->  <!-- active -->

| Phase        | Status  |
|--------------|---------|
| constitution | pending |
| specify      | pending |
| clarify      | pending |
| plan         | pending |
| tasks        | pending |
| analyze      | pending |
| implement    | pending |
| issues       | pending |
PIPELINE_EOF
    echo "  installed .sdd/pipeline.md"
  fi

  echo "Done. Restart your AI tool in the project to load the adapter."
fi
```

- [ ] **Step 5: Test `--tool claude` flag end-to-end**

```bash
TMPDIR=$(mktemp -d)
bash install.sh --tool claude --project "$TMPDIR"
echo "--- adapter file ---"
head -10 "$TMPDIR/.claude/CLAUDE.md"
echo "--- pipeline.md ---"
cat "$TMPDIR/.sdd/pipeline.md"
```

Expected:
- `.claude/CLAUDE.md` exists and starts with `# SDD Pipeline — claude`
- `.sdd/pipeline.md` exists with the feature table and all phases `pending`

- [ ] **Step 6: Test all four tool names write to the correct paths**

```bash
TMPDIR=$(mktemp -d)
bash install.sh --tool claude    --project "$TMPDIR" && echo "OK claude"
bash install.sh --tool cursor    --project "$TMPDIR" && echo "OK cursor"
bash install.sh --tool windsurf  --project "$TMPDIR" && echo "OK windsurf"
bash install.sh --tool agents    --project "$TMPDIR" && echo "OK agents"
ls "$TMPDIR/.claude/" "$TMPDIR/" | grep -E "CLAUDE\.md|\.cursorrules|\.windsurfrules|AGENTS\.md"
```

Expected: four `OK <tool>` lines, then the four files listed.

- [ ] **Step 7: Test no-clobber behavior**

```bash
# Re-run — all files already exist
bash install.sh --tool claude    --project "$TMPDIR" 2>&1 | grep "skip"
bash install.sh --tool agents    --project "$TMPDIR" 2>&1 | grep "skip"
```

Expected: `skip .claude/CLAUDE.md (already exists ...)` and `skip AGENTS.md (already exists ...)`

- [ ] **Step 8: Test `--tool` without `--project` exits 1**

```bash
bash install.sh --tool claude 2>&1; echo "exit: $?"
```

Expected: prints usage error, `exit: 1`

- [ ] **Step 9: Test adapter contains all seven phases in pipeline order**

```bash
grep "^# SDD —" "$TMPDIR/.claude/CLAUDE.md"
```

Expected (in order):
```
# SDD — Constitution Phase
# SDD — Specify Phase
# SDD — Clarify Phase (Optional)
# SDD — Plan Phase
# SDD — Tasks Phase
# SDD — Analyze Phase (Optional, Recommended)
# SDD — Implement Phase
```

- [ ] **Step 10: Verify global install still works (no args)**

```bash
bash install.sh 2>&1 | tail -3
```

Expected: ends with `Done. Restart Devin CLI (or re-scan skills) to load them.` — no errors.

- [ ] **Step 11: Clean up temp dir and commit**

```bash
rm -rf "$TMPDIR"
git add install.sh
git commit -m "feat(install): add --tool flag to write non-Devin adapter into a project

bash install.sh --tool <name> --project <path> assembles a single
Markdown adapter file (CLAUDE.md / .cursorrules / .windsurfrules /
AGENTS.md) from phase-instructions.md files in pipeline order, and
writes .sdd/pipeline.md for Markdown-based state tracking.
Supported tools: claude, cursor, windsurf, agents.
Global install behavior (no args) and --project flag are unchanged."
```

---

## Task 4: Update `README.md`

**Files:**
- Modify: `README.md`

Three additions: multi-tool section, install note, developer block note.

- [ ] **Step 1: Add multi-tool support section after the existing install section**

In `README.md`, after the `**Good to know**` block (the bullet list ending around line 63), add:

```markdown
### Multi-tool support (Claude Code, Cursor, Windsurf, AGENTS.md)

The SDD pipeline can be installed into any project for use with tools other than Devin CLI — Claude Code, Cursor, Windsurf, or any tool that reads `AGENTS.md`.

Run this after the global install:
```bash
# Claude Code
bash install.sh --tool claude --project /path/to/your-project

# Cursor
bash install.sh --tool cursor --project /path/to/your-project

# Windsurf
bash install.sh --tool windsurf --project /path/to/your-project

# Generic (any tool reading AGENTS.md)
bash install.sh --tool agents --project /path/to/your-project
```

This writes a single Markdown adapter file (e.g. `.claude/CLAUDE.md`) and `.sdd/pipeline.md` into your project. The adapter contains the full pipeline instructions for all phases. Non-Devin tools track phase state in `.sdd/pipeline.md` (a Markdown table) instead of `sdd-lib.sh`.

Commit both files to your project repo alongside `.sdd/constitution.md` and `specs/`.
```

- [ ] **Step 2: Add a note to the developer `<details>` block**

In the developer `<details>` block (around line 76), after the existing `Every skill the pipeline needs is vendored in this repo` sentence, add:

```markdown
Each pipeline phase also has a `phase-instructions.md` — the tool-agnostic canonical source. `SKILL.md` is the Devin adapter (YAML frontmatter + shell calls). `vendor.sh` re-syncs both automatically.
```

- [ ] **Step 3: Verify README changes**

```bash
grep -n "Multi-tool\|--tool\|phase-instructions" README.md
```

Expected: at least three matches — one per addition.

- [ ] **Step 4: Commit**

```bash
git add README.md
git commit -m "docs(readme): document multi-tool support and --tool install flag

Adds multi-tool section with copy-paste examples for claude, cursor,
windsurf, and agents. Adds developer note about phase-instructions.md
as the canonical source and SKILL.md as the Devin adapter."
```

---

## Task 5: Run existing tests and verify nothing is broken

**Files:** none modified — verification only

- [ ] **Step 1: Run the existing sdd-lib test suite**

```bash
bash m-sdd/test_sdd_lib.sh
```

Expected: all tests pass, no failures.

- [ ] **Step 2: Verify `sdd-lib.sh` is unchanged**

```bash
git diff m-sdd/sdd-lib.sh
```

Expected: empty output (no changes).

- [ ] **Step 3: Verify `_shared.md` is unchanged**

```bash
git diff m-sdd/_shared.md
```

Expected: empty output (no changes).

- [ ] **Step 4: Verify global install works end-to-end**

```bash
bash install.sh 2>&1
```

Expected: all `h-*` skills installed/linked with no errors, ends with `Done.`

- [ ] **Step 5: Verify all seven `phase-instructions.md` files are present in `~/.config/devin/skills/` after install**

```bash
for phase in constitution specify clarify plan tasks analyze implement; do
  f="$HOME/.config/devin/skills/m-sdd-$phase/phase-instructions.md"
  [ -e "$f" ] && echo "OK m-sdd-$phase" || echo "MISSING m-sdd-$phase"
done
```

Expected: seven `OK` lines (symlinks resolve because `install.sh` symlinks the whole `m-sdd-<phase>/` folder).

- [ ] **Step 6: Final status check**

```bash
git status
```

If clean, done. If any unstaged changes remain, stage and commit with an appropriate message.

---

## Acceptance Checklist (from design spec)

- [ ] Every pipeline phase has a `phase-instructions.md` with no Devin-specific shell calls or `~/.config/devin/…` paths
- [ ] Every `SKILL.md` behavior is identical to today — `bash m-sdd/test_sdd_lib.sh` passes
- [ ] `bash install.sh --tool claude --project <path>` writes `<path>/.claude/CLAUDE.md` with all phase instructions in pipeline order
- [ ] `bash install.sh --tool cursor --project <path>` writes `<path>/.cursorrules`
- [ ] `bash install.sh --tool windsurf --project <path>` writes `<path>/.windsurfrules`
- [ ] `bash install.sh --tool agents --project <path>` writes `<path>/AGENTS.md`
- [ ] Each adapter install writes `<path>/.sdd/pipeline.md` if not already present
- [ ] `bash install.sh` (no args) works exactly as today — zero regression
- [ ] `bash install.sh --project <path>` (quality skills) works exactly as today — zero regression
- [ ] `bash install.sh --tool <name>` without `--project` exits 1 with a clear usage message
- [ ] No adapter file is clobbered if it already exists in the target project
- [ ] `bash m-sdd/test_sdd_lib.sh` passes — `sdd-lib.sh` unchanged
- [ ] `m-sdd/_shared.md` Devin behavior is identical — file unchanged
