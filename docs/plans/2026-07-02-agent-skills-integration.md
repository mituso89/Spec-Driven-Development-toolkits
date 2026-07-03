# Agent-Skills Quality Pack Integration — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use m-subagent-driven-development (recommended) or m-executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Vendor five `agent-skills` quality skills into `sdd-toolkit-devin` as `h-*` companions, wire them as optional hints into three SDD phase skills, extend `vendor.sh` to re-sync them, add `--project` flag to `install.sh`, and update the README.

**Architecture:** Thin-wrapper approach — SKILL.md files copied verbatim from `agent-skills`, renamed with `h-` prefix; no logic changes to existing pipeline skills or `sdd-lib.sh`; three one-line companion notes added to `m-sdd-plan`, `m-sdd-analyze`, and `m-sdd-implement`.

**Tech Stack:** Bash (`install.sh`, `vendor.sh`), Markdown (SKILL.md files), no runtime dependencies beyond existing ones (`jq`, `perl` already used by `vendor.sh`).

---

## File Map

### Files created
- `m-security-and-hardening/SKILL.md` — verbatim copy from `agent-skills`
- `m-performance-optimization/SKILL.md` — verbatim copy from `agent-skills`
- `m-debugging-and-error-recovery/SKILL.md` — verbatim copy from `agent-skills`
- `m-api-and-interface-design/SKILL.md` — verbatim copy from `agent-skills`
- `m-frontend-ui-engineering/SKILL.md` — verbatim copy from `agent-skills`

### Files modified
- `vendor.sh` — add `== 1b. copy from agent-skills ==` block (lines after existing `== 1. copy ==`)
- `install.sh` — add `--project <path>` flag handling
- `m-sdd-plan/SKILL.md` — add optional-companion note at end of Phase 2
- `m-sdd-analyze/SKILL.md` — add optional-companion note at end of Phase 1
- `m-sdd-implement/SKILL.md` — add optional-companion note at end of Phase 0
- `README.md` — three small additions (bundled skills table, install note, developer block)

---

## Task 1: Copy the five new skill folders

**Files:**
- Create: `m-security-and-hardening/SKILL.md`
- Create: `m-performance-optimization/SKILL.md`
- Create: `m-debugging-and-error-recovery/SKILL.md`
- Create: `m-api-and-interface-design/SKILL.md`
- Create: `m-frontend-ui-engineering/SKILL.md`

- [ ] **Step 1: Copy all five SKILL.md files from agent-skills**

```bash
AGENT_SKILLS_SRC="$HOME/work/agent-skills/skills"
TOOLKIT="$(cd "$(dirname "$0")" && pwd)"  # run from toolkit root

for skill in security-and-hardening performance-optimization \
             debugging-and-error-recovery api-and-interface-design \
             frontend-ui-engineering; do
  mkdir -p "$TOOLKIT/h-$skill"
  cp "$AGENT_SKILLS_SRC/$skill/SKILL.md" "$TOOLKIT/h-$skill/SKILL.md"
  echo "copied $skill -> h-$skill"
done
```

Run from the `sdd-toolkit-devin` root:
```bash
AGENT_SKILLS_SRC="$HOME/work/agent-skills/skills" && \
for skill in security-and-hardening performance-optimization \
             debugging-and-error-recovery api-and-interface-design \
             frontend-ui-engineering; do
  mkdir -p "h-$skill"
  cp "$AGENT_SKILLS_SRC/$skill/SKILL.md" "h-$skill/SKILL.md"
  echo "copied h-$skill"
done
```

Expected output:
```
copied m-security-and-hardening
copied m-performance-optimization
copied m-debugging-and-error-recovery
copied m-api-and-interface-design
copied m-frontend-ui-engineering
```

- [ ] **Step 2: Verify all five folders and files exist**

```bash
for skill in security-and-hardening performance-optimization \
             debugging-and-error-recovery api-and-interface-design \
             frontend-ui-engineering; do
  [ -f "h-$skill/SKILL.md" ] && echo "OK h-$skill" || echo "MISSING h-$skill"
done
```

Expected: five `OK h-*` lines, no `MISSING`.

- [ ] **Step 3: Verify each SKILL.md has valid YAML frontmatter**

```bash
for skill in security-and-hardening performance-optimization \
             debugging-and-error-recovery api-and-interface-design \
             frontend-ui-engineering; do
  head -4 "h-$skill/SKILL.md"
  echo "---"
done
```

Expected: each file starts with `---`, has a `name:` line and a `description:` line.

- [ ] **Step 4: Commit**

