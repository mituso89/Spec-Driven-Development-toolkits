---
name: m-sdd-tasks
description: "SDD phase 5 — normalize the plan's steps into an ordered specs/<id>/tasks.md checklist. Routed by m-sdd."
---

# SDD — Tasks

> **TL;DR** — Gate on an **approved** plan (0) → extract the plan's checkbox tasks into `specs/<id>/tasks.md` with stable IDs (1) → mark done & route (2). Read `<skills-root>/m-sdd/_shared.md` first.

**Pipeline:** plan → **tasks** → analyze.

## Phase 0 — Preflight & gate
- Read `_shared.md`.
- `source <skills-root>/m-sdd/sdd-lib.sh; root="$(pwd)"; id="$(sdd_active_feature "$root")"`
- `sdd_require "$root" "$id" plan "approved"` — the plan must be human-approved (not merely drafted) before it is broken into tasks.

## Phase 1 — Derive tasks.md
- `sdd_set_phase "$root" "$id" tasks in_progress`
- Read `specs/$id/plan.md`. `m-writing-plans` already emits bite-sized `- [ ]` steps; collect them into an ordered checklist in `specs/$id/tasks.md` (start from `.sdd/templates/tasks-template.md`). If the plan has no `- [ ]` steps, derive the tasks from its file-structure and Testing Strategy sections instead — and tell the user you did so.
- Assign stable IDs `T001, T002, …` in dependency order. Keep each task independently testable. Do not invent work not in the plan.
- **Traceability + tests:** tag each task with the user-story / success-criterion IDs
  it serves (`[US#]`, `[SC-###]`). Carry the plan's Testing Strategy into concrete
  **test tasks** labelled the same way, so every story and SC-### has a verifying task.
  UI test tasks name the `design/<screen>` they accept against. Whether missing
  coverage is *blocking* is the constitution's call (default: expected, not blocking);
  do not invent tests the plan's strategy didn't call for.
- **Acceptance links:** read `specs/$id/acceptance.json` (schema: `<skills-root>/m-sdd/acceptance-schema.md`). Tag each task with the plan phase it belongs to and the criterion IDs it helps satisfy, e.g. `[PH1][AC-1.2]`, and keep tasks grouped under one `## PH<n> - <outcome>` heading per phase, in phase order. Every criterion must be served by ≥1 task; a task that serves no criterion still names its phase.
- **Single source of truth:** once `tasks.md` exists, *it* is the canonical execution checklist — `m-sdd-implement` ticks boxes here, not in `plan.md`. To avoid two drifting copies, replace `plan.md`'s `## Tasks` body with a one-line pointer: `See ./tasks.md (canonical).`

## Phase 2 — Record & route
- **Self-check before marking done:** verify every `US#` and `SC-###` from `spec.md` appears on ≥1 task, every criterion ID in `acceptance.json` appears on ≥1 task, and every task names a phase; fix or flag any gap first. If `acceptance.json` is missing, stop and send the user back to `m-sdd-plan` to write it.
- `sdd_set_phase "$root" "$id" tasks done`; route to `m-sdd-analyze` (then `m-sdd-implement`).
