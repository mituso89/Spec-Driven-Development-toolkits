# Project handbook

> Loaded into every agent session (as `AGENTS.md`, or `CLAUDE.md` for Claude Code).
> It is the memory the agent does not otherwise have. Keep it short, current, and
> true — a stale handbook is worse than none, because it is believed.

## What this is
<One paragraph: what the project is and who it serves.>

## Stack
<Languages, framework, package manager, test runner, data layer. Name banned
alternatives if any.>

## Commands
| Purpose | Command | Notes |
|---|---|---|
| Run | `<...>` | |
| Tests | `<...>` | |
| Lint | `<...>` | |
| **Verify (the gate)** | `<npm run verify / make test / ...>` | the single "prove it works" command |

## Conventions
- <e.g. pure, I/O-free logic in one layer; only one file touches the network>
- <naming: branches, commits, tickets>
- Config/guardrail changes (`.devin/`, `.claude/`, `scripts/agent-hooks/`, `.sdd/`
  state) are never part of a feature change — they are their own reviewed change.

## Things that always break
- <the two or three real traps a new hire would hit>

## Definition of done
Not done until all are true:
1. The verification gate exits 0.
2. The diff contains nothing unrelated to the task.
3. You have observed the behaviour yourself — ran the command, read the output.
   "Should work" is not evidence.
4. You can state, in one sentence, how you verified it.

## Intake → two lanes
Start every piece of work the same way, whether or not a ticket exists. The lane
is decided by *definition + size*, not by whether a ticket exists. Both lanes end
at the verification gate above.

- **Have a ticket?** Don't re-scope it — read and judge it. **No ticket?** The
  request itself is the input.
- **Defined + small** (one paragraph, clear yes/no done condition) → build now
  (`m-implement`); if there is no ticket yet, write one first.
- **Fuzzy or feature-weight** (multi-story, crosses a trust boundary, needs
  sign-off) → the SDD pipeline via **m-sdd** (`specify` is the requirement
  capture — no ticket needed).

## Guardrails
- Permission tiers live in `.devin/config.json` and/or `.claude/settings.json`
  (safe / ask-first / human-owned). Hooks in `scripts/agent-hooks/` run
  regardless of what the model decided.
- The binding rules the SDD pipeline enforces live in `.sdd/constitution.md`
  (this handbook's enforceable half). Keep the two in sync.
