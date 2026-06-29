---
name: h-sdd-constitution
description: "SDD phase 1 — establish project principles, conventions, and guardrails that gate every later phase. Writes .sdd/constitution.md. Triggers: sdd constitution, project constitution, sdd principles, define guardrails, project conventions doc, establish standards."
---

# SDD — Constitution

> **TL;DR** — Discover existing conventions (1) → elicit/derive principles (2) → write `.sdd/constitution.md` (3) → mark phase done & route (4). Read `~/.config/devin/skills/h-sdd/_shared.md` first.

The constitution gates all downstream phases. It is project-level (one per project), not per-feature.

## Phase 0 — Preflight
- Read `~/.config/devin/skills/h-sdd/_shared.md`.
- `source ~/.config/devin/skills/h-sdd/sdd-lib.sh; root="$(pwd)"`; ensure scaffold: `sdd_scaffold "$root"`.
- **Discover:** scan the project for existing standards — `AGENTS.md`, `CLAUDE.md`, `README`, `CONTRIBUTING`, lint/format config, existing `docs/` conventions. Reuse them; do not invent rules that contradict the repo.

## Phase 1 — Draft
- Start from `.sdd/templates/constitution-template.md`.
- Fill **Principles, Conventions, Guardrails, Decision rules** from what you discovered. Ask the user only for gaps you cannot infer (one question at a time).
- Among the Principles, explicitly settle the **testing policy** (mandatory vs.
  expected coverage) — `h-sdd-tasks`/`h-sdd-analyze` read it to decide whether a
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
- If there is an active feature, route to `h-sdd-specify`; otherwise tell the user
  to create one via the **h-sdd** skill (`new "<feature>"`).
