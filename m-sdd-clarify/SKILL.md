---
name: m-sdd-clarify
description: "SDD phase 3 (optional) — interview the user to resolve spec ambiguities, appending a Clarifications section to specs/<id>/spec.md. Routed by m-sdd."
---

# SDD — Clarify

> **TL;DR** — Gate on an approved spec (0) → run a **self-contained ambiguity interview** of the user (1) → append answers under `## Clarifications` in `spec.md` & mark done/skipped (2). Read `<skills-root>/m-sdd/_shared.md` first.

**Pipeline:** specify → **clarify** → plan. This phase is optional.

> **Clarify asks; it does not answer.** The user is the source of truth for every
> ambiguity. Do **not** delegate this phase to `m-ask` — m-ask's spine is to
> *answer* questions from the codebase (it's an advisor), the exact inversion of
> what clarify needs. Using it risks silently *auto-resolving* a requirement
> ambiguity from repo evidence when the human was supposed to decide it —
> bypassing the very sign-off this phase exists to capture. Codebase/knowledge
> facts may *sharpen a question's framing*; they never *replace the user's answer*.

## Phase 0 — Preflight & gate
- Read `_shared.md`; load constitution. Load `.sdd/knowledge.md` if present — its glossary/facts let you frame sharper, project-grounded questions (framing only — never to answer for the user).
- `source <skills-root>/m-sdd/sdd-lib.sh; root="$(pwd)"; id="$(sdd_active_feature "$root")"`
- `sdd_require "$root" "$id" specify "approved"` — stop if the spec isn't approved.
- If the user wants to skip: `sdd_set_phase "$root" "$id" clarify skipped` and route to `m-sdd-plan`.

## Phase 1 — Ambiguity interview (self-contained)
- `sdd_set_phase "$root" "$id" clarify in_progress`
- Read `specs/$id/spec.md` and collect its open points — prioritizing:
  - **Assumptions** — each is an informed guess from specify, awaiting confirmation.
  - **Edge Cases** answered with a `?`, and any vague/two-way-readable requirement.
  - Any surviving `[NEEDS CLARIFICATION]` markers (there shouldn't be — specify zeroes them — but resolve any that slipped through).
  - Before asking a question, check `specs/$id/design/` (if present): a mockup may
    already answer a UI ambiguity. Use it to *inform* the question; the user still
    decides (a design is PO input, not an auto-answer).
  - To frame a question with repo facts, dispatch the **m-research-helpers** locator or analyzer (when installed) and use their short results instead of reading whole files - this keeps the main context small. Their findings frame the question; they never answer it.
- Interview the user **one question at a time**; prefer multiple-choice over open-ended. For each: state the ambiguity, give the spec's current assumption (if any) as the default, and let the user confirm or override.
  - **You ask — the user decides.** Never auto-answer an ambiguity from the codebase and move on: repo facts may *inform* how you phrase the question, but the answer is the user's.
  - Stay requirement-first — questions are about user value, scope, and acceptance, never technology or approach (that's `m-sdd-plan`).
  - **Be honest and critical.** When a requirement, an Assumption, or the user's answer looks weak (contradicts another requirement, can't be measured, adds scope with little value, or carries a real risk), say so plainly in one or two lines with the reason and a better option. Then let the user decide; never quietly accept a weak decision, and never override one.
  - **Record what is NOT being built.** Every option the user rejects or defers, and every "not now", goes into the spec's `## Non-Goals (out of scope - not building)` list in plain words, so plan and implement do not build it by accident.
  - **Keep asking while critical ambiguity remains.** A point is critical when different answers change scope, a user story, a requirement, or a success criterion. Do not write the Clarifications section or mark the phase done while one is open in this interview - there is no question limit for critical points (a point routed to the decision skill below counts as handled: it is tracked in `decisions.md`). Stop when what is left is only safe Assumptions; don't manufacture questions there.
  - **Keep it short.** One short question per message, short options; accept short answers ("A", "yes", "skip") and do not ask the user to write paragraphs.
- **Questions someone else owns.** When the person who must decide is not the user running the session (for example the ticket's requester, or the author of earlier work the spec conflicts with) and a project decision skill is installed (`m-sdd-decision`), route that question through it instead of guessing or asking the user to speak for them.
  It finds the owner, asks them, and records the question in `specs/$id/decisions.md` with `Status: open`, `Blocks build: yes|no` and the default used meanwhile (normally the spec's current Assumption).
  The user's own questions stay in this interview as above.
  With no decision skill installed, ask the user as today and note who should confirm the answer.

## Phase 2 — Record, re-approve & route
- Append the resolved Q&A under the `## Clarifications` heading in `specs/$id/spec.md` (do not rewrite earlier sections), one short line per answer. Add each rejected or deferred item to the `## Non-Goals (out of scope - not building)` list - the one earlier section clarify extends.
- **Re-approval gate:** clarify mutates an already-`approved` spec, so its approval is now stale. If any answer changed scope/requirements, reset and re-confirm: `sdd_set_phase "$root" "$id" specify in_progress`, show the user the updated spec, and on their OK `sdd_set_phase "$root" "$id" specify approved`. Pure wording tweaks that change no requirement may keep the existing approval — say which you did.
- Answers that arrive later through the decision skill come back here: fold them into `## Clarifications` with their `D-NNN` id and apply the same re-approval gate.
- `sdd_set_phase "$root" "$id" clarify done`; route to `m-sdd-plan` (which `sdd_require`s `specify approved`). If `decisions.md` still has an open blocking entry, say so: plan will stop until it is answered.
