# <Feature> Implementation Plan

**Feature:** <NNN-slug>  ·  **Spec:** ./spec.md

## Architecture
<2-3 sentences>

## Tech choices
<stack/libraries and rationale; must respect ../../.sdd/constitution.md>

## File structure
<files to create/modify and each one's responsibility>

<!-- If ../design/ exists, read ../design/README.md and its screens as the visual
     implementation reference — derive components/layouts/states from the mockups. -->

## Tasks
<bite-sized checkbox tasks — produced by m-writing-plans. m-sdd-tasks normalizes these
into ./tasks.md (the canonical, tracked checklist) and replaces this section with:
"See ./tasks.md (canonical)." so progress lives in exactly one file.>

## Testing Strategy
<!-- The spec's acceptance scenarios (Given/When/Then) and Success Criteria (SC-###)
     are the contract this verifies. Test mechanics live here, not in the spec. -->
- **Levels:** <which of unit / integration / e2e apply, and why>
- **Coverage map:** each user story and **SC-###** → how it is verified.
  - US1 → <test that proves it>
  - SC-001 → <test/measurement that proves it>
- **Test data & fixtures:** <what's needed>
- **How to run:** <exact command(s)>
- **Mandatory?** Per `../../.sdd/constitution.md` testing principle. If none is
  defined, coverage is *expected* (a soft default), not blocking.

## Companion artifacts
- research.md — <if needed>
- data-model.md — <if needed>
- contracts/ — <API/interface contracts, if needed>
