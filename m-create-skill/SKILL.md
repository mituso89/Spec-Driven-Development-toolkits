---
name: m-create-skill
description: "Author a new Claude Code skill — folder + SKILL.md + frontmatter, lean 50–120 lines, grounded in the host project's real files and conventions, integrated with sibling skills. Triggers: create skill, new skill, add skill, write skill, skill for, author skill, scaffold skill."
---

# Create Skill

> **TL;DR** — Idea (1) → classify (2) → folder + frontmatter (3) → draft phases (4) → ground against THIS project + review (5).

Skills auto-load from `.claude/skills/<name>/SKILL.md` (project) or `~/.claude/skills/<name>/SKILL.md` (global). No registration step.

---

## Phase 1 — Expand the idea

State the skill's purpose in one sentence:

```
<name>: <verb> <topic> — <what it produces>.
```

If the idea overlaps an existing skill, **stop** — extend that skill rather than fragmenting. Before writing, list the skills already installed (project + global) and check for overlap.

---

## Phase 2 — Classify

| Type | Shape |
|---|---|
| Orchestrator | multi-phase, plan-first, routes to other skills |
| Audit | sweep + report with severity buckets |
| Pattern guide | how to use one pattern correctly, with a code example |
| Workflow | tool-driven procedure (git, build, deploy) |

---

## Phase 3 — Folder + frontmatter

```bash
mkdir -p .claude/skills/<name>            # or ~/.claude/skills/<name> for global
```

`SKILL.md` opens with:

```md
---
name: <name>
description: "<one-line purpose>. Triggers: kw1, kw2, kw3."
---

# <Title>

> **TL;DR** — <one sentence>.

…
```

- `name` MUST match the folder name.
- `description` ends with a `Triggers:` list — 5–15 lowercase, comma-separated keywords/phrases users actually type.
- Decide scope: a **global** skill must be framework-agnostic (it loads in every project); a **project** skill may hardcode that project's stack.

---

## Phase 4 — Draft

Outline by type:

```
Orchestrator: Plan → Place → Implement → Verify → Finalize → Never
Audit:        Sweep → Findings buckets → Report shape → Never
Pattern:      When to use → Pattern (code) → Edge cases → Never
```

Use tables to compress constraints. Keep code examples in the project's actual language. Cite real file paths (or clearly-illustrative placeholders for a global skill).

---

## Phase 5 — Ground & review

Before saving, walk through:

- **Ground to the host project.** Read its `CLAUDE.md` / conventions / manifest. Every cited path exists or follows its conventions; every example uses tools the project actually allows; no example recommends something the project bans.
- **For a global skill:** strip all project-specific names/paths; use neutral placeholders so it's safe in any repo.
- Does it end with a `## Never` list (3–6 bullets)?
- Length 50–120 lines? If over, trim — skills are reference cards.

Then audit the draft with `/m-review-skill`.

---

## Pitfalls

| Pitfall | Fix |
|---|---|
| Trigger list too narrow | Add synonyms users actually type |
| Trigger list too broad | Skill fires on unrelated work; tighten |
| Global skill hardcodes one project's stack | Genericize or scope it to that project |
| Duplicates an existing skill | Defer to it; add only what's new |
| No routing to a sibling skill | Add a handoff line |

---

## Never

- Register a skill anywhere — the `SKILL.md` file is sufficient.
- Ship a global skill that names one project's packages, paths, or stack.
- Recommend, in any example, a tool the host project bans.
- Skip the `## Never` list.
- Exceed 120 lines without a strong reason — trim first.
- Copy another skill verbatim — reference it instead.
