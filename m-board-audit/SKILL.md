---
name: m-board-audit
description: "Audit a Jira or Azure DevOps board against ways-of-working rules, produce a tagged cleanup plan, then on one confirm gate apply safe bulk fixes and delegate epic/story/subtask creation to sibling skills. Triggers: audit my board, board audit, ado board audit, jira audit, audit board, backlog cleanup, board hygiene, board health, clean up jira, sprint cleanup, iteration cleanup, sprints used as epics, hidden tickets, fix backlog, organize backlog, epic story audit, backlog triage."
---

# Board Audit & Cleanup

> **TL;DR** — Detect provider (−1) → auto-resolve board context (0) → **read-only sweep** of the board's health checks (1) → emit health report + **tagged, ordered cleanup plan** (2) → **user confirms** (3) → execute [auto] then [confirm] steps, **delegate [delegate] steps** to siblings (4) → run log (5).

This skill **diagnoses and orchestrates** — it never re-implements ticket creation. Net-new
epic/story/subtask hierarchy goes to **`/m-story-breakdown`**; a too-technical ticket goes to
**`/m-pm-ticket`**. All board work uses the provider's MCP tools — never a CLI. If a tool isn't
loaded, discover it via `ToolSearch` using the name hints in the provider file (Phase −1).

**Hard rule — never dump raw tickets.** Ticket descriptions overflow the tool token limit. Every
query passes a compact field list (no `description`/all-fields) and you **aggregate** (counts,
group-by). When a result is still large it is saved to a file — read it with `jq`, never inline.

**Do NOT write anything before the Phase 3 gate.** The whole sweep + report is read-only.

---

## Phase −1 — Provider detection (delegate to `m-board`)

Run the sibling `m-board` skill's detection procedure: read this skill's `config.json`
`"provider"` (`"jira"` | `"ado"`) if present; else discover via `ToolSearch` over the session's
MCP tools; else ask the user once and offer to record the answer in `config.json`. Then read
**`m-board/providers/<provider>.md`** for concrete tool names, the query language (JQL / WIQL),
and type/field/state mapping. If no provider surface is loaded at all:
`Board connector not loaded — add your Jira or Azure DevOps connector, then retry` and stop.

## Phase 0 — Resolve board context (auto-discover; config optional)

**Zero-config by default** — discover everything from the live board. A config file is *optional*
and only **overrides** discovery; the skill runs fully without one.

Discover with the provider's read tools (project list, ticket-type/field metadata, sample ticket):

