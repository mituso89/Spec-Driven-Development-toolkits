# Skills best-practice audit & fixes — 2026-07-03

Full review of all 30 skills against skill-authoring best practice (frontmatter
quality, trigger routing, progressive disclosure, cross-skill consistency,
multi-tool portability), followed by a repo-wide fix pass. `elay/` was reviewed
but deliberately **not modified** — it is a Devin/Elay product-scoped skill.

Nothing in this pass changes runtime behaviour for Devin installs: all fixes use
tool-neutral wording, and `~/.config/devin/skills` remains the documented global
example everywhere the new `<skills-root>` convention is defined.

---

## 1. Audit verdict (before fixes)

| Tier | Skills | State |
|---|---|---|
| Strong | 12 `m-sdd*` + m-story-breakdown | Uniform frontmatter, tested state lib, explicit HITL gates — but hardcoded Devin install paths and a few internal contradictions |
| Mid | Vendored process skills (brainstorming, plans, TDD, reviews, worktrees) | Excellent bodies; weak WHEN-only descriptions, leftover Devin/Superpowers artifacts, one duplicate skill pair |
| Weak shape | 5 quality guides (api, debugging, frontend, performance, security) | Good content in monolithic files; `name:` mismatched directory, dangling `references/*.md` links |

Key defects found: 9 skills sourcing `~/.config/devin/skills/m-sdd/sdd-lib.sh`
literally (broke `--tool claude` project installs); `run_subagent`/`todo_write`
tool names; 4 dangling reference links; 2 orphan reviewer prompts contradicting
their own skill; `m-worktree` vs `m-using-git-worktrees` duplication with
inverted trigger routing; constitution described as both "gates all phases" and
"advisory"; README `h-*`/`m-*` prefix drift; assorted concrete bugs (see §3).

## 2. Changes by category

### 2.1 Portability (`<skills-root>` convention)

