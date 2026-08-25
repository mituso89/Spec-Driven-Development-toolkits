# Routines — the calendar

An employee does not wait to be asked before checking whether the build is green.
Run these as a scheduled task or cron job (e.g. a CLI invocation with a prompt).
Each prompt stands on its own — a scheduled run starts a fresh session.

## Rules for anything unattended
1. **Read and report, never fix.** A routine that edits code while you sleep will
   eventually edit the wrong thing.
2. **Say when it cannot check something.** Silence about a gap reads as "all clear".
3. **One line when nothing is wrong.** A long report about nothing trains you to
   skip it — and then you skip the one that mattered.
4. **Start where being wrong is free.** Earn trust before widening scope.

## Morning health check — weekdays
```
Open the project at <ABSOLUTE PATH>. Report repo health in under ten lines:
run the verification gate and give its real exit code; note anything committed
since yesterday; list any in-progress work with no recent commit. End with the
single thing that needs a human, or "nothing". Do not edit, commit, or push.
```

## Nightly verification
```
Open the project at <ABSOLUTE PATH>. Run the verification gate and report the
real exit code. If it failed, isolate which layer broke (lint / tests / smoke)
and quote the exact error text. Name the most likely commit responsible. Do not
attempt a fix — report only.
```

## Weekly stalled-work sweep
```
Open the project at <ABSOLUTE PATH>. List: SDD features stuck between phases;
tickets/specs whose acceptance criteria are not actually testable; work that
looks finished but was never closed. Output a table with the one action that
would unstick each. Do not modify any files.
```

## Handbook / constitution drift check — monthly
```
Open the project at <ABSOLUTE PATH>. Verify the handbook against reality: run
each command in its table; check the paths it names still exist; spot-check three
conventions against the current code. Report the specific lines that are now
false. Do not edit — a human decides the new truth.
```

## Scaling up carefully
Once a read-only routine has been right for weeks, the next step is **not**
letting it commit — it is letting it open a draft PR a human merges. That keeps
reversibility while removing the typing.
