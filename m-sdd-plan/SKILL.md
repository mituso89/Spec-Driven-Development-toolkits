---
name: m-sdd-plan
description: "SDD phase 4 — produce the technical implementation plan by delegating to the m-writing-plans skill, writing specs/<id>/plan.md (+ research/data-model/contracts). Triggers: sdd plan, write sdd plan, plan feature sdd, implementation plan sdd, technical plan."
---

# SDD — Plan

> **TL;DR** — Gate on an approved spec (0) → delegate to **m-writing-plans**, redirecting output to `specs/<id>/plan.md` (1) → add companion artifacts, **get human approval & mark `approved`**, route (2). Read `~/.config/devin/skills/m-sdd/_shared.md` first.

**Pipeline:** clarify → **plan** → tasks.

## Phase 0 — Preflight & gate
- Read `_shared.md`; load constitution (the plan's tech choices must respect it).
- Load the **structural grounding** if present: read `.sdd/knowledge.md`'s `Structural grounding` line → load `.sdd/repo-map.md` (generated), or use the named code MCP (`serena`/`codegraph`). This is the structural half of grounding (knowledge.md = curated facts); use it in Phase 1.
- `source ~/.config/devin/skills/m-sdd/sdd-lib.sh; root="$(pwd)"; id="$(sdd_active_feature "$root")"`
- `sdd_require "$root" "$id" specify "approved"` — no plan without an approved spec.

## Phase 1 — Delegate to m-writing-plans
- `sdd_set_phase "$root" "$id" plan in_progress`
- Invoke **m-writing-plans** with two overrides:
  1. Read the spec from `specs/$id/spec.md`; write the plan to `specs/$id/plan.md` (start from `.sdd/templates/plan-template.md`), NOT to `docs/plans/`. The spec is requirements-only (no HOW) — all tech decisions are made *here*; honor any technology preferences the spec parked under **Assumptions**. If `specs/$id/design/` exists, read `design/README.md` + its screens as the **visual implementation reference** — derive components, layouts, and states from the mockups (they are read-only; do not edit them).
  2. **Do NOT offer the execution handoff** at the end — implementation is the separate `m-sdd-implement` phase. Return control here.
  3. **Fill the `## Testing Strategy` section** of the plan: map every user story and **success criterion (SC-###)** from the spec to how it will be verified, choose test levels, and state how to run tests. Whether coverage is *mandatory* or merely *expected* follows the constitution's testing principle (default: expected, not blocking, if none is defined). Keep the spec unchanged — strategy lives here, the acceptance contract stays in the spec.
  4. **Ground the plan in the structural layer** (from Phase 0): use `.sdd/repo-map.md` (or the code MCP) to base file/architecture choices on what already exists, and **explicitly name the existing symbols/conventions to reuse** (factories, base classes, validators, route/registration patterns) instead of hand-rolling. Prefer extending an existing module over creating a new one; when new code is unavoidable, match the neighbors the map reveals. This makes the plan the carrier of grounding into implementation.

## Phase 2 — Companions, approval gate & route
- If the spec implies them, create `specs/$id/research.md`, `specs/$id/data-model.md`, and contracts under `specs/$id/contracts/`.
- **Human approval gate (load-bearing):** present the plan to the user and get explicit approval — architecture and task decomposition are cheap to fix on paper, expensive in code. Only on approval: `sdd_set_phase "$root" "$id" plan approved`.
- If the user requests changes, revise and re-present; leave the phase `in_progress` (do NOT mark `approved`). Never advance to tasks/implement on an unapproved plan.
- Route to `m-sdd-tasks`.

> Optional companions: if the spec involves an API or module boundary, run `m-api-and-interface-design` while drafting the plan. If the spec involves user-facing UI, run `m-frontend-ui-engineering`. Neither blocks the approval gate.
