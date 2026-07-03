# Checklist: [DOMAIN] — [FEATURE NAME]

**Spec:** `specs/[ID]/spec.md` · **Generated:** [DATE]
Append-only: never renumber; strike resolved items (`~~CHK00X~~`).

Items test requirement QUALITY (the spec's wording), not implementation behavior.
Markers: `[Gap]` missing requirement · `[Ambiguity]` vague wording ·
`[Conflict]` contradicts spec/constitution · `[Assumption]` unstated premise.
≥80% of items must cite a spec section (§) or carry a marker.

## Completeness
- [ ] CHK001 [example] Are error states specified for every user-facing action? [Gap]

## Clarity / Measurability
- [ ] CHK002 [example] Is "fast" quantified with a concrete threshold? [Ambiguity §X.Y]

## Consistency (spec ↔ constitution)
- [ ] CHK003 [example] Does §X.Y's storage choice comply with the constitution's data rules? [Conflict]

## Coverage / Assumptions
- [ ] CHK004 [example] Does the spec state which locales are in scope, or is en-only assumed? [Assumption]
