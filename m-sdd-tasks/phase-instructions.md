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
