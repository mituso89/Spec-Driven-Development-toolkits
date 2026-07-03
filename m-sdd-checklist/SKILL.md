---
name: m-sdd-checklist
description: "SDD optional quality gate — per-domain requirement-quality checklists ('unit tests for English') that test the spec's wording, not the implementation. Writes specs/<id>/checklists/<domain>.md. Triggers: sdd checklist, spec checklist, requirements quality, unit tests for english, requirement checklist, spec quality check, checklist the spec."
---

# SDD — Checklist (optional, untracked)

> **TL;DR** — Scope domains with the user (1) → generate `specs/<id>/checklists/<domain>.md` testing requirement QUALITY, never implementation (2) → walk failures back into the spec (3). Read `~/.config/devin/skills/m-sdd/_shared.md` first. Like `m-sdd-knowledge`, this is **not a tracked phase** — it never blocks the pipeline and writes no state.

Checklists are unit tests for English: they probe whether the spec's requirements
are complete, clear, consistent, measurable, and covered — never whether the code
works. Best run after `specify` (before or after approval); re-run any time the
spec changes. `m-sdd-analyze` checks artifacts against *each other*; this skill
checks the spec against *itself*.

## Phase 0 — Preflight
- Read `~/.config/devin/skills/m-sdd/_shared.md`. Load `.sdd/constitution.md` and `.sdd/knowledge.md` when present.
- `source ~/.config/devin/skills/m-sdd/sdd-lib.sh; root="$(pwd)"; id="$(sdd_active_feature "$root")"`
- Require a spec to test: `test -s "$root/specs/$id/spec.md"` — if missing, stop and route to `m-sdd-specify`.

## Phase 1 — Scope
Ask the user 1–3 questions (never more than 5) to pick the checklist **domains** —
e.g. `ux`, `security`, `api`, `data`, `performance`, `a11y`. Propose the 2–3 domains
the spec's content obviously implies as the default. One file per domain.

## Phase 2 — Generate
- Start from `.sdd/templates/checklist-template.md`; write `specs/$id/checklists/<domain>.md`.
- Items are `- [ ] CHK###`, numbered from CHK001, **append-only across re-runs** —
  never renumber or delete; strike resolved items (`~~CHK00X~~`).
- Every item tests the spec's WORDING, not behavior:
  - Wrong: "Verify the button displays correctly" (implementation test).
  - Right: "Is 'prominent display' quantified with specific sizing? [Ambiguity §3.2]".
  - Never pair verify/test/confirm with runtime behavior.
- **≥80% of items** must cite a spec section (`§`) or carry one of
  `[Gap]` `[Ambiguity]` `[Conflict]` `[Assumption]`.
- Cover the quality axes: completeness, clarity, consistency (incl. against the
  constitution), measurability, coverage, unstated assumptions.

## Phase 3 — Walk & route
- Walk the unchecked items with the user. Fixes belong in the **spec**, not the checklist:
  - spec not yet `approved` → edit `specs/$id/spec.md` directly;
  - spec already `approved` → route to `m-sdd-clarify` (it resets approval
    correctly — never edit an approved spec in place).
- Writes no state (untracked). Route onward via `sdd_status "$root"`.
