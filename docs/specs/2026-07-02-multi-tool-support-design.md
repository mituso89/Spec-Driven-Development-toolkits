# Design: Multi-Tool Support for SDD Toolkit

**Date:** 2026-07-02
**Status:** Approved

---

## Goal

Make the SDD pipeline available to any AI agent tool — not just Devin CLI. Target tools: Claude Code, Cursor, Windsurf, and any tool that reads a generic `AGENTS.md`. The full pipeline (all phases) must be available in each tool, with a clean single source of truth so changes to phase logic propagate everywhere.

---

## Constraints

- Devin CLI experience is unchanged — zero regression to existing skills, `sdd-lib.sh`, `_shared.md`, `install.sh` (no-args), or `install.sh --project`
- No new runtime dependencies (no templating engine, no Node, no Python — pure bash + `cat`)
- `vendor.sh` requires no changes — `phase-instructions.md` files live inside `h-*` folders that vendor already re-syncs
- Non-Devin tools cannot run shell at spec time — state tracking must be Markdown-only for them
- `install.sh --tool` never clobbers an existing adapter file in the target project
- Every pipeline phase gets a `phase-instructions.md`; non-pipeline skills (`m-sdd-knowledge`, `m-sdd-checklist`, `m-sdd-tasks-to-issues`) are excluded

---

## Shaped by

- `install.sh:32-42` — existing `for d in "$SRC"/h-*` loop; new flags are additive, no loop changes
- `vendor.sh:15-23` — copies entire `h-*` folders; `phase-instructions.md` files are picked up automatically
- `m-sdd/_shared.md` — Devin adapter pattern; `m-sdd/phase-instructions.md` is its tool-agnostic twin
- `m-sdd-specify/SKILL.md:39-43` — example of Devin-specific shell calls that must stay out of `phase-instructions.md`
- `docs/specs/2026-07-02-agent-skills-integration-design.md` — established `--project` flag pattern this builds on

---

## Approach: Shared phase docs + per-tool adapter layer (Approach A)

Each pipeline phase directory gets a `phase-instructions.md` — the canonical, tool-agnostic source of truth. The existing `SKILL.md` becomes a thin Devin adapter: YAML frontmatter + the Devin-specific shell calls, incorporating `phase-instructions.md` content. Non-Devin adapters are assembled by `install.sh --tool` via concatenation at install time.

---

## Section 1 — Canonical source split

### What goes in `phase-instructions.md` (tool-agnostic)

- Phase purpose, contract, and non-negotiable rules (e.g. the requirement-first contract in specify)
- Artifact descriptions: what the output file must contain, section by section
- HITL gate descriptions in plain English ("do not proceed without explicit user approval")
- Artifact paths — these are project-relative (`.sdd/constitution.md`, `specs/<id>/spec.md`) and identical across all tools
- Pipeline order and routing descriptions
- Interview and convergence rules
- Companion skill hints (e.g. optional `m-api-and-interface-design` note)

### What stays Devin-only (in `SKILL.md` only, never in `phase-instructions.md`)

- `source ~/.config/devin/skills/m-sdd/sdd-lib.sh`
- All `sdd_set_phase`, `sdd_require`, `sdd_scaffold`, `sdd_active_feature`, `sdd_create_feature` calls
- `~/.config/devin/skills/…` path references
- YAML frontmatter (`name:`, `description:`, trigger keywords)

### Shared rules (`m-sdd/`)

| File | Role |
|---|---|
| `m-sdd/phase-instructions.md` | Tool-agnostic shared rules — the three rules, artifact locations, routing, and HITL gate descriptions extracted from `_shared.md`, with all Devin-specific shell content removed |
| `m-sdd/_shared.md` | Devin adapter — retains the tool-agnostic content (now also in `phase-instructions.md`) **plus** the lib usage block and shell-call examples that are Devin-only; no file-include mechanism, content is duplicated by design so Devin keeps a self-contained file |

---

## Section 2 — Non-Devin adapter format & state

### Adapter files written per tool

| Flag | File written into project | Format |
|---|---|---|
| `--tool claude` | `<project>/.claude/CLAUDE.md` | Markdown |
| `--tool cursor` | `<project>/.cursorrules` | Markdown |
| `--tool windsurf` | `<project>/.windsurfrules` | Markdown |
| `--tool agents` | `<project>/AGENTS.md` | Markdown (generic) |

Each adapter file is assembled by `install.sh` via concatenation in this order:
1. Short header: `# SDD Pipeline — <tool name>` + one-line description
2. `m-sdd/phase-instructions.md` (shared rules)
3. Each pipeline phase's `phase-instructions.md` in pipeline order, separated by `---`

Pipeline order: `constitution → specify → clarify → plan → tasks → analyze → implement`

No generation tooling — pure `cat` in bash.

### State for non-Devin tools — `.sdd/pipeline.md`

Non-Devin tools cannot run `sdd-lib.sh`. State is tracked in a plain Markdown file written into the project at adapter-install time:

```markdown
# SDD Pipeline State

## Feature: <name>  <!-- active -->
| Phase        | Status  |
|--------------|---------|
| constitution | pending |
| specify      | pending |
| clarify      | pending |
| plan         | pending |
| tasks        | pending |
| analyze      | pending |
| implement    | pending |
| issues       | pending |
```

Each non-Devin `phase-instructions.md` includes instructions for the AI to:
- Read `.sdd/pipeline.md` at phase start
- Update the relevant row to `in_progress` when beginning
- Update to `done` (mechanical phases) or `approved` (human-gated phases: specify, plan) on completion

Devin ignores `.sdd/pipeline.md` — it continues using `sdd-lib.sh` + `.sdd/state.json` exclusively.

