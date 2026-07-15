---
name: m-sdd-specify
description: "SDD phase 2 — requirement-capture interview producing an approved, PO-readable spec (what/why, no tech) at specs/<id>/spec.md. Routed by m-sdd."
---

# SDD — Specify

> **TL;DR** — Preflight + ensure a feature exists (0) → run a **convergent requirement-capture interview** under the **requirement-first contract** below, filling `specs/<id>/spec.md` (1) → self-validate with a requirements checklist, ≤3 iterations (1.5) → resolve ≤3 `[NEEDS CLARIFICATION]` markers as sequential questions, get approval & mark `specify approved` (2). Read `<skills-root>/m-sdd/_shared.md` first.

**Pipeline:** constitution → **specify** → clarify.

> **Specify converges; it does not brainstorm.** This phase *captures* requirements
> into a reviewable contract — it is not divergent ideation, and it does not propose
> solutions, architectures, or approaches (that's `m-sdd-plan`). If the user still
> needs to *explore* the problem or weigh options before committing to requirements,
> that's an upstream activity: point them at **m-ask** (design-first / brainstorm
> mode) first, then return here to specify. Do **not** delegate this phase to
> `m-brainstorming` — its solution-oriented spine (propose approaches → design
> architecture → hand off to plans) fights the requirement-first contract.

## The requirement-first contract (non-negotiable)

The spec is written **for business stakeholders (PO/PM), not developers**. It
describes **WHAT users need and WHY** — never HOW.

- **Banned from spec.md** (they belong in `plan.md`, phase `m-sdd-plan`): tech
  stack, languages, frameworks, APIs/endpoints, database or schema design, code
  structure, library choices. If the user's input contains these, capture the
  *requirement behind them* and note the technology preference under
  **Assumptions** (the plan phase will honor it).
- **User stories are prioritized (P1/P2/P3) and independently testable** — each
  must be a viable slice on its own, with **Given/When/Then** acceptance scenarios.
- **Functional requirements** are testable "System MUST …" statements in
  business terms; **success criteria** are measurable and technology-agnostic.
- **Don't interrogate — decide.** Make informed guesses and record them under
  **Assumptions**. Only for decisions that genuinely change scope, insert at
  most **3** `[NEEDS CLARIFICATION: <specific question>]` markers.

## Phase 0 — Preflight
- Read `_shared.md`; load constitution (`.sdd/constitution.md`). If absent, warn and offer `m-sdd-constitution`.
- Load `.sdd/knowledge.md` if present (project facts/glossary/pointers) to ground the spec; if absent, note it and suggest `m-sdd-knowledge` (non-blocking).
- `source <skills-root>/m-sdd/sdd-lib.sh; root="$(pwd)"; sdd_scaffold "$root"` (idempotent — makes cold-starting here on a fresh repo safe), then `id="$(sdd_active_feature "$root")"`.
- If `id` is empty: ask the feature name, then `id="$(sdd_create_feature "$root" "<name>")"`.

## Phase 1 — Requirement-capture interview (self-contained)
- `sdd_set_phase "$root" "$id" specify in_progress`
- **Explore context first** — skim the files, recent commits, and any `.sdd/knowledge.md` glossary/facts so the spec is grounded in this project, not generic.
- **Visual design (optional, read-only).** If the PO already designed UI elsewhere
  (e.g. in an AI chat tool), tell them they can drop the HTML into
  `specs/$id/design/` — it becomes the feature's visual reference.
  - If `specs/$id/design/` holds HTML but no `README.md`, **offer to generate the
    index** from `.sdd/templates/design-readme-template.md`: ask the PO only which
    user story each screen serves, then write the table yourself.
  - When an indexed design exists, add the optional **Visual reference** line to the
    matching user stories (per the spec template). The spec stays requirement-first:
    reference the mockup as *what done looks like*, never copy tech detail from it.
  - Never author or modify the mockups — they are PO ground-truth.
- Open `.sdd/templates/spec-template.md` and fill **every** section into `specs/$id/spec.md` — Problem & Goal, Non-Goals, User Stories (prioritized, Given/When/Then), Functional Requirements, Key Entities, Success Criteria, Assumptions, Edge Cases. Leave `## Clarifications` empty (it's `m-sdd-clarify`'s).
- **Interview to converge, not to interrogate.** Ask questions **only** where the answer changes *scope* (what's in/out, who the user is, what "done" means). For everything else, make an informed guess and record it under **Assumptions** — don't ask.
  - One question at a time; prefer multiple-choice over open-ended.
  - This is a *requirement* funnel: every question is about user value, scope, or acceptance — **never** about technology, approach, or design. If the user volunteers a tech preference, capture the requirement behind it and note the preference under Assumptions (the plan phase honors it).
  - Decisions that genuinely change scope and that you *can't* responsibly guess become at most **3** `[NEEDS CLARIFICATION: <question>]` markers (resolved in Phase 2) — not interview questions now.
- **Scope check:** if the idea spans multiple independent subsystems, say so and help split it — each piece gets its own feature (`sdd_create_feature`) and its own spec. Don't specify a tangle as one feature.
- **Terminal state: the spec file.** Do NOT propose a solution, write a plan, or invoke any implementation/planning skill. Planning is a separate phase (`m-sdd-plan`). Return control here once the spec is written.
- Ensure the spec respects the constitution.

## Phase 1.5 — Self-validate (requirements checklist)
Before showing the spec for approval, test its *wording* (spec-kit parity:
auto `checklists/requirements.md`):
- Generate `specs/$id/checklists/requirements.md`: read
  `<skills-root>/m-sdd-checklist/SKILL.md` Phase 2 and apply its rules
  (domain = `requirements`; CHK### items; ≥80% cite `§` or carry
  `[Gap]`/`[Ambiguity]`/`[Conflict]`/`[Assumption]`): no banned implementation
  detail, every story has acceptance scenarios, requirements testable, success
  criteria measurable, edge cases present, ≤3 clarification markers.
- Fix what the checklist catches by editing the spec, re-check — **at most 3
  iterations**, then proceed regardless (note remaining items to the user).

## Phase 2 — Clarify markers, approve & route
- If the spec carries `[NEEDS CLARIFICATION]` markers, present them **one at a
  time as sequential questions**; replace each marker
  with the answer. Max 3 — if more emerged, downgrade the least scope-critical
  to Assumptions. Before approval, verify none survive (not even in comments):
  `grep -c 'NEEDS CLARIFICATION' "specs/$id/spec.md"` must print 0.
- Present the spec. After the user approves: `sdd_set_phase "$root" "$id" specify approved`.
- Route: suggest `m-sdd-clarify` (optional, for deeper ambiguity sweeps) or
  `m-sdd-plan`; mention `m-sdd-checklist` for extra domains (ux, security, …).
  Print `Next: $(sdd_get_next "$root" "$id")`.
