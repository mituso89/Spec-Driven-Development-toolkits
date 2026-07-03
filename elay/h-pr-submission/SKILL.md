---
name: h-pr-submission
description: >
  Elay product — full git-to-PR workflow: craft a Conventional Commits message,
  branch correctly, run quality gates, and submit a compliant Draft PR with ADO
  story, description template, label, and assignee.
  Triggers: create PR, submit PR, open pull request, finish branch, push and PR,
  git commit PR, conventional commits PR, PR submission, PR checklist.
allowed-tools:
  - read
  - grep
  - glob
  - exec
  - edit
  - write
---

# Elay — Git Commit → Pull Request Workflow

> **TL;DR** — Commit (1–5) → Branch & push (6–7) → Quality gates (8–9) → Create PR (10–14).

---

## Phase 1 — Inspect staged changes

```bash
git status --short
git diff --cached --stat
git diff --cached
```

Stage explicit paths only — **never** `git add -A` or `git add .`.

---

## Phase 2 — Pick type + scope (Conventional Commits)

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

> **Note:** The `git-workflow` skill also allows `bug` as an alias for `fix` in commit messages. Both are accepted.

Scope = the package, module, or area touched (lowercase). Adapt to repo manifest names.

---

## Phase 3 — Header format

```
<type>(<scope>): <imperative subject, <= 72 chars>
```

Rules:
- Imperative present: "add", "fix", "rename" — not "added" / "adds".
- Lowercase first letter unless proper noun. No trailing period.
- Breaking change: append `!` after scope and add `BREAKING CHANGE:` block in body.

Examples:
```
feat(auth): add JWT token validation
fix(api): resolve null pointer in user endpoint
refactor(cache): simplify redis connection handler
chore(repo): bump package manager version
feat(api)!: rename Item.status -> Item.statusCategory
```

> **IMPORTANT:** Do **NOT** add any attribution footer (no "Generated with Devin", no "Co-Authored-By") to commit messages. Keep them clean.

---

## Phase 4 — Body (when needed)

Body required for `feat`, `fix`, `refactor` with non-obvious motivation, or anything with `!`.

```
<blank line>
Why: one-sentence rationale.

What:
- bullet list of substantive changes

<blank line>
BREAKING CHANGE: <only when ! is used; describe migration>

<blank line>
Refs: TICKET-123  (optional)
```

Lines wrap at 100 chars.

---

## Phase 5 — Verify the commit-msg hook

```bash
git commit -m "$(cat <<'EOF'
feat(auth): add JWT token validation

Why: endpoints need stateless auth without session storage.

What:
- JWT middleware with RS256 verification
- token refresh endpoint
- unit tests for edge cases
EOF
)"
```

If the hook rejects: read hook output, fix the offending part, create a **new** commit — never `--amend` after a hook failure unless explicitly asked.

---

## Phase 6 — Branch naming

| Work type | Pattern | Example |
|---|---|---|
| Feature | `feat/[ticket-id]-description` | `feat/1753818-add-user-auth` |
| Bug | `bug/[ticket-id]-description` | `bug/1753818-fix-login-bug` |
| Hotfix | `hot/[ticket-id]-description` | `hot/1753818-patch-security` |
| No ticket | `feat/description` | `feat/admin-panel-improvements` |

> Do **NOT** generate a ticket ID if the user hasn't provided one.

### Base branch selection

| Work type | Branch from |
|---|---|
| Features / Bugs | `dev` |
| Hotfixes | `main` |

### Working on an existing feature branch

1. Do **NOT** commit directly to the feature branch.
2. Create a new branch from it: `feat/[ticket-id]-description`.
3. Open the PR **to that feature branch** (not to `dev`).

---

## Phase 7 — Push

```bash
git push origin <branch-name>
```

---

## Phase 8 — CodeScene delta analysis (mandatory before PR)

Run locally and fix **ALL** code health issues before pushing to a PR:

```bash
cs delta dev   # or the appropriate base branch
```

See the "CodeScene" knowledge note for full CLI usage.

---

## Phase 9 — SonarQube analysis (mandatory before PR)

Run locally and ensure 100% Quality Gate compliance:

- Code coverage of new code: ≥ 80 %
- Code duplication of new code: < 3 %
- Zero open bugs, vulnerabilities, code smells
- All security hotspots reviewed and resolved
- All tests pass, all linting issues resolved