| Value | How discovered | Fallback if inconclusive |
|---|---|---|
| **Project** | match the user's term ("audit for X") to the provider's project list by name/key (case-insensitive) | one match → use; several → ask; no term + one project → use, else ask |
| **Sprint/iteration field** | per provider file (Jira: sniff a sample ticket's field schema; ADO: built-in iteration path) | provider file's noted default, else ask |
| **Epic/parent link field** | per provider file (custom field vs built-in parent link) | provider file's noted default |
| **Story points field** | field named like "Story Points" / "Effort" | skip sizing checks if absent |
| **Components / area paths** | project metadata (allowed component values / area-path tree) | — |
| **Status buckets** | the provider's status/state **category**: to-do → todo, in-progress → inProgress, done → done | config may remap nuanced statuses |

*(boardId is not needed — the sweep scopes by project plus sprint/iteration query clauses.)*

**Policy defaults** (override via config): `sprintPolicy` = 1 active + 1 planned, 2-week length;
`staleDays` = 90; `highPriorityNames` = per provider's priority scheme (e.g. High, Highest / 1, 2);
`fixVersionScheme` = unset (check 6 flags empties but proposes no auto-value until a scheme is defined).

**Optional config** (override only) — first hit wins: `<cwd>/.claude/skills/m-board-audit/config.json`,
then `~/.claude/skills/m-board-audit/config.json`. Any value present wins over discovery. See
`config.example.json` for the override shape and `rules.md` for the ways-of-working enforced.
Announce once whether you ran **discovered** or **config-backed**.

## Phase 1 — Read-only sweep (the check battery)

Run each check as a compact, aggregated query. Each yields a count + the affected keys/ids.

| # | Check | Query signal | Recommended action |
|---|---|---|---|
| 1 | Zombie active sprints/iterations | active sprint/iteration with end date past | close; carry over not-Done |
| 2 | Too many active/planned sprints | open+future count vs `sprintPolicy` | convert/close excess |
| 3 | Done clutter in active sprint | tickets in active sprint with done-category status | clears on close |
| 4 | Sprints used as epics | future sprint/iteration name isn't a date/cadence | convert to epic |
| 5 | Hidden high-priority | high-priority tickets parked in future sprints/iterations | re-rank / pull in |
| 6 | Missing release version | fix version / release field empty | set per scheme |
| 7 | Missing component/area path | component or area path empty | assign from list |
| 8 | Missing epic/parent link | story/task/bug with no epic or parent link | attach to epic |
| 9 | Label-as-field smell | labels/tags matching platform or module names | migrate to field/component |
| 10 | Stale open tickets | not-started status, untouched > `staleDays` | **list + confirm** per batch |

**Status-aware closing (cross-cutting).** Before closing any sprint/iteration (1 or 3), split its
tickets by `statusBuckets`: `done` → drops off on close; `todo`/`inProgress` → **carry-over**,
enumerated and routed to a user-chosen destination (backlog or active sprint). Never silently dropped.

## Phase 2 — Health report + cleanup plan

Emit one report (chat; offer to save to `docs/specs/YYYY-MM-DD-<project>-board-audit.md`):
a `SUMMARY` line, one row per failing check (icon · count · action), then an **ordered, reversible-first**
`PROPOSED CLEANUP PLAN`. Tag every step:

- **[auto]** — safe, reversible field write (component/area path, release version). Runs first.
- **[confirm]** — needs an explicit yes; **shows the ticket list** before acting.
- **[delegate→<skill>]** — handed to a sibling; names the parent + child intents.

Nothing executes here. This is the plan only.

## Phase 3 — Confirm gate

Present the plan and **stop**. The user approves all, edits, or picks steps. No write until this passes.

## Phase 4 — Execute (top-down, most-reversible first)

- **[auto]** — batched ticket edits (provider file names the edit tool) in bounded groups; report
  counts (`set Component 41/41`).
- **[confirm]** — per step: show list → wait for yes → act.
  - *Close sprint/iteration* → move carry-over tickets to the chosen destination; then name any
    manual board click the ticket API can't do (e.g. Jira's **"Complete sprint"** button).
  - *Convert sprint→epic* → create the epic, move the sprint's tickets onto it, clear their sprint.
  - *Re-rank hidden high-priority* → top-of-backlog or pull into the active sprint/iteration.
- **[delegate]** — invoke `/m-story-breakdown` (create + link hierarchy) or `/m-pm-ticket` (rewrite a
  too-technical ticket). Hand over intents plus the detected provider; the sibling owns creation.

## Phase 5 — Run log

Summarize what changed, what was delegated (with new keys/ids), and the manual board clicks left for the user.

## Never

- Write anything before the Phase 3 gate, or auto-close/auto-delete on a judgment call.
- Dump raw tickets or request `description`/all fields in a query — aggregate, or `jq` a saved file.
- Re-implement ticket/hierarchy creation — defer to `/m-story-breakdown` / `/m-pm-ticket`.
- Silently drop a not-Done ticket when closing a sprint/iteration — always route carry-over.
- Claim a sprint was started/completed via the ticket API — surface the manual board step.
- Hardcode one tenant's project key / components / field ids in this file — discover them at
  runtime; an optional `config.json` may override.
- Put Jira-only or ADO-only tool names in this file — they live in `m-board/providers/<provider>.md`.
