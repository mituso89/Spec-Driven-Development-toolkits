---
name: m-sdd-decision
description: >
  Route open spec, scout or build questions on a ticket to the person who
  should decide: product questions to the ticket's creator or requester,
  engineering questions to whoever made the conflicting earlier work (found via
  PR and commit history), with the evidence recorded. Questions for the person
  running the session stay in chat. Builds one question thread per ticket in a
  fixed format (linked ticket, numbered questions, options with examples,
  recommendation, blocks-the-build, default, one-line reply), keeps the decision
  log in specs/<id>/decisions.md, and hands posting and ticket write-back to a
  project-defined step. Called by m-sdd-clarify, m-sdd-plan and m-sdd-implement.
  Triggers: spec decision, sdd decision, ask the PO, who should I ask, open
  question on ticket, conflicting earlier work, blocking question, decision log,
  who owns this decision.
---

# SDD - Decision routing

> **TL;DR** - Load config (0) -> list the open questions and find each owner with evidence (1) -> split: session user in chat, everyone else in one thread per ticket (2) -> build the post (3) -> hand it to the project's post step (4) -> log every question (5) -> collect answers (6) -> hand the answer to the project's write-back step (7).

This skill decides **who** to ask, **what** to ask and **what was decided**.
**How** a post reaches people (chat tool, channel, mentions) and **how** a ticket is updated (tracker, fields, comments) belong to the project, through the extension points in Phase 4 and Phase 7.
Never hard-code a tracker API, chat API, channel, field name or person in this skill.

## When to use

- A spec, scout or build has an open product or engineering question on a ticket.
- `m-sdd-clarify`, `m-sdd-plan` or `m-sdd-implement` hands over a question whose owner is not the person running the session.
- Someone asks "who should decide this?".

## Two rules

1. **Only post when someone else must answer.** A question the session user owns is asked in chat and never posted. Nothing else is posted either: no recaps, no summaries, no "thanks, noted" replies.
2. **Every ticket reference is a link.** Build it from `ticketLinkTemplate` and write it as `[<ref>](<url>)` everywhere this skill writes: the post, chat, the log, the write-back record. Never rely on a tool auto-linking a bare reference.

## Phase 0 - Config

Resolve config in order, first hit wins: `<project skills root>/m-sdd-decision/config.json` -> `<global skills root>/m-sdd-decision/config.json` -> `<skill-dir>/config.example.json`.
If only the example was found, tell the user once to copy it to `config.json` and fill it in.

| Key | Use |
|---|---|
| `ticketRefFormat` | How a ticket is written, with `{id}`, e.g. `PROJ-{id}`. |
| `ticketLinkTemplate` | Ticket URL with `{id}`. If unset, ask once; never guess a tracker URL. |
| `sessionUser` | Identity of the person running the session (tracker or git). Their questions go to chat. If unset, ask once. |
| `language` | Language of the post, log and write-back. Default `en`. |
| `decisionLogPath` | Log path when there is no SDD feature (Phase 5). |
| `delivery.post`, `delivery.collect`, `delivery.writeBack` | The project's extension points (Phase 4, 6, 7). Unset means hand back to the caller. |

`config.json` is gitignored. Never commit names, e-mails, user ids, channel ids or tokens.

## Phase 1 - Questions and owners

Read the ticket in full first (description, acceptance criteria, comments, linked tickets).
Write each open question in one sentence and classify it:

- **Product** - what the user sees, scope, wording, behaviour, priority.
  Owner: the requester named in the ticket (a "requested by" line, a stakeholder field, or the person a comment says asked for it); otherwise the ticket's creator.
