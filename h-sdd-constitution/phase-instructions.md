# SDD — Constitution Phase

> Read `h-sdd/phase-instructions.md` (shared rules) first.

**Pipeline:** → constitution → specify

The constitution is project-level (one per project, not per feature). It gates all downstream phases. Read by every phase; enforced by the analyze phase.

## Preflight

- Read `.sdd/pipeline.md`; note the active feature.
- Check for an existing `.sdd/constitution.md` — if present and non-empty, the constitution is already done. Offer to review/update it instead of re-running.
- Create `.sdd/` and `specs/` directories if absent.
- **Discover existing conventions:** scan the project for `AGENTS.md`, `CLAUDE.md`, `README`, `CONTRIBUTING`, lint/format config, existing `docs/` conventions. Reuse them; do not invent rules that contradict the repo.

## Phase 1 — Draft

- Start from `.sdd/templates/constitution-template.md` (if present).
- Fill **Principles, Conventions, Guardrails, Decision rules** from what you discovered. Ask the user only for gaps you cannot infer — one question at a time.
- Explicitly settle the **testing policy** (mandatory vs. expected coverage). If the user has no preference, record "test coverage expected, not blocking".
- Keep it binding and specific — every line should be something a later phase can be checked against.

## Phase 2 — Write & approve

- Save the filled document to `.sdd/constitution.md`.
- Show the user the result and get explicit approval (this is a gate).
- Update `.sdd/pipeline.md`: set `constitution` row to `approved`.

## Phase 3 — Route

- If there is an active feature, route to the specify phase; otherwise tell the user to create one.