See the "SonarQube" knowledge note for full CLI usage.

Verify compliance once more after fixing issues.

---

## Phase 10 — User approval (BLOCKING)

**NEVER push commits to Git or create a Pull Request without explicit user approval.**

Before pushing or creating a PR:
1. Notify the user that changes are ready.
2. Summarise what was changed (files modified, key changes).
3. **Wait for explicit approval.**

---

## Phase 11 — ADO story check (BLOCKING)

If the ADO story ID is **not** explicitly provided, ask the user:

> **What is the relevant ADO story ID for this PR (e.g. AB#123456)?**

| Scenario | PR title prefix | PR description line |
|---|---|---|
| ID provided | `[AB#123456] …` | `Relevant ADO Story: AB#123456` |
| No ID | `[AB#N/A] …` | `Relevant ADO Story: AB#N/A` + justification in Insights |

> `[AB#TICKETID]` goes in **PR title and description only** — never in commit messages.

---

## Phase 12 — PR title

```
[AB#TICKETID] Short, clear description of the change
```

Use the ADO ticket title as the description when working on an ADO ticket.

---

## Phase 13 — PR description (mandatory template)

Do **NOT** rely on auto-generated descriptions. Manually create using this template:

```
Relevant ADO Story: AB#123456




## What Changed


Describe the changes introduced by this pull request.
If the PR is a work in progress, include a checklist of planned changes.




## Insights


Explain:
- Why this solution was chosen
- Alternatives considered and rejected (if any)
- How reviewers can verify the changes


If no ADO story exists, justify the use of AB#N/A here.




## Proof of Work


Provide evidence that the changes work as intended, such as:
- Screenshots (preferred)
- GIFs
- Logs or console output
- Test results
```

After creating the PR, immediately update the description using `git_update_pr`. Do **NOT** skip this step even if the PR tool auto-generated something.

### Keeping the description in sync

Every time you push new commits to an existing PR:
1. Read the current description (`git_view_pr`).
2. Diff it against `git diff --merge-base <base>` and `git log <base>..HEAD`.
3. Update if: new files added/removed, approach changed, new insights, checklist items completed, new proof of work.
4. Preserve the template structure; use `- [x]` / `- [ ]` checklists in "What Changed".
5. Never remove previously documented context unless it is now incorrect.

---

## Phase 14 — Create the PR (Draft)

All PRs **MUST** be created as Draft. Mark as Ready for Review only after initial feedback is addressed.

### Label (exactly one required)

| Label | Use for |
|---|---|
| `type: feature` | New feature or behavior change |
| `type: bug` | Bug fix |
| `type: chore` | Refactoring or non-functional work |
| `type: hotfix` | Urgent production fix |
| `type: release` | Release preparation |
| `type: security` | Security fix or hardening |

Apply via `issue_write` (GitHub repos — `github-elay` MCP):
```
issue_write(method="update", owner=..., repo=..., issue_number=<PR#>, labels=["type: bug"])
```

> For Azure DevOps repos (`access-devops/Elay/*`), use ADO tags or work item links instead of labels.

### Assignee

Assign the PR to the original requester. For GitHub repos use `issue_write` (not `update_pull_request`):
```
issue_write(method="update", owner=..., repo=..., issue_number=<PR#>, assignees=["<github-username>"])
```
Call `get_me` first to get the authenticated username. Send `labels` and `assignees` as **separate** `issue_write` calls.

---

## PR Creation Checklist (verify all before notifying user)

- [ ] User explicitly approved push and PR creation
- [ ] PR title: `[AB#TICKETID] Description`
- [ ] PR description: manually created using the template above
- [ ] Assignee set (via `issue_write`)
- [ ] Exactly one `type:` label applied (via `issue_write`)
- [ ] PR created as **Draft**

---

## Never

- `git add -A` / `git add .` — stage explicit paths only.
- `--no-verify` to bypass the commit-msg hook.
- Subject longer than 72 chars.
- Empty body when `!` (breaking change) is used.
- Multiple unrelated changes in one commit — split them.
- Push or create a PR without explicit user approval.
- Guess or invent an ADO story ID.
- Resolve merge conflicts automatically — always ask first and propose a resolution plan.
