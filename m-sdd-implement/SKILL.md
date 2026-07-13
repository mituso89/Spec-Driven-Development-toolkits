---
name: m-sdd-implement
description: "SDD phase 7 — the SDD adapter around the m-implement engine: gate on tasks+analyze, human GO, then delegate the implement→test→verify→review→finalize loop to m-implement, and record/route the SDD state. Triggers: sdd implement, execute sdd plan, build the feature sdd, run sdd tasks, implement sdd."
---

# SDD — Implement

> **TL;DR** — Gate on tasks + analyze, then a **human GO** (0) → delegate the whole execution loop to the **m-implement** engine over spec/plan/tasks (1) → record `done` & route (2). This skill is the **SDD adapter**; the execute→test→verify→review→finalize work lives in `m-implement` — don't duplicate it here. Read `<skills-root>/m-sdd/_shared.md` first.

**Pipeline:** analyze → **implement** → issues.

## Phase 0 — Preflight & gate
- Read `_shared.md`; load constitution (implementation must respect it).
- Load the **structural grounding** source (`.sdd/repo-map.md`, or the code MCP named in `.sdd/knowledge.md`'s `Structural grounding` line) — it is fed to implementers as reuse context in Phase 1 and named in the GO summary.
- `source <skills-root>/m-sdd/sdd-lib.sh; root="$(pwd)"; id="$(sdd_active_feature "$root")"`
- `sdd_require "$root" "$id" tasks "done"` — tasks must be derived.
- `sdd_require "$root" "$id" analyze "done,skipped"` — analyze must have run clean or been explicitly skipped; never implement on a still-`pending`/`in_progress` consistency gate.
- **Human GO gate — the point of no return into code (load-bearing).** Before writing any code: summarize what will be built (the `tasks.md` list), the target branch/worktree, and any open analyze findings the user must own; then get the user's explicit "go". If not confirmed, stop. Do NOT proceed autonomously past this point. **This is the single GO gate for the run** — the engine in Phase 1 is told it is already gated and must not ask again.

> Optional companion: if implementation hits unexpected failures or test breakages, run `m-debugging-and-error-recovery` for structured root-cause triage before retrying.

## Phase 1 — Delegate execution to the m-implement engine
- `sdd_set_phase "$root" "$id" implement in_progress`
- Invoke **m-implement** as the execution engine — do **not** re-implement its worktree/implement/test/verify/review/finalize steps here. Hand it, as the pre-assembled context pack:
  - **Business logic:** `specs/$id/spec.md` + `specs/$id/plan.md` + `specs/$id/tasks.md` (the source of truth — no board ticket needed; m-implement's ticket/test-plan steps no-op in SDD mode).
  - **Code quality:** `.sdd/constitution.md`.
  - **Project knowledge / reuse:** the structural grounding from Phase 0 (`.sdd/repo-map.md` or the code MCP) + `.sdd/knowledge.md`.
  - **Pre-gated flag:** GO was obtained in Phase 0 — m-implement must skip its own Phase 0 GO/ambiguity gate and start at implement.
- As tasks complete, update the `- [ ]` boxes in `tasks.md` (SDD bookkeeping the engine doesn't own).

## Phase 2 — Record & route
- The engine has already finished the branch (merge/PR/cleanup) and committed. Here just record SDD state and route.
- `sdd_set_phase "$root" "$id" implement done`.
- Route: offer `m-sdd-tasks-to-issues` if the team tracks work in a board; otherwise the pipeline is complete.

## Never
- Re-describe or duplicate the execute→test→verify→review→finalize loop here — it lives in **m-implement**; this skill only gates, sets SDD state, and routes.
- Add a second GO gate — Phase 0 holds the run's single gate; the engine is handed a pre-gated flag.
- Delegate with `analyze` still `pending`/`in_progress`, or before `tasks` is `done` — the Phase 0 `sdd_require` gates are load-bearing.
- Hand-edit `state.json` — always go through `sdd-lib.sh`.
