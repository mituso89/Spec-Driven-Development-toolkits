# <Feature> Tasks

**Feature:** <NNN-slug>  ·  **Plan:** ./plan.md  ·  **Acceptance:** ./acceptance.json

> Ordered, dependency-respecting checklist derived from plan.md. Each task is
> independently testable.

## PH1 - <phase outcome>
- [ ] T001 — <task> [PH1][AC-1.1][US1]
- [ ] T002 — Test: <behavior that proves US1> [PH1][AC-1.1][US1][SC-001]

<!-- Traceability spine: tag each task with its plan phase (PH#), the acceptance
     criteria it helps satisfy (AC-#.#, from acceptance.json), and the user-story /
     success-criterion IDs it serves. Test tasks carry [US#] and/or [SC-###] so
     m-sdd-analyze can confirm every story and SC-### has a verifying task. UI test
     tasks also name the design/ screen they accept against, e.g. "verify against
     design/login.html". A phase is done only when its evidence file
     (evidence/PH#.md) shows every criterion PASS - ticked boxes alone are not enough. -->
