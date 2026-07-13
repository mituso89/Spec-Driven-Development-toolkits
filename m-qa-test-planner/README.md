# m-qa-test-planner

A Claude Code skill for QA engineers to generate test plans, manual test cases, regression test suites, Figma design validations, and structured bug reports.

## Purpose

Eliminates the repetitive work of formatting QA documentation while ensuring best practices are followed for test coverage, bug reporting, and design validation. Everything is generated as Markdown, ready to paste into Jira, Linear, GitHub Issues, TestRail, Confluence, or Notion.

## When to Use

- Create a comprehensive test plan for a new feature or release
- Generate manual test cases with step-by-step instructions and expected results
- Build regression test suites (smoke, targeted, full, sanity)
- Validate UI implementation against Figma designs (requires the optional Figma MCP)
- Document bugs with clear reproduction steps
- Establish testing standards for your team

### Activation

Invoke the skill by name:

```
m-qa-test-planner
use the skill m-qa-test-planner
"Use m-qa-test-planner to create a test plan for the checkout flow"
```

## How It Works

The skill follows a three-phase workflow (see `SKILL.md`):

1. **Analyze** — parse the request, pick the deliverable type (plan / cases / suite / validation / bug report), determine test types, scope, priorities, and edge cases. Missing inputs are asked for, not invented.
2. **Generate** — build the deliverable from the matching template in `references/`, applying QA best practices (one behavior per test case, expected result per step, tiered regression, exact-value design checks).
3. **Validate** — check completeness, requirement-to-test traceability, and that every step is actionable before delivering.

`SKILL.md` is intentionally lean: it holds the workflow and one-line summaries of each deliverable, and points to the `references/` files for full templates and deep guidance.

## Usage Examples

```
"Use m-qa-test-planner: create a test plan for the user authentication feature"
"Use m-qa-test-planner: generate 5 manual test cases for the checkout flow"
"Use m-qa-test-planner: build a smoke test suite for the payment module"
"Use m-qa-test-planner: compare the login page against the Figma design at [URL]"
"Use m-qa-test-planner: create a bug report for: form submits with empty email field"
```

## Skill Structure

```
m-qa-test-planner/
├── README.md                          # This file
├── SKILL.md                           # Workflow (Analyze → Generate → Validate) + pointers
├── references/
│   ├── test_case_templates.md        # Test case formats (standard, functional, UI) + examples
│   ├── bug_report_templates.md       # Bug templates, severity definitions, priority matrix
│   ├── regression_testing.md         # Suite tiers, construction, execution reports, coverage
│   └── figma_validation.md           # Design-implementation validation workflow
└── scripts/
    ├── generate_test_cases.sh        # Interactive test case generator
    └── create_bug_report.sh          # Interactive bug report creator
```

## Interactive Scripts

```bash
./scripts/generate_test_cases.sh   # prompts for feature, test type, count, priority
./scripts/create_bug_report.sh     # prompts for title, severity, steps, environment
```

## Figma MCP Integration (optional)

When the Figma MCP is configured, the skill can extract design specifications (dimensions, hex colors, typography, spacing, interactive states) from Figma URLs, generate pixel-level validation test cases, and file bugs with design links for discrepancies. Without it, all other deliverables still work; design checks use specs the user supplies. See `references/figma_validation.md`.

## Quality Standards

- **Test plans:** explicit in/out scope, measurable entry/exit criteria, risks with mitigations.
- **Test cases:** expected result per step, documented preconditions and test data, priority assigned, edge cases included.
- **Bug reports:** reproducible steps, complete environment, evidence attached, severity/priority set.
- **Regression:** smoke → P0 → P1/P2 execution order; any P0 failure blocks the release.
