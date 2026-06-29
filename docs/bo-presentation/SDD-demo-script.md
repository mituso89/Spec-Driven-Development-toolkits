# SDD Live Demo — Presenter Script (~5 minutes)

**Goal:** let the business owner *see* a real business need become an approved
spec and a tracked task list — and watch the approval gate work — without drowning
them in technical detail.

**Audience takeaway:** "I can read this, I approve this, and nothing gets built
until I say go."

---

## Before the meeting (setup — do this in advance)

1. Open a terminal in a real project where the toolkit is installed.
   - Confirm install once: `bash install.sh` was run; restart Claude Code so the
     `h-sdd*` skills are picked up.
   - Prerequisite is just `jq` (`brew install jq`).
2. Pick **one small, real feature** the owner will recognize (e.g. "let customers
   save a payment method"). Keep it tiny — this is a walkthrough, not real delivery.
3. Do a dry run start-to-finish once so you know the timing and the prompts.
4. Have these ready to show on screen, zoomed in and readable:
   - The terminal running Claude Code.
   - A file viewer for `specs/<feature>/spec.md` and `tasks.md`.

> Tip: pre-generate the artifacts before the meeting so you can *show* polished
> documents, and only *re-run* the one or two steps live that land best (Specify
> + the approval gate). Live generation can be slow; showing finished docs reads
> better to an executive.

---

## The 5-minute flow

### 1. Frame it (30 sec)
> "I'll take one real feature and show you how we go from an idea to something the
> team can build — with you approving the important parts. Watch how it's all
> written down."

### 2. Show the starting point (30 sec)
Run: `h-sdd`
- Point out: it shows **what phase we're in** and the **same path every feature
  follows**. "This is repeatable — every feature goes through these steps."

### 3. Write the spec — the WHAT and WHY (90 sec)
Run: `h-sdd-specify` for the chosen feature.
- Open `specs/<feature>/spec.md` and read 2–3 lines aloud.
- Emphasize: **"Notice there's no technical jargon. This is written for you. It
  says what we're building, why, and how we'll know it's done."**
- Point to the user stories / success criteria in plain English.

### 4. The approval gate — the key moment (60 sec)
> "Here's the important part: nothing moves forward until I approve this spec."
- Show that the next phase (**Plan**) is *blocked* until the spec is approved.
- Approve it, and show the status flip to **approved**.
- Land the line: **"This is the control point. You decide if it's right before a
  single hour is spent building."**

### 5. From spec to tracked work (60 sec)
Show the already-generated `plan.md` (one sentence: "engineering's how") and then
`tasks.md`.
- Point at the checklist: **"Every task traces back to the spec. When these are
  done, the feature is done — and you can see progress the whole way."**

### 6. Close (30 sec)
> "So: written down, approved by you, and traceable end to end. That's the whole
> idea — and it works the same for every feature. Can we pilot this on one real
> feature next sprint?"

---

## Likely questions & crisp answers

- **"Does this slow us down?"** — Up front, slightly; overall, faster. We stop
  paying for rework and wrong builds. The spec is minutes; a wrong build is weeks.
- **"Do I have to write the spec myself?"** — No. The tool drafts it from a
  conversation; you review and approve. You own the *decision*, not the typing.
- **"What's the role of AI here?"** — AI does the heavy lifting (drafting, planning,
  building) — but only against what *you approved*. The gates keep it on the rails.
- **"How is this different from just writing tickets?"** — Tickets describe tasks.
  SDD starts from the *requirement*, approves it, and traces every task back to it.
- **"Where does this live?"** — In our own project, as plain documents in version
  control. Nothing locked in a vendor tool.

---

## If the live demo risks running long

Fall back to **show, don't run**: walk through the pre-generated `spec.md`,
`tasks.md`, and the approval status. The story (written → approved → traceable)
lands without waiting on generation.
