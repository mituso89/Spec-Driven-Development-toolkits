---
name: m-sdd-clarify
description: "SDD phase 3 (optional) — resolve ambiguities in the spec by interviewing the user, appending a Clarifications section to specs/<id>/spec.md. Triggers: sdd clarify, clarify spec, resolve ambiguities, sdd questions, tighten spec."
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
- Interview the user **one question at a time**; prefer multiple-choice over open-ended. For each: state the ambiguity, give the spec's current assumption (if any) as the default, and let the user confirm or override.
  - **You ask — the user decides.** Never auto-answer an ambiguity from the codebase and move on: repo facts may *inform* how you phrase the question, but the answer is the user's.
  - Stay requirement-first — questions are about user value, scope, and acceptance, never technology or approach (that's `m-sdd-plan`).
  - Keep it bounded: cover the points that actually affect scope; don't manufacture questions where the Assumption is already safe.

## Phase 2 — Record, re-approve & route
- Append the resolved Q&A under the `## Clarifications` heading in `specs/$id/spec.md` (do not rewrite earlier sections).
- **Re-approval gate:** clarify mutates an already-`approved` spec, so its approval is now stale. If any answer changed scope/requirements, reset and re-confirm: `sdd_set_phase "$root" "$id" specify in_progress`, show the user the updated spec, and on their OK `sdd_set_phase "$root" "$id" specify approved`. Pure wording tweaks that change no requirement may keep the existing approval — say which you did.
- `sdd_set_phase "$root" "$id" clarify done`; route to `m-sdd-plan` (which `sdd_require`s `specify approved`).
