# SDD Shared Rules (All Tools)

Every SDD phase reads this first. These rules apply regardless of which AI tool you are using.

---

## Rule 1 — Delegate, don't hand-roll

Where a phase names a delegate skill (plan → writing-plans, implement → subagent-driven-development, tasks-to-issues → story-breakdown) — use it. Hand-rolling what a skill already covers is a failure.

**Self-contained exceptions:** `specify` and `clarify` run their own user-facing interviews rather than delegating, because a requirement interview *asks the user* questions. Divergent exploration, when wanted, is an upstream activity *before* specify.

---

## Rule 2 — Constitution (advisory context, not an enforced gate)

1. Load `.sdd/constitution.md` before doing phase work; your output must respect it. If it is absent, warn and offer to run the constitution phase, then proceed with a recorded note (no phase hard-blocks on it).
2. Enforcement is by review, not by hard gate: the analyze phase checks every artifact *against* the constitution and can raise `blocking` findings there. The hard gates are spec/plan/implement — see Rule 3.
3. **Facts vs rules:** `constitution.md` holds binding *rules*; the optional `.sdd/knowledge.md` holds project *facts/pointers* that specify/clarify load to ground their questions. Load when present; never gate on it.

---

## Rule 3 — Human approval gates (HITL)

Gate where the cost of being wrong is high and human intent matters; auto-advance mechanical steps.

| Gate | Set by | Enforcement downstream |
|---|---|---|
| **constitution** | constitution phase (user approves) | advisory: loaded by all phases, checked by analyze |
| **specify** | specify phase → `approved` | plan AND clarify need `specify approved` |
| **plan** | plan phase → `approved` (user approves) | tasks needs `plan approved` |
| **implement GO** | implement phase (explicit "go" before any code) | hard stop; also requires tasks done + analyze done/skipped |

`clarify` is itself interactive (human Q&A); `tasks` is mechanical; `analyze` blocks on `blocking` findings. Never advance a load-bearing gate autonomously — if unsure whether the human approved, treat it as not approved.

---

## State tracking (non-Devin tools)

Read `.sdd/pipeline.md` at the start of each phase. Update the row for the current phase:
- Set to `in_progress` when you begin phase work.
- Set to `done` when the phase completes mechanically.
- Set to `approved` for human-gated phases (specify, plan) — only after the user gives explicit approval.
- Set to `skipped` if the user explicitly skips an optional phase.

Never advance a `pending` phase to `approved` without an explicit human OK.

---

## Artifact locations (per active feature `<id>`)

- Spec:  `specs/<id>/spec.md`
- Plan:  `specs/<id>/plan.md`
- Tasks: `specs/<id>/tasks.md`
- Analysis: `specs/<id>/analysis.md`
- Design (optional): `specs/<id>/design/` — visual reference, read-only input
- Plan companions: `specs/<id>/{research.md,data-model.md,contracts/}`
- Checklists (optional): `specs/<id>/checklists/<domain>.md`
- Project-level: `.sdd/constitution.md` (rules) · `.sdd/knowledge.md` (facts, optional) · `.sdd/pipeline.md` (non-Devin state)

---

## Routing

After completing a phase, tell the user the next phase and name the skill/command to run next.

Pipeline order: `constitution → specify → clarify → plan → tasks → analyze → implement → issues`

---

## Never (applies to every phase)

- Advance a load-bearing gate (specify/plan/implement-GO) without an explicit human OK.
- Mark a phase `approved` to mean "finished" — `approved` is human sign-off; use `done` for mechanical completion.
- Edit an `approved` spec/plan in place without resetting its approval and re-confirming.
