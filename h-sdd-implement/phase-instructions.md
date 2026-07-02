# SDD — Implement Phase

> Read `h-sdd/phase-instructions.md` (shared rules) first.

**Pipeline:** analyze → implement → issues

## Preflight & gate

- Read `.sdd/pipeline.md`. If `tasks` is not `done`, stop.
- Read `.sdd/pipeline.md`. If `analyze` is not `done` or `skipped`, stop — never implement on a still-pending/in-progress consistency gate.
- Load `.sdd/constitution.md`.
- Load the structural grounding source if present (`.sdd/repo-map.md` or the code index named in `.sdd/knowledge.md`).
- **Human GO gate — the point of no return into code (load-bearing).** Before writing any code: summarize what will be built (the `tasks.md` list), the target branch, and any open analyze findings the user must own; then get the user's explicit "go". If not confirmed, stop. Do NOT proceed autonomously past this point.
- Optional companion: if implementation hits unexpected failures or test breakages, use the debugging-and-error-recovery skill for structured root-cause triage before retrying.

## Phase 1 — Execute

- Update `.sdd/pipeline.md`: set `implement` row to `in_progress`.
- Create an isolated feature branch for the work.
- Execute `specs/<id>/plan.md` and `specs/<id>/tasks.md` task by task, ticking `- [ ]` boxes in `tasks.md` as tasks complete. Feed the structural grounding (repo map or code index) as reuse context to each task so existing symbols/conventions are reused.

## Phase 2 — Finish, record & route

- Verify tests pass. Prepare for merge/PR.
- Update `.sdd/pipeline.md`: set `implement` row to `done`.
- Route: offer the issues phase if the team tracks work in Jira; otherwise the pipeline is complete.
