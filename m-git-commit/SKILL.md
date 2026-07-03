---
name: m-git-commit
description: "Draft a Conventional Commits message that passes a commit-msg hook on the first try — type, scope, subject, body, breaking changes, fixup, branch and PR titles. Triggers: git commit, commit message, conventional commits, --amend, fixup, squash, PR title, branch name."
---

# Git Commit

> **TL;DR** — Inspect diff (1) → pick type + scope (2) → format header (3) → body explains why (4) → verify hook (5).

---

## Phase 1 — Inspect

```bash
git status --short
git diff --cached --stat
git diff --cached
```

If nothing is staged, stage explicitly (`git add <path>`) — never `git add -A` or `.` to avoid sweeping secrets / unrelated changes.

---

## Phase 2 — Type + Scope

| Type | When |
|---|---|
| `feat` | New user-facing feature or new public API |
| `fix` | Bug fix |
| `refactor` | No behavior change |
| `perf` | Measurable perf win (cite the metric) |
| `docs` | Docs / README / ADR only |
| `test` | Tests only |
| `chore` | Tooling, deps, configs |
| `build` | Build scripts, packaging plumbing |
| `ci` | CI pipelines |
| `style` | Formatting only |

Scope = the package, module, or area touched (lowercase, no scope prefix). Use a path-like scope for a sub-area. **Illustrative example only** — these are not this repo's scopes:

| Scope | Meaning |
|---|---|
| `ui` | UI / component package |
| `api` | API / service layer |
| `web` | the app |
| `web/dashboard` | a route or feature inside the app |
| `repo` | root configs / workspace plumbing |

Derive the real scopes from the repo itself: check `git log --oneline -30` for the scopes already in use, and read the package/module names from the workspace manifest (e.g. `package.json` workspaces, `Cargo.toml` members).

---

## Phase 3 — Header format

```
<type>(<scope>): <imperative subject, <= 72 chars>
```

Rules:
- Subject is imperative present: "add", "fix", "rename" — not "added" / "adds".
- Lowercase the first letter unless it's a proper noun.
- No trailing period.
- Breaking change: append `!` after scope — `feat(api)!: …` — and add a `BREAKING CHANGE:` block in the body.

Examples:
```
feat(ui): add Dropdown primitive with variants
fix(web/dashboard): stream table behind a suspense boundary
refactor(api): split list schema from the wrapper
chore(repo): bump package manager version
feat(api)!: rename Item.status -> Item.statusCategory
```

---

## Phase 4 — Body (when needed)

Body required for: `feat`, `fix`, `refactor` with non-obvious motivation, anything with `!`.

```
<blank line>
Why: one-sentence rationale.

What: bullet list of substantive changes.
- …
- …

<blank line>
BREAKING CHANGE: <only when ! is used; describe migration>

<blank line>
Refs: TICKET-123  (optional)
```

Lines wrap at 100 chars.

---

## Phase 5 — Verify the hook

```bash
git commit -m "$(cat <<'EOF'
feat(ui): add Dropdown primitive

Why: filters need a >5-option selection that tabs can't host.

What:
- Dropdown component with variants
- story / example for it
- barrel export
EOF
)"
```

If the `commit-msg` hook rejects: no commit was created — the hook aborted it. Read the hook output, fix the offending part (type, scope, length, missing body for breaking change), and retry `git commit` with the corrected message. Never `--amend` here — there is nothing to amend; it would rewrite the previous, unrelated commit.

If the repo has no `commit-msg` hook: the format above still applies — just skip the hook-verification step.

---

## Fixup & squash

To fold a correction into an earlier commit on the branch:

```bash
git commit --fixup=<sha>          # marks the commit as a fixup of <sha>
git rebase --autosquash <base>    # squashes fixups into place
```

Note: `--autosquash` runs an interactive rebase under the hood — it may need harness support (a non-interactive environment can use `GIT_SEQUENCE_EDITOR=true`). Never rebase commits that are already pushed and shared.

---

## Branch / PR titles

- Branch: `<type>/<scope>-<kebab-subject>` — e.g. `feat/ui-dropdown`, `fix/web-dashboard-stream`.
- PR title: same format as the commit header. Squash merges adopt the PR title — keep it conventional.

---

## Never

- `git add -A` / `git add .` — stage explicit paths.
- `--no-verify` to bypass the hook.
- Subject longer than 72 chars.
- Empty body when `!` (breaking) is used.
- Multiple unrelated changes in one commit — split them.
