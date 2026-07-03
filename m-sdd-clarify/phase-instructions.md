# SDD — Clarify Phase (Optional)

> Read `m-sdd/phase-instructions.md` (shared rules) first.

**Pipeline:** specify → clarify → plan. This phase is optional.

> **Clarify asks; it does not answer.** The user is the source of truth for every ambiguity. Codebase/knowledge facts may sharpen a question's framing; they never replace the user's answer.

## Preflight

- Read `.sdd/pipeline.md`. If `specify` is not `approved`, stop and tell the user to complete the specify phase first.
- Load `.sdd/constitution.md`. Load `.sdd/knowledge.md` if present — use its glossary/facts to frame sharper questions (framing only, never to auto-answer).
- If the user wants to skip: update `.sdd/pipeline.md`: set `clarify` row to `skipped`; route to plan phase.
- Update `.sdd/pipeline.md`: set `clarify` row to `in_progress`.

## Phase 1 — Ambiguity interview

- Read `specs/<id>/spec.md` and collect open points, prioritizing:
  - **Assumptions** — each is an informed guess from specify, awaiting confirmation.
  - **Edge Cases** answered with a `?`, and any vague/two-way-readable requirement.
  - Any surviving `[NEEDS CLARIFICATION]` markers.
  - If `specs/<id>/design/` exists, a mockup may already answer a UI ambiguity — use it to inform the question; the user still decides.
- Interview the user **one question at a time**; prefer multiple-choice. For each: state the ambiguity, give the spec's current assumption as the default, and let the user confirm or override.
- Stay requirement-first — questions are about user value, scope, and acceptance, never technology.

## Phase 2 — Record, re-approve & route

- Append the resolved Q&A under the `## Clarifications` heading in `specs/<id>/spec.md` (do not rewrite earlier sections).
- **Re-approval:** if any answer changed scope/requirements, reset `specify` to `in_progress` in `.sdd/pipeline.md`, show the user the updated spec, and on their OK set `specify` back to `approved`. Pure wording tweaks that change no requirement may keep the existing approval — state which you did.
- Update `.sdd/pipeline.md`: set `clarify` row to `done`.
- Route to plan phase.
