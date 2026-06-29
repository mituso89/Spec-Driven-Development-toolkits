---
name: h-sdd-tasks
description: "SDD phase 5 — normalize the plan's bite-sized steps into an ordered specs/<id>/tasks.md checklist. Triggers: sdd tasks, generate tasks sdd, task breakdown sdd, tasks from plan, sdd task list."
---

# SDD — Tasks

> **TL;DR** — Gate on an **approved** plan (0) → extract the plan's checkbox tasks into `specs/<id>/tasks.md` with stable IDs (1) → mark done & route (2). Read `~/.config/devin/skills/h-sdd/_shared.md` first.

**Pipeline:** plan → **tasks** → analyze.

## Phase 0 — Preflight & gate
- Read `_shared.md`.
- `source ~/.config/devin/skills/h-sdd/sdd-lib.sh; root="$(pwd)"; id="$(sdd_active_feature "$root")"`
- `sdd_require "$root" "$id" plan "approved"` — the plan must be human-approved (not merely drafted) before it is broken into tasks.

## Phase 1 — Derive tasks.md
- `sdd_set_phase "$root" "$id" tasks in_progress`
- Read `specs/$id/plan.md`. `h-writing-plans` already emits bite-sized `- [ ]` steps; collect them into an ordered checklist in `specs/$id/tasks.md` (start from `.sdd/templates/tasks-template.md`).
- Assign stable IDs `T001, T002, …` in dependency order. Keep each task independently testable. Do not invent work not in the plan.
- **Traceability + tests:** tag each task with the user-story / success-criterion IDs
  it serves (`[US#]`, `[SC-###]`). Carry the plan's Testing Strategy into concrete
  **test tasks** labelled the same way, so every story and SC-### has a verifying task.
  UI test tasks name the `design/<screen>` they accept against. Whether missing
  coverage is *blocking* is the constitution's call (default: expected, not blocking);
  do not invent tests the plan's strategy didn't call for.
- **Single source of truth:** once `tasks.md` exists, *it* is the canonical execution checklist — `h-sdd-implement` ticks boxes here, not in `plan.md`. To avoid two drifting copies, replace `plan.md`'s `## Tasks` body with a one-line pointer: `See ./tasks.md (canonical).`

## Phase 2 — Record & route
- `sdd_set_phase "$root" "$id" tasks done`; route to `h-sdd-analyze` (then `h-sdd-implement`).
