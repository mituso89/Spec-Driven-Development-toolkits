---
name: m-sdd-decision
description: >
  Outreach (Elay) product - route open spec, scout or build questions on an
  Outreach ADO ticket to the right person: product questions to the ticket's
  creator or requester, engineering questions to whoever made the conflicting
  earlier work. Posts one English question thread per ticket to the team's
  Teams spec decision channel (every AB# linked), keeps a decision log, and
  writes the answered decision back to the ticket as a linked ADO comment.
  Questions for the person running the session are asked in chat, never posted.
  Triggers: spec decision, sdd decision, ask the PO, who should I ask, open
  question on ticket, conflicting earlier work, blocking question, decision log,
  post question to Teams, spec decision channel, record the answer on the ticket.
allowed-tools:
  - read
  - grep
  - glob
  - exec
  - edit
  - write
---

# Outreach - SDD decision routing

> **TL;DR** - Load config (0) -> list the open questions and find each owner with evidence (1) -> split: session user in chat, everyone else in one Teams thread per ticket (2) -> build the post (3) -> post or hand back the exact post (4) -> log every question (5) -> collect answers (6) -> write the answer back to the ticket (7).

Built for the Outreach (Elay) team: tickets in Azure DevOps, questions in a Teams spec decision channel.
The layout below is the Outreach format; do not swap in another team's question style.
All posted text, log entries and ticket comments are in English.

## When to use

- A spec, scout or build has an open product or engineering question on an Outreach ticket (`AB#<id>`).
- `m-sdd-clarify`, `m-sdd-plan` or `m-sdd-implement` hands you a question whose owner is not the person running the session.
- Someone asks "who should I ask about this?" for an Outreach ticket.

## The two rules that shape everything

1. **Only post when someone else must answer.** A question for the session user is asked in chat and never posted. Nothing else is ever posted either: no recaps, no summaries, no "thanks, noted" replies.
2. **Every ticket reference is a link.** Every `AB#<id>` you write - in Teams, in chat, in the log, in an ADO comment - links to `https://dev.azure.com/<org>/<project>/_workitems/edit/<id>` (org and project from config, defaults `access-devops` / `Elay`). In Markdown write `[AB#<id>](<url>)`; in HTML write `<a href="<url>">AB#<id></a>`. Bare `AB#<id>` and bare URLs are not rendered as links by ADO comments, so never rely on auto-linking.

## Phase 0 - Config

Resolve config in order, first hit wins: `<project skills root>/m-sdd-decision/config.json` -> `<global skills root>/m-sdd-decision/config.json`.
If neither exists, read `config.example.json`, tell the user once to copy it to `config.json` next to it and fill it in, and continue in **hand-back mode** (Phase 4) with org/project defaults.

| Key | Use |
|---|---|
| `ado.organization`, `ado.project` | Ticket links and ADO API calls. Defaults `access-devops`, `Elay`. |
| `sessionUser` | ADO unique name of the person running the session. Questions they own go to chat. If unset, ask once. |
| `teams.teamId`, `teams.channelId`, `teams.channelName` | The spec decision channel. Ids come only from here - never guess, search for or hard-code them. |
| `people` | ADO unique name -> Teams `displayName` + `aadUserId` for @mentions. Mention ids come only from here. |
| `decisionLogPath` | Log path when there is no SDD feature (Phase 5). |

`config.json` is gitignored. Never commit names, e-mails, user ids, Teams ids or tokens.

## Phase 1 - Questions and owners

Read the ticket in full first: title, description, acceptance criteria, repro steps, comments and links (`System.Description` and `Microsoft.VSTS.TCM.ReproSteps` both).
Then write each open question in one sentence and classify it:

- **Product** - what the user sees, scope, wording, behaviour, priority.
  Owner: the requester named in the ticket (a "Requested by" line, a stakeholder field, or the person a comment says asked for it); otherwise the ticket creator (`System.CreatedBy`).
- **Engineering** - the question exists because the new work conflicts with something already built (code, contract, package layout, an earlier ticket's decision).
  Owner: the person who made that earlier work, found in this order and stopping at the first hit:
  1. Author of the PR that introduced it (find the commit with `git log -S '<symbol>' --oneline` or `git blame -L <start>,<end> <file>`, then the PR that merged it).
  2. Author of that commit when no PR exists.
  3. `System.AssignedTo` of the earlier ticket that delivered it.
  4. Fallback: ask the session user who owns it. Never guess.

Skip bots and service accounts.
Record the evidence for every owner as one line you can link, for example "created [AB#2897973](...)" or "authored [PR 1931](...) that built the Contacts filter panel".
If the owner is not in `config.people`, ask the session user to add them; until then hand back the post with a plain-name placeholder instead of a broken mention.

## Phase 2 - Split

- Owner is `sessionUser` -> ask in chat now, one question at a time, using the same question block as Phase 3 (options, recommendation, blocks-the-build). Do not post it.
- Every other owner -> one Teams thread per ticket holding all of that ticket's questions; every owner is @mentioned once in the owner line.

For each question decide **blocks the build: yes/no**.
It blocks when the answer changes the data model, an API or package contract, user-visible scope, or anything expensive to undo.
Otherwise it does not block: name the **default** you will use (normally your recommendation) and keep working on it.

## Phase 3 - The Outreach post

- **Subject** (Teams thread subject, plain text): `[AB#<id>] <short title>` - under 80 characters. Teams subjects cannot hold links, so the body opens with the ticket as a link.
- **Body** (HTML), top to bottom:
  1. Header: `<linked AB#id> · <short title>`.
  2. Owner line: `<N> question(s) · for @<owner> (<why them, with the evidence link>)`. With several owners, list each one once here: `for @A (...) and @B (...)`.
  3. A rule (`<hr>`).
  4. Per question, in order:
     - `Q<n> · <bold question ending in ?>`. With several owners, follow it with `(for <owner name>)` so each person sees which question is theirs.
     - `Situation:` the facts in plain words, with the evidence linked inline (PRs, files pinned to a commit, earlier tickets as linked `AB#<id>`).
     - Lettered options `a)`, `b)`, `c)` - each with a concrete Outreach example (a real screen, list, flow, package or user action).
     - `Recommendation: <letter> - <reason>`.
     - `Blocks the build: yes` or `Blocks the build: no`.
     - `Default if no answer: <letter> - <option>` when it does not block; `Default if no answer: none - the build waits` when it does.
  5. A rule (`<hr>`).
  6. `Reply in one line: Q1: a - because ...` (one line per question when there are several). A bare `Q1: a` is valid; anything outside the options is `Q1: other - ...`.
- Keep it short enough to read on a phone. No greetings, sign-offs or recap.

A complete rendered example ([AB#2897973](https://dev.azure.com/access-devops/Elay/_workitems/edit/2897973), shared filter panel package question), its HTML, the Graph payload, a reply, the log entry and the ADO write-back are in `references/example-post.md`.
Match that layout exactly.

## Phase 4 - Post or hand back

Show the user the exact post (subject, rendered body, who gets mentioned) and get an OK before sending.

- **Teams route available** (a Microsoft Graph route such as an MCP connector for Teams channel messages, or a Graph token allowed to send channel messages): `POST /teams/{teamId}/channels/{channelId}/messages` with `subject`, `body.contentType = "html"`, and a `mentions` array whose entries match the `<at id="N">` tags in the body. Read the message back and confirm the mentions and links rendered. Keep the returned message id and web URL for the log.
- **No Teams route** (no access, config incomplete, or the call fails): stop and hand back the exact post for the caller to send - the subject, the full HTML body, and the mention list (display name + AAD id, or the placeholder). Never retry with a guessed id or a different channel.

## Phase 5 - Decision log

Append one entry per question - chat questions included - when it is asked, and update it when answered.
Path: `specs/<feature-id>/decisions.md` when an SDD feature is active (`.sdd/` exists), otherwise `config.decisionLogPath`.
Create the file with a `# Decisions` heading if it is missing.
Ids `D-001`, `D-002`, ... are per file.

```markdown
## D-001 - <short question title>
- Ticket: [AB#<id>](<ticket url>)
- Kind: product | engineering
- Owner: <name> - <evidence with link>
- Status: open | answered
- Blocks build: yes | no
- Default if no answer: <letter - option, or "none - the build waits" when it blocks>
- Question: <the bold question line>
- Asked: <YYYY-MM-DD> in [Teams thread](<message url>) | in chat
- Answer: <letter - reason as given>
- Answered by: <name>
- Answered on: <YYYY-MM-DD>
- Links: [PR <n>](<url>), [<file>](<url>), [AB#<id>](<url>)
```

`Status:` and `Blocks build:` are the contract the SDD phases read: `m-sdd-plan` and `m-sdd-implement` stop while any entry is `Status: open` with `Blocks build: yes`.

## Phase 6 - Collect answers

Read the thread replies (`GET .../messages/{messageId}/replies`) when the route allows it; otherwise ask the caller to paste them.
Parse `Q<n>: <letter|other> - <reason>` per line.
An answer is valid only from the question's owner, or from someone the owner or session user names in the thread; anything else, or an unclear reply, goes to the session user in chat.
Update the log entry to `Status: answered` with answer, who and date.
Do not reply in Teams to confirm; the ticket comment in Phase 7 is the record.
In an SDD feature, hand product answers to `m-sdd-clarify` Phase 2 to fold into the spec (it owns re-approval); engineering answers feed `m-sdd-plan`.

## Phase 7 - Write back to the ticket

For each answer from someone other than the session user, post an English ADO comment on the ticket (azure-devops MCP comment tool, `az boards work-item update --discussion`, or `POST _apis/wit/workItems/{id}/comments?api-version=7.1-preview.4`).
Use HTML with explicit `<a href>` anchors for every ticket, PR, file and the Teams thread.
Read the comment back with `$expand=renderedText` and count the anchors before saying it is done.
The session user's own chat answers go to the log only, unless they ask for a ticket comment.

## Never

- Post a question the session user owns, or post any recap, summary or acknowledgement.
- Write a bare `AB#<id>` or bare URL anywhere this skill writes.
- Guess an owner, a Teams id or a mention id, or commit one.
- Mark a question non-blocking just to keep going when its answer would change a contract or user-visible scope.
- Treat a non-owner's reply as the decision.
