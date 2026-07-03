---
name: m-worktree
description: "Isolated git worktree per feature branch — create, bootstrap, and clean up .worktrees/<branch> for parallel work without branch switching. Triggers: worktree, parallel branch, isolated workspace, new feature branch, git worktree, isolate my changes, work in parallel, don't touch my current branch."
---

# Worktree

## Overview

Ensure work happens in an isolated workspace. Prefer your platform's native worktree tools. Fall back to manual git worktrees only when no native tool is available.

**Core principle:** Detect existing isolation first. Then use native tools. Then fall back to git. Never fight the harness.

**Announce at start:** "I'm using the m-worktree skill to set up an isolated workspace."

## When to use vs when not

| Scenario | Use worktree? |
|---|---|
| Hotfix on `main` while a feature branch is in progress | Yes |
| Parallel agents on independent branches | Yes |
| Quick edit on the active branch | No — just edit |
| Long-running migration with codegen | Yes |
| Reviewing someone else's PR locally | Yes |

## Step 0: Detect Existing Isolation

**Before creating anything, check if you are already in an isolated workspace.**

```bash
GIT_DIR=$(cd "$(git rev-parse --git-dir)" 2>/dev/null && pwd -P)
GIT_COMMON=$(cd "$(git rev-parse --git-common-dir)" 2>/dev/null && pwd -P)
BRANCH=$(git branch --show-current)
```

**Submodule guard:** `GIT_DIR != GIT_COMMON` is also true inside git submodules. Before concluding "already in a worktree," verify you are not in a submodule:

```bash
# If this returns a path, you're in a submodule, not a worktree — treat as normal repo
git rev-parse --show-superproject-working-tree 2>/dev/null
```

**If `GIT_DIR != GIT_COMMON` (and not a submodule):** You are already in a linked worktree. Skip to Step 2 (Bootstrap). Do NOT create another worktree.

**If `GIT_DIR == GIT_COMMON` (or in a submodule):** You are in a normal repo checkout.

Has the user already indicated their worktree preference in your instructions? If not, ask for consent before creating a worktree:

> "Would you like me to set up an isolated worktree? It protects your current branch from changes."

Honor any existing declared preference without asking. If the user declines consent, work in place and skip to Step 2.

## Step 1: Create Isolated Workspace

**You have two mechanisms. Try them in this order.**

### 1a. Native Worktree Tools (preferred)

Do you already have a way to create a worktree? It might be a tool with a name like `EnterWorktree`, `WorktreeCreate`, a `/worktree` command, or a `--worktree` flag. If you do, use it and skip to Step 2.

Native tools handle directory placement, branch creation, and cleanup automatically. Using `git worktree add` when you have a native tool creates phantom state your harness can't see or manage.

### 1b. Git Worktree Fallback

**Only use this if Step 1a does not apply.**

#### Directory Selection

Follow this priority order. Explicit user preference always beats observed filesystem state.

1. **Check your instructions for a declared worktree directory preference.** If the user has already specified one, use it without asking.
2. **Check for an existing project-local directory:** `.worktrees/` (preferred, hidden) or `worktrees/`. If both exist, `.worktrees/` wins.
3. **If there is no other guidance available**, default to `.worktrees/` at the project root.
4. **Backward compat only:** if a legacy global directory `~/.config/sdd-toolkit/worktrees/<project>/` already exists, you may keep using it — but never create it fresh.

#### Safety Verification (project-local directories only)

**MUST verify the directory is ignored before creating a worktree:**

```bash
git check-ignore -q .worktrees 2>/dev/null || git check-ignore -q worktrees 2>/dev/null
```

**If NOT ignored:** Add to `.gitignore`, commit the change, then proceed. This prevents accidentally committing worktree contents to the repository.

#### Create the Worktree

Branch names follow `m-git-commit` conventions: `feat/ui-dropdown`, `fix/api-401`.

```bash
git worktree add .worktrees/<branch> -b <branch>
# or, checking out an existing branch
git worktree add .worktrees/<branch> <branch>
cd .worktrees/<branch>
```

**Sandbox fallback:** If `git worktree add` fails with a permission error (sandbox denial), tell the user the sandbox blocked worktree creation and you're working in the current directory instead. Then run setup and baseline tests in place.

## Step 2: Bootstrap

The worktree shares `.git` with the main checkout but has its own dependencies and local config.

Auto-detect and run appropriate setup:

```bash
# Node.js
if [ -f package.json ]; then npm install; fi   # or pnpm install / yarn

# Rust
if [ -f Cargo.toml ]; then cargo build; fi

# Python
if [ -f requirements.txt ]; then pip install -r requirements.txt; fi
if [ -f pyproject.toml ]; then poetry install; fi

# Go
if [ -f go.mod ]; then go mod download; fi
```

Copy untracked local config from the main checkout root (never commit it):

```bash
MAIN_ROOT=$(git -C "$(git rev-parse --git-common-dir)/.." rev-parse --show-toplevel)
[ -f "$MAIN_ROOT/.env.local" ] && cp "$MAIN_ROOT/.env.local" .env.local
```

Don't compute the source path with `../..` relative hops — slash-containing branch names (`feat/ui-dropdown`) nest the worktree deeper and break the copy.

## Step 3: Verify Clean Baseline

Run tests to ensure the workspace starts clean:

```bash
# Use project-appropriate command
npm test / cargo test / pytest / go test ./...
```

**If tests fail:** Report failures, ask whether to proceed or investigate.
**If tests pass:** Report ready: "Worktree ready at `<full-path>`, tests passing (<N> tests, 0 failures)."

**Opt-out:** if the suite is known to be very slow (many minutes), tell the user and ask whether to skip the baseline run instead of silently burning time.

## Step 4: Develop

Inside the worktree, all the usual scripts work. Avoid collisions with the main checkout:

- Use a distinct `PORT` per worktree for any dev server (`PORT=3001 <your dev script>`).
- Don't run two installs simultaneously against the same shared store — run sequentially when bootstrapping.

## Step 5: Clean up

When the branch is merged or abandoned, use the `m-finishing-a-development-branch` skill — it verifies tests, presents merge/PR/keep/discard options, and owns worktree removal.

Maintenance commands for listing / pruning stale worktrees:

```bash
git worktree list
git worktree prune
```

## Never

- Create a worktree when Step 0 detects existing isolation.
- Use `git worktree add` when you have a native worktree tool. This is the #1 mistake — if you have it, use it.
- Create a project-local worktree without verifying the directory is gitignored.
- Commit the `.worktrees/` directory.
- `rm -rf .worktrees/<branch>` instead of `git worktree remove` — leaves stale metadata.
- Share a `.env.local` symlink across worktrees — copy the file so divergent secrets don't leak.
- Open the same dev server port in two worktrees — set `PORT` per worktree.
- `--no-verify` to bypass hooks inside a worktree — the hook is the same.
- Skip baseline test verification (unless the user opted out for a slow suite).
