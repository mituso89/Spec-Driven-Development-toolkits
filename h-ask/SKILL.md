---
name: h-ask
description: "Project-grounded advisor: answer any question, brainstorm, compare approaches, or recommend strategy grounded in THIS codebase and its own conventions — not generic advice. Triggers: how do I, what is, should I, why does, explain, brainstorm, compare, best way, recommend, advice, strategy, which approach, what's the difference, help me think, can I, is it possible, design first, shape this, sketch a design, how should I structure, design the X before building."
---

# Ask Advisor

> **TL;DR** — Classify (0) → learn this project's stack & rules (1) → gather code context (2) → answer with evidence (3) → route to next skill (4).

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
| **Why broken** | "Why is X broken" | → a debugging skill / `engineering:debug` |
| **Implement** | "Build / add X" | → an implementation skill |
| **Review** | "Is this ready" | → a review skill / `/code-review` |

For implement/debug/review intents, hand off to the project's matching skill if one exists; otherwise proceed but say you're answering directly.

**Design-first vs `h-brainstorming`** — handle the design *inline* here when the user wants a quick shaping conversation and an answer they can act on now. Hand off to the `h-brainstorming` skill instead when the work needs the full gate: a committed spec file, a multi-step plan, or an explicit design-approval ritual before any code. Rule of thumb: *one screen of design → stay here; a spec doc that gets committed → `h-brainstorming`.* When in doubt, offer both: give the inline design, then say "want the full committed spec? → `h-brainstorming`."

---

## Phase 1 — Learn the project (do this before constraining anything)

Do NOT assume a stack. Read what this project actually locks, in this order, stopping when you have enough:

1. `CLAUDE.md` / `AGENTS.md` at the repo root — project instructions and rules.
2. `.devin/rules/*` or a `CONVENTIONS.md` — explicit do/don't lists.
3. `package.json` / `pyproject.toml` / `go.mod` / `Cargo.toml` — the real dependencies and scripts.
4. The folder layout — where code of each kind lives.

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
End with: "Build it via [implementation skill], or want the full committed spec → `h-brainstorming`."

### Explain
```
[Concept] in this project:
  [2–3 sentences grounded in actual code]
Lives in:  [file:line]
Used in:   [file:line]
```

---

## Phase 4 — Route

End with one concrete next step: an implementation skill, a debug skill, a review skill/`/code-review`, or "Done — no further action."

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
- Run the heavy design ritual here (committed spec file, multi-step plan, approval gate) — that's `h-brainstorming`'s job. Design-first mode stays to one inline screen, then hands off.