New convention, defined once in `m-sdd/_shared.md`: `<skills-root>` = the
directory the skill was loaded from (global `~/.config/devin/skills`, or a
project's `.devin/skills` / `.claude/skills`). All hardcoded absolute paths were
replaced with it.

- `m-sdd/_shared.md` — convention definition + Library-usage `source` line.
- `m-sdd`, `m-sdd-constitution`, `m-sdd-knowledge`, `m-sdd-specify`,
  `m-sdd-clarify`, `m-sdd-plan`, `m-sdd-tasks`, `m-sdd-analyze`,
  `m-sdd-checklist`, `m-sdd-implement`, `m-sdd-tasks-to-issues` — every
  `~/.config/devin/skills/...` reference → `<skills-root>/...`.
- `m-story-breakdown` — config resolution reworded to project/global
  skills-root terms; hardcoded `mcp__mcp-atlassian__*` tool IDs → "the Atlassian
  MCP's `jira_create_issue` tool (discover the prefixed name via tool search)";
  `todo_write` → "your todo tool"; unnamed Phase-8 delegate → "a test-plan skill
  if installed, otherwise skip".
- Tool-neutral subagent wording ("dispatch a fresh general-purpose subagent
  using your platform's subagent tool") replaced `run_subagent (profile:
  subagent_general)` in `m-requesting-code-review` (SKILL.md +
  `code-reviewer.md`) and `m-subagent-driven-development` (SKILL.md + all three
  prompt templates). `todo_write` also fixed in `m-executing-plans` and
  `m-subagent-driven-development`.

### 2.2 Frontmatter & descriptions

- **Name/directory mismatch fixed** (5): the quality guides now declare
  `name: m-api-and-interface-design`, `m-debugging-and-error-recovery`,
  `m-frontend-ui-engineering`, `m-performance-optimization`,
  `m-security-and-hardening` — matching their folders like every other skill.
- **Descriptions rewritten to WHAT + WHEN + `Triggers:`** (11):
  the 5 guides (plus stack notes "Examples assume TypeScript/REST" /
  "React/Tailwind"; "or GraphQL" removed from api — the body has no GraphQL),
  `m-brainstorming`, `m-writing-plans`, `m-executing-plans`,
  `m-subagent-driven-development`, `m-test-driven-development`,
  `m-requesting-code-review`, `m-receiving-code-review`,
  `m-finishing-a-development-branch` (triggers added).
- **Routing disambiguation encoded at selection time**:
  - `m-ask` ↔ `m-brainstorming`: both descriptions now carry the boundary
    (quick inline shaping → m-ask; committed spec/design gate → m-brainstorming).
  - `m-executing-plans` ↔ `m-subagent-driven-development`: the real rule
    ("prefer subagent-driven when subagents are available") is now in the
    descriptions, replacing the opaque "separate session"/"current session".

### 2.3 Progressive disclosure (guide splits)

Code catalogs moved verbatim into new `references/` files; each SKILL.md keeps
principles/process/red-flags/verification inline plus a conditional pointer
("When X, read references/Y.md"). This also repaired all four dangling links.

| Skill | SKILL.md lines | New references/ files |
|---|---|---|
| m-security-and-hardening | 461 → 123 | owasp-patterns.md, supply-chain.md, llm-security.md, security-checklist.md |
| m-performance-optimization | 350 → 185 | optimization-patterns.md, performance-checklist.md |
| m-api-and-interface-design | 295 → 192 | rest-and-type-patterns.md |
| m-debugging-and-error-recovery | 301 → 233 | triage-and-fallbacks.md |
| m-frontend-ui-engineering | 329 → 277 | accessibility-checklist.md |

Content-level fixes made while splitting: Safe Fallback patterns gated behind
"root cause understood + user sign-off for silent defaults"; npm/Jest commands
labelled "example (Node) — adapt to the project's stack"; performance budget
numbers marked as an example template; Core Web Vitals table marked "verify at
web.dev/vitals"; missing blank line before security's `## See Also` fixed.

### 2.4 Worktree consolidation

- `m-worktree/SKILL.md` — now the **canonical merged skill**: defensive spine
  from m-using-git-worktrees (isolation detection with submodule guard, native
  harness-tool preference, consent gate, gitignore verification, dependency
  setup, baseline tests with slow-suite opt-out, sandbox fallback) + the old
  m-worktree's when-to-use table, port-per-worktree hygiene, `.env.local`
  copying, and `git worktree list`/`prune`. Steps renumbered contiguously;
  cleanup delegates to m-finishing-a-development-branch; legacy
  `~/.config/sdd-toolkit/worktrees/` demoted to backward-compat only.
  **Bug fixed**: `.env.local` was copied via `cp ../../.env.local`, which breaks
  for slash-containing branches — now copied from the main checkout root
  (`git rev-parse --git-common-dir`).
- `m-using-git-worktrees/SKILL.md` — reduced to an 8-line deprecation stub
  (kept so existing symlinks/references don't break).
- References repointed to m-worktree in `m-sdd-implement` and `README.md`.

### 2.5 Commit/PR ownership

- `m-git-commit` — scope table marked illustrative (derive real scopes from
  `git log --oneline -30` + manifest names); new "Fixup & squash" section
  (`--fixup`, `rebase --autosquash`, no rebasing shared commits) — the
  description's triggers promised it; hook-rejection advice corrected (a
  rejected commit-msg created no commit: retry `git commit`, never `--amend`);
  no-hook branch added.
- `m-finishing-a-development-branch` — base-branch detection bug fixed
  (`git merge-base` returns a commit, not a branch → replaced with
  `git rev-parse --abbrev-ref origin/HEAD` → `git show-ref` main/master → ask);
  Option 2 now delegates PR-title format to m-git-commit and defers to a
  project PR-submission skill when installed; provenance-path list annotated to
  stay in sync with m-worktree's `.worktrees/` default.

### 2.6 SDD family consistency

- Constitution is consistently **advisory** (checked by analyze), matching
  `_shared.md` Rule 2 and the lib — fixed in `m-sdd-constitution/SKILL.md`
  ("gates all downstream phases" removed) and its `phase-instructions.md`
  (status `approved` → `done`; `approved` is reserved for spec/plan). TL;DR
  renumbered to match the actual 0–3 phases with no marking step.
- `m-sdd-analyze` — "optional but recommended" → skippable gate (implement
  refuses to start until `done`/`skipped`); "borrow the rigor of
  m-requesting-code-review" → three concrete review behaviours.
- `m-sdd-tasks-to-issues` — header now "runs any time after tasks (typically
  after implement)" matching its actual gate; partial-failure path added
  (report created keys, stay `in_progress`, re-run without duplicating).
- `m-sdd-checklist` — empty-`$id` guard (route to m-sdd); note that
  specify-Phase-1.5 invocation skips Phase 1 scoping.
- `m-sdd-implement` — executor choice criteria (default
  m-subagent-driven-development; m-executing-plans for few/coupled tasks or
  inline watching); failing-tests loop-back to Phase 1; names m-worktree only.
