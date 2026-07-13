---
name: m-board
description: "Shared board-provider layer — detect whether this session talks to Jira or Azure DevOps (ADO), load the matching provider mapping (tool names, query language, types, states), and record the choice in the calling skill's config.json. Board-facing skills delegate their provider detection here and stay platform-neutral. Triggers: which board provider, board setup, connect jira, connect ado, azure devops setup, board provider."
---

# Board Provider Layer (Jira / Azure DevOps)

> **TL;DR** — Detect the provider (config → tool discovery → ask once) (1) → read `providers/<provider>.md` for concrete tool names, query language, and type/field/state mapping (2) → on user confirmation, record the choice in the calling skill's `config.json` (3). Workflow skills stay platform-neutral; everything provider-specific lives here.

This skill is the shared adapter for every board-facing `m-*` skill (story breakdown, ticket authoring, board audits). It owns *which board* and *which tools*; the calling skill owns the workflow.

## Phase 1 — Detect the provider

Run these in order; stop at the first hit:

1. **Config** — the calling skill's `config.json` has `"provider": "jira" | "ado"` → use it.
2. **Tool discovery** — ToolSearch over the session's MCP tools:
   - Atlassian surface present (`searchJiraIssuesUsingJql`, `createJiraIssue`, other camelCase connector tools, or self-hosted `mcp__<server>__jira_*` tools) → **jira**.
   - ADO surface present (work-item tools such as `wit_*` from Microsoft's azure-devops-mcp, `mcp__azure-devops__*` prefixes, or tool names matching "work item" / "wiql") → **ado**.
3. **Ask** — both surfaces present, or neither → ask the user once which board to use; offer to record the answer (Phase 3).

Announce the detected provider and how it was determined (config / discovered / asked). If neither surface exists and the user has no board MCP to add, stop — board-facing skills cannot run without one.

## Phase 2 — Load the provider mapping

Read `providers/<provider>.md` (relative to this skill's folder) before calling any board tool:

- `providers/jira.md` — both Atlassian tool surfaces (remote connector camelCase vs self-hosted snake_case), cloudId resolution, JQL, Epic/Story/Sub-task tiers, transitions, components, sprint custom fields.
- `providers/ado.md` — azure-devops-mcp tool-name patterns, WIQL, Epic/User Story (or Product Backlog Item)/Task, states per process template, area paths, iterations.

Provider files are **discovery-first**: they list likely tool-name patterns as hints. Always verify the actual tool names present in this session via ToolSearch before calling — never treat a documented name as guaranteed.

## Phase 3 — Record the choice

If the provider came from discovery or asking (not from config), offer once: *"Record `"provider": "<provider>"` in `<calling-skill>/config.json` so detection is skipped next time?"* On an explicit yes, add the key to the calling skill's gitignored `config.json` (create it from that skill's `config.example.json` if absent). Never write config without confirmation.

## For skill authors

Board-facing skills must not hardcode a platform. Instead:

1. Make your skill's Phase −1: *"Provider detection — delegate to `m-board` (config → discovery → ask), then read `m-board/providers/<provider>.md` for concrete tool names."*
2. Write the workflow body in neutral vocabulary; only the provider files name real tools:

| Neutral term | Jira | ADO |
|---|---|---|
| ticket | issue | work item |
| epic / story / subtask | Epic / Story / Sub-task | Epic / User Story / Task |
| sprint | sprint | iteration |
| query | JQL | WIQL |
| component | component | area path |
| status transition | transition | state change |
| board | board | board/backlog |

3. Tenant values (project keys, org URLs, cloud ids, board ids, field ids) come from the user's gitignored `config.json` or runtime discovery — never from shipped files. `config.example.json` ships placeholders only (e.g. `"PROJ"`, `"you@example.com"`).

## Never

- Hardcode tenant values in any shipped file — cloud ids, org URLs, project keys, board ids, customfield ids, real names/emails, real ticket keys.
- Assume a provider without running the Phase 1 detection order.
- Skip ToolSearch verification of tool names — provider files list patterns, not guarantees.
- Assume a workflow: transitions, states, types, and field ids are discovered at runtime, per provider file.
- Write to a `config.json` without explicit user confirmation.
