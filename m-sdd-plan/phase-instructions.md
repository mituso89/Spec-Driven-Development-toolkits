# SDD — Plan Phase

> Read `m-sdd/phase-instructions.md` (shared rules) first.

**Pipeline:** clarify → plan → tasks

## Preflight

- Read `.sdd/pipeline.md`. If `specify` is not `approved`, stop and tell the user to complete the specify phase first.
- Load `.sdd/constitution.md` — the plan's tech choices must respect it.
- **Open decisions gate.** If `specs/<id>/decisions.md` exists, read every `## D-NNN` entry.
  - Any entry with `Status: open` and `Blocks build: yes` -> stop. List each one (id, question, owner, ticket link) and tell the user the plan waits for those answers. Do not plan around a guessed answer.
  - Entries with `Status: open` and `Blocks build: no` -> continue on their `Default if no answer:`. List each default to the user now, and record them in the plan as assumptions to revisit.
  - `Status: answered` entries are inputs: the plan must follow them.
- Load `.sdd/knowledge.md`'s `Structural grounding` pointer if present (repo map or code index) — use it to base file/architecture choices on what already exists.
- Update `.sdd/pipeline.md`: set `plan` row to `in_progress`.

## Phase 1 — Technical plan

**Research with the read-only helpers** (the research-helpers skill, `m-research-helpers`, when installed): dispatch the locator to find the files and symbols the spec touches, the pattern finder for existing examples to copy, the analyzer for any flow the change must hook into, and the web researcher for external library/API facts. Use their short results (paths, line ranges, cited facts) instead of reading whole files - this keeps the main context small. Without the helpers, do the same searches inline and read only line ranges.

Using the writing-plans skill (or equivalent), produce `specs/<id>/plan.md` (start from `.sdd/templates/plan-template.md` if present):

- Read the spec from `specs/<id>/spec.md`. All tech decisions are made here; honor technology preferences parked under **Assumptions** in the spec.
- If `specs/<id>/design/` exists, read `design/README.md` and its screens as the visual implementation reference — derive components, layouts, and states from the mockups (read-only; do not edit them).
- **Fill the `## Testing Strategy` section:** map every user story and success criterion (SC-###) from the spec to how it will be verified, choose test levels, and state how to run tests. Whether coverage is mandatory or expected follows the constitution's testing principle.
- **Ground the plan in the structural layer:** use the repo map (if present) to base file/architecture choices on what already exists. Name the existing symbols/conventions to reuse. Prefer extending an existing module over creating a new one.
- **Group the tasks into phases** under `## Phases` (`PH1`, `PH2`, ...): each phase is a shippable slice with a one-line outcome, in build order.
- Do NOT offer an execution handoff at the end of the plan — implementation is a separate phase.

## Phase 2 — Companions, acceptance, approval gate & route

- If the spec implies them, create `specs/<id>/research.md`, `specs/<id>/data-model.md`, and contracts under `specs/<id>/contracts/`.
- **Write `specs/<id>/acceptance.json`** next to `plan.md`, following `m-sdd/acceptance-schema.md` (the single schema reference): one entry per plan phase, each with acceptance criteria whose steps are exact and checkable - commands to run (`automated`) or things to verify (`manual`), each with its pass condition. Every spec `US#`/`FR-###`/`SC-###` must appear in some criterion's `covers`. With `bash` and `jq`, check it with `sdd_validate_acceptance specs/<id>/acceptance.json specs/<id>/spec.md` after sourcing `m-sdd/sdd-lib.sh` from your installed skills folder, and fix every problem it prints; otherwise check it by hand against the schema.
- `acceptance.json` is part of the plan: present it with the plan at the approval gate, and editing it after approval resets plan approval the same way.
- Optional companions: if the spec involves an API or module boundary, use the api-and-interface-design skill while drafting the plan. If the spec involves user-facing UI, use the frontend-ui-engineering skill. Neither blocks the approval gate.
- **Human approval gate (load-bearing):** present the plan to the user and get explicit approval — architecture and task decomposition are cheap to fix on paper, expensive in code. Only on approval: update `.sdd/pipeline.md`: set `plan` row to `approved`.
- If the user requests changes, revise and re-present; leave the phase `in_progress`. Never advance to tasks/implement on an unapproved plan.
- Route to tasks phase.
