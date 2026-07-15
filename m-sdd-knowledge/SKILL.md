---
name: m-sdd-knowledge
description: "Build .sdd/knowledge.md — project facts index (stack profile, file map, glossary, doc links, decisions) grounding specify/clarify/plan. Triggers: sdd knowledge, knowledge base."
---

# SDD — Knowledge Base

> **TL;DR** — Draft `.sdd/knowledge.md` from repo discovery + context7 **and generate the `.sdd/repo-map.md` structural layer** (1) → user curates & write, recording the structural-grounding source (2) → route to specify (3). Read `<skills-root>/m-sdd/_shared.md` first.

Project-level facts/pointers, sibling to `constitution.md`. **knowledge.md = what is *true* (facts); constitution.md = what you *must do* (rules).** Optional and intentionally **not** a tracked pipeline phase — `specify`/`clarify` read it when present.

## Phase 0 — Preflight
- Read `<skills-root>/m-sdd/_shared.md`.
- `source <skills-root>/m-sdd/sdd-lib.sh; root="$(pwd)"`; ensure scaffold: `sdd_scaffold "$root"` (copies `knowledge-template.md` into `.sdd/templates/`).
- No hard gate — knowledge is project-level and optional. If `.sdd/constitution.md` is absent, suggest `m-sdd-constitution` but proceed.

## Phase 1 — Draft (assisted: discover + context7)
- **Discover:** scan `CLAUDE.md`/`AGENTS.md`, `ARCHITECTURE.md`, `README`, the manifest (`package.json`/`pyproject.toml`/`go.mod`/…), the folder layout, and the key modules. Extract a one-paragraph **stack profile**, a **pointer map** (link out — do NOT copy), and **candidate glossary terms**.
- **Structural map (generated):** run the repo-map generator to capture files +
  key symbols across the repo's languages:
  `bash <skills-root>/m-sdd-knowledge/repo-map.sh "$root"` → writes
  `$root/.sdd/repo-map.md`. This is the rot-proof machine layer; it replaces
  manual file-by-file eyeballing for structural facts. Re-runnable anytime.
- **Optional code MCP:** if a code-intelligence MCP is available in this session
  (Serena symbol tools, or CodeGraph graph tools), prefer it as the structural
  source — note it in the "Structural grounding" line below; the static map then
  serves as the offline fallback.
- **External docs:** for the project's main libraries, use the context7 MCP (`resolve-library-id` → `query-docs`) to gather authoritative doc links for *External knowledge*. If context7 is unavailable (headless/cron), skip it and record a note.
- Build a **draft** from `.sdd/templates/knowledge-template.md`.

## Phase 2 — Curate & write
- Present the draft; the user edits/approves (curation, not a hard gate).
- Keep it an **index of pointers**, not a copy — repo facts are linked (`ARCHITECTURE.md §x`, `path:line`); glossary and decisions are written inline (they live nowhere else).
- Write the result to `$root/.sdd/knowledge.md`.
- Record a **Structural grounding** line in `knowledge.md` naming the active
  source: `.sdd/repo-map.md` (generated), or the MCP name (`serena` / `codegraph`).
- Ensure the target repo ignores the generated map (it is a regenerated artifact) —
  **ask the user first** (or at minimum announce it before doing it; never touch
  `.gitignore` silently):
  `grep -qxF '.sdd/repo-map.md' "$root/.gitignore" 2>/dev/null || printf '.sdd/repo-map.md\n' >> "$root/.gitignore"`

## Phase 3 — Route
- Point to `m-sdd-specify` (next step), or `m-sdd-constitution` if rules aren't set yet.
- Refresh anytime by re-running this skill; it never gates the pipeline.

## Never
- Duplicate repo facts into knowledge.md — link to `ARCHITECTURE.md` / `path:line` instead (a copy rots).
- Hardcode a specific stack — discover it per project (this skill is portable across repos).
- Add a `knowledge` phase to `state.json` / `sdd-lib.sh` — it is intentionally not state-tracked.
- Block any phase when knowledge.md is missing — it is optional; warn and proceed.
- Put binding rules here — those belong in `constitution.md`.
- Commit or hand-edit `.sdd/repo-map.md` — it is generated; regenerate via this skill.
- Duplicate symbols from `repo-map.md` into `knowledge.md` — reference, don't copy.
