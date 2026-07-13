---
name: m-review-skill
description: "Meta audit of a SKILL.md — frontmatter shape, trigger coverage, grounding to real files, compliance with the HOST project's own conventions, integration with sibling skills, length & tone. Triggers: review skill, audit skill, check skill, skill quality, validate skill, skill review."
---

# Skill Quality Audit

> **TL;DR** — Frontmatter (1) → grounding (2) → integration (3) → project-convention compliance (4) → length & tone (5) → fix list.

A skill that doesn't trigger — or triggers and gives advice that contradicts the project it's installed in — is worse than no skill. This audit adapts to **whatever the host project locks**, not a fixed stack.

---

## Phase 0 — Learn the rules first

If the skill is **project-scoped** (`<repo>/.claude/skills/...`), read the project's `CLAUDE.md` / `.claude/rules/*` / conventions and its manifest. Derive the project's **allowed** and **banned** tools from those files — that list drives Phase 4. If the skill is **global** (`~/.claude/skills/...`), there is no host stack to comply with; instead require that it stays framework-agnostic (no project-specific names/paths baked in).

---

## Phase 1 — Frontmatter

Required shape:

```md
---
name: <kebab-name>
description: "<one-line purpose>. Triggers: kw1, kw2, kw3, ..."
---
```

Checks:
- `name` matches the folder name (`foo/SKILL.md` → `name: foo`).
- `description` ends with an explicit `Triggers:` list — comma-separated, lowercase.
- Triggers cover synonyms for the topic users actually type.
- No leaked terminology from a stack the skill isn't about (unless it's a migration skill).

---

## Phase 2 — Grounding

Every code example must be valid for the skill's target:

| Check | Pass if |
|---|---|
| Imports | resolve in the target project (or are clearly illustrative placeholders for a global skill) |
| File paths cited | exist or follow the project's convention table |
| Function signatures | match real exports or are clearly illustrative |
| Examples | in the project's actual language |

Failures = High severity.

---

## Phase 3 — Integration

- Does it cross-reference sibling skills by their slash form (`/<name>`)?
- Does it route to the project's implementation / debugging / review / finalize skills where relevant?
- Does it avoid duplicating another skill's content (defer instead)?
- Does the `## Never` list at the end include 3–6 anti-patterns specific to this skill?

---

## Phase 4 — Project-convention compliance

Using the allowed/banned lists derived in Phase 0, search the skill for recommendations that contradict them. Example shape (substitute the project's actual banned tools):

```bash
rg -i "<banned-lib-1>|<banned-lib-2>|<banned-pattern>" .claude/skills/<skill>/
rg "@ts-ignore|as any" .claude/skills/<skill>/        # if the project bans them
rg "#[0-9a-fA-F]{3,8}\b" .claude/skills/<skill>/      # raw hex, if the project mandates tokens
```

Any recommendation the project bans = Critical. For a global skill, the equivalent Critical is a hardcoded reference to one specific project's stack/paths.

---

## Phase 5 — Length & tone

- 50–120 lines including frontmatter. Skills are reference cards, not essays.
- Lead with a TL;DR. Use tables to compress constraints. End with a `## Never` list.
- No emoji unless explicitly themed. Examples in the project's real language.

---

## Report shape

```
## Skill Audit — <name>

### Critical
- [compliance] line 42 — recommends <banned tool>; project mandates <allowed tool>.

### High
- [grounding] line 18 — cites `src/api/foo.ts` which doesn't exist; correct path per conventions is `lib/api/*`.

### Medium
- [integration] missing routing line to the implementation skill at the end.

### Low
- [length] 180 lines — trim the edge-cases section.
```

---

## Never

- Approve a skill that recommends something the host project bans.
- Approve a skill citing nonexistent file paths.
- Approve a global skill hardcoded to one project's stack or paths.
- Approve a skill missing the `Triggers:` list.
- Pad a skill past 120 lines — trim instead.