---

## Section 3 — `install.sh` changes

### New flags

```bash
bash install.sh --tool <name> --project <path>
```

- `--tool` is always paired with `--project` (error if `--project` is absent)
- Supported tool names: `claude`, `cursor`, `windsurf`, `agents`
- Assembles the adapter file from `phase-instructions.md` sources via `cat`
- Also writes `.sdd/pipeline.md` into `<project>/.sdd/` if not already present
- Never clobbers an existing adapter file — prints `skip <file> (already exists — delete it to regenerate)` and continues
- Creates the target directory (e.g. `.claude/`) if absent

### Flag matrix (complete)

| Invocation | Behavior |
|---|---|
| `bash install.sh` | Global Devin install — **unchanged** |
| `bash install.sh --project <path>` | Copy quality skills into project — **unchanged** |
| `bash install.sh --tool <name> --project <path>` | Write non-Devin adapter + `.sdd/pipeline.md` into project |
| `bash install.sh --tool <name>` (no `--project`) | Error: prints usage and exits 1 |

### No changes to `vendor.sh`

`vendor.sh` copies entire `h-*` folders. `phase-instructions.md` files live inside those folders — they are re-synced automatically.

---

## Section 4 — Toolkit layout

New files marked `← NEW`. Unchanged files not listed except where relevant.

```
sdd-toolkit-devin/
  m-sdd/
    phase-instructions.md      ← NEW — tool-agnostic shared rules
    _shared.md                 ← Devin adapter (incorporates phase-instructions.md; shell calls stay)
    sdd-lib.sh                 ← unchanged
    test_sdd_lib.sh            ← unchanged
    templates/                 ← unchanged

  m-sdd-constitution/
    phase-instructions.md      ← NEW — tool-agnostic phase logic (no shell calls, no Devin paths)
    SKILL.md                   ← Devin adapter: YAML frontmatter + phase-instructions.md content reproduced + Devin shell calls appended

  m-sdd-specify/
    phase-instructions.md      ← NEW
    SKILL.md                   ← Devin adapter (same pattern)

  m-sdd-clarify/
    phase-instructions.md      ← NEW
    SKILL.md                   ← Devin adapter

  m-sdd-plan/
    phase-instructions.md      ← NEW
    SKILL.md                   ← Devin adapter

  m-sdd-tasks/
    phase-instructions.md      ← NEW
    SKILL.md                   ← Devin adapter

  m-sdd-analyze/
    phase-instructions.md      ← NEW
    SKILL.md                   ← Devin adapter

  m-sdd-implement/
    phase-instructions.md      ← NEW
    SKILL.md                   ← Devin adapter

  m-sdd-knowledge/             ← unchanged (not a pipeline phase)
  m-sdd-checklist/             ← unchanged (not a pipeline phase)
  m-sdd-tasks-to-issues/       ← unchanged (not a pipeline phase)

  install.sh                   ← extended: --tool + --project flags
  vendor.sh                    ← unchanged
  README.md                    ← updated: multi-tool section + install examples
```

### README additions

1. **Multi-tool support** section after install steps — explains `--tool` flag with copy-paste examples for each supported tool
2. **Bundled skills table** — note that each pipeline phase has a `phase-instructions.md` as canonical source
3. **Developer `<details>` block** — note that `phase-instructions.md` is the single source of truth; `SKILL.md` is the Devin adapter

---

## Acceptance criteria

- [ ] Every pipeline phase (`constitution`, `specify`, `clarify`, `plan`, `tasks`, `analyze`, `implement`) has a `phase-instructions.md` containing no Devin-specific shell calls or `~/.config/devin/…` paths
- [ ] Every `SKILL.md` behavior is identical to today — Devin regression tests pass (`bash m-sdd/test_sdd_lib.sh`)
- [ ] `bash install.sh --tool claude --project <path>` writes `<path>/.claude/CLAUDE.md` with all phase instructions concatenated in pipeline order
- [ ] `bash install.sh --tool cursor --project <path>` writes `<path>/.cursorrules`
- [ ] `bash install.sh --tool windsurf --project <path>` writes `<path>/.windsurfrules`
- [ ] `bash install.sh --tool agents --project <path>` writes `<path>/AGENTS.md`
- [ ] Each adapter install also writes `<path>/.sdd/pipeline.md` if not already present
- [ ] `bash install.sh` (no args) works exactly as today — zero regression
- [ ] `bash install.sh --project <path>` (quality skills) works exactly as today — zero regression
- [ ] `bash install.sh --tool <name>` without `--project` exits 1 with a clear usage message
- [ ] No adapter file is clobbered if it already exists in the target project
- [ ] `bash m-sdd/test_sdd_lib.sh` passes — `sdd-lib.sh` and `_shared.md` content unchanged
- [ ] `m-sdd/_shared.md` Devin behavior is identical (shell calls, lib usage block unchanged)

---

## Alternatives considered

**Approach B — Generate from SKILL.md (strip YAML frontmatter):** Reuse existing `SKILL.md` as canonical source; `install.sh` strips frontmatter and scrubs Devin-specific lines via `perl`. Rejected in favour of A because: as the Devin and non-Devin phase instructions diverge over time (Devin gains richer shell orchestration; non-Devin gains richer Markdown-state instructions), a single file becomes a scrubbing maintenance burden. Explicit split (A) is clearer and more maintainable.

**Approach C — Independent per-tool files per phase:** Each phase directory holds `SKILL.md`, `CLAUDE.md`, `CURSOR.md`, `AGENTS.md`. Rejected — 7 phases × 4 tool files = 28 additional files that diverge immediately with no enforcement.