```bash
git add m-security-and-hardening/ m-performance-optimization/ \
        m-debugging-and-error-recovery/ m-api-and-interface-design/ \
        m-frontend-ui-engineering/
git commit -m "feat: vendor five agent-skills quality companions as h-* skills

Copies security-and-hardening, performance-optimization,
debugging-and-error-recovery, api-and-interface-design, and
frontend-ui-engineering from agent-skills verbatim, renamed with h- prefix."
```

---

## Task 2: Update `vendor.sh` to re-sync the five skills

**Files:**
- Modify: `vendor.sh` — add block after existing `== 1. copy ==` section (after line 23)

- [ ] **Step 1: Read the current vendor.sh to confirm the insert point**

Open `vendor.sh`. Confirm line 23 ends the existing `== 1. copy ==` block (the last `done` of the `for s in $HSK` loop). The new block goes immediately after line 23.

- [ ] **Step 2: Add the `== 1b. copy from agent-skills ==` block**

In `vendor.sh`, after this existing block:
```bash
for s in $HSK; do
  if [ -d "$SRC/$s" ]; then rm -rf "$DEST/$s"; cp -R "$SRC/$s" "$DEST/$s"; echo "  vendored $s (as-is)"
  else echo "  WARN missing $s"; fi
done
```

Add:
```bash
# agent-skills quality companions -> vendored as h-<name>
AGENT_SKILLS_SRC="${AGENT_SKILLS_SRC:-$HOME/work/agent-skills/skills}"
AGENT_SKILLS="security-and-hardening performance-optimization \
debugging-and-error-recovery api-and-interface-design frontend-ui-engineering"

echo "== 1b. copy from agent-skills =="
for s in $AGENT_SKILLS; do
  if [ -d "$AGENT_SKILLS_SRC/$s" ]; then
    rm -rf "$DEST/h-$s"
    cp -R "$AGENT_SKILLS_SRC/$s" "$DEST/h-$s"
    echo "  vendored $s -> h-$s"
  else
    echo "  WARN missing $AGENT_SKILLS_SRC/$s"
  fi
done
```

- [ ] **Step 3: Test vendor.sh re-sync**

```bash
AGENT_SKILLS_SRC="$HOME/work/agent-skills/skills" bash vendor.sh 2>&1 | grep -E "^(== |  vendored|  WARN)"
```

Expected output includes:
```
== 1. copy ==
  vendored brainstorming -> m-brainstorming
  ...
== 1b. copy from agent-skills ==
  vendored security-and-hardening -> m-security-and-hardening
  vendored performance-optimization -> m-performance-optimization
  vendored debugging-and-error-recovery -> m-debugging-and-error-recovery
  vendored api-and-interface-design -> m-api-and-interface-design
  vendored frontend-ui-engineering -> m-frontend-ui-engineering
== 2. rewrite references ...
```

No `WARN` lines for the five new skills.

- [ ] **Step 4: Verify the five SKILL.md files are still valid after vendor.sh runs**

```bash
for skill in security-and-hardening performance-optimization \
             debugging-and-error-recovery api-and-interface-design \
             frontend-ui-engineering; do
  head -1 "h-$skill/SKILL.md"
done
```

