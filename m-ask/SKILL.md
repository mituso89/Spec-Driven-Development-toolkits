---
name: m-ask
description: "Project-grounded advisor and front-door router: answer any question grounded in THIS codebase, and read the intent of a request or board ticket to route it to the right track — m-implement (scoped build), m-brainstorming (design exploration), or m-sdd (gated spec pipeline). Triggers: how do I, what is, should I, why does, explain, brainstorm, compare, best way, recommend, advice, strategy, which approach, what's the difference, help me think, can I, is it possible, design first, shape this, sketch a design, how should I structure, design the X before building, triage this ticket, what does this ticket need, which skill, where do I start."
---

# Ask — Advisor & Router

> **TL;DR** — Classify & triage intent (0) → learn this project's stack & rules (1) → gather code context (2) → answer with evidence (3) → route (4). Questions get grounded answers here; build/design/spec intents get *judged* and routed to `m-implement` / `m-brainstorming` / `m-sdd`.

Generic advice without project context is worse than no advice. Every claim about how something works *here* must trace to an actual file in *this* repo.

---

## Phase 0 — Classify

| Type | Pattern | Action |
|---|---|---|
| **How** | "How do I add X" | Find the real pattern in this repo → show it |
| **What** | "What does X do here" | Explain from evidence |
| **Should** | "Should I X or Y" | Decision constrained to this project's stack |
| **Compare** | "X vs Y" | Side-by-side within this stack |
| **Brainstorm** | "Help me think through X" | Options → implementation-ready output |
| **Design-first** | "Help me design / shape / structure X before I build it" | Lightweight inline design (Phase 3 → Design shape) |
| **Explain** | "Explain how X works" | Grounded walkthrough with `file:line` |
| **Why broken** | "Why is X broken" | → `m-debugging-and-error-recovery` |
| **Implement** | "Build / add X" | → **Intent triage** below |
| **Ticket** | ticket key/id, ticket URL, "look at this ticket" | Fetch it → **Intent triage** below |
| **Review** | "Is this ready" | → `m-requesting-code-review` |

For debug/review intents, hand off to the project's matching skill if one exists; otherwise proceed but say you're answering directly. Build/design/spec intents go through the triage below — never straight to a skill by keyword.

**Intent triage — the routing decision.** For build/design/spec intents (the Brainstorm · Design-first · Implement · Ticket rows), judge what the words *actually ask for* — never route on the trigger keyword alone:

1. **Ticket?** If a board ticket is named (key/id or URL), delegate provider detection to **m-board** (Jira or ADO) and fetch it **read-only** here; transitions, comments, and the lifecycle belong to `m-implement`. Its summary + description + acceptance criteria are the intent text; issue type is a scope signal (Epic, or a story with many children ⇒ SDD-weight). Then judge it exactly like a prompt:
2. **WHAT already defined?** Concrete acceptance criteria (or a bug with a repro), scoped to one deliverable → **`m-implement`**, straight to the build loop (it runs its own GO gate). Borderline-clear is fine — its ambiguity gate sends unclear AC back here before any code.
3. **WHAT fuzzy, shaping is small?** One screen of design the user acts on *now*, no committed artifact → stay inline (Design-first, Phase 3).
4. **WHAT fuzzy, shaping is real work?** Pick the committed track:
   - **`m-sdd`** — the project already runs SDD (`.sdd/` present, Phase 1), *or* the intent itself is heavy: multi-story scope, PO/stakeholder sign-off, traceable tasks, risky domain (auth/money/data). A new feature's requirements ⇒ `m-sdd-specify`; `m-sdd` scaffolds `.sdd/` itself if absent.
   - **`m-brainstorming`** — non-SDD project, a single feature needing design exploration → design doc (`docs/specs/…`) + plan, without SDD's state machine and per-phase gates.

Announce the route in one line naming the signals you read, and hand the track the context you gathered (ticket key, acceptance criteria, stack profile). Genuinely torn between two tracks → ask the user one question with both options; don't guess.

---

## Phase 1 — Learn the project (do this before constraining anything)

Do NOT assume a stack. Read what this project actually locks, in this order, stopping when you have enough:

1. `CLAUDE.md` / `AGENTS.md` at the repo root — project instructions and rules.
2. The project's agent rules/config (e.g. `.devin/rules`, `.claude/`, `AGENTS.md`) or a `CONVENTIONS.md` — explicit do/don't lists.
3. `package.json` / `pyproject.toml` / `go.mod` / `Cargo.toml` — the real dependencies and scripts.
4. The folder layout — where code of each kind lives.

