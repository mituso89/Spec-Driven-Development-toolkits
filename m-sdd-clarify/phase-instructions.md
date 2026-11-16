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
  - To frame a question with repo facts, use the read-only research helpers (`m-research-helpers` locator or analyzer) when available instead of reading whole files - this keeps the main context small. Their findings frame the question; they never answer it.
- Interview the user **one question at a time**; prefer multiple-choice. For each: state the ambiguity, give the spec's current assumption as the default, and let the user confirm or override.
- Stay requirement-first — questions are about user value, scope, and acceptance, never technology.
- **Be honest and critical.** When a requirement, an Assumption, or the user's answer looks weak (contradicts another requirement, can't be measured, adds scope with little value, or carries a real risk), say so plainly in one or two lines with the reason and a better option. Then let the user decide; never quietly accept a weak decision, and never override one.
- **Record what is NOT being built.** Every option the user rejects or defers, and every "not now", goes into the spec's `## Non-Goals (out of scope - not building)` list in plain words.
- **Keep asking while critical ambiguity remains.** A point is critical when different answers change scope, a user story, a requirement, or a success criterion. Do not write the Clarifications section or mark the phase done while one is open in this interview - there is no question limit for critical points (a point routed to the decision skill below counts as handled: it is tracked in `decisions.md`). Stop when what is left is only safe Assumptions.
- **Keep it short.** One short question per message, short options; accept short answers ("A", "yes", "skip").
- **Questions someone else owns.** When the person who must decide is not the user running the session (for example the ticket's requester, or the author of earlier work the spec conflicts with) and a project decision skill is installed (`m-sdd-decision`), route that question through it instead of guessing or asking the user to speak for them.
  It finds the owner, asks them, and records the question in `specs/<id>/decisions.md` with `Status: open`, `Blocks build: yes|no` and the default used meanwhile (normally the spec's current Assumption).
  The user's own questions stay in this interview as above.
  With no decision skill installed, ask the user as today and note who should confirm the answer.

## Phase 2 — Record, re-approve & route

- Append the resolved Q&A under the `## Clarifications` heading in `specs/<id>/spec.md` (do not rewrite earlier sections), one short line per answer. Add each rejected or deferred item to the `## Non-Goals (out of scope - not building)` list - the one earlier section clarify extends.
- **Re-approval:** if any answer changed scope/requirements, reset `specify` to `in_progress` in `.sdd/pipeline.md`, show the user the updated spec, and on their OK set `specify` back to `approved`. Pure wording tweaks that change no requirement may keep the existing approval — state which you did.
- Answers that arrive later through the decision skill come back here: fold them into `## Clarifications` with their `D-NNN` id and apply the same re-approval rule.
- Update `.sdd/pipeline.md`: set `clarify` row to `done`.
- Route to plan phase. If `specs/<id>/decisions.md` still has an open blocking entry, say so: plan will stop until it is answered.
