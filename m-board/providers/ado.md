# Provider mapping — Azure DevOps (ADO)

**Discovery-first.** ADO reaches a session via Microsoft's official **azure-devops-mcp** server (commonly prefixed `mcp__azure-devops__*`, but the server name varies per install). The names below are **patterns to verify via ToolSearch, not guaranteed names** — the server renames tools between releases. Never call a name you haven't confirmed exists in this session.

## Tool-name patterns (verify every one via ToolSearch)

Work-item tools are commonly prefixed `wit_*`; project/team tools `core_*`; sprint/board tools `work_*`.

| Operation | Likely pattern (ToolSearch hint) |
|---|---|
| Read work item(s) | `wit_get_work_item`, `wit_get_work_items_batch_by_ids` — search "work item get" |
| Create work item | `wit_create_work_item` — search "work item create" |
| Update fields / state | `wit_update_work_item`, `wit_update_work_items_batch` — search "work item update" |
| Query (WIQL) | `wit_get_work_items_for_iteration`, WIQL query tools — search "wiql" |
| Link parent/child | `wit_work_items_link`, `wit_add_child_work_items` — search "work item link" |
| Comments | `wit_add_work_item_comment`, `wit_list_work_item_comments` — search "work item comment" |
| Type & state metadata | work-item-type tools — search "work item type" |
| Iterations (sprints) | `work_list_team_iterations` — search "iteration" |
| Projects / teams | `core_list_projects`, `core_list_project_teams` — search "project list" |

## Org & project — from config or asking, never hardcoded

The organization URL (`https://dev.azure.com/<org>`) and project name come from the user's gitignored `config.json` or from asking the user — **never from shipped files**. Most azure-devops-mcp tools take `project` as a parameter; resolve it once (confirm against the projects-list tool) and reuse for the run.

## Query language — WIQL

Searches use WIQL, SQL-like over work items:

```
SELECT [System.Id], [System.Title], [System.State]
FROM WorkItems
WHERE [System.TeamProject] = @project AND [System.WorkItemType] = 'User Story'
ORDER BY [System.ChangedDate] DESC
```

WIQL returns ids/refs — fetch full fields with a batch-get afterwards, passing a compact field list.

## Work item types — depend on the process template

| Neutral | Agile process | Scrum process | Basic process |
|---|---|---|---|
| epic | Epic | Epic | Epic |
| story | User Story | **Product Backlog Item** | Issue |
| subtask | Task | Task | Task |

Discover the project's actual types via work-item-type metadata before creating — never assume the Agile template. (Custom inherited processes rename types too.)

## States, not transitions

ADO sets `System.State` directly — there is no transition API. But **legal states vary per work item type and per process template** (e.g. New/Active/Resolved/Closed in Agile vs New/Approved/Committed/Done in Scrum, plus custom states). Discover the allowed states from the work item type's metadata before writing one; never assume a state name exists.

## Field mapping

| Neutral | ADO field |
|---|---|
| component | Area path — `System.AreaPath` |
| sprint | Iteration — `System.IterationPath` |
| title / description | `System.Title` / `System.Description` (HTML, not Markdown) |
| acceptance criteria | `Microsoft.VSTS.Common.AcceptanceCriteria` (Agile/Scrum) |
| labels | Tags — `System.Tags` (semicolon-separated) |
| parent linkage | Hierarchy link (`System.LinkTypes.Hierarchy-Reverse` = parent), or a child-add tool |

Area paths and iterations are per-project trees — discover valid values (classification-node / iteration tools) rather than inventing paths.
