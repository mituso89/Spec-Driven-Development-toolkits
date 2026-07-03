---
name: m-sdd-analyze
description: "SDD phase 6 (optional gate) — cross-check constitution, spec, plan, and tasks for consistency and coverage before implementation; writes specs/<id>/analysis.md. Triggers: sdd analyze, consistency check sdd, validate spec plan tasks, sdd gate, pre-implementation review."
---

# SDD — Analyze

> **TL;DR** — Gate on completed tasks (0) → cross-check the four artifacts against each other and the constitution (1) → write `analysis.md`, mark done or block, route (2). Read `~/.config/devin/skills/m-sdd/_shared.md` first.

**Pipeline:** tasks → **analyze** → implement. Optional but recommended.

## Phase 0 — Preflight & gate
- Read `_shared.md`; load `.sdd/constitution.md`.
- `source ~/.config/devin/skills/m-sdd/sdd-lib.sh; root="$(pwd)"; id="$(sdd_active_feature "$root")"`
- `sdd_require "$root" "$id" tasks "done"`.
- Borrow the rigor of `m-requesting-code-review` for the cross-checks below; this phase does not delegate.

## Phase 1 — Cross-artifact analysis
- `sdd_set_phase "$root" "$id" analyze in_progress`
- Compare, and record findings in `specs/$id/analysis.md`:
  - **Coverage:** every spec requirement maps to ≥1 task; flag uncovered requirements.
  - **Test coverage:** every user story and **success criterion (SC-###)** has ≥1
    verifying test task (`[US#]`/`[SC-###]`). Severity follows the constitution's
    testing principle — **blocking** if it mandates coverage; otherwise a
    **non-blocking** note. If the constitution defines no testing principle, default to non-blocking (coverage expected, not gate-blocking).
  - **Design coverage:** if `specs/$id/design/` exists, every screen in
    `design/README.md` maps to a user story, and the plan covers every screen. Flag
    orphans both ways (non-blocking).
  - **Consistency:** plan/tasks don't contradict the spec; names/types used consistently.
  - **Constitution:** no artifact violates `.sdd/constitution.md` (guardrails, conventions).
  - **Scope:** still a single implementable unit (else recommend decomposition).
- Classify each finding `blocking` or `non-blocking`.

> Optional companions: before recording the verdict, run `m-security-and-hardening` to check for security gaps and `m-performance-optimization` to check for performance regressions. Findings from either feed into this phase's analysis.md as non-blocking notes unless the constitution mandates otherwise.

## Phase 2 — Record & route
- If any `blocking` findings: leave `analyze` `in_progress`, report them, and send the user back to the relevant phase (`m-sdd-specify`/`m-sdd-plan`/`m-sdd-tasks`).
- If clean (or user accepts non-blocking): `sdd_set_phase "$root" "$id" analyze done`; route to `m-sdd-implement`. To skip entirely: `sdd_set_phase "$root" "$id" analyze skipped`.
