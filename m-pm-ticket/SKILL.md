---
name: m-pm-ticket
description: "PM ticket authoring at the right altitude — turn a bug report, feature ask, or an over-technical draft into ONE clean ticket/work item that stops at Problem, Impact, Reproduction, and Acceptance Criteria, stripping engineering diagnosis (root cause, code, file:line, commit hashes, proposed fix) and leaving it to engineering. Works against Jira or Azure DevOps via the m-board provider layer; creates the ticket only after a confirm gate. Triggers: write a ticket, pm ticket, create work item, ado ticket, jira ticket, bug ticket at the right altitude, de-technify this ticket, file a bug, report a bug, raise a ticket, bug report, feature request, my ticket is too technical, clean up this ticket, acceptance criteria, problem impact reproduction, ticket too engineering-heavy."
---

# PM Ticket — Author at the Right Altitude

> **TL;DR** — Detect provider + load config (−1) → capture input, **always confirm assignee + sprint/iteration** (0) → **altitude scan: CUT diagnosis/fix, KEEP observations** (1) → rewrite into the PM template (2) → **AC quality gate: observable, black-box** (3) → show draft, **user confirms** (4) → create on the board via the provider's MCP tools (5) → if scope spans stacks/teams, offer `/m-story-breakdown` (6) → deliver (7).

A PM ticket describes **what is wrong and how we'll know it's fixed** — not **why** it's broken or **how** to fix it. Diagnosis is engineering's job; pre-deciding it in the ticket narrows their options and is often wrong. This skill keeps the ticket at PM altitude and hands the rest off.

**Do NOT create any ticket until the Phase 4 gate has passed.** All board work uses the provider's MCP tools — never a CLI.

## The altitude line (the heart of this skill)

| KEEP — PM owns it | CUT — engineering owns it |
|---|---|
| **Problem** — the user-visible symptom in plain language | **Root cause / diagnosis** — *why* it happens |
| **Impact** — who's hit, how often, how badly | **Code references** — `file:line`, function names, commit hashes |
| **Reproduction** — steps, expected, actual, environment | **Proposed fix** — code blocks, new functions, refactors |
| **Observations** — factual *what was seen* | **Interpretation** of those observations |
| **Acceptance Criteria** — observable, black-box outcomes | **Implementation-level AC** — internal field names, DB paths, module internals |
| **Context** — reporter, related tickets, attachments | **Internal-mechanism scope notes** |

**The test for a line:** could the PM have written it *without reading the source code*? If yes → keep. If it required opening the repo → it's a diagnosis or a fix → cut it (engineering will rediscover it, correctly, and own it).

**Keep observations, cut interpretations.** "The change held in the open browser tab but was gone in a fresh session" is an *observation* — keep it (great repro evidence). "So it's client-side state, not the database" is a *diagnosis* — cut it.

## Phase −1 — Provider Detection & Config

