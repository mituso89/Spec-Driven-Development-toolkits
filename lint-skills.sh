#!/usr/bin/env bash
# lint-skills.sh — catch skill-authoring drift before it ships.
#
# Checks every m-*/SKILL.md for:
#   1. frontmatter `name` matching the directory name
#   2. description present and ≤ 1024 chars
#   3. referenced references/*.md files that don't exist
#   4. hardcoded install paths (~/.config/devin) outside the <skills-root> definition
#   5. platform-specific tool names that break the multi-tool install
#   6. oversized SKILL.md (warn > 350 lines — split into references/)
#
# elay/ is product-scoped (Devin/Elay) and exempt from portability checks.
#
# Usage: bash lint-skills.sh   (exit 1 on errors; warnings don't fail)
set -uo pipefail
cd "$(dirname "$0")"

errors=0
warnings=0
err()  { echo "ERROR $1"; errors=$((errors+1)); }
warn() { echo "WARN  $1"; warnings=$((warnings+1)); }

frontmatter() { awk '/^---$/{c++; next} c==1{print} c>=2{exit}' "$1"; }

for dir in m-*/; do
  dir="${dir%/}"
  skill="$dir/SKILL.md"
  [ -f "$skill" ] || { err "$dir: missing SKILL.md"; continue; }
  fm="$(frontmatter "$skill")"

  # 1. name == directory
  name="$(printf '%s\n' "$fm" | sed -n 's/^name:[[:space:]]*//p' | head -1 | tr -d '"')"
  [ "$name" = "$dir" ] || err "$skill: frontmatter name '$name' != directory '$dir'"

  # 2. description present, ≤ 1024 chars (normalize folded YAML to one line)
  desc="$(printf '%s\n' "$fm" | awk '/^description:/{f=1} f && /^[a-z_-]+:/ && !/^description:/{exit} f{print}' \
          | sed 's/^description:[[:space:]]*//' | tr '\n' ' ' | sed 's/^[">|-]*[[:space:]]*//; s/[[:space:]]*$//')"
  if [ -z "$desc" ]; then
    err "$skill: missing description"
  elif [ "${#desc}" -gt 1024 ]; then
    err "$skill: description is ${#desc} chars (max 1024)"
  fi

  # 3. referenced references/*.md must exist
  for ref in $(grep -o 'references/[A-Za-z0-9._-]*\.md' "$skill" 2>/dev/null | sort -u); do
    [ -f "$dir/$ref" ] || err "$skill: references nonexistent file $ref"
  done

  # 4. hardcoded install paths (allowed only where <skills-root> is defined/exemplified)
  # (lines that define/exemplify the skills-root convention are exempt)
  if grep -qn '~/.config/devin' "$skill"; then
    grep -n '~/.config/devin' "$skill" | grep -vE 'skills[- ]root' | while read -r line; do
      err "$skill: hardcoded install path — use <skills-root>: ${line%%:*}"
    done
    # subshell can't bump the counter; re-count
    n=$(grep -n '~/.config/devin' "$skill" | grep -cvE 'skills[- ]root')
    errors=$((errors+n))
  fi

  # 5. platform-specific tool names (tool-neutral wording required)
  for tok in run_subagent subagent_general todo_write 'mcp__mcp-atlassian'; do
    if grep -rqn "$tok" "$dir" 2>/dev/null; then
      err "$dir: contains platform-specific token '$tok' (use tool-neutral wording)"
    fi
  done

  # 6. size budget
  lines=$(wc -l < "$skill")
  [ "$lines" -le 350 ] || warn "$skill: $lines lines — consider splitting into references/"
done

echo
echo "lint-skills: $errors error(s), $warnings warning(s)"
[ "$errors" -eq 0 ]
