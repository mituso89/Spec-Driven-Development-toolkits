# SDD — Specify Phase

> Read `h-sdd/phase-instructions.md` (shared rules) first.

**Pipeline:** constitution → specify → clarify

## The requirement-first contract (non-negotiable)

The spec is written **for business stakeholders (PO/PM), not developers**. It describes **WHAT users need and WHY** — never HOW.

- **Banned from spec.md:** tech stack, languages, frameworks, APIs/endpoints, database or schema design, code structure, library choices. If the user's input contains these, capture the *requirement behind them* and note the technology preference under **Assumptions**.
- **User stories are prioritized (P1/P2/P3) and independently testable** — each must be a viable slice on its own, with **Given/When/Then** acceptance scenarios.
- **Functional requirements** are testable "System MUST …" statements in business terms; **success criteria** are measurable and technology-agnostic.
- **Don't interrogate — decide.** Make informed guesses and record them under **Assumptions**. Only for decisions that genuinely change scope, insert at most **3** `[NEEDS CLARIFICATION: <specific question>]` markers.

## Preflight

- Read `.sdd/pipeline.md`; note the active feature. If no active feature, ask the user for a feature name and add it under a new `## Feature: <name>` section.
- Load `.sdd/constitution.md` (warn and offer to run constitution phase if absent — non-blocking).
- Load `.sdd/knowledge.md` if present.
- Update `.sdd/pipeline.md`: set `specify` row to `in_progress`.

## Phase 1 — Requirement-capture interview

- **Explore context first** — skim the files, recent commits, and any `.sdd/knowledge.md` glossary/facts.
- **Visual design (optional, read-only).** If `specs/<id>/design/` holds files, offer to generate `design/README.md` indexing each screen to a user story. Reference mockups in user stories as *what done looks like*; never copy tech detail.
- Open `.sdd/templates/spec-template.md` (if present) and fill every section into `specs/<id>/spec.md` — Problem & Goal, Non-Goals, User Stories (prioritized, Given/When/Then), Functional Requirements, Key Entities, Success Criteria, Assumptions, Edge Cases.
- **Interview to converge, not to interrogate.** Ask questions only where the answer changes scope. One question at a time; prefer multiple-choice. Mark scope-critical unknowns as `[NEEDS CLARIFICATION: <question>]` (max 3).
- **Scope check:** if the idea spans multiple independent subsystems, help the user split it — each piece gets its own feature in `.sdd/pipeline.md`.

## Phase 1.5 — Self-validate

Before showing the spec for approval, verify:
- No banned implementation detail in the spec.
- Every story has Given/When/Then acceptance scenarios.
- All functional requirements are testable "System MUST …" statements.
- Success criteria are measurable.
- Edge cases are present.
- No more than 3 `[NEEDS CLARIFICATION]` markers.

Fix issues and re-check — at most 3 iterations, then proceed regardless (note remaining items to the user).

## Phase 2 — Clarify markers, approve & route

- If the spec carries `[NEEDS CLARIFICATION]` markers, present them one at a time; replace each marker with the answer. Verify none survive: search the spec for `NEEDS CLARIFICATION` — must return 0 matches before approval.
- Present the spec to the user. After explicit approval: update `.sdd/pipeline.md`: set `specify` row to `approved`.
- Route: suggest clarify phase (optional) or plan phase.