Expected: each prints `---` (YAML frontmatter intact; vendor.sh's perl rewrites must not corrupt them).

- [ ] **Step 5: Commit**

```bash
git add vendor.sh
git commit -m "feat(vendor): add agent-skills quality companions to vendor.sh re-sync

Adds == 1b. copy from agent-skills == block. Source path is
configurable via AGENT_SKILLS_SRC env var, defaulting to
\$HOME/work/agent-skills/skills."
```

---

## Task 3: Add `--project` flag to `install.sh`

**Files:**
- Modify: `install.sh` — add flag parsing and per-project copy logic

- [ ] **Step 1: Read current install.sh to understand structure**

Open `install.sh`. Note:
- `SRC` = toolkit root (line 12)
- `DEST` = `~/.config/devin/skills` (line 13)
- The `METHOD` (symlink/copy) detection block (lines 16–19)
- The `install_one` function (lines 22–30)
- The main loop `for d in "$SRC"/h-*` (lines 32–42)

The new `--project` flag bypasses `DEST` and `METHOD`, uses a hardcoded copy to `<project>/.devin/skills/` for only the 5 quality skills.

- [ ] **Step 2: Add flag parsing and project-install function**

After the `set -euo pipefail` line (line 11) and before `SRC=...`, add:

```bash
PROJECT_DIR=""
while [[ $# -gt 0 ]]; do
  case "$1" in
    --project) PROJECT_DIR="$2"; shift 2 ;;
    *) echo "Unknown argument: $1"; exit 1 ;;
  esac
done
```

After the closing `echo "Done. Restart Devin CLI..."` line, add:

```bash
# --project: copy quality companion skills into a target project's .devin/skills/
if [ -n "$PROJECT_DIR" ]; then
  QUALITY_SKILLS="m-security-and-hardening m-performance-optimization \
m-debugging-and-error-recovery m-api-and-interface-design m-frontend-ui-engineering"
  PROJ_DEST="$PROJECT_DIR/.devin/skills"
  mkdir -p "$PROJ_DEST"
  echo "Installing quality companion skills into $PROJ_DEST"
  for skill in $QUALITY_SKILLS; do
    src="$SRC/$skill"
    target="$PROJ_DEST/$skill"
    if [ ! -d "$src" ]; then
      echo "  WARN $skill not found in toolkit — run vendor.sh first"; continue
    fi
    if [ -e "$target" ]; then
      echo "  skip $skill (already exists in project — left untouched)"; continue
    fi
    cp -R "$src" "$target"
    echo "  installed $skill -> $target"
  done
  echo "Done. Restart Devin CLI in the project to load them."
fi
```

- [ ] **Step 3: Test global install still works (no args)**

```bash
bash install.sh 2>&1 | tail -3
```

Expected: ends with `Done. Restart Devin CLI (or re-scan skills) if needed.` — no errors.

- [ ] **Step 4: Test `--project` flag**

```bash
TMPDIR=$(mktemp -d)
bash install.sh --project "$TMPDIR"
ls "$TMPDIR/.devin/skills/"
```

Expected output from `ls`:
```
m-api-and-interface-design
m-debugging-and-error-recovery
m-frontend-ui-engineering
m-performance-optimization
m-security-and-hardening
```

- [ ] **Step 5: Test no-clobber behavior**

```bash
# Pre-create one skill dir to simulate existing
mkdir -p "$TMPDIR/.devin/skills/m-security-and-hardening"
bash install.sh --project "$TMPDIR" 2>&1 | grep "security"
```

Expected: `skip m-security-and-hardening (already exists in project — left untouched)`

- [ ] **Step 6: Clean up temp dir and commit**

```bash
rm -rf "$TMPDIR"
git add install.sh
git commit -m "feat(install): add --project flag to copy quality skills into a project

bash install.sh --project /path/to/project copies the five h-* quality
companion skills into <project>/.devin/skills/. Global install behavior
(no args) is unchanged. Never clobbers existing skill directories."
```

---

## Task 4: Add optional-companion notes to three SDD phase skills

**Files:**
- Modify: `m-sdd-plan/SKILL.md` — append to Phase 2 section
- Modify: `m-sdd-analyze/SKILL.md` — append to Phase 1 section
- Modify: `m-sdd-implement/SKILL.md` — append to Phase 0 section

- [ ] **Step 1: Add companion note to `m-sdd-plan/SKILL.md`**

At the end of the `## Phase 2 — Companions, approval gate & route` section (after the `- Route to \`m-sdd-tasks\`.` line), add:

```markdown
> Optional companions: if the spec involves an API or module boundary, run `m-api-and-interface-design` while drafting the plan. If the spec involves user-facing UI, run `m-frontend-ui-engineering`. Neither blocks the approval gate.
```

- [ ] **Step 2: Add companion note to `m-sdd-analyze/SKILL.md`**

At the end of the `## Phase 1 — Cross-artifact analysis` section (after the `- Classify each finding \`blocking\` or \`non-blocking\`.` line), add:

```markdown
> Optional companions: before recording the verdict, run `m-security-and-hardening` to check for security gaps and `m-performance-optimization` to check for performance regressions. Findings from either feed into this phase's analysis.md as non-blocking notes unless the constitution mandates otherwise.
```

- [ ] **Step 3: Add companion note to `m-sdd-implement/SKILL.md`**

At the end of the `## Phase 0 — Preflight & gate` section (after the Human GO gate paragraph), add:

```markdown
> Optional companion: if implementation hits unexpected failures or test breakages, run `m-debugging-and-error-recovery` for structured root-cause triage before retrying.
```

- [ ] **Step 4: Verify no existing content was accidentally removed**

```bash
wc -l m-sdd-plan/SKILL.md m-sdd-analyze/SKILL.md m-sdd-implement/SKILL.md
```

Expected: each file's line count is its original count + 2 (the new blockquote line + a blank line before it).

Original counts: `m-sdd-plan` = 30 lines → 33; `m-sdd-analyze` = 36 lines → 39; `m-sdd-implement` = 28 lines → 31.

- [ ] **Step 5: Commit**

```bash
git add m-sdd-plan/SKILL.md m-sdd-analyze/SKILL.md m-sdd-implement/SKILL.md
git commit -m "feat(sdd): add optional quality companion hints to plan/analyze/implement

m-sdd-plan references m-api-and-interface-design and m-frontend-ui-engineering.
m-sdd-analyze references m-security-and-hardening and m-performance-optimization.
m-sdd-implement references m-debugging-and-error-recovery.
All are non-blocking opt-in companions — no sdd_require calls added."
```

---

## Task 5: Update README.md

**Files:**
- Modify: `README.md` — three additions

- [ ] **Step 1: Add quality companions row to the Bundled skills table**

Find the bundled skills table (around line 160). It currently ends with:

```markdown
| tasks-to-issues | `m-story-breakdown` (+ Atlassian MCP) |
```

Add a new row after it:

```markdown
| quality companions (optional) | `m-security-and-hardening`, `m-performance-optimization`, `m-debugging-and-error-recovery`, `m-api-and-interface-design`, `m-frontend-ui-engineering` |
```

- [ ] **Step 2: Add per-project install note to the Install section**

Find the `**Good to know**` block (around line 61). After the existing bullet list, add:

```markdown
- **Quality companions per project:** to also drop the five quality skills into a specific project's `.devin/skills/`, run:
  ```bash
  bash install.sh --project /path/to/your-project
  ```
```

- [ ] **Step 3: Add vendor.sh re-sync note to the developer `<details>` block**

Find the developer `<details>` block (around line 76). After the existing `Every skill the pipeline needs is vendored in this repo` sentence, add:

```markdown
Re-sync quality skills from a local `agent-skills` clone: `AGENT_SKILLS_SRC=/path/to/agent-skills/skills bash vendor.sh`
```

- [ ] **Step 4: Verify README renders correctly**

```bash
grep -n "quality companions" README.md
grep -n "\-\-project" README.md
grep -n "AGENT_SKILLS_SRC" README.md
```

Expected: one match per grep, at the lines just edited.

- [ ] **Step 5: Commit**

```bash
git add README.md
git commit -m "docs(readme): document quality companion skills and --project install flag

Adds quality companions row to bundled skills table, per-project
install note with bash install.sh --project example, and vendor.sh
re-sync note for maintainers."
```

---

## Task 6: Run existing tests and verify nothing is broken

**Files:** none modified — verification only

- [ ] **Step 1: Run the existing sdd-lib test suite**

```bash
bash m-sdd/test_sdd_lib.sh
```

Expected: all tests pass, no failures. (The suite tests `sdd-lib.sh` state machine functions — none of which were touched.)

- [ ] **Step 2: Verify install.sh still works end-to-end**

```bash
bash install.sh 2>&1
```

Expected: all `h-*` skills installed/linked with no errors, ends with `Done.`

- [ ] **Step 3: Verify the five new skills are present in `~/.config/devin/skills/`**

```bash
for skill in security-and-hardening performance-optimization \
             debugging-and-error-recovery api-and-interface-design \
             frontend-ui-engineering; do
  [ -e "$HOME/.config/devin/skills/h-$skill/SKILL.md" ] \
    && echo "OK h-$skill" || echo "MISSING h-$skill"
done
```

Expected: five `OK h-*` lines.

- [ ] **Step 4: Verify SKILL.md frontmatter for all five installed skills**

```bash
for skill in security-and-hardening performance-optimization \
             debugging-and-error-recovery api-and-interface-design \
             frontend-ui-engineering; do
  echo "=== h-$skill ==="
  head -4 "$HOME/.config/devin/skills/h-$skill/SKILL.md"
done
```

Expected: each has `---`, `name: <skill-name>`, `description: ...` — valid YAML frontmatter.

- [ ] **Step 5: Final commit if any loose files remain**

```bash
git status
```

If clean, done. If any unstaged changes remain from earlier steps, stage and commit them with an appropriate message.

---

## Acceptance Checklist (from design spec)

- [ ] `bash install.sh` installs all 5 new `h-*` skills into `~/.config/devin/skills/`
- [ ] `bash install.sh --project <path>` copies the 5 quality skills into `<path>/.devin/skills/`; existing skills untouched
- [ ] `AGENT_SKILLS_SRC=/path/to/agent-skills/skills bash vendor.sh` re-syncs all 5
- [ ] `m-sdd-plan/SKILL.md` mentions `m-api-and-interface-design` and `m-frontend-ui-engineering`
- [ ] `m-sdd-analyze/SKILL.md` mentions `m-security-and-hardening` and `m-performance-optimization`
- [ ] `m-sdd-implement/SKILL.md` mentions `m-debugging-and-error-recovery`
- [ ] `m-sdd/test_sdd_lib.sh` passes
- [ ] `sdd-lib.sh` is unchanged
- [ ] `m-sdd/_shared.md` is unchanged
