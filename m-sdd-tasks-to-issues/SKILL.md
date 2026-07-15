---
name: m-sdd-tasks-to-issues
description: "SDD phase 8 (optional) — push the feature's tasks.md to the board as linked dev tickets via m-story-breakdown. Routed by m-sdd."
---

# SDD — Tasks → Issues

> **TL;DR** — Gate on tasks ready (0) → delegate to **m-story-breakdown** to create linked Jira tickets from `tasks.md` (1) → mark done/skipped (2). Read `<skills-root>/m-sdd/_shared.md` first.

**Pipeline:** **issues** (terminal, optional) — runs any time after tasks (typically after implement).

## Phase 0 — Preflight & gate
- Read `_shared.md`.
- `source <skills-root>/m-sdd/sdd-lib.sh; root="$(pwd)"; id="$(sdd_active_feature "$root")"`
- `sdd_require "$root" "$id" tasks "done"`. **By design this gates on tasks, not
  implement:** teams that plan in Jira may push tickets before (or instead of)
  building. Implement's status is irrelevant here.
- Delegate is **m-story-breakdown**. If Jira/Atlassian MCP isn't configured, tell the user and `sdd_set_phase "$root" "$id" issues skipped`.

## Phase 1 — Delegate to m-story-breakdown
- `sdd_set_phase "$root" "$id" issues in_progress`
- Feed the tasks from `specs/$id/tasks.md` (and the spec for context) to **m-story-breakdown**; let it create per-stack tickets linked to the parent story and return the URLs. Follow its own user-confirmation gates.
  - **No parent in Jira yet?** That's m-story-breakdown's native entry mode B — point it at the spec's `## User Stories` (each maps 1:1 to a Jira story: title → summary, as-a/I-want/so-that → goal, acceptance scenarios → AC) and it creates the parent (user-gated) before breaking down. It also assesses whether breakdown is warranted at all and types each child Story/Task/Subtask by intent — accept those recommendations.

## Phase 2 — Record
- On success: `sdd_set_phase "$root" "$id" issues done` and report the created ticket URLs.
- On partial ticket creation (some creates failed): report the issue keys that WERE created, leave the phase `in_progress`, and tell the user to re-run this skill (feeding it the already-created keys so nothing is duplicated).
