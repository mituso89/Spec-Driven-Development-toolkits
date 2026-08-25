---
name: m-employee-setup
description: "Scaffold the operational layer that turns SDD into a runnable 'AI employee' — a durable handbook, permission tiers (job level), guardrail hooks (company policy), a verification gate (the eyes), and scheduled read-and-report routines (the calendar) — then wire them to the SDD constitution and the two-lane intake. Idempotent and no-clobber; works across Devin CLI and Claude Code. Use to onboard an agent to a project the way you would onboard a new hire, or to make an existing SDD project safe to run less-supervised. Triggers: ai employee, employee setup, onboard the agent, set up guardrails, permission tiers, agent hooks, verification gate, scheduled routines, make this safe to run unattended, operational layer."
---

# Employee Setup — the operational layer for SDD

> **TL;DR** — Preflight & detect harness (0) → handbook (1) → permission tiers (2) → guardrail hooks (3) → the verification gate (4) → routines (5) → wire to SDD & document the two-lane intake (6). Read `<skills-root>/m-sdd/_shared.md` first. Everything is idempotent and **never clobbers** a file that already exists.

SDD covers *how work flows* (constitution → specify → plan → tasks → implement).
This skill covers *how the employee is run day to day* — the layer that lets you
stop supervising every keystroke. It does **not** replace any SDD phase; it
installs the guardrails SDD assumes and points them at the same constitution and
verification gate.

Onboard an agent the way you would a new hire: a desk, a handbook, a job level
(what it may do freely / must ask about / may never do), company policy that runs
regardless of what the model decided, eyes to check its own work, and a calendar.

## Phase 0 — Preflight & detect

- Read `<skills-root>/m-sdd/_shared.md`.
- `source <skills-root>/m-sdd/sdd-lib.sh; root="$(pwd)"`; ensure SDD scaffold:
  `sdd_scaffold "$root"` (safe to re-run).
- **Detect harness(es)** so you write the matching config, not a guess:
  - Devin CLI → `.devin/config.json`
  - Claude Code → `.claude/settings.json`
  - Decide from what already exists (`.devin/`, `.claude/`) and what the user
    runs; if unclear, ask once. You may set up **both** (a bridge) — the hook
    scripts are shared; only the matcher/env-var differ per harness.
- Announce a short plan of which files you will create; skip any that exist.

## Phase 1 — Handbook (the desk & memory)

- Prefer an existing handbook: if `CLAUDE.md` or `AGENTS.md` exists, **reuse and
  extend it**; do not create a second one.
- Otherwise create `AGENTS.md` from `<skills-root>/m-employee-setup/templates/handbook.md`
  (read by every tool). Fill the stack, the real run/test commands, the two or
  three things that always break, and the Definition of Done. Keep it under a page —
  a handbook, not a wiki. A stale handbook is worse than none.

## Phase 2 — Permission tiers (the job level)

Sort every operation with one question: *if this ran a hundred times unattended
and ten percent were wrong, what would it cost me?* → **allow** (nothing, re-run) /
**ask** (recoverable from git) / **deny** (money, data, reputation, irreversible).

- Devin: write `.devin/config.json` from `templates/permissions.devin.json`.
- Claude Code: write `.claude/settings.json` from `templates/permissions.claude.json`.
- Tune the globs to the project's real layout and gate command. Be generous on
  reads and idempotent checks; strict on writes; deny secrets, history rewrites,
  publishes, and the guardrail files themselves.

## Phase 3 — Guardrail hooks (company policy)

Permissions decide what the model may *attempt*; hooks run **your** code
regardless of what it decided. Install the two shared scripts (they read the tool
payload with `jq`, so they work under any harness and need no per-tool helper):

- Copy `templates/hooks/protect-paths.sh` and `templates/hooks/post-edit-check.sh`
  into a neutral `scripts/agent-hooks/` in the project; `chmod +x` both.
- Reference them from each harness config on file edits/writes:
  - Devin `.devin/config.json` → matcher `^(edit|write)$`, command
    `"$DEVIN_PROJECT_DIR/scripts/agent-hooks/protect-paths.sh"` (and the
    post-edit check on `PostToolUse`).
  - Claude `.claude/settings.json` → matcher `Edit|Write`, command
    `"$CLAUDE_PROJECT_DIR/scripts/agent-hooks/protect-paths.sh"`.
  - The starter templates already wire this — keep the matcher case per harness
    (Devin tool names are lowercase; getting this wrong makes hooks silently
    never fire).
- `protect-paths.sh` blocks writes to secrets and to guardrail/SDD-state files;
  `post-edit-check.sh` syntax-checks a file the moment it is written. Exit 2
  blocks and feeds stderr back so the agent can correct itself.

## Phase 4 — The verification gate (the eyes)

The single most important part: an agent that cannot observe the result of its
own change is guessing.

- **Discover** the project's real "prove it works" command (`npm run verify`,
  `make test`, `pytest -q`, `cargo test`, a smoke script…). Do **not** invent one.
- If none exists, offer `templates/verify.sh` as a starting point (lint → tests →
  a live smoke check) and wire it into the project's task runner.
- **Record it as a first-class fact** in `.sdd/knowledge.md` under
  **Verification gate** (see the `knowledge-template.md` field). SDD's implement
  phase names this gate in its GO summary and runs it — this is what makes
  "prove it, don't claim it" enforceable rather than aspirational.

## Phase 5 — Routines (the calendar)

- Create/extend `docs/routines.md` from `templates/routines.md`: a morning health
  check, a nightly verify, a weekly stalled-work sweep, a handbook-drift check.
- **Rule for anything unattended: read and report, never fix.** Start on something
  where being wrong is free; earn trust before widening scope. One line when
  nothing is wrong.

## Phase 6 — Wire to SDD & the two-lane intake

- If `.sdd/constitution.md` is absent, route to **m-sdd-constitution** — it
  ingests the handbook you just wrote and turns its conventions + Definition of
  Done into the binding rules every SDD phase is checked against. The handbook is
  the readable memory; the constitution is its enforceable half. Keep them in sync.
- Document the **two-lane intake** in the handbook (ticket or not is orthogonal to
  the lane; the lane is chosen by definition + size, and both lanes end at the
  verification gate):
  - **Defined + small** → build now (ship it / `m-implement`); if no ticket,
    write one first.
  - **Fuzzy or feature-weight** → the SDD pipeline via **m-sdd** (`specify` is the
    requirement capture — no ticket needed).
- Route: suggest `m-sdd` to start the pipeline, or `m-sdd-knowledge` to record the
  gate and project facts.

## Never

- Overwrite a handbook, permission config, hook, or gate the project already has —
  reuse and extend; this skill is no-clobber.
- Put the permission tiers only in a rule/handbook and call it done — a request in
  prose is not a boundary; the `deny`/`ask` config and the hooks are.
- Widen an agent's own permissions or edit guardrail/hook files as part of feature
  work — that is a separate, human-reviewed change (the hooks enforce this).
- Let a scheduled routine write, commit, or push — routines read and report.
- Invent a verification gate — discover the project's real one; a fake gate is
  worse than none because it is trusted.
- Duplicate SDD phase work here — this installs the operating layer around SDD,
  it does not re-run constitution/specify/plan/implement.
