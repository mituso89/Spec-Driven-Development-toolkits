---
name: h-story-breakdown
description: "Jira story/epic orchestrator — create the parent story or epic if it doesn't exist, assess whether it needs breaking down, and (on confirmation) create per-stack tickets typed Story/Task/Subtask by intent, linked via the Atlassian MCP. Triggers: break story, split story, decompose story, story breakdown, create subtasks, create dev tickets, story to tasks, jira breakdown, create story, create epic, jira from feature, feature to jira, plan to jira tickets."
---

# Jira — Story/Epic Breakdown Orchestrator

> **TL;DR** — Expand (0) → **user confirms** → resolve parent: fetch it, or **create the story/epic** if none exists (1) → **assess: does this need breakdown at all?** recommend, user decides (2) → verify stacks + slice, typing each ticket Story/Task/Subtask **by intent** (3) → propose (4) → **user confirms** → create (5) → link (6) → deliver (7) → optional test-plan handoff (8).

Follow every phase in order. **Do NOT create any Jira issue until its user gate has passed** (Phase 1 gate for the parent, Phase 4 gate for children).

All Jira work uses the `mcp__mcp-atlassian__*` MCP tools — never a CLI. If a required tool is not loaded, fetch its schema via `ToolSearch` first.

> **Install location** — portable: works at `<repo>/.devin/skills/h-story-breakdown/` or `~/.config/devin/skills/h-story-breakdown/`. The Atlassian MCP must be reachable; a project `.mcp.json` wins over global MCP config.

---

## Phase -1 — Load Config

Resolve config by trying in order, stopping at the first hit (Read each; on error, next):

1. `<cwd>/.devin/skills/h-story-breakdown/config.json` (project override)
2. `<cwd>/.devin/skills/h-story-breakdown/config.example.json`
3. `~/.config/devin/skills/h-story-breakdown/config.json` (global default)
4. `<skill-dir>/config.example.json` (last resort)

Announce the resolved source once. If only the example was found, tell the user once to copy it to `config.json` and customise. If the Atlassian MCP tools are missing: `Atlassian MCP not loaded — add it to <cwd>/.devin/config.json or ~/.config/devin/config.json` and stop.

**Config shape** (see `config.example.json`):

```json
{
  "defaultProject": "PROJ",
  "defaultIssueType": "Task",             // fallback when intent is ambiguous
  "parentLinkage": "parent",              // "parent" | "link"
  "contentLanguage": "en",
  "stacks": {
    "Mobile":  { "components": ["Mobile"],  "labels": ["mobile"] },
    "Backend": { "components": ["Backend"], "labels": ["backend"] }
  },
  "inheritFromStory": ["priority", "components", "labels", "fixVersions"],
  "alwaysAddLabels": [],
  "defaultAssignee": null
}
```

**Merge precedence** (lowest → highest): config defaults → parent inheritance (Phase 1) → `config.stacks[<stack>]` → `alwaysAddLabels` → user chat overrides. Apply per ticket payload in Phase 5.

---

## Phase 0 — Expand the Request

Detect the **entry mode** first:

- **Mode A — parent exists:** the user gave an issue key (or a link).
- **Mode B — no parent yet:** the user gave a feature description, spec, plan, or task list with no Jira key → this skill will **offer to create the parent first** (Phase 1).

Produce this block immediately, then **stop and wait for user confirmation**:

```
EXPANDED REQUEST
======================================================
Original: "[user's exact words]"

Entry mode:           [A: existing ISSUE-KEY | B: create new parent]
Parent:               [ISSUE-KEY  |  NEW → proposed type: Story | Epic]
Target project key:   [PROJ]   (default: parent's project / config.defaultProject)
Parent linkage:       [parent field | "Relates to" link | "Blocks" link]

Stacks in scope (from user intent; common set below):
  [ ] [Mobile]    [ ] [Backend]   [ ] [Web]
  [ ] [Design]    [ ] [QA]        [ ] [DevOps]    [ ] [Other: ___]

Assumptions:
  . [assumption] — reason: [why most reasonable]
Out of scope:
  . [anything user explicitly excluded]
======================================================
```

