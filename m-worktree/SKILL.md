---
name: m-worktree
description: "Isolated git worktree per feature branch — create, bootstrap, and clean up .worktrees/<branch> for parallel work without branch switching. Triggers: worktree, parallel branch, isolated workspace, new feature branch, git worktree."
---

# Worktree

> **TL;DR** — Create `.worktrees/<branch>` (1) → bootstrap install (2) → develop in isolation (3) → clean up when done (4).

Use a worktree when you need to ship a small fix while a long-running feature is still in progress, or when running parallel agents on separate branches without install thrashing.

---

## Phase 1 — Create

From the repo root:

```bash
git worktree add .worktrees/<branch> -b <branch>
# or, checking out an existing branch
git worktree add .worktrees/<branch> <branch>
```

Add `.worktrees/` to `.gitignore` if it isn't already. Branch names follow `/m-git-commit` conventions: `feat/ui-dropdown`, `fix/api-401`.

---

## Phase 2 — Bootstrap

```bash
cd .worktrees/<branch>
<your package manager> install          # e.g. pnpm install / npm ci / yarn
cp ../../.env.local .env.local          # copy local secrets, never commit
```

The worktree shares `.git` with the main checkout but has its own dependencies. A content-addressed store (pnpm) makes the second install fast.

---

## Phase 3 — Develop

Inside the worktree, all the usual scripts work. Avoid collisions with the main checkout:

```bash
PORT=3001 <your dev script>          # different port per worktree
<your typecheck script>
<your build script>
```

Conflict avoidance:
- Use a distinct `PORT` per worktree for any dev server.
- Don't run two installs simultaneously against the same shared store — run sequentially when bootstrapping.

---

## Phase 4 — Clean up

When the branch is merged or abandoned:

```bash
# from repo root
git worktree remove .worktrees/<branch>
git branch -d <branch>            # or -D if abandoned without merge
```

To list / prune stale worktrees:

```bash
git worktree list
git worktree prune
```

---

## When to use vs when not

| Scenario | Use worktree? |
|---|---|
| Hotfix on `main` while a feature branch is in progress | Yes |
| Parallel agents on independent branches | Yes |
| Quick edit on the active branch | No — just edit |
| Long-running migration with codegen | Yes |
| Reviewing someone else's PR locally | Yes |

---

## Never

- Commit the `.worktrees/` directory — gitignore it.
- `rm -rf .worktrees/<branch>` instead of `git worktree remove` — leaves stale metadata.
- Share a `.env.local` symlink across worktrees — copy the file so divergent secrets don't leak.
- Open the same dev server port in two worktrees — set `PORT` per worktree.
- `--no-verify` to bypass hooks inside a worktree — the hook is the same.
