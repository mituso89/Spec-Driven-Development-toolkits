# Provider mapping — Jira (Atlassian)

**Discovery-first.** The tool names below are the *common* names per surface — verify each via ToolSearch before calling; server prefixes vary per install. If no Atlassian tools exist in the session, tell the user to add the Atlassian connector (or a self-hosted Atlassian MCP server) and stop.

## Two tool surfaces — detect which one you have

Jira reaches a session one of two ways. Detect by which tool names ToolSearch finds:

**A. Atlassian remote connector** (claude.ai connector — what most managed setups have): camelCase tools. Every Jira call on this surface needs a `cloudId` (see below).

| Operation | Tool (verify via ToolSearch) |
|---|---|
| List accessible sites → cloudId | `getAccessibleAtlassianResources` |
| List visible projects | `getVisibleJiraProjects` |
| Project's issue types | `getJiraProjectIssueTypesMetadata` |
| Fields per issue type | `getJiraIssueTypeMetaWithFields` |
| Search (JQL) | `searchJiraIssuesUsingJql` |
| Read issue | `getJiraIssue` |
| Create issue | `createJiraIssue` |
| Edit issue | `editJiraIssue` |
| List / apply transitions | `getTransitionsForJiraIssue` / `transitionJiraIssue` |
| Link issues | `createIssueLink` (types via `getIssueLinkTypes`) |
| Resolve a person → account id | `lookupJiraAccountId` |

`createJiraIssue` accepts Markdown descriptions (the connector converts — do not hand-build ADF).

**B. Self-hosted Atlassian MCP server**: snake_case tools prefixed with the server name — pattern `mcp__<server>__jira_*`, where `<server>` is commonly named `mcp-atlassian`. Typical tools: `jira_get_issue`, `jira_search`, `jira_create_issue`, `jira_update_issue`, `jira_transition_issue`, `jira_create_issue_link`, `jira_search_fields`, `jira_batch_create_issues`. The site is baked into the server config, so `cloudId` is implicit — skip cloudId resolution.

## cloudId resolution (surface A only)

Call `getAccessibleAtlassianResources` once at the start of the run and use the returned site `id` as `cloudId` on every subsequent call. More than one site returned → ask the user which. Never hardcode a cloudId or reuse one across sessions.

## Query language — JQL

All searches use JQL (e.g. `project = <KEY> AND statusCategory != Done ORDER BY rank`). Always pass a compact `fields` list (never `description` or `*all` in bulk queries) and aggregate results — raw issue dumps overflow tool token limits.

## Type tiers

| Neutral | Jira issue type |
|---|---|
| epic | `Epic` |
| story | `Story` |
| subtask | `Sub-task` (UI name; some create APIs expect `Subtask`, one word) |

Confirm the type actually exists in the target project via `getJiraProjectIssueTypesMetadata` (or the project create metadata on surface B) before creating — team-managed vs company-managed projects differ, and some projects rename or omit types. No match → ask the user; never invent a type.

## Status transitions

Jira moves issues via **transitions**, never direct status writes. Discover the legal moves for an issue with `getTransitionsForJiraIssue`, then apply one with `transitionJiraIssue`. Workflows vary per project and issue type — never assume transition ids or names.

## Components

`components` is a first-class Jira field. Valid values are per-project — discover them from the project's create/edit metadata (`allowedValues`); assigning a nonexistent component fails the write.

## Sprint & other custom fields

Sprint, Epic Link, and Story Points are **custom fields whose ids vary per tenant** (`customfield_100xx` on one site is a different id — or absent — on another). Discover ids at runtime: `jira_search_fields` on surface B, or read a sample issue with `expand=names` and match on `schema.custom` (e.g. `…gh-sprint`, `…gh-epic-link`). **Never hardcode a customfield id** in a skill, config example, or query. If a sprint/field id can't be resolved, create the issue without it and tell the user to set it in the Jira UI — never fail the create over it.