Mode B parent-type heuristic: scope spanning multiple independent user-facing capabilities (multi-sprint) → **Epic**; one user-facing capability → **Story**. Say which you propose and why.

User confirms → Phase 1. Revisions → update the block, wait again.

---

## Phase 1 — Resolve the Parent (fetch or create)

**Mode A — fetch:**
```
mcp__mcp-atlassian__jira_get_issue(
  issue_key: "<ISSUE-KEY>",
  fields: "summary,description,status,issuetype,labels,components,priority,assignee,parent",
  comment_limit: 0
)
```
Extract `summary`, `description` (mine for Acceptance Criteria, flows, contracts), `components`/`labels`/`priority` (inherit), `issuetype`. If the parent is already a Task/Subtask, stop and ask. If the description is too thin to assess, **stop and ask** for AC — do not invent.

**Mode B — create (the parent the user confirmed in Phase 0):**
- Draft the parent from the user's input: summary; description with `## Goal`, `## Acceptance Criteria` (from the input — a requirement spec's user story maps 1:1: title → summary, as-a/I-want/so-that → Goal, its scenarios → AC).
- **Show the draft, get explicit OK, then** `jira_create_issue` with `issue_type: "Story"` (or `"Epic"`). Some company-managed projects require an *Epic Name* field — the Phase 5 pre-flight pattern (validate → add missing fields → retry) applies here too.
- The created key becomes `<PARENT-KEY>` for everything downstream.

---

## Phase 2 — Breakdown Assessment (recommend, user decides)

Before slicing anything, judge whether breakdown is warranted and **say so**:

- **Recommend NO breakdown** when the parent is closeable as one deliverable: single stack, ≤ ~3 AC, one PR's worth, no cross-team dependency. Offer instead to enrich the parent's description (AC checklist, technical notes) and stop after that.
- **Recommend breakdown** when AC span stacks/teams, contain independent deliverables, or an Epic holds multiple capabilities. State the expected shape ("~N tickets across [Mobile][Backend]").

Present the recommendation with its reasoning, then **wait**: the user's choice wins either way. "No breakdown" → enrich parent if wanted, jump to Phase 7 delivery. "Break it down" → Phase 3.

---

## Phase 3 — Verify Stacks, Then Slice

### 3a — Stack-need check (mandatory gate)

Phase 0 stacks are *intent*. Scan summary + description + AC for evidence each is needed (UI screens → `[Mobile]`/`[Web]`; API/DB/auth → `[Backend]`; new flows w/o mockups → `[Design]`; complex AC matrix → `[QA]`; env/infra/CI → `[DevOps]`). Produce a verification block; **stop if any row is MISMATCH** (picked, no evidence) or **SUGGEST ADD** (needed, not picked). All NEEDED → proceed.

### 3b — Slice, typing each ticket by intent

| Parent | Item's intent | Issue type |
|---|---|---|
| Epic | independent user-facing capability (own AC, own value) | **Story** |
| Epic | technical/enabling work (infra, migration, spike) | **Task** |
| Story | internal step — no independent value, same team, tracked under the story's workflow | **Subtask** |
| Story | independent deliverable (one PR, possibly another stack/team) | **Task** |
| ambiguous | — | `config.defaultIssueType`; flag it in Phase 4 for the user to settle |

Slicing rules:
1. **One ticket = one deliverable** (closeable in a single PR).
2. **Prefix developer tickets** (`Task`/`Subtask`) `[Stack] <imperative action>`; **Stories get plain user-value summaries** (no stack tag). Tags stay English; summary + description in `config.contentLanguage`.
3. **No cross-stack coupling** in one ticket — Mobile needing a new API = two tickets + a "Blocks" link.
4. **Every AC line maps to ≥1 ticket; every ticket maps to ≥1 AC.** No speculative work.