- `m-sdd-plan` — "two overrides" → four; override-passing mechanism stated;
  companion-skill output destinations named.
- `m-sdd-specify` — cross-skill dependency made explicit (read
  `<skills-root>/m-sdd-checklist/SKILL.md` Phase 2); vague "m-ask patterns"
  removed.
- `m-sdd-tasks` — fallback for plans without checkbox steps; pre-`done`
  self-check (every US#/SC-### on ≥1 task); design-screen detail synced into
  `phase-instructions.md`.
- `m-sdd-knowledge` — `.gitignore` append now asks the user first.
- `m-sdd` — note added that `phase-instructions.md` files are install-time
  input for non-Devin adapters, not runtime reading; duplicated pipeline order
  dropped (points at `sdd_phases` in the lib).

### 2.7 De-vendoring & cleanup

- "your human partner" → "the user" (`m-receiving-code-review`,
  `m-test-driven-development` + `testing-anti-patterns.md`).
- Removed: Circle-K in-joke (replaced with a plain push-back instruction),
  "(explicit CLAUDE.md violation)" (rule stated directly), Superpowers branding
  in `m-brainstorming/scripts/frame-template.html`, the fabricated "implementer
  finished suspiciously quickly" premise in `spec-reviewer-prompt.md` (now
  "treat the report as unverified claims"), the redundant "Advantages" section
  in `m-subagent-driven-development`.
- Deleted files: `m-brainstorming/spec-document-reviewer-prompt.md` and
  `m-writing-plans/plan-document-reviewer-prompt.md` (orphans contradicting
  their skills' "review inline, not a subagent" instruction), and the junk
  `m-brainstorming/scripts/frame-template.html:sec.endpointdlp` DLP artifact.
- Path fixes: `skills/m-brainstorming/visual-companion.md` → skill-relative;
  visual-companion launch instructions made tool-neutral.
- `m-ask` — Phase-0 handoffs now name concrete skills
  (m-debugging-and-error-recovery, m-writing-plans →
  m-subagent-driven-development, m-requesting-code-review); external
  `engineering:debug` / `/code-review` references replaced.
- `m-requesting-code-review` — fragile `git log | grep "Task 1"` example
  replaced; note added that the SHA-range approach misses uncommitted work.
- `README.md` — all `h-*` prefix mentions corrected to `m-*` (install/uninstall
  instructions, layout, vendoring note); implement-phase delegate row lists
  m-worktree only.

### 2.8 New: `lint-skills.sh`

Drift guard at the repo root (`bash lint-skills.sh`, exit 1 on error). Checks
every `m-*/SKILL.md` for: frontmatter `name` == directory; description present
and ≤ 1024 chars; dangling `references/*.md` links; hardcoded
`~/.config/devin` paths (definitional skills-root examples exempt);
platform-specific tokens (`run_subagent`, `subagent_general`, `todo_write`,
`mcp__mcp-atlassian`); SKILL.md > 350 lines (warning). Consider wiring it into
CI or `vendor.sh`.

## 3. Verification

- `bash lint-skills.sh` → **0 errors**, 1 warning
  (m-test-driven-development at 375 lines — deliberate: worked examples, and it
  already has `testing-anti-patterns.md`).
- Content-integrity spot checks on the splits (SSRF/STRIDE/LLM/`<picture>`
  sections all present in their new homes; nothing dropped).
- `git status elay/` → clean (untouched).
- Diff footprint: 43 files changed (+331 / −1285) plus 9 new files
  (8 `references/*.md` + `lint-skills.sh`).

## 4. Known remaining items (deliberately deferred)

- `elay/h-pr-submission` — still Devin/Elay-bound: invalid-for-Claude
  `allowed-tools` casing, Devin-only tools (`git_update_pr`, `issue_write`),
  dangling `git-workflow`/knowledge-note references, ~90 lines duplicating
  m-git-commit with conflicting branch/PR-title conventions. Fix only if a
  Claude Code port of that skill is wanted.
- `phase-instructions.md` twin layer has no automated sync check against
  SKILL.md — a diff-lint in `vendor.sh`/CI would catch future drift.
- Cross-guide duplication (zod-validation snippet, pagination rules) still has
  two homes each; consolidation was judged not worth the churn this pass.
- `vendor.sh` re-syncs from an upstream `agent-skills` clone — re-running it
  may resurrect vendored wording fixed here; review its diff before accepting.
