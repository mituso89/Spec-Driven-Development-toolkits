---
name: m-sdd-constitution
description: "SDD phase 1 — establish project principles, conventions, and guardrails in .sdd/constitution.md. Invoked by name or routed by m-sdd."
---

# SDD — Constitution

> **TL;DR** — Discover existing conventions (0) → elicit/derive principles (1) → write `.sdd/constitution.md` & get approval (2) → route (3 — no marking step: status derives from the file). Read `<skills-root>/m-sdd/_shared.md` first.

The constitution is advisory context, not an enforced gate: every phase loads it and must respect it, and `m-sdd-analyze` checks all artifacts against it (see `_shared.md` Rule 2). It is project-level (one per project), not per-feature.

## Phase 0 — Preflight
- Read `<skills-root>/m-sdd/_shared.md`.
- `source <skills-root>/m-sdd/sdd-lib.sh; root="$(pwd)"`; ensure scaffold: `sdd_scaffold "$root"`.
- **Discover:** scan the project for existing standards — `AGENTS.md`, `CLAUDE.md`, `README`, `CONTRIBUTING`, lint/format config, existing `docs/` conventions. Reuse them; do not invent rules that contradict the repo.

## Phase 1 — Draft
- Start from `.sdd/templates/constitution-template.md`.
- Fill **Principles, Conventions, Guardrails, Decision rules** from what you discovered. Ask the user only for gaps you cannot infer (one question at a time).
- Among the Principles, explicitly settle the **testing policy** (mandatory vs.
  expected coverage) — `m-sdd-tasks`/`m-sdd-analyze` read it to decide whether a
  missing test is blocking. If the user has no preference, record "test coverage
  expected, not blocking" so analyze defaults soft.
- Keep it binding and specific — every line should be something a later phase can be checked against.

## Phase 2 — Write
- Save the filled document to `$root/.sdd/constitution.md`.
- Show the user the result and get explicit approval (this is a gate).

## Phase 3 — Record & route
- No marking step: constitution status **derives from the file** — once
  `$root/.sdd/constitution.md` is non-empty, every feature (existing and future)
  reads `constitution: done` automatically. To skip it project-wide instead:
  `sdd_set_phase "$root" "<any-id>" constitution skipped`.
- If there is an active feature, route to `m-sdd-specify`; otherwise tell the user
  to create one via the **m-sdd** skill (`new "<feature>"`).
