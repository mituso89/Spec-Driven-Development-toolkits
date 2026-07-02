---
name: h-sdd-implement
description: "SDD phase 7 — execute the plan/tasks by delegating to h-subagent-driven-development (or h-executing-plans), in an isolated worktree, finishing with branch wrap-up. Triggers: sdd implement, execute sdd plan, build the feature sdd, run sdd tasks, implement sdd."
---

# SDD — Implement

> **TL;DR** — Gate on tasks + analyze, then a **human GO** (0) → isolate via **h-worktree**, delegate to **h-subagent-driven-development** over plan.md+tasks.md (1) → finish the branch & mark done (2). Read `~/.config/devin/skills/h-sdd/_shared.md` first.

**Pipeline:** analyze → **implement** → issues.

## Phase 0 — Preflight & gate
- Read `_shared.md`; load constitution (implementation must respect it).
- Load the **structural grounding** source (`.sdd/repo-map.md`, or the code MCP named in `.sdd/knowledge.md`'s `Structural grounding` line) — it is fed to implementers as reuse context in Phase 1 and named in the GO summary.
- `source ~/.config/devin/skills/h-sdd/sdd-lib.sh; root="$(pwd)"; id="$(sdd_active_feature "$root")"`
- `sdd_require "$root" "$id" tasks "done"` — tasks must be derived.
- `sdd_require "$root" "$id" analyze "done,skipped"` — analyze must have run clean or been explicitly skipped; never implement on a still-`pending`/`in_progress` consistency gate.
- **Human GO gate — the point of no return into code (load-bearing).** Before writing any code: summarize what will be built (the `tasks.md` list), the target branch/worktree, and any open analyze findings the user must own; then get the user's explicit "go". If not confirmed, stop. Do NOT proceed autonomously past this point.

> Optional companion: if implementation hits unexpected failures or test breakages, run `h-debugging-and-error-recovery` for structured root-cause triage before retrying.

## Phase 1 — Execute
- `sdd_set_phase "$root" "$id" implement in_progress`
- Isolation: use **h-worktree** (or `h-using-git-worktrees`) to create a feature branch/worktree.
- Invoke **h-subagent-driven-development** (fresh subagent per task, review between tasks) — or **h-executing-plans** for inline execution — feeding it `specs/$id/plan.md` and `specs/$id/tasks.md`, **plus the structural grounding (`.sdd/repo-map.md`, or the code MCP) as reuse context** so each implementer reuses existing symbols/conventions for anything the plan didn't spell out. Include it in the task context you construct here; do **not** modify the delegated skill. Update the `- [ ]` boxes in `tasks.md` as tasks complete.

## Phase 2 — Finish, record & route
- Use **h-finishing-a-development-branch** to verify tests and choose merge/PR/cleanup; use **h-git-commit** for Conventional Commit messages.
- `sdd_set_phase "$root" "$id" implement done`.
- Route: offer `h-sdd-tasks-to-issues` if the team tracks work in Jira; otherwise the pipeline is complete.
