---
name: m-sdd-implement
description: "SDD phase 7 — gate on tasks+analyze and a human GO, then delegate the build loop to m-implement and record SDD state. Routed by m-sdd."
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
- `sdd_validate_acceptance "specs/$id/acceptance.json" "specs/$id/spec.md"` must print `acceptance: ok` - without a valid acceptance file there is no definition of done; route back to `m-sdd-plan` to write or fix it.
- **Open decisions gate.** If `specs/$id/decisions.md` exists, re-read it now (answers can change after the plan): any `## D-NNN` entry with `Status: open` and `Blocks build: yes` -> stop and list it (id, question, owner, ticket link); no GO is asked while one is open. Entries with `Status: open` and `Blocks build: no` go into the GO summary with the default the build will use.
- **Human GO gate — the point of no return into code (load-bearing).** Before writing any code: summarize what will be built (the `tasks.md` list, grouped by acceptance phase), the target branch/worktree, the defaults used for open non-blocking decisions, and any open analyze findings the user must own; then get the user's explicit "go". If not confirmed, stop. Do NOT proceed autonomously past this point. **This is the single GO gate for the run** — the engine in Phase 1 is told it is already gated and must not ask again.

> Optional companion: if implementation hits unexpected failures or test breakages, run `m-debugging-and-error-recovery` for structured root-cause triage before retrying.

## Phase 1 — Delegate execution to the m-implement engine
- `sdd_set_phase "$root" "$id" implement in_progress`
- Invoke **m-implement** as the execution engine — do **not** re-implement its worktree/implement/test/verify/review/finalize steps here. Hand it, as the pre-assembled context pack:
  - **Business logic:** `specs/$id/spec.md` + `specs/$id/plan.md` + `specs/$id/tasks.md` (the source of truth — no board ticket needed; m-implement's ticket/test-plan steps no-op in SDD mode).
  - **Definition of done:** `specs/$id/acceptance.json` - m-implement builds phase by phase and runs its acceptance gate per phase, writing `specs/$id/evidence/<phase-id>.md` (format: `<skills-root>/m-sdd/acceptance-schema.md`).
  - **Code quality:** `.sdd/constitution.md`.
  - **Project knowledge / reuse:** the structural grounding from Phase 0 (`.sdd/repo-map.md` or the code MCP) + `.sdd/knowledge.md`.
  - **Pre-gated flag:** GO was obtained in Phase 0 — m-implement must skip its own Phase 0 GO/ambiguity gate and start at implement.
- As tasks complete, update the `- [ ]` boxes in `tasks.md` (SDD bookkeeping the engine doesn't own).
- A new question that someone other than the user must answer goes through `m-sdd-decision` when it is installed. If it blocks the build, stop the affected tasks until it is answered; if not, continue on its default and list it in the final report.

## Phase 2 — Record & route
- The engine has already finished the branch (merge/PR/cleanup) and committed. Here just check the evidence, record SDD state, and route.
- **Evidence gate (load-bearing):** every phase in `acceptance.json` must have `specs/$id/evidence/<phase-id>.md` with every criterion `PASS`. A missing file, a `FAIL`, or a `NOT RUN` step means the feature is not done: leave `implement` `in_progress`, list the failing criteria, and go back to the build.
- Only then: `sdd_set_phase "$root" "$id" implement done`.
- Route: offer `m-sdd-tasks-to-issues` if the team tracks work in a board; otherwise the pipeline is complete.

## Never
- Re-describe or duplicate the execute→test→verify→review→finalize loop here — it lives in **m-implement**; this skill only gates, sets SDD state, and routes.
- Add a second GO gate — Phase 0 holds the run's single gate; the engine is handed a pre-gated flag.
- Delegate with `analyze` still `pending`/`in_progress`, or before `tasks` is `done` — the Phase 0 `sdd_require` gates are load-bearing.
- Hand-edit `state.json` — always go through `sdd-lib.sh`.
- Mark `implement` done on ticked boxes alone, or edit `acceptance.json` to make a failing step pass - a wrong criterion goes back to `m-sdd-plan` and its approval gate.
