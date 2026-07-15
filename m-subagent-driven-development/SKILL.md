---
name: m-subagent-driven-development
description: Use when executing implementation plans with independent tasks in the current session
---

# Subagent-Driven Development

> **TL;DR** — Extract every task from the plan once (1) → per task: fresh implementer subagent, then spec-compliance review, then code-quality review, looping until both approve (2) → final whole-implementation review → **m-finishing-a-development-branch** (3).

Execute a plan by dispatching a **fresh subagent per task**, with a **two-stage review** after each: spec compliance first, then code quality.

**Why subagents:** isolated context per task — you craft exactly what each one needs, nothing inherits your session history, and your own context stays free for coordination.

**Continuous execution:** don't pause between tasks for check-ins or progress summaries. Stop only for: a BLOCKED status you can't resolve, ambiguity that genuinely prevents progress, or all tasks complete.

## When to use

Have a written plan with mostly independent tasks → this skill. No plan yet → **m-writing-plans** first. Tightly coupled tasks → execute manually.

## The loop

1. **Prep once:** read the plan file, extract every task's full text plus scene-setting context, create the task list. Subagents never read the plan file themselves.
2. **Per task:**
   - Dispatch an **implementer** (`./implementer-prompt.md`) with the task's full text and its **slice** of context: scene-setting (where this task fits, dependencies), the acceptance criteria this task satisfies, the constitution rules it touches, and *paths* to the full artifacts for on-demand reading. Don't paste whole spec/plan/tasks files into every prompt — slicing trims tokens, not grounding.
   - The implementer may ask questions first — answer completely before it proceeds. It implements, tests, self-reviews, commits.
   - Dispatch a **spec reviewer** (`./spec-reviewer-prompt.md`): does the code match the spec — nothing missing, nothing extra? Issues → same implementer fixes → re-review until ✅.
   - Dispatch a **code-quality reviewer** (`./code-quality-reviewer-prompt.md`). Issues → implementer fixes → re-review until approved. Quality review never starts before spec compliance is ✅.
   - Mark the task complete.
3. **After all tasks:** dispatch a final code reviewer over the entire implementation, then use **m-finishing-a-development-branch** — unless the caller (e.g. `m-implement`) told you to return to it instead of running your own finishing handoff.

## Model selection

Use the least powerful model that can handle the role:

- 1–2 files, complete spec, mechanical → cheap/fast model
- Multi-file integration, pattern matching, debugging → standard model
- Design judgment, architecture, review → most capable model

## Implementer statuses

- **DONE** → proceed to spec review.
- **DONE_WITH_CONCERNS** → read them: correctness/scope concerns get addressed before review; observations get noted.
- **NEEDS_CONTEXT** → provide the missing context, re-dispatch.
- **BLOCKED** → diagnose: context problem → add context; reasoning problem → stronger model; task too large → split it; plan wrong → escalate to the human. Never re-dispatch unchanged.

## Never

- Start on main/master without explicit user consent.
- Skip either review stage, proceed with unfixed issues, or skip the re-review after a fix.
- Start code-quality review before spec compliance passes.
- Dispatch multiple implementers in parallel (conflicts).
- Make a subagent read the plan file to find its task — the controller provides the task text.
- Let the implementer's self-review replace the independent reviews — both are needed.
- Ignore subagent questions or escalations — answer, add context, or change something first.
- Fix a failed task by hand — dispatch a fix subagent with specific instructions (context pollution).

## Integration

- **m-worktree** — isolated workspace first
- **m-writing-plans** — produces the plan this skill executes
- **m-test-driven-development** — implementers follow it per task
- **m-requesting-code-review** — review template for reviewer subagents
- **m-finishing-a-development-branch** — after all tasks pass the final review (when no caller owns finalization)
