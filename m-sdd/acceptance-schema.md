# Acceptance file and evidence - schema

This is the single reference for `specs/<id>/acceptance.json` and the evidence files that prove it.
Other skills link here instead of repeating the format.

- **Written by:** `m-sdd-plan`, next to `plan.md`, before the plan approval gate.
- **Read by:** `m-sdd-tasks` (links tasks to criteria), `m-sdd-analyze` (checks coverage), `m-sdd-implement` and `m-implement` (run every step and record evidence).
- **Why:** "done" stops being an opinion.
Each plan phase lists the exact steps a worker runs or checks, and the phase is done only when every step has passing evidence.

## acceptance.json

```json
{
  "feature": "004-csv-export",
  "created_at": "2026-01-31T09:00:00Z",
  "phases": [
    {
      "id": "PH1",
      "description": "Users can export the visible table rows as a CSV file",
      "acceptance_criteria": [
        {
          "id": "AC-1.1",
          "description": "The export contains exactly the visible rows and columns",
          "covers": ["US1", "FR-001"],
          "steps": [
            {
              "type": "automated",
              "run": "npm test -- csv-export",
              "expect": "Exit code 0 and the csv-export suite reports 0 failed"
            }
          ]
        },
        {
          "id": "AC-1.2",
          "description": "A user can download the file from the table toolbar",
          "covers": ["US1", "SC-001"],
          "steps": [
            {
              "type": "manual",
              "check": "Open the Orders table with a filter applied, click Export, open the downloaded file",
              "expect": "The file opens in a spreadsheet app and shows the same filtered rows and columns as the table"
            }
          ]
        }
      ]
    },
    {
      "id": "PH2",
      "description": "Large exports run in the background and tell the user when they are ready",
      "acceptance_criteria": [
        {
          "id": "AC-2.1",
          "description": "An export over the size limit is queued and the user is notified when it finishes",
          "covers": ["US2", "FR-002", "SC-002"],
          "steps": [
            {
              "type": "automated",
              "run": "npm run test:e2e -- large-export.spec.ts",
              "expect": "Exit code 0; the test sees the 'Export ready' notice within 60 seconds"
            },
            {
              "type": "manual",
              "check": "Export a table with more rows than the limit, then keep using the app",
              "expect": "The app stays usable and an 'Export ready' notice with a download link appears"
            }
          ]
        }
      ]
    }
  ]
}
```

### Fields

| Field | Type | Rule |
|---|---|---|
| `feature` | string | The feature id, the same as the `specs/<id>/` folder name. |
| `created_at` | string | ISO-8601 date-time in UTC, e.g. `2026-01-31T09:00:00Z`. |
| `phases` | array, not empty | One entry per plan phase, in build order. |
| `phases[].id` | string | Unique in the file. Convention: `PH1`, `PH2`, ... (`PH`, so it never reads like a story priority `P1`-`P3`). |
| `phases[].description` | string | One line: what this phase delivers, in outcome terms. |
| `phases[].acceptance_criteria` | array, not empty | Everything that must be true before the phase is done. |
| `…criteria[].id` | string | Unique in the file. Convention: `AC-<phase>.<n>`, e.g. `AC-2.1`. |
| `…criteria[].description` | string | One observable outcome. |
| `…criteria[].covers` | array of strings | The spec IDs this criterion proves (`US#`, `FR-###`, `SC-###`). May be empty for a purely technical criterion. |
| `…criteria[].steps` | array, not empty | The exact steps that prove the criterion. |
| `…steps[].type` | `"automated"` or `"manual"` | Automated: a command. Manual: a person or a browser agent checks. |
| `…steps[].run` | string | Automated only. The exact command, run from the repo root. |
| `…steps[].check` | string | Manual only. Exactly where to go, what to do, and what to look at. |
| `…steps[].expect` | string | The pass condition: exit code, output text, or the visible result. |

### Writing good steps

A step is good when two different workers would get the same PASS or FAIL from it.

| Weak | Concrete |
|---|---|
| "Tests pass" | `run: "npm test -- csv-export"`, `expect: "Exit code 0, 0 failed"` |
| "Export works" | `check: "Click Export on the Orders table, open the file"`, `expect: "Same rows and columns as the table"` |
| "Looks right" | `check: "Open Settings > Export at 375px width"`, `expect: "The Export button is fully visible and not overlapping the title"` |

- Prefer automated steps; use manual steps for what a command cannot see (layout, real downloads, third-party screens).
- Name the test, file, page, or account a step needs.
Never write a step that depends on knowing the code.
- Every spec `US#`, `FR-###`, and `SC-###` must appear in at least one criterion's `covers`.
- `acceptance.json` is part of the plan.
Changing it after the plan is approved resets plan approval, the same as editing `plan.md`.

### Validate

```bash
source <skills-root>/m-sdd/sdd-lib.sh
sdd_validate_acceptance specs/<id>/acceptance.json specs/<id>/spec.md
```

It prints `acceptance: ok`, or one `acceptance: <problem>` line per problem and returns 1.
The spec argument is optional; with it, the check also lists spec IDs that no criterion covers and covered IDs the spec does not have.
Without `bash` and `jq`, check the file by hand against the table above.

## Evidence files

Before a phase is called done, the worker runs or checks every step of every criterion in that phase and writes `specs/<id>/evidence/<phase-id>.md`, e.g. `specs/004-csv-export/evidence/PH1.md`:

```markdown
# Evidence - PH1: Users can export the visible table rows as a CSV file

Checked: 2026-02-03T14:02:00Z - Commit: 3f9c2e1

## AC-1.1 - PASS
- Step 1 (automated): `npm test -- csv-export`
  - Result: PASS
  - Output: `Tests: 6 passed, 6 total` (exit code 0)

## AC-1.2 - FAIL
- Step 1 (manual): Open the Orders table with a filter applied, click Export, open the downloaded file
  - Result: FAIL
  - Evidence: `specs/004-csv-export/evidence/PH1-AC-1.2.png`
  - Note: the Total column is missing from the file

**Phase result:** FAIL - AC-1.2
```

Rules:

- One `## <criterion-id> - PASS|FAIL` section per criterion, and one entry per step, in file order.
- Automated steps: record the exact command, the exit code, and a short output excerpt (the lines that prove the result, never secrets or full logs).
- Manual steps: record a screenshot path under `specs/<id>/evidence/` or the exact observation, and who checked it when it was not the agent.
- A step that was not run is `NOT RUN` and counts as FAIL.
- A criterion is PASS only when all its steps pass; the phase is done only when every criterion is PASS.
- Any FAIL blocks "done" for that phase: fix the work, re-run the whole phase, and overwrite the file (git keeps the history).
- Never edit `acceptance.json` to make a failing step pass; a wrong criterion goes back to the plan and its approval gate.
