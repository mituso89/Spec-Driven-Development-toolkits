#!/usr/bin/env bash
# PostToolUse hook — runs after a file edit/write, under any harness.
#
# The "eyes" made automatic and cheap: every time a file is written it is
# syntax-checked immediately, so a broken file surfaces at the moment it is
# created rather than at the end of the task. This is a fast per-file check, not
# the full verification gate (that is `npm run verify` / your project command).
#
# Reads the target path from stdin with jq. Extend the case block with your
# project's languages. Checks are best-effort: if a checker is not installed the
# file is left alone (exit 0) rather than falsely blocked.
#
# Exit 0 -> silent success. Exit 2 -> stderr is fed back to the agent to fix.

set -uo pipefail

payload="$(cat)"
file_path="$(printf '%s' "$payload" | jq -r '.tool_input.file_path // .tool_input.path // ""' 2>/dev/null)"

[ -z "$file_path" ] && exit 0
[ -f "$file_path" ] || exit 0

case "$file_path" in
  *.js|*.mjs|*.cjs)
    command -v node >/dev/null 2>&1 || exit 0
    # `node --check file.js` can silently pass broken ESM; piping the source in
    # with --input-type=module actually parses it.
    if ! out="$(node --input-type=module --check < "$file_path" 2>&1)"; then
      echo "Syntax error introduced in $file_path:" >&2
      printf '%s\n' "$out" | sed "s|\[stdin\]|$file_path|g" | grep -v '^[[:space:]]*$' | head -3 >&2
      exit 2
    fi
    ;;
  *.json)
    if ! out="$(jq empty "$file_path" 2>&1)"; then
      echo "Invalid JSON in $file_path:" >&2
      printf '%s\n' "$out" | grep -v '^[[:space:]]*$' | head -3 >&2
      exit 2
    fi
    ;;
  *.py)
    command -v python3 >/dev/null 2>&1 || exit 0
    if ! out="$(python3 -m py_compile "$file_path" 2>&1)"; then
      echo "Syntax error introduced in $file_path:" >&2
      printf '%s\n' "$out" | grep -v '^[[:space:]]*$' | head -3 >&2
      exit 2
    fi
    ;;
  *.sh|*.bash)
    if ! out="$(bash -n "$file_path" 2>&1)"; then
      echo "Syntax error introduced in $file_path:" >&2
      printf '%s\n' "$out" | grep -v '^[[:space:]]*$' | head -3 >&2
      exit 2
    fi
    ;;
esac

exit 0
