# SDD Toolkit for Devin CLI (`m-sdd-*`)

**Spec-Driven Development for [Devin CLI](https://cli.devin.ai/docs).** Turn a feature idea into a reviewed spec → plan → tasks → working code, with human approval gates at each step. It replicates github/spec-kit's pipeline as a set of Devin CLI skills — no separate CLI to install.

You drive it by talking to Devin CLI. Each phase is a skill (`m-sdd`, `m-sdd-specify`, …) that writes a file you review, and records progress in `.sdd/state.json` so Devin always knows "what phase am I in."

> **Devin port notes**
> - This is a port of the original Claude Code toolkit. Skills use the `SKILL.md` format Devin reads, and the bundled `m-sdd/sdd-lib.sh` / `_shared.md` are sourced from `~/.config/devin/skills/m-sdd/` (the global install location below).
> - `install.sh` installs **globally** into `~/.config/devin/skills/` — available in all your local projects.
> - **Devin Cloud / remote agents won't see a global install.** Global skills live on your machine, not in your repo. To use these in Devin Cloud, copy the `h-*` folders into a repo's `.devin/skills/` and rewrite the `~/.config/devin/skills/m-sdd/...` sourcing paths to be repo-relative.
> - Requires `jq` (the state machine depends on it).

---

## Install it (Windows & Mac — about 10 minutes, no coding)

> **Not technical? You're in the right place.** Follow the steps for *your* computer and copy each command exactly. If a step shows an error, copy the message and send it to whoever shared this with you.

**First, make sure [Devin CLI](https://cli.devin.ai/docs) is installed and working** — you can open it and chat with it. Devin CLI already includes almost everything this toolkit needs. You'll just add one small free helper called **`jq`**, then install the toolkit folder. (No WSL required on Windows.)

<details open>
<summary><b>🪟 &nbsp;Windows</b></summary>

1. **Install the `jq` helper.** Open the Start menu, type **PowerShell**, and open it. Paste this and press Enter:
   ```
   winget install jqlang.jq
   ```
   Wait for **Successfully installed**, then close PowerShell.
2. **Get the toolkit folder.** Unzip the `sdd-toolkit` ZIP you were given — either the file sent to you directly, or downloaded from Bitbucket (open the repo → **Source** → the **⋯** menu → **Download**). Unzip it somewhere easy like your Desktop; you'll get a folder named `sdd-toolkit`.
3. **Install the skills.** Open the `sdd-toolkit` folder, right-click an empty area inside it, and choose **Open Git Bash here** (on Windows 11, click **Show more options** first). In the window that opens, paste this and press Enter:
   ```
   bash install.sh
   ```
   You'll see a few `installed …` lines ending in `Done.`
4. **Restart Devin CLI**, then type `m-sdd` (or ask *"what phase am I in?"*). It should respond.

</details>

<details>
<summary><b>🍎 &nbsp;Mac</b></summary>

1. **Open Terminal.** Press `Cmd + Space`, type **Terminal**, press Enter.
2. **Install the `jq` helper.** If you've never used Homebrew, paste this first and follow the prompts (it may ask for your Mac password — typing is invisible, that's normal):
   ```
   /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
   ```
   Then install jq:
   ```
   brew install jq
   ```
3. **Get the toolkit folder.** Unzip the `sdd-toolkit` ZIP you were given — either the file sent to you directly, or downloaded from Bitbucket (open the repo → **Source** → the **⋯** menu → **Download**). Unzip it somewhere easy like your Desktop.
4. **Install the skills.** In Terminal, type `cd ` (the word `cd` then a space), then **drag the `sdd-toolkit` folder onto the Terminal window** and press Enter. Now paste:
   ```
   bash install.sh
   ```
5. **Restart Devin CLI**, then type `m-sdd`. It should respond.

</details>

**Good to know**
- It **never overwrites your own skills.** If you already have a skill with the same name, the installer leaves yours alone.
- Fully self-contained — no accounts, no servers, nothing tied to one machine. Re-run `bash install.sh` anytime to update.
- **Uninstall:** delete the `h-*` folders the installer added — under `~/.config/devin/skills/` on Mac, or `%APPDATA%\devin\skills\` on Windows.
- **Quality companions per project:** to also drop the five quality skills into a specific project's `.devin/skills/`, run:
  ```bash
  bash install.sh --project /path/to/your-project
  ```

### Multi-tool support (Claude Code, Cursor, Windsurf, AGENTS.md)

The SDD pipeline can be installed into any project for use with tools other than Devin CLI — Claude Code, Cursor, Windsurf, or any tool that reads `AGENTS.md`.

Run this after the global install:
```bash
# Claude Code
bash install.sh --tool claude --project /path/to/your-project

# Cursor
bash install.sh --tool cursor --project /path/to/your-project

# Windsurf
bash install.sh --tool windsurf --project /path/to/your-project

# Generic (any tool reading AGENTS.md)
bash install.sh --tool agents --project /path/to/your-project
```

This writes a single Markdown adapter file (e.g. `.claude/CLAUDE.md`) and `.sdd/pipeline.md` into your project. The adapter contains the full pipeline instructions for all phases. Non-Devin tools track phase state in `.sdd/pipeline.md` (a Markdown table) instead of `sdd-lib.sh`.

Commit both files to your project repo alongside `.sdd/constitution.md` and `specs/`.

<details>
<summary>🛟 &nbsp;Something went wrong?</summary>

- **`jq: command not found`** — jq isn't installed yet, or the terminal was already open when you installed it. Redo the jq step, then **close and reopen** the terminal.
- **Typing `m-sdd` does nothing** — fully quit and reopen Devin CLI so it re-scans your skills.
- **`bad interpreter` or `'\r'` errors** — re-download the toolkit as a fresh ZIP (don't move it through other apps), then run `bash install.sh` again.
- **Still stuck** — copy the exact error text and send it to whoever shared this with you.

</details>

<details>
<summary>⚙️ &nbsp;For developers</summary>

Install `jq` without the package-manager UI: `brew install jq` (macOS) · `sudo apt install jq` (Linux) · `winget install jqlang.jq` (Windows). Optional MCPs: **context7** enriches `m-sdd-knowledge` doc links; **Atlassian** lets `m-sdd-tasks-to-issues` push tasks to Jira.

Clone and install in one go:
```bash
git clone <your-repo-url> sdd-toolkit && cd sdd-toolkit && bash install.sh
```
On Mac/Linux `install.sh` **symlinks** each `h-*` skill into `~/.config/devin/skills/` (edit-in-place); on Windows/Git Bash it **copies** them (native symlinks need Developer Mode) and marks each with a hidden `.sdd-vendored` file so re-runs update cleanly without touching skills you wrote yourself. Every skill the pipeline needs is vendored in this repo — no external skill prerequisites. Re-sync quality skills from a local `agent-skills` clone: `AGENT_SKILLS_SRC=/path/to/agent-skills/skills bash vendor.sh`

Each pipeline phase also has a `phase-instructions.md` — the tool-agnostic canonical source. `SKILL.md` is the Devin adapter (YAML frontmatter + shell calls). `vendor.sh` re-syncs both automatically.

</details>

---

## How to use it

You invoke a phase two ways, whichever feels natural:
- **Just say what you want** — *"let's start spec-driven development for a CSV export feature"* — and the matching skill triggers.
- **Name the phase** — *"run `m-sdd-specify`"*.

Run each phase **inside the project you're building** (not inside the toolkit repo). The first run scaffolds `.sdd/` and `specs/` in that project.

### The pipeline at a glance

```
constitution → specify → clarify → plan → tasks → analyze → implement → issues
   (once)        (req)    (opt)    (tech)  (list)   (opt)     (build)    (opt→Jira)
```

Each phase reads the previous artifact and writes the next. **Bold** phases below need your explicit approval before the next can start.

### Step-by-step

**0. Start / check status — `m-sdd`**
> *"Start SDD"* or *"what phase am I in?"*
Scaffolds `.sdd/` + `specs/` in your project, creates or selects a feature, and shows the pipeline status with the next step. Run it anytime to re-orient.

**1. Constitution (once per project) — `m-sdd-constitution`**
Establishes your project's principles, conventions, and guardrails (stack, testing policy, naming…). Written to `.sdd/constitution.md`; every later phase is checked against it. You approve it.
*Optional next:* `m-sdd-knowledge` builds `.sdd/knowledge.md` — project facts/glossary that ground the spec questions.

**2. Specify — `m-sdd-specify`**  ⟶ *approval gate*
A requirement-first interview. Produces `specs/<id>/spec.md` written for a product owner: **WHAT/WHY only** — prioritized user stories with Given/When/Then, measurable success criteria, **no tech detail**. You review and approve.
*Optional next:* `m-sdd-clarify` (resolve ambiguities) · `m-sdd-checklist` (requirement-quality "unit tests for English").

**3. Plan — `m-sdd-plan`**  ⟶ *approval gate*
The technical design: stack, architecture, file structure, and a **Testing Strategy** that maps each story/success-criterion to how it's verified. Written to `specs/<id>/plan.md` (+ `research.md`/`data-model.md`/`contracts/` if needed). You approve.

**4. Tasks — `m-sdd-tasks`**
Normalizes the plan into an ordered, checkable `specs/<id>/tasks.md`, with `[US#]/[SC-###]` labels tying each task back to a requirement.

**5. Analyze (optional, recommended) — `m-sdd-analyze`**
Cross-checks constitution ↔ spec ↔ plan ↔ tasks for gaps/contradictions and test/design coverage. Blocks on serious findings; writes `specs/<id>/analysis.md`.

**6. Implement — `m-sdd-implement`**  ⟶ *GO gate*
Builds the feature in an isolated branch/worktree, task by task, ticking boxes in `tasks.md`. Asks for an explicit "go" before writing any code, and finishes with merge/PR options.

**7. Issues (optional) — `m-sdd-tasks-to-issues`**
Pushes `tasks.md` to Jira as linked dev tickets (needs the Atlassian MCP).

### Where your work lives

Artifacts live **in your project**, not in the toolkit:
```
<project>/.sdd/{constitution.md, knowledge.md, config.json, state.json, templates/}
<project>/specs/<NNN-slug>/{spec.md, plan.md, tasks.md, analysis.md, design/, ...}
```
Commit `.sdd/` and `specs/` to your project repo — they're the durable record of intent.

---

## Working with designs & testing

**Already have a UI design?** (e.g. you mocked it up in an AI chat tool.) Drop the HTML — or a Figma link — into `specs/<id>/design/`. `m-sdd-specify`/`m-sdd-plan` will index it (an auto-generated `design/README.md` maps each screen to a user story) and **reference it read-only** while writing the spec and plan. It's a committed visual reference, not a tracked phase or gate.

**Testing** is woven in, not a separate phase: the spec holds the acceptance contract (Given/When/Then + `SC-###`), the plan's `## Testing Strategy` says how each is verified, `tasks.md` carries `[US#]/[SC-###]`-labelled test tasks, and `analyze` checks coverage. Whether tests are *mandatory* is a line in your constitution (default if unset: expected, not blocking).

---

## Reference

### Bundled skills
The pipeline's delegates are vendored here (vendored upstream skills gain an `h-` prefix so they never collide with your originals):

| Phase | Delegates to (bundled) |
|---|---|
| specify | — self-contained (convergent requirement-capture interview; optional upstream brainstorm via `m-ask`) |
| clarify | — self-contained (ambiguity interview of the user; the user decides, not the codebase) |
| checklist (optional) | — self-contained (`m-sdd-checklist`, spec-kit `/speckit.checklist` parity) |
| plan | `m-writing-plans` |
| implement | `m-subagent-driven-development` (or `m-executing-plans`), `m-using-git-worktrees`/`m-worktree`, `m-finishing-a-development-branch`, `m-git-commit` |
| tasks-to-issues | `m-story-breakdown` (+ Atlassian MCP) |
| quality companions (optional) | `m-security-and-hardening`, `m-performance-optimization`, `m-debugging-and-error-recovery`, `m-api-and-interface-design`, `m-frontend-ui-engineering` |

Plus transitive deps (`m-test-driven-development`, `m-requesting-code-review`, `m-receiving-code-review`). Refresh the vendored copies from your live skills with `bash vendor.sh`.

### State helpers (`m-sdd/sdd-lib.sh`)
`sdd_list` (all features, `*` = active) · `sdd_set_active <id>` (switch feature) · `sdd_status` (active feature's pipeline). Never hand-edit `.sdd/state.json`/`config.json` — go through the lib. After changing the lib, run `bash m-sdd/test_sdd_lib.sh` (dual bash+zsh suite).

### Layout
```
sdd-toolkit/
  install.sh                 # symlinks every h-* skill into ~/.config/devin/skills
  vendor.sh                  # refresh vendored upstream skills (maintainers)
  m-sdd/                     # umbrella: scaffold / status / route
    sdd-lib.sh               # jq-backed state machine (zsh-safe)
    test_sdd_lib.sh          # dual bash+zsh unit suite
    _shared.md               # cross-cutting rules (delegate, constitution, HITL gates)
    templates/               # constitution / knowledge / spec / plan / tasks / checklist / design
  m-sdd-<phase>/SKILL.md     # one folder per pipeline phase
  docs/                      # design notes, plans, audits
```

### Troubleshooting
- **Skills don't trigger:** restart Devin CLI after `install.sh`, and confirm `~/.config/devin/skills/m-sdd` is a symlink to this repo (`ls -l ~/.config/devin/skills/m-sdd`).
- **`MISSING jq`:** install `jq` (see [Install it](#install-it-windows--mac--about-10-minutes-no-coding)) — the state machine can't run without it.
- **Wrong/old skill loaded:** if you keep your own `m-ask` etc., the installer left yours in place by design; remove your copy if you want the bundled one.
