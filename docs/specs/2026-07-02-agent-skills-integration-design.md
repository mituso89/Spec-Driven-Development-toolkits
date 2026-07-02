# Design: Integrating agent-skills Quality Pack into sdd-toolkit-devin

**Date:** 2026-07-02
**Status:** Approved

---

## Goal

Bring five production-grade quality skills from
[`agent-skills`](https://github.com/addyosmani/agent-skills) into
`sdd-toolkit-devin` as first-class vendored skills, available globally (via
`install.sh`) and optionally copyable into individual project repos
(`install.sh --project <path>`), with lightweight optional-companion hooks into
the SDD pipeline at the right phases.

---

## Constraints

- Devin CLI only (skills use `SKILL.md` format, installed into
  `~/.config/devin/skills/`)
- Zero breaking changes to existing pipeline skills or `sdd-lib.sh`
- New skills are **never blocking gates** — always opt-in companions
- `install.sh` existing behavior (no args = global install) unchanged
- `vendor.sh` re-sync must work without manual file editing

---

## Shaped by

- `install.sh:32-42` — existing `for d in "$SRC"/h-*` loop auto-picks up new
  `h-*` folders
- `vendor.sh:9-23` — existing upstream copy pattern; new skills follow same
  pattern with a separate source variable
- `h-sdd/_shared.md:1-11` — delegate rule; new skills are named companions, not
  delegates
- `h-sdd/_shared.md:38-55` — HITL gate rules; new skills must never be added as
  `sdd_require` gates

---

## Approach: Thin Wrapper (A)

Copy the 5 SKILL.md files verbatim from `agent-skills`, rename with `h-` prefix,
add one optional-companion note to the relevant SDD phase skill. No logic changes
to existing skills.

---

## Section 1 — New skill folders

Five new folders added to the toolkit root, each containing one `SKILL.md`
copied verbatim from `agent-skills/skills/<name>/SKILL.md`:

```
sdd-toolkit-devin/
  h-security-and-hardening/
    SKILL.md    ← agent-skills/skills/security-and-hardening/SKILL.md
  h-performance-optimization/
    SKILL.md    ← agent-skills/skills/performance-optimization/SKILL.md
  h-debugging-and-error-recovery/
    SKILL.md    ← agent-skills/skills/debugging-and-error-recovery/SKILL.md
  h-api-and-interface-design/
    SKILL.md    ← agent-skills/skills/api-and-interface-design/SKILL.md
  h-frontend-ui-engineering/
    SKILL.md    ← agent-skills/skills/frontend-ui-engineering/SKILL.md
```

The existing `install.sh` loop (`for d in "$SRC"/h-*`) picks these up
automatically — no changes to `install.sh` global path needed.

---

## Section 2 — SDD pipeline integration (optional-companion notes)

Three existing phase skills get a single "Optional companion" line each.
No logic, no gates, no `sdd_require` calls added.

| Phase skill | Insert point | Companion(s) |
|---|---|---|
| `h-sdd-plan/SKILL.md` | End of phase, after plan artifact drafted | `h-api-and-interface-design` (if spec involves an API), `h-frontend-ui-engineering` (if spec involves UI) |
| `h-sdd-analyze/SKILL.md` | In cross-check section, before analyze verdict | `h-security-and-hardening`, `h-performance-optimization` |
| `h-sdd-implement/SKILL.md` | In failure/recovery section | `h-debugging-and-error-recovery` |

**Wording pattern** (matches existing `_shared.md` delegate style):

```
> Optional companion: if this feature involves [X], run `h-<skill>` before
> moving to the next phase.
```

---

## Section 3 — `vendor.sh` update

Add a new block `== 1b. copy from agent-skills ==` after the existing
`== 1. copy ==` block.

Source path is configurable via env var with a sensible fallback:

```bash
AGENT_SKILLS_SRC="${AGENT_SKILLS_SRC:-$HOME/work/agent-skills/skills}"
AGENT_SKILLS="security-and-hardening performance-optimization \
debugging-and-error-recovery api-and-interface-design frontend-ui-engineering"

echo "== 1b. copy from agent-skills =="
for s in $AGENT_SKILLS; do
  if [ -d "$AGENT_SKILLS_SRC/$s" ]; then
    rm -rf "$DEST/h-$s"
    cp -R "$AGENT_SKILLS_SRC/$s" "$DEST/h-$s"
    echo "  vendored $s -> h-$s"
  else
    echo "  WARN missing $AGENT_SKILLS_SRC/$s"
  fi
done
```

Re-sync command for maintainers:
```bash
AGENT_SKILLS_SRC=/path/to/agent-skills/skills bash vendor.sh
```

---

## Section 4 — `install.sh` `--project` flag

Add an optional `--project <path>` flag. When supplied, copies only the 5 new
quality skills into `<path>/.devin/skills/` (never symlinks; creates the
directory if absent; never clobbers existing skills).

Global install behavior (no args) is unchanged.

```bash
bash install.sh --project /path/to/my-project
```

**Skills copied per-project:** only the 5 new ones. The SDD pipeline skills
(`h-sdd`, `h-sdd-specify`, etc.) are global-only.

**Behavior:**
- Creates `<project>/.devin/skills/` if absent
- Skips any skill that already exists (same "never clobber" rule)
- Prints `installed h-<name> → <project>/.devin/skills/<name>` per skill

---

## Section 5 — README updates

Three small additions to `README.md`:

1. **Bundled skills table** — new row:
   `quality companions (optional)` → lists all 5 new `h-*` skills

2. **Install section** — new note after the existing install steps:
   ```
   To also copy the quality companion skills into a specific project:
     bash install.sh --project /path/to/your-project
   ```

3. **Developer `<details>` block** — one new line:
   ```
   Re-sync quality skills from agent-skills:
     AGENT_SKILLS_SRC=/path/to/agent-skills/skills bash vendor.sh
   ```

---

## Acceptance criteria

- [ ] `bash install.sh` installs all 5 new `h-*` skills into
      `~/.config/devin/skills/` alongside existing skills
- [ ] `bash install.sh --project <path>` copies the 5 quality skills into
      `<path>/.devin/skills/`; existing skills in that dir are not touched
- [ ] `AGENT_SKILLS_SRC=/path/to/agent-skills/skills bash vendor.sh`
      re-syncs all 5 from the upstream source
- [ ] `h-sdd-plan/SKILL.md` mentions `h-api-and-interface-design` and
      `h-frontend-ui-engineering` as optional companions
- [ ] `h-sdd-analyze/SKILL.md` mentions `h-security-and-hardening` and
      `h-performance-optimization` as optional companions
- [ ] `h-sdd-implement/SKILL.md` mentions `h-debugging-and-error-recovery`
      as an optional companion
- [ ] No existing tests in `h-sdd/test_sdd_lib.sh` break
- [ ] `sdd-lib.sh` is unchanged
- [ ] `_shared.md` is unchanged

---

## Alternatives considered

**Approach B — Deep integration:** Rewrite `h-sdd-analyze` to actively invoke
the new skills as sub-steps. Rejected — modifies a core pipeline skill, higher
maintenance burden, overkill for opt-in quality checks.

**Approach C — Quality pack orchestrator:** One `h-quality-pack` skill
orchestrates all 5. Rejected — hides individual skills, reduces composability,
prevents invoking a single skill on demand.
