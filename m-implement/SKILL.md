---
name: m-implement
description: "Standalone task orchestrator — take a request (or a board ticket) from GO gate through implement → test → verify → review → finalize by delegating to sibling m-skills. Works with or without an SDD spec. Triggers: implement, build, create feature, add feature, new screen, new page, task, scaffold, build X, ship this ticket, work on this ticket, do the ticket."
---

# Task Orchestrator (implement → test → verify → review)

> **TL;DR** — GO gate + ticket setup (0) → implement in a worktree (1) → test to green (2) → verify the running app (3) → review (4) → finalize & close the ticket (5). This skill is **thin**: every stage delegates to a sibling skill; it owns only the gates and the ordering.

This is the default entry point for "build X" when you are **not** running the full
SDD pipeline. (Inside SDD, `m-sdd-implement` already covers phase 7.) It carries **no
implementation logic of its own** — it sequences the specialist skills and enforces the
GO gate between planning and code.

## Phase 0 — Preflight, ticket & GO gate

- **If invoked by another skill (e.g. `m-sdd-implement`) that already assembled the context
  pack and ran the GO gate:** accept it as pre-gated — skip the ticket/test-plan/ambiguity/GO
  steps below and start at **Phase 1** with the pack the caller handed you. Otherwise run
  Phase 0 in full.
- **If a ticket reference was given** (a key/id or a ticket URL): delegate provider detection
  to **m-board** (its Phase −1: skill `config.json`, else ToolSearch discovery of the session's
  MCP surface), then read `m-board/providers/<provider>.md` for the concrete tool mapping and
  fetch the ticket. Then, following any board rules in the host project's `CLAUDE.md`:
  - **Move it to In Progress** if it is in a not-started state. Transitions/states vary per
    board and some boards need intermediate hops (e.g. `Open → Ready for Dev → In Progress`)
    — **discover the available transitions/states dynamically via the provider's tools and
    step through them**; never hard-code a transition/state id.
  - **Test plan check (load-bearing):** scan the ticket's **comments** for an existing QA
    test plan. If none exists, generate one with **m-qa-test-planner** (grounded in the
    ticket's description + acceptance criteria) and **post it back as a comment** before
    coding — the plan drives Phase 3's verification. (Regenerate/update it after Phase 1 if
    implementation changed the scope.) Target shape: ticket In Progress + a
    `QA Test Plan — <KEY>` comment with `TC-FUNC-*` / `TC-REG-*` cases.
- **Assemble the context pack (load-bearing — this is where quality is set).** Gather the
  three grounding inputs below, then **slice per delegation — never dump verbatim**: each
  subagent gets only what its task needs (the current task's text, the acceptance criteria
  it satisfies, the constitution rules it touches) plus **paths** to the full artifacts to
  read on demand. Pasting spec+plan+tasks into every prompt multiplies input tokens per
  subagent without adding grounding; an implementer working blind is the other failure mode —
  the slice must still cover its task completely:
  - **Code quality →** `.sdd/constitution.md` (allowed/banned patterns, conventions). If it
    doesn't exist, recommend `m-sdd-constitution` first — without it there is no quality bar.
  - **Project knowledge →** `.sdd/knowledge.md` + host `CLAUDE.md` (file map, domain glossary,
    stack, prior decisions) + `.sdd/repo-map.md` or the code MCP for structural reuse. If
    knowledge is thin, recommend `m-sdd-knowledge`.
  - **Business logic →** the ticket's acceptance criteria + the QA test plan (above) + any
    `specs/<id>/` spec. This is the source of truth for *what correct means*.
- **Ambiguity gate.** If the acceptance criteria are unclear or a design decision is
  non-obvious (data shape, edge-case behaviour, which screen), resolve it **before** GO via
  `m-brainstorming` / `m-ask` (or `m-sdd-clarify` in SDD) — never guess business intent.
- **GO gate — the point of no return into code.** Summarize: what will be built (one-liner +
  the touched files/areas), the target **branch/worktree**, the ticket + its test plan, the
  context pack loaded, and any open decisions the user must own. Get the user's explicit
  **"go"**. If not confirmed, **stop** — do not proceed autonomously past this line.

## Phase 1 — Implement

- Isolate first: create a feature branch/worktree via **m-worktree**.
- Delegate the build to **m-subagent-driven-development** (fresh subagent per task, review
  between tasks), feeding each implementer its **slice of the Phase 0 context pack** (per the
  slicing rule above) so it reuses real symbols/paths and obeys the constitution instead of
  inventing. Do **not** modify the delegated skill — pass context into it. Do tell it to
  **return here when its tasks are complete instead of running its own finishing handoff** —
  finalization happens in Phase 5, after test/verify/review.

## Phase 2 — Test

- Delegate to **m-test-driven-development**: write/extend tests for the new behaviour and
  **loop until green**. Cover the ticket's acceptance criteria and the failure modes the QA
  plan named. Do not advance while tests are red.

## Phase 3 — Verify

- Delegate to the built-in **`verify`** skill: run the actual app and observe behaviour —
  walk the **golden path plus at least one edge case** (ideally the top `TC-*` cases from the
  Phase 0 test plan). Type checks and unit tests prove code correctness, not feature
  correctness; this step proves the feature.

## Phase 4 — Review

- Run review by a **fresh perspective**, not the author, and grade against the Phase 0 pack
  on both axes: **code quality** (run the `code-review` skill for correctness bugs) and
  **business correctness** (does it satisfy every acceptance criterion / `TC-*` case?). Add
  `m-requesting-code-review` against `.sdd/constitution.md` **only if the Phase 1 delegate
  didn't already run per-task + whole-feature quality reviews** (m-subagent-driven-development
  does — don't re-run the same reviewer template a third time). A finding on either axis
  blocks merge.
- Process the feedback with **m-receiving-code-review** — verify each point technically
  rather than agreeing reflexively; loop back to Phase 1–2 for any real fix, then re-verify.

## Phase 5 — Finalize & close out

- Use **m-finishing-a-development-branch** to confirm tests pass and choose merge / PR /
  cleanup; author messages with **m-git-commit** (never a hand-crafted commit).
- **Close the loop on the board:** transition the ticket onward (the board's Code Review /
  Done equivalent, again discovered dynamically via the provider) — don't leave merged work
  in an earlier state.

## Never

- Write code before the user's explicit "go", or advance past a gate before it's met — no
  Phase 3 while tests are red, no "done" without the Phase 3 running-app check.
- Hard-code transition/state ids — always discover them per board and step through hops.
- Start implementing when the ticket has no test plan and one could be generated first.
- Let a subagent implement or review without its slice of the Phase 0 context pack, or accept
  a self-review — the pack (constitution + knowledge + acceptance criteria) IS the quality
  control, and the reviewer must be an independent perspective grading against it. Slicing
  trims tokens, not grounding: "relevant slice + paths" never means "no context".
- Re-implement anything a sibling skill owns — this orchestrator only gates and sequences.
- Invoke this **directly** mid-SDD — enter through `m-sdd-implement`, which drives this engine
  (and passes the SDD context pack + a pre-gated flag). Being *called by* SDD is expected.
