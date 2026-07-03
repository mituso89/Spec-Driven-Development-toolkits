# SDD — Analyze Phase (Optional, Recommended)

> Read `m-sdd/phase-instructions.md` (shared rules) first.

**Pipeline:** tasks → analyze → implement. Optional but recommended.

## Preflight

- Read `.sdd/pipeline.md`. If `tasks` is not `done`, stop.
- Load `.sdd/constitution.md`.
- Update `.sdd/pipeline.md`: set `analyze` row to `in_progress`.

## Phase 1 — Cross-artifact analysis

Compare, and record findings in `specs/<id>/analysis.md`:

- **Coverage:** every spec requirement maps to ≥1 task; flag uncovered requirements.
- **Test coverage:** every user story and success criterion (SC-###) has ≥1 verifying test task. Severity follows the constitution's testing principle — blocking if it mandates coverage; otherwise non-blocking. Default: non-blocking.
- **Design coverage:** if `specs/<id>/design/` exists, every screen in `design/README.md` maps to a user story, and the plan covers every screen. Flag orphans both ways (non-blocking).
- **Consistency:** plan/tasks don't contradict the spec; names/types used consistently.
- **Constitution:** no artifact violates `.sdd/constitution.md` (guardrails, conventions).
- **Scope:** still a single implementable unit (else recommend decomposition).
- Classify each finding `blocking` or `non-blocking`.
- Optional companions: before recording the verdict, use the security-and-hardening skill to check for security gaps and the performance-optimization skill to check for performance regressions. Findings feed into analysis.md as non-blocking notes unless the constitution mandates otherwise.

## Phase 2 — Record & route

- If any `blocking` findings: leave `analyze` `in_progress`, report them, and send the user back to the relevant phase (specify/plan/tasks).
- If clean (or user accepts non-blocking): update `.sdd/pipeline.md`: set `analyze` row to `done`; route to implement phase.
- To skip entirely: update `.sdd/pipeline.md`: set `analyze` row to `skipped`.
