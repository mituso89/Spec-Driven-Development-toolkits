# SDD — Plan Phase

> Read `h-sdd/phase-instructions.md` (shared rules) first.

**Pipeline:** clarify → plan → tasks

## Preflight

- Read `.sdd/pipeline.md`. If `specify` is not `approved`, stop and tell the user to complete the specify phase first.
- Load `.sdd/constitution.md` — the plan's tech choices must respect it.
- Load `.sdd/knowledge.md`'s `Structural grounding` pointer if present (repo map or code index) — use it to base file/architecture choices on what already exists.
- Update `.sdd/pipeline.md`: set `plan` row to `in_progress`.

## Phase 1 — Technical plan

Using the writing-plans skill (or equivalent), produce `specs/<id>/plan.md` (start from `.sdd/templates/plan-template.md` if present):

- Read the spec from `specs/<id>/spec.md`. All tech decisions are made here; honor technology preferences parked under **Assumptions** in the spec.
- If `specs/<id>/design/` exists, read `design/README.md` and its screens as the visual implementation reference — derive components, layouts, and states from the mockups (read-only; do not edit them).
- **Fill the `## Testing Strategy` section:** map every user story and success criterion (SC-###) from the spec to how it will be verified, choose test levels, and state how to run tests. Whether coverage is mandatory or expected follows the constitution's testing principle.
- **Ground the plan in the structural layer:** use the repo map (if present) to base file/architecture choices on what already exists. Name the existing symbols/conventions to reuse. Prefer extending an existing module over creating a new one.
- Do NOT offer an execution handoff at the end of the plan — implementation is a separate phase.

## Phase 2 — Companions, approval gate & route

- If the spec implies them, create `specs/<id>/research.md`, `specs/<id>/data-model.md`, and contracts under `specs/<id>/contracts/`.
- Optional companions: if the spec involves an API or module boundary, use the api-and-interface-design skill while drafting the plan. If the spec involves user-facing UI, use the frontend-ui-engineering skill. Neither blocks the approval gate.
- **Human approval gate (load-bearing):** present the plan to the user and get explicit approval — architecture and task decomposition are cheap to fix on paper, expensive in code. Only on approval: update `.sdd/pipeline.md`: set `plan` row to `approved`.
- If the user requests changes, revise and re-present; leave the phase `in_progress`. Never advance to tasks/implement on an unapproved plan.
- Route to tasks phase.
