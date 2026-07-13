---
name: m-qa-test-planner
description: "QA deliverable generator — produce test plans, manual test cases, regression suites, design-vs-implementation validations, and structured bug reports from a feature description, in Markdown ready for any tracker. Optional Figma MCP integration for pixel-level design validation. Triggers: test plan, test cases, regression suite, QA, bug report, figma validation, manual testing, smoke test, test coverage."
---

# QA Test Planner

> **TL;DR** — Analyze the feature and pick the deliverable type (1) → Generate it from the matching template in `references/` (2) → Validate completeness, traceability, and actionability before delivering (3). Everything is Markdown, ready to paste into Jira/Linear/TestRail/Confluence.

Invoke by name: `m-qa-test-planner` — e.g. "use m-qa-test-planner to create a test plan for the checkout flow".

**Optional dependency:** design validation uses the **Figma MCP** to pull specs (colors, spacing, typography, states) from design files. Without it, all other deliverables work; design checks fall back to specs the user provides.

---

## Phase 1 — Analyze

Parse the request and decide what to build before writing anything:

1. **Deliverable type** — which of the five is being asked for?

   | Request sounds like | Deliverable | Depth lives in |
   |---|---|---|
   | "test plan for X" | Test plan (scope, strategy, criteria, risks) | Outline below |
   | "test cases for X" | Manual test cases with steps + expected results | `references/test_case_templates.md` |
   | "regression / smoke suite" | Tiered regression suite | `references/regression_testing.md` |
   | "compare against Figma / the design" | Design validation checklist + TCs | `references/figma_validation.md` |
   | "bug report for X" | Structured, reproducible bug report | `references/bug_report_templates.md` |

2. **Test types needed** — one test case tests one thing:

   | Type | Focus | Example |
   |---|---|---|
   | Functional | Business logic | Login with valid credentials |
   | UI/Visual | Appearance, layout, design fidelity | Button matches design spec |
   | Integration | Component interaction | API returns data to frontend |
   | Regression | Existing functionality still works | Previous features after a change |
   | Performance | Speed, load handling | Page loads under 3 seconds |
   | Security | Vulnerabilities | SQL injection prevented |

3. **Scope and priority** — what's in/out, which flows are P0 (business-critical) vs P1–P3, and which edge cases matter (boundary values, nulls, empty states, invalid input).
4. **Missing inputs** — if requirements, environments, or test data are unknown, ask; don't invent them.

## Phase 2 — Generate

Build the deliverable from the matching template. Read the relevant reference file first — don't reconstruct formats from memory.

### Test plan

Sections, in order:

- Executive summary — what's tested, objectives, key risks, timeline overview.
- Scope — explicit **in** and **out** lists (features, platforms, flows; known exclusions).
- Strategy — test types plus approach: positive/negative testing, boundary value analysis, equivalence partitioning.
- Environments — OS/browser/device matrix, backend environments, test data requirements.
- Entry criteria — requirements documented, designs final, environment ready, test data prepared, build deployed.
- Exit criteria — measurable: e.g. all P0 cases executed, 90%+ pass rate, no open critical/high bugs, regression passed.
- Risk table (probability × impact, each with a mitigation) and deliverables list.

### Manual test cases

`TC-[MODULE]-[ID]` naming; each has objective, preconditions, numbered steps *each with its own expected result*, test data, post-conditions, priority, and linked edge-case variants.
Full formats (standard, functional, UI/visual, plus worked examples): `references/test_case_templates.md`. Interactive guided creation: `scripts/generate_test_cases.sh`.

### Regression suites

Tiered by purpose — smoke (15–30 min, daily, critical paths only), targeted (30–60 min, per change, affected areas), full (2–4 h, per release), sanity (10–15 min, post-hotfix). Execution order: smoke → P0 → P1/P2 → exploratory; any P0 failure blocks the release.
Suite construction (identify critical paths → prioritize P0–P2 → group by feature area), pass/fail criteria, maintenance, and the execution-report + coverage-matrix templates: `references/regression_testing.md`.

### Design validation (Figma MCP)

Pull specs via the Figma MCP (dimensions, hex colors, typography, spacing, radius, interactive states), compare against the implementation with browser DevTools, and document each discrepancy as a bug with expected-(design) vs actual values and the design link.
Workflow, per-element checklists (layout, typography, colors, components, states, responsive), common discrepancies, and the TC-UI template: `references/figma_validation.md`.

### Bug reports

Specific title ("[Feature] issue when [action]"), environment (OS/browser/device/build/URL), numbered reproduction steps, expected vs actual behavior, evidence (screenshot/video/console errors), impact + workaround, severity (Critical/High/Medium/Low) and priority (P0–P3) — Critical/P0 = crash, data loss, security, payments; Low/P3 = cosmetic.
All templates (standard, quick, UI/visual, performance, security, crash), severity definitions, and the priority-vs-severity matrix: `references/bug_report_templates.md`. Interactive guided creation: `scripts/create_bug_report.sh`.

### Execution tracking

After test runs, report totals (executed/pass/fail/blocked, pass rate), results by priority, critical failures with linked bugs, and a go/no-go recommendation. Templates (test run report, coverage matrix): `references/regression_testing.md`.

## Phase 3 — Validate

Check the deliverable before handing it over:

- **Test plan:** scope explicit (in *and* out) · entry/exit criteria measurable · risks have mitigations · timeline realistic.
- **Test cases:** every step has an expected result · preconditions and test data documented · priority assigned · edge cases included.
- **Regression suite:** critical paths covered · execution order and pass/fail criteria stated · duration matches the tier.
- **Bug reports:** steps reproduce for someone with no context · environment complete · evidence attached · severity/priority set.
- **Traceability:** each requirement/flow in scope maps to at least one test case; note gaps explicitly rather than silently skipping.

Deliver as Markdown and offer the next step (e.g. generate the test cases the plan calls for, or file the bugs found during validation).

---

## Scripts

| Script | Purpose |
|---|---|
| `scripts/generate_test_cases.sh` | Interactive prompt-driven test case creation |
| `scripts/create_bug_report.sh` | Interactive guided bug report creation |

## Never

- Write a test step without its expected result, or a test case without preconditions and test data — vague steps can't be reproduced and blocked testers can't execute.
- Combine multiple behaviors in one test case — one test, one thing.
- Use generic bug titles ("button broken") or file a bug without reproduction steps, environment, and severity/priority.
- Skip edge cases (boundaries, nulls, empty states, invalid input) — that's where the critical bugs are.
- Invent requirements, environments, or test data the user didn't give — ask instead.
- Declare a design validated without comparing exact values (hex, px, font) against the design source.
- Let a regression suite pass with a P0 failure, or skip regression before a release.
- Hardcode real user credentials, customer names, or production URLs into test data — use placeholders like `test@example.com`.