Also check for **`.sdd/`** at the repo root: if present, the project uses the **SDD pipeline** — a strong signal for the Phase 0 triage's committed track — and `.sdd/constitution.md` + `.sdd/knowledge.md` are authoritative inputs to the stack profile below.

Extract a short **stack profile**: framework, language + strictness, package manager, styling, state, data layer, and any explicitly banned alternatives. This profile — not your defaults — is what you constrain answers to.

---

## Phase 2 — Code context

Skip for pure concept questions answerable without the repo. For codebase-dependent questions, locate the relevant files by topic (routing, data layer, schemas, errors, UI, config). If ≥3 files are involved, delegate to an Explore subagent; otherwise read inline.

---

## Phase 3 — Answer shapes

### How
```
Pattern: [name]
File:    [path:line in THIS repo]

```<lang>
// short example using THIS project's real APIs / imports
```

Rules:
  · [grounded in the evidence you read]
```

### Should / Compare
```
Decision: [what's being chosen]
A: [option]  Use when: …  Example: [file:line]
B: [option]  Use when: …  Example: [file:line]
Recommendation: A — [1 sentence tied to a pattern already in this repo].
```

### Brainstorm
```
Goal: [restated]
Shaped by: [file:line — existing code]
Approaches (within this stack):
  1. [name] — [how] — [tradeoff]
  2. [name] — [how] — [tradeoff]
Recommended: N — [reason].
```

### Design-first
A lightweight, one-screen design — enough to start building, without the full committed-spec ritual. Ask at most 1–2 clarifying questions first if intent/constraints are unclear, then:
```
Designing: [feature restated in one line]
Constraints: [from Phase 1 stack profile — banned alts, required patterns]
Shaped by:   [file:line — existing code this should mirror]

Approach (recommended): [name]
  Pieces:
    · [component / module] — [responsibility] — [lives at path per conventions]
    · [data/schema/state]  — [shape] — [file]
  Boundaries: [server vs client / layer split, tied to this repo's rules]
Acceptance:
  - [ ] [observable outcome 1]
  - [ ] [observable outcome 2]
Alternatives considered: [name — why not]
```
End with the one handoff that fits (per the Phase 0 triage): build it now via `m-implement`; or for a committed, gated spec → `m-sdd` when the project uses SDD, else `m-brainstorming`.

### Explain
```
[Concept] in this project:
  [2–3 sentences grounded in actual code]
Lives in:  [file:line]
Used in:   [file:line]
```

---

## Phase 4 — Route

End with one concrete next step. For build/design/spec intents the Phase 0 triage decides: the SDD pipeline (`m-sdd`, or `m-sdd-specify` for a new feature's spec), `m-brainstorming` (non-SDD design doc), or `m-implement` (scoped build — pass the ticket key if there is one). Otherwise: a debug skill (`m-debugging-and-error-recovery`), a review skill (`m-requesting-code-review`), or "Done — no further action."

---

## Response rules

- Lead with the answer — no preamble.
- Every claim about existing behavior cites `file:line` you actually read.
- Every code example matches the stack profile from Phase 1 — never recommend a tool the project's rules ban.
- Keep How / What / Explain under ~300 words.

## Never

- Hallucinate a `file:line`. If you didn't read it, don't cite it.
- Assume a framework or library — confirm it from Phase 1 first.
- Recommend an alternative the project explicitly bans, even with caveats.
- Skip the Phase 1 stack read for a codebase-specific "how" question.
- Run a committed-spec ritual here (spec file, multi-step plan, approval gate) — that belongs to `m-sdd`/`m-sdd-specify` (SDD projects) or `m-brainstorming` (non-SDD). Design-first mode stays to one inline screen, then hands off.
- Send feature/design/"build" work to `m-brainstorming` when `.sdd/` exists — in an SDD project the committed-spec path is `m-sdd`, not `m-brainstorming`.
- Route on a trigger keyword without reading the intent — a "build X" prompt with no defined WHAT needs shaping first, and a vague one-line ticket is not implement-ready.
- Transition, comment on, or otherwise mutate a board ticket from here — m-ask *reads* tickets to judge them; the ticket lifecycle belongs to `m-implement`.