- **Engineering** - the question exists because the new work conflicts with something already built (code, contract, package layout, an earlier ticket's decision).
  Owner: the person who made that earlier work, first hit wins:
  1. Author of the PR that introduced it (find the commit with `git log -S '<symbol>' --oneline` or `git blame -L <start>,<end> <file>`, then the PR that merged it).
  2. Author of that commit when no PR exists.
  3. Assignee of the earlier ticket that delivered it.
  4. Fallback: ask the session user who owns it. Never guess.

Skip bots and service accounts.
Record the evidence for every owner as one linked line, for example "created [PROJ-123](...)" or "authored [PR 45](...) that built the current filter panel".

## Phase 2 - Split

- Owner is `sessionUser` -> ask in chat now, one question at a time, with the same question block as Phase 3. Do not post it.
- Every other owner -> one thread per ticket holding all of that ticket's questions.

For each question decide **blocks the build: yes/no**.
It blocks when the answer changes the data model, an API or package contract, user-visible scope, or anything expensive to undo.
Otherwise it does not block: name the **default** used meanwhile (normally your recommendation) and keep working on it.

## Phase 3 - The post

Produce a **post package**: subject, body (Markdown), and the mention list.

- **Subject:** `[<ref>] <short title>`, under 80 characters, plain text.
- **Body**, top to bottom:
  1. Header: `<linked ref> · <short title>`.
  2. Owner line: `<N> question(s) · for @<owner> (<why them, with the evidence link>)`; several owners are each listed once: `for @a (...) and @b (...)`.
  3. A rule (`---`).
  4. Per question:
     - `Q<n> · **<question ending in ?>**`, followed by `(for <owner>)` when there are several owners.
     - `Situation:` the facts in plain words, evidence linked inline (PRs, files pinned to a commit, linked tickets).
     - Options `a)`, `b)`, `c)`, each with a concrete example from this product (a real screen, flow, module or user action).
     - `Recommendation: <letter> - <reason>`.
     - `Blocks the build: yes` or `Blocks the build: no`.
     - `Default if no answer: <letter> - <option>`, or `Default if no answer: none - the build waits` when it blocks.
  5. A rule (`---`).
  6. `Reply in one line: Q1: a - because ...` (one line per question). A bare `Q1: a` is valid; anything outside the options is `Q1: other - ...`.
- **Mention list:** each owner's identity as found in Phase 1 (tracker or git) and the question numbers they own. The project's post step maps identities to its chat tool's mentions.
- Short enough to read on a phone. No greetings, sign-offs or recap.

A complete example is in `references/example-post.md`.

## Phase 4 - Post (extension point)

Show the user the post package and get an OK.
Then hand it to `delivery.post` - a project skill or documented step that knows the chat tool, the channel and how to mention people.
That step returns the thread link, which goes in the log.
If `delivery.post` is unset or fails, hand the exact post package back to the caller to send, and log the question with `Asked: <date> - handed back for posting`.

## Phase 5 - Decision log

Append one entry per question - chat questions included - when it is asked; update it when answered.
Path: `specs/<feature-id>/decisions.md` when an SDD feature is active (`.sdd/` exists), otherwise `decisionLogPath`.
Create the file with a `# Decisions` heading if missing. Ids `D-001`, `D-002`, ... are per file.

```markdown
## D-001 - <short question title>
- Ticket: [<ref>](<ticket url>)
- Kind: product | engineering
- Owner: <name> - <evidence with link>
- Status: open | answered
- Blocks build: yes | no
- Default if no answer: <letter - option, or "none - the build waits" when it blocks>
- Question: <the question line>
- Asked: <YYYY-MM-DD> in [thread](<thread url>) | in chat
- Answer: <letter - reason as given>
- Answered by: <name>
- Answered on: <YYYY-MM-DD>
- Changes what must be built: yes | no
- Links: [PR <n>](<url>), [<file>](<url>), [<ref>](<url>)
```

`Status:` and `Blocks build:` are the contract the SDD phases read: `m-sdd-plan` and `m-sdd-implement` stop while any entry is `Status: open` with `Blocks build: yes`.

## Phase 6 - Collect answers

Get the replies through `delivery.collect`, or ask the caller to paste them.
Parse `Q<n>: <letter|other> - <reason>` per line.
An answer counts only from the question's owner, or from someone the owner or session user names in the thread; anything else, or an unclear reply, goes to the session user in chat.
Update the log entry to `Status: answered`, and set `Changes what must be built`.
Do not post a confirmation; the write-back is the record.
In an SDD feature, product answers go back to `m-sdd-clarify` Phase 2 to fold into the spec (it owns re-approval); engineering answers feed `m-sdd-plan`.

## Phase 7 - Write back (extension point)

Hand each answered entry to `delivery.writeBack` - a project skill or documented step that knows the tracker.
`m-board` can serve as that step for teams whose board it supports; it is one option, not a requirement.
Pass it the **decision record**: the log entry plus a short ready-to-use text in `language` - question, answer, who answered, date, and links (ticket, thread, PRs) all written as links.
When `Changes what must be built: yes`, also pass the acceptance-criteria line to add, suffixed `(D-NNN, <date>)`.
What the project step must honour: read before writing, keep existing ticket text (add, never reword or delete), and read back to verify.
If `delivery.writeBack` is unset, hand the decision record back to the caller.

## Never

- Post a question the session user owns, or post any recap, summary or acknowledgement.
- Write a bare ticket reference or bare URL anywhere this skill writes.
- Guess an owner, or commit a name, identity or channel.
- Call a tracker or chat API from this skill - that is the project's delivery step.
- Mark a question non-blocking just to keep going when its answer would change a contract or user-visible scope.