Delegate provider detection to the **`m-board`** skill: read `m-board/SKILL.md` and run its detection procedure (this skill's `config.json` `"provider"` key wins; else discover via tool search; else ask once). Then read `m-board/providers/<provider>.md` for the concrete creation tool names, query language, and type/field mapping. If no board MCP is reachable, say so and stop.

Resolve config by trying in order, stopping at the first hit: `<project skills root>/m-pm-ticket/config.json` → its `config.example.json` → `<global skills root>/m-pm-ticket/config.json` → `<skill-dir>/config.example.json`. Announce the resolved source once; if only the example was found, tell the user once to copy it to `config.json` and customise.

**Config shape** (see `config.example.json`): `provider`, `defaultProject`, `defaultIssueType` (usually `Bug` or `Task`), `contentLanguage`, `defaultPriority`, `alwaysAddLabels`, `defaultAssignee`, and `engineeringHandoffLabel` (label/tag added when diagnosis was stripped, e.g. `needs-triage`). `defaultAssignee` may be a single value **or** a project → assignee map (e.g. `{ "PROJ": "pm@example.com" }`); when it's a map, the matching entry is only the *suggested* value when asking (Phase 0), never applied silently.

## Phase 0 — Capture the Input

Detect the **entry mode**: **A — repair a draft** (user pasted an over-technical ticket → lint it up to altitude), **B — author fresh** (prose bug/feature description), **C — from a file** (Read the path, then treat as A). Then emit this block and **stop for confirmation**:

```
TICKET INTAKE
======================================================
Mode:          [A repair | B author | C file: <path>]
Kind:          [Bug | Feature | Improvement]   → ticket type: <from config.defaultIssueType or kind>
Target project: [KEY]   (config.defaultProject; ask if unset)
One-liner:     [the ticket in a single sentence]

Reporter / source: [name, channel, date — if given]
Related:           [ticket keys / links — if given]
Assignee:          [ALWAYS ASK — suggest config.defaultAssignee if set, else "unassigned"]
Sprint/iteration:  [ALWAYS ASK — name/number, or "backlog" / "none"]
Unknowns to confirm: [anything you'd otherwise have to invent]
======================================================
```

**Always ask the user for assignee and sprint/iteration** — every ticket, even when a default exists (offer it as the suggestion, don't apply it silently). If the input lacks something a PM ticket needs (impact, expected behaviour, repro) — **ask, do not invent.**

## Phase 1 — Altitude Scan (CUT / KEEP / ASK)

Walk the input against **the altitude line** and report explicitly — this is where the value is:

```
ALTITUDE SCAN
------------------------------------------------------
KEEP (PM altitude):   · [line / fact] → maps to [Problem | Impact | Reproduction | AC | Context]
CUT (engineering owns): · [root cause / code / file:line / commit / proposed fix] — reason: [diagnosis | fix | internal mechanism]
DEMOTE (observation inside an interpretation): · was: "[interpretation]" → keep only: "[bare observation]"
ASK (needed, not present): · [missing impact / expected behaviour / frequency …]
------------------------------------------------------
```

If everything was already at altitude, say so. Resolve every **ASK** with the user before Phase 2. Never carry a CUT item into the ticket body "just in case."

## Phase 2 — Rewrite into the PM Template

Produce the ticket in `config.contentLanguage`; section labels stay as below.

```
Summary: <plain user-facing symptom, no stack tag, no "fix">   (imperative for features)

## Problem
<What the user experiences, in plain language. No "because", no mechanism.>

## Impact
- Who:        <roles / customers affected>
- Frequency:  <every time | intermittent | once — as observed>
- Severity:   <blocks work | annoying | cosmetic — business framing>

## Steps to Reproduce
1. <action>
**Expected:** <what should happen>
**Actual:**   <what happens instead — observation only>
**Environment:** <browser / OS / role / data condition actually observed>

## Acceptance Criteria
- [ ] <observable, black-box outcome>

## Out of Scope
- <explicitly excluded — optional>

## Context
- Reported by: <name, channel, date>   · Related: <ticket keys / links>   · Attachments: <if any>
```

Rules: **Summary names the symptom, never the fix.** **Problem says what, never why** — a sentence with "because", a file path, or a function name is in the wrong section. **Reproduction is observed fact only.** **No code blocks, `file:line`, or commit hashes** anywhere in the body.

## Phase 3 — Acceptance-Criteria Gate (observable & black-box)

Every AC line must pass all three or get rewritten: **Observable** — a non-engineer could verify it by using the product. **Black-box** — no internal names (DB tables, fields, modules, functions); rephrase to the user-visible effect. **Outcome, not method** — the end state, never how to achieve it. Show any before→after rewrite briefly. An AC statable only in engineering terms is a verification note for engineering — drop it (they'll add their own).

## Phase 4 — Show Draft & Confirm (User Gate)

Present the full ticket exactly as it will be created, plus a one-line footer: `Will create: <type> in <PROJECT> · priority <P> · assignee <name|unassigned> · sprint <name|backlog> · labels [<…>, <engineeringHandoffLabel if diagnosis was stripped>]` and `Cut N engineering items — engineering will own diagnosis.` **Wait for explicit approval.** Edits → re-present and wait again. No board write yet.

## Phase 5 — Create on the Board

Follow `m-board/providers/<provider>.md` (from Phase −1) for the concrete flow — resolving the site/org, confirming the ticket type exists in the target project (no match → ask, never invent), creating with the Phase 2 Markdown body, resolving the assignee to an account/identity (ambiguous → ask, don't guess), and setting the sprint/iteration. If the sprint field can't be resolved, create **without** it and tell the user to set it in the board UI — never fail the create over the sprint. Add `config.alwaysAddLabels` plus `engineeringHandoffLabel` when diagnosis was stripped. On a create failure (required field, rejected value), surface the exact error and ask — do **not** loop-retry with the same input. Record the returned **key + URL**.

## Phase 6 — Breakdown Handoff (offer, don't assume)

If the ticket's scope clearly spans multiple stacks/teams or holds several independent deliverables, offer: *"This spans [X + Y] — want `/m-story-breakdown` to split it into per-stack dev tickets under this one?"* Pass the new ticket key. A single-deliverable bug needs no breakdown — say so and stop.

## Phase 7 — Delivery

Emit a `DONE` block: created **key + URL**, ticket type, project, priority/labels, and `Check: created ok · altitude ok (N eng items cut) · AC observable ok`. If creation failed, report the error verbatim under `Failed:` — do not retry silently.

**Worked example** (over-technical draft → correctly-altituded ticket): see `references/example.md`.

## Never Do

- Create a ticket before the Phase 4 gate passes.
- Create a ticket without confirming **assignee and sprint/iteration** — always ask, even when a default exists.
- Put root cause, a proposed fix, code blocks, `file:line`, or commit hashes in the ticket — that's diagnosis, and it's engineering's call.
- Keep an *interpretation* of an observation — keep the observation, drop the verdict.
- Invent impact, frequency, expected behaviour, or AC that isn't in the input — ask instead.
- Write acceptance criteria in engineering terms — they must be observable and black-box.
- Decide a ticket "needs breakdown" and do it here — offer `/m-story-breakdown` and let the user choose.
- Loop-retry a failing create without changing the input — surface the error and stop.
- Reach the board through a CLI — provider MCP tools only.
