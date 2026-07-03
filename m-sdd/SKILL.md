---
name: m-sdd
description: "Spec-Driven Development orchestrator — scaffold .sdd/, create/select a feature, show pipeline status, and route to the next phase. Triggers: sdd, spec-driven, start sdd, sdd status, sdd init, new feature spec, what phase, which sdd phase, spec kit, speckit."
---

# SDD — Orchestrator

> **TL;DR** — Scaffold `.sdd/` (1) → create or select a feature (2) → show status & route to the next `m-sdd-<phase>` skill (3). Read `_shared.md` for the rules every phase shares.

This is the entry point. Phase skills (`m-sdd-constitution` … `m-sdd-tasks-to-issues`) do the per-phase work; this skill sets up state and tells you where you are.

## Phase 0 — Preflight
- Read sibling `m-sdd/_shared.md`.
- Require `jq`: `command -v jq >/dev/null || echo "MISSING jq"` — if it prints
  `MISSING jq`, **STOP**: tell the user to install it (`brew install jq`) and do
  not run any `sdd_*` function until it is present.
- `source ~/.config/devin/skills/m-sdd/sdd-lib.sh; root="$(pwd)"`

## Phase 1 — Scaffold (idempotent)
- `sdd_scaffold "$root"` — creates `.sdd/{config.json,state.json,templates/}` and `specs/`.
- Mention that `.sdd/` and `specs/` should be committed to the project repo.

## Phase 2 — Feature selection
First show what exists: `sdd_list "$root"` (one line per feature, `* ` marks active). Then interpret intent:
- **New feature** ("new <name>"): `id="$(sdd_create_feature "$root" "<name>")"` then report `$id` (this also makes it active).
- **Select existing**: `sdd_set_active "$root" "<id>"` — never hand-edit `config.json`.
- **Just status**: skip to Phase 3.

## Phase 3 — Status & route
- `sdd_status "$root"` — prints the active feature, each phase's status, and `Next:`.
- Tell the user which skill to run next: `m-sdd-<next>` (from `sdd_get_next`).
- If `Next: constitution` and no `.sdd/constitution.md`, recommend `m-sdd-constitution`.
- After the constitution, mention the optional `m-sdd-knowledge` (builds `.sdd/knowledge.md` — project facts that ground specify/clarify); it is not a tracked phase, so it won't appear in `sdd_status`.
- After specify, mention the optional `m-sdd-checklist` (requirement-quality checklists in `specs/<id>/checklists/` — "unit tests for English"); also untracked.
- If the user has UI designs made elsewhere (e.g. in an AI chat tool), note they can drop the HTML into `specs/<id>/design/` — `m-sdd-specify`/`m-sdd-plan` will index and reference it (visual reference, not a tracked phase).

## Notes
- Never hand-edit `state.json`; always go through `sdd-lib.sh`.
- Pipeline order: constitution → specify → clarify → plan → tasks → analyze → implement → issues.
