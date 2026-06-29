# SDD Shared Conventions

Every `h-sdd-*` skill reads this first. Three rules are identical across all phases.

## Rule 1 — Delegate, don't hand-roll
Where a phase names a delegate skill (plan→`h-writing-plans`,
implement→`h-subagent-driven-development`, tasks-to-issues→`h-story-breakdown`,
etc.) — use it; hand-rolling what a skill already covers is a failure. Do **not**
run `skill` (search) to "confirm" a delegate that is already named — that is wasted
ceremony. Run `skill` (search) only when the named delegate is missing/uninstalled
and you need a substitute.

**Self-contained exceptions** (deliberately *not* delegated — their natural
delegate's spine would fight the phase contract): `specify` and `clarify` both
run their own user-facing interview rather than delegate, because a requirement
interview *asks the user* questions, whereas `h-brainstorming` (specify's tempting
delegate) explores *solutions* and `h-ask` (clarify's) *answers* questions from the
codebase — both point the wrong way. Divergent exploration, when wanted, is an
upstream `h-ask` activity *before* specify.

## Rule 2 — Constitution (advisory context, not an enforced gate)
1. Load `$root/.sdd/constitution.md` before doing phase work; your output must
   respect it. If it is absent, warn and offer to run **h-sdd-constitution**,
   then proceed with a recorded note (no phase hard-blocks on it).
   Its pipeline status is **derived from disk**, not stored per feature:
   file non-empty → `done`; project-wide skip flag (`sdd_set_phase … constitution
   skipped`) → `skipped`; else `pending`. Never try to "mark" it per feature.
2. Enforcement is by review, not by `sdd_require`: `h-sdd-analyze` checks every
   artifact *against* the constitution and can raise `blocking` findings there.
   (The hard, `sdd_require`-enforced gates are spec/plan/implement — see Rule 3.)
3. **Facts vs rules:** `constitution.md` holds binding *rules*; the optional
   `.sdd/knowledge.md` (built by `h-sdd-knowledge`) holds project *facts/pointers*
   that `specify`/`clarify` load to ground their questions. Its **structural half** —
   `.sdd/repo-map.md` (generated), or the code MCP named in knowledge.md's
   `Structural grounding` line — is loaded by `plan`/`implement` so they reuse
   existing symbols/conventions. Load when present; never gate on it.

## Rule 3 — Human approval gates (HITL)
Gate where the cost of being wrong is high and human intent matters; auto-advance
mechanical steps. Three gates are **hard-enforced by `sdd_require`** — the phase
that consumes the artifact refuses to start until the gate is satisfied. The
constitution is human-approved when authored but enforced by *review* (analyze),
not a hard block:

| Gate | Set by | Enforcement downstream |
|---|---|---|
| **constitution** | `h-sdd-constitution` (user approves) | advisory: loaded by all phases, checked by `h-sdd-analyze` |
| **specify** | `h-sdd-specify` → `approved` | `sdd_require`: `h-sdd-plan` AND `h-sdd-clarify` need `specify approved` |
| **plan** | `h-sdd-plan` → `approved` (user approves) | `sdd_require`: `h-sdd-tasks` needs `plan approved` |
| **implement GO** | `h-sdd-implement` (explicit "go" before any code) | hard stop; also `sdd_require`s `tasks` done + `analyze` done/skipped |

`clarify` is itself interactive (human Q&A); `tasks` is mechanical (auto-`done`);
`analyze` blocks on `blocking` findings and needs a human call on non-blocking ones;
`issues` self-confirms via `h-story-breakdown`. Never advance a load-bearing gate
autonomously — if unsure whether the human approved, treat it as not approved.

## Library usage (deterministic state — never hand-edit state.json)
Source the helper library, then use its functions:
```bash
source ~/.config/devin/skills/h-sdd/sdd-lib.sh
root="$(pwd)"
id="$(sdd_active_feature "$root")"          # "" if none
sdd_list "$root"                            # all features, "* " marks active
sdd_set_active "$root" "<id>"               # switch active feature (must exist)
sdd_require "$root" "$id" <prereq> <accepted-csv>   # gate; returns 1 if unmet
sdd_set_phase "$root" "$id" <phase> in_progress
# ... do the phase work ...
sdd_set_phase "$root" "$id" <phase> done    # or: approved | skipped
echo "Next: $(sdd_get_next "$root" "$id")"
```
Status vocabulary: `pending → in_progress → done | approved | skipped`.
Use `approved` for human-gated artifacts (**spec, plan**); downstream phases require
it (see Rule 3). `done` alone is NOT an approval — it means a phase finished its work.

## Artifact locations (per active feature `$id`)
- Spec:  `specs/$id/spec.md`        Plan: `specs/$id/plan.md`
- Tasks: `specs/$id/tasks.md`       Analysis: `specs/$id/analysis.md`
- Design (optional): `specs/$id/design/` — committed, PO-authored **visual reference** (HTML mockups or external links), indexed by `design/README.md`. Read-only input to specify/clarify/plan/analyze; never a tracked phase or gate. Created lazily when a design exists.
- Plan companions: `specs/$id/{research.md,data-model.md,contracts/}`
- Checklists (optional, `h-sdd-checklist`): `specs/$id/checklists/<domain>.md`
- Project-level: `.sdd/constitution.md` (rules) · `.sdd/knowledge.md` (curated facts/pointers, optional) · `.sdd/repo-map.md` (generated structural map, optional — built by `h-sdd-knowledge`)

## Routing
After completing a phase, tell the user the next phase from
`sdd_get_next` and name the skill to run (`h-sdd-<next>`).

## Never (applies to every phase)
- Hand-edit `.sdd/state.json` or `.sdd/config.json` — mutate state only via `sdd-lib.sh`.
- Advance a load-bearing gate (specify/plan/implement-GO) without an explicit human OK; if unsure it was given, treat it as NOT given.
- Mark a phase `approved` to mean "finished" — `approved` is human sign-off; use `done` for mechanical completion.
- Run `skill` (search) to "confirm" a delegate a phase already names (only when one is missing).
- Skip the prereq `sdd_require` for a phase, or implement on a `pending`/`in_progress` analyze gate.
- Edit an `approved` spec/plan in place without resetting its approval and re-confirming (see `h-sdd-clarify`).
