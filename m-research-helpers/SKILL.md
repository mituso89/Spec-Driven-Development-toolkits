---
name: m-research-helpers
description: "Four strictly read-only research helpers - locator (find files and symbols), analyzer (explain one flow with file:line references), pattern finder (show existing examples to copy), web researcher (primary sources, cited) - dispatched as subagents so the main agent stays lean and never reads whole files itself. Used by m-sdd-plan, m-sdd-clarify and m-implement research steps. Triggers: find where, which files, locate, how does this flow work, trace this, existing pattern, example to copy, look up the docs, research helper, codebase locator, keep context small."
---

# Research Helpers (read-only)

> **TL;DR** - Pick the narrowest helper for the question (1) → dispatch it as a read-only subagent with the filled prompt template (2) → use its short structured result; read only the line ranges it points to (3).

The main agent's context is the scarce resource.
Reading whole files to answer "where is X" or "how does Y work" fills it with code that is not needed later.
These helpers do the searching and reading in their own context and return only paths, line ranges, and short findings.

## The helpers

| Helper | Ask it | It returns | Template |
|---|---|---|---|
| **Locator** | "Where is X?" - files, symbols, config, tests | Paths with line ranges, grouped, one line each. No explanations. | `./locator-prompt.md` |
| **Analyzer** | "How does this one flow work?" | A numbered walk through the flow, each step with `file:line`. | `./analyzer-prompt.md` |
| **Pattern finder** | "Show me an existing example of X to copy" | 1-3 real examples with `file:line`, a short excerpt, and what to copy or avoid. | `./pattern-finder-prompt.md` |
| **Web researcher** | "What do the official docs say about X?" | Short answers, each claim cited to a primary source URL. | `./web-researcher-prompt.md` |

Use them in this order when you know little: locator first (cheap), then analyzer or pattern finder on what it found.
Use the web researcher only for facts outside the repo: library and API behaviour, standards, version changes.

## How to dispatch

1. Fill the template: replace `{QUESTION}`, `{SCOPE}`, and `{WHY}` with one narrow question, where to look, and how the answer will be used.
Helpers are stateless and cannot ask follow-ups, so put everything they need in the prompt.
2. Dispatch it as a **subagent with read-only tools** - in Devin CLI the read-only explore profile, in Claude Code a subagent limited to read, search, and (for the web researcher) web tools.
Independent questions can run in parallel; each helper only reads.
3. Read the result, not the files.
Open a file yourself only at the line ranges a helper returned, and only when you need the exact code.
4. If a result is unsupported (no path, no line, no citation), treat it as a lead, not a fact, and re-ask more narrowly.

**No subagents in this tool?** Do the same work inline with the same discipline: search before reading, read only line ranges, and write down the same short result shape before moving on.

## Native profiles (optional)

To make a helper a named profile, create one file per helper and paste the template body (everything below its title) as the system prompt:

- **Claude Code:** `.claude/agents/<name>.md` with frontmatter `name`, `description`, and `tools: Read, Grep, Glob` (web researcher: `tools: WebSearch, WebFetch, Read`).
- **Devin CLI:** `.devin/agents/<name>.md` with frontmatter `name`, `description`, and `allowed-tools:` listing `read`, `grep`, `glob` (web researcher: `web_search`, `webfetch`, `read`).

Suggested names: `codebase-locator`, `codebase-analyzer`, `pattern-finder`, `web-researcher`.
Keep the template in this folder as the source; re-copy it when it changes.

## Never

- Give a helper write, edit, or shell-execution tools, or ask it to change anything.
- Ask a helper an open question like "tell me about the codebase"; one narrow question per dispatch.
- Paste a helper's raw file dumps back into the main context; its value is the short result.
- Let a helper decide requirements or design; it reports what exists, the caller and the user decide.

## Integration

- **m-sdd-plan** - grounds file and reuse choices (locator + pattern finder) and external facts (web researcher).
- **m-sdd-clarify** - sharpens question framing with repo facts (locator + analyzer); never answers for the user.
- **m-implement** - builds the Phase 0 context pack slice per task (locator + pattern finder).
