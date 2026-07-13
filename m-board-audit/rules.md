# Ways of Working — rules this audit enforces

The audit checks in `SKILL.md` map 1:1 to these rules. Vocabulary is provider-neutral: a *ticket*
is a Jira issue or an ADO work item; a *sprint* is a Jira sprint or an ADO iteration; a
*component* is a Jira component or an ADO area path.

## Core model

- **Backlog is the only parking lot.** Nothing is pre-assigned to far-future named sprints.
- **At most 1 active + 1 planned sprint per board** (`sprintPolicy`). No sprints created months ahead.
- **Sprints are 2-week commitments, not folders for "things due later."** A theme is an epic, not a sprint.
- A ticket enters a sprint **only at sprint planning**, pulled top-down from the ranked backlog by capacity.

## Where timing/meaning lives (fields, not sprint names)

| Field | Question it answers |
|---|---|
| **Release version** (fix version / release tag) | Which release / by when (the deadline anchor), per your `fixVersionScheme`. |
| **Component / area path** | Which module of the product (routing, reporting, ownership). |
| **Platform/surface field** (if the project has one) | Which surface — e.g. mobile / web / backend (a bug can hit several). |
| **Priority + backlog rank** | How urgent / what order. |
| **Epic / parent link** | Which big theme. Epics never enter a sprint. |
| **Due date** | Hard external deadline (optional, for time-bound items). |

Labels/tags are **not** a substitute for a component or platform field — migrate platform- or
module-named labels to the proper fields.

## Hierarchy

- **Epic** — large theme, spans many sprints, never in a sprint.
- **Story** — one shippable slice of user value, fits one 2-week sprint. The unit pushed into sprints.
- **Subtask** — internal engineering step inside a story.

Sizing test: fits one sprint → story; spans many / is a theme → epic; internal step → subtask.

## Smells the audit flags

- A sprint marked active whose end date has passed (zombie — close it).
- More than `maxActive + maxPlanned` sprints existing at once.
- Future sprints named like themes ("Prioritized fixes", "Performance overhaul") → really epics.
- High-priority tickets parked in **inactive** future sprints → invisible to devs.
- Tickets with no release version, no component/area path, or no epic/parent link.
- Done tickets left sitting in the active sprint.
- Not-started tickets untouched longer than `staleDays`.

## Closing a sprint safely

Split tickets by `statusBuckets`. `done` → drops off on close. `todo` + `inProgress` →
**carry-over**: enumerate and move to backlog or the active sprint before completing the sprint.
Never let an unfinished ticket vanish with a closed sprint.
