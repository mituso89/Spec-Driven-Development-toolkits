# Worked Example — Over-Technical Draft → PM-Altitude Ticket

Fictional scenario: a SaaS project-management product. A developer-turned-reporter drafted a bug
ticket after digging into the code. The draft is *correct* — and still wrong for a PM ticket,
because it pre-decides the diagnosis and the fix. Below: the draft as submitted, the altitude
scan, and the final ticket.

---

## Before (engineering altitude — the draft as submitted)

```
Summary: Fix stale selector so saved report filters write through to the API

The Reports dashboard filter panel doesn't persist filters. Root cause: in
ReportFilters.tsx:142-157 the onApply handler writes to the local `filterDraft`
state slice but the `useSavedFilters` selector memoizes on the stale `filters.v1`
key, so `saveFilters()` is never called with the new values. This regressed in
commit 4be7a91c when the filter store was migrated to the v2 schema.

Proposed fix:
  1. Change the selector to key on `filters.v2`.
  2. In onApply, await saveFilters(draft) before closing the panel.
  3. Backfill: migrate rows in `user_preferences` that still have a `filters.v1` blob.

Repro: apply any filter on Reports, reload → filters reset to defaults. The applied
filters DO survive while the tab stays open (they live in Redux), but a fresh
session shows defaults — so it's in-memory state, not the database. Reported by a
customer admin at Northwind Retail.

AC:
- `saveFilters()` fires with the v2 payload and `user_preferences.filters.v2` is updated.
- The selector returns the persisted value after rehydration.
- No `filters.v1` reads remain in the codebase.
```

## Altitude scan (what the skill does with it)

- **KEEP** — "apply any filter on Reports, reload → filters reset to defaults" → Reproduction.
- **KEEP** — "reported by a customer admin at Northwind Retail" → Impact/Context.
- **DEMOTE** — "filters survive while the tab stays open, but a fresh session shows defaults"
  is a great *observation* (keep); "so it's in-memory state, not the database" is the
  *interpretation* (cut).
- **CUT** — `ReportFilters.tsx:142-157`, the stale-selector diagnosis, commit `4be7a91c`,
  all three proposed-fix steps, and every AC line (all engineering verification, not
  user-observable outcomes).
- **ASK** — frequency and business severity weren't stated → confirmed with the user
  ("every time; admins rebuild their filter set daily").

## After (PM altitude — as created, e.g. `PROJ-124` in project `PROJ`)

```
Summary: Report filters don't stay applied after a page reload

## Problem
On the Reports dashboard, filters a user applies look saved but are back to the
defaults after a full page reload or in a new session.

## Impact
- Who:        customer admins who rely on saved report views (reported by an admin
              at Northwind Retail).
- Frequency:  every time — applied filters never persist across sessions.
- Severity:   admins rebuild their filter set daily; some export the wrong data
              without noticing the filters were reset.

## Steps to Reproduce
1. Open Reports and apply any filter (e.g. date range + team).
2. Hard-reload the page (or open Reports in a new browser session).
**Expected:** the filters applied in step 1 are still active.
**Actual:**   the dashboard shows the default filters again.
**Environment:** filters were observed surviving within the still-open tab but
resetting in a fresh session — i.e. the applied state isn't really stored.

## Acceptance Criteria
- [ ] Apply filters → hard reload (and a new session/browser) → same filters still active.
- [ ] Clear filters back to defaults → reload → defaults stay.
- [ ] Filters saved before this fix ships behave the same as newly saved ones.
- [ ] Exports run after a reload use the filters the user last applied.

## Out of Scope
- Reports dashboard layout refresh (PROJ-123) — same screen, coordinate separately.

## Context
- Reported by: customer admin, Northwind Retail — support ticket, 2026-07-01 (screen recording).
- Related: PROJ-123.
```

Everything about the stale selector, `ReportFilters.tsx`, commit hashes, the
`user_preferences` table, and the three-step fix is **gone** — engineering will
diagnose and own the fix. The ticket carries the `needs-triage` handoff label
(from `engineeringHandoffLabel`) because diagnosis was stripped.