Template per ticket:
```
Summary:    [Stack] <action>   (Stories: <user-value phrase>, no tag)
Issue type: Story | Task | Subtask   (from the intent table)
Project:    <PROJ>   Parent: <PARENT-KEY>
Priority/Components/Labels: inherited + stack entry
Description (Markdown):
  ## Context — Parent: <PARENT-KEY> — <summary>
  ## Scope — delivers / does NOT deliver
  ## Acceptance Criteria — [ ] copied/tightened from parent
  ## Technical Notes — paths, endpoints, patterns (optional)
```

---

## Phase 4 — Propose Breakdown (User Gate)

Present the full proposed list in one compact numbered block — **type, stack, priority, deps ("blocks #N"), and any type-flagged-ambiguous rows** — then **wait for approval**. No `jira_create_issue` yet. Edits → re-present; stay here until approved.

---

## Phase 5 — Create Tickets

`todo_write`: one todo per ticket + one for linking; flip as you go.

**Pre-flight — project-required custom fields** (per-Jira-project): do ONE validation create (or `validate_only: true` batch) to surface what this project requires; discover field IDs via `jira_search_fields` once, cache for the turn. Unclear required value → **stop and ask**.

**Preferred path (supports parent): one `jira_create_issue` per ticket.**
```
mcp__mcp-atlassian__jira_create_issue(
  project_key: "PROJ",
  summary: "[Mobile] Login screen UI",
  issue_type: "Task",                              // per ticket, from the intent table
  description: "<markdown from Phase 3>",
  components: "Mobile,Auth",                       // comma-separated string, not array
  additional_fields: "{\"parent\": \"<PARENT-KEY>\", \"priority\": {\"name\": \"Medium\"}, \"labels\": [\"mobile\"]}"
)
```
Notes: `additional_fields` is a **JSON string**. `parent` is a **bare string** (`"PROJ-26"`). Subtasks use `issue_type: "Subtask"` (one word) and **require** `parent`. **Hierarchy error** (`parent does not belong to appropriate hierarchy` — e.g. Task under Epic on some setups) → re-call with `parent` REMOVED, then link in Phase 6.

**Fast path (long lists, no parent-on-create):** `jira_batch_create_issues` (`validate_only: true` first when ≥10), then link in Phase 6. Batch does **not** accept parent — never use it for Subtasks.

Record each returned `key`.

---

## Phase 6 — Link (only if parent not set at creation)

Skip if Phase 5 set `parent` everywhere. Otherwise per child:
```
mcp__mcp-atlassian__jira_create_issue_link(
  link_type: "Relates",            // or "Blocks" for dependency order
  inward_issue_key: "<PARENT-KEY>", outward_issue_key: "<CHILD-KEY>"
)
```
Cross-ticket deps from Phase 4 ("#3 blocks #2") also go here with `"Blocks"`.

---

## Phase 7 — Delivery

Emit a `DONE` block: parent (note if created this run), project, the `KEY  TYPE  [Stack]  summary` list, links created, and `Check: N/N created · parent linkage ok · types per intent ok · prefixes ok`. Failures go under `Failed:` with the error verbatim — do NOT retry silently. (No-breakdown path: report the parent + enrichment only.)

---

## Phase 8 — Optional Test Plan Handoff

Ask once whether to draft a test plan from the parent's AC via a test-plan skill (if installed) — pass parent key, AC list, created keys, `contentLanguage`. On "later", add a `test-plan-pending` label to the parent. No test-plan skill installed → say so and stop.

---

## Never Do

- Create any Jira issue before its user gate (Phase 1 for the parent, Phase 4 for children).
- Slice without the Phase 2 assessment — recommending NO breakdown is a first-class outcome.
- Invent acceptance criteria, endpoints, or scope not in the source input.
- Give every ticket one blanket issue type — type follows the intent table; flag ambiguity instead of guessing.
- Skip the `[Stack]` prefix on a developer ticket, put two stacks in one ticket, or stack-tag a Story.
- Pass `additional_fields` as an object — it's a JSON **string**; or use `Sub-task` (hyphen) — it's `Subtask`.
- Use `jira_batch_create_issues` for Subtasks or when parent must be set at creation.
- Loop-retry a failing create without changing input — surface the error and stop.
- Read Jira via a CLI — `mcp__mcp-atlassian__*` only.
