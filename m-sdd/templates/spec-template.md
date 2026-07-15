# <Feature> Specification

**Feature:** <NNN-slug>
**Status:** in_progress | approved <!-- mirrors the specify phase status in .sdd/state.json -->

<!--
  AUDIENCE: business stakeholders (PO/PM), not developers.
  This spec describes WHAT users need and WHY — never HOW.
  BANNED here (they belong in plan.md): tech stack, languages, frameworks,
  APIs, endpoints, database/schema design, code structure, library choices.
  Unknowns: make an informed guess and record it under Assumptions; only for
  decisions that genuinely change scope, insert at most 3 inline clarification
  markers (exact `[NEEDS …]` syntax defined in m-sdd-specify). DELETE this whole
  comment block before requesting approval — the approval gate greps the entire
  file, comments included, for leftover marker text.
-->

## Problem & Goal
<what user/business problem this solves and why now — no implementation detail>

## Non-Goals
- <explicitly out of scope>

## User Stories
<!-- Each story: independently testable — delivering it alone is a viable slice.
     Priority: P1 = must-have / MVP, P2 = important, P3 = nice-to-have. -->

### US1 — <title> (P1)
As a <user type>, I want <capability>, so that <benefit>.

**Why this priority:** <value justification>

**Acceptance scenarios:**
1. **Given** <initial state>, **When** <action>, **Then** <observable outcome>.
2. **Given** <...>, **When** <...>, **Then** <...>.

**Visual reference (optional):** `design/<screen>.html` — what this story looks like when done. Read-only; the spec stays requirement-first (a mockup shows WHAT the user sees, never HOW it's built). Omit if no design exists.

### US2 — <title> (P2)
<...same shape...>

## Functional Requirements
<!-- Testable "System MUST ..." statements, in business terms. -->
- **FR-001:** System MUST <capability>.
- **FR-002:** System MUST <capability>.
- **FR-003:** Users MUST be able to <action>.

## Key Entities
<!-- Business-domain things and relationships, NOT a data model.
     Omit this section if the feature involves no data. -->
- **<Entity>:** <what it represents, key attributes in plain language>

## Success Criteria
<!-- Measurable and technology-agnostic: a number, a time, a rate an observer
     could verify without knowing how the system is built. -->
- **SC-001:** <e.g. "users complete <task> in under N minutes">
- **SC-002:** <e.g. "X% of <event> succeed without support intervention">

## Assumptions
- <informed guesses made instead of asking; each one is overridable at review>

## Edge Cases
- What happens when <boundary condition>?
- How does the system handle <error/empty/concurrent case>?

## Clarifications
<populated by m-sdd-clarify; empty until then>
