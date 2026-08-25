#!/usr/bin/env bash
# PreToolUse guardrail hook — runs on file edits/writes, under any harness.
#
# Company policy that runs regardless of what the model decided. Permission
# tiers are the primary boundary; this is the belt to those braces, and it is
# where rules about *paths* live rather than rules about tools.
#
# Harness-agnostic: it reads the target path from the tool payload on stdin with
# jq (tool_input.file_path or .path), so the same script serves Devin CLI and
# Claude Code. Wire it with matcher ^(edit|write)$ (Devin) or Edit|Write (Claude).
#
# Exit 0 -> allow. Exit 2 -> block; stderr is fed back to the agent to correct.

set -uo pipefail

payload="$(cat)"
file_path="$(printf '%s' "$payload" | jq -r '.tool_input.file_path // .tool_input.path // ""' 2>/dev/null)"

[ -z "$file_path" ] && exit 0

case "$file_path" in
  *.env|*.env.*|*.pem|*id_rsa*)
    echo "BLOCKED: $file_path holds secrets/keys. Ask a human to change it." >&2
    exit 2
    ;;
  */.claude/settings.json|.claude/settings.json|*/.claude/hooks/*|.claude/hooks/*|\
  */.devin/config.json|.devin/config.json|*/.devin/config.local.json|.devin/config.local.json|\
  */.devin/hooks/*|.devin/hooks/*|*/.devin/rules/*|.devin/rules/*|\
  */scripts/agent-hooks/*|scripts/agent-hooks/*)
    echo "BLOCKED: $file_path is a guardrail file. Changing permissions, hooks, or rules is a separate, human-reviewed change - not part of feature work." >&2
    exit 2
    ;;
  */.sdd/state.json|.sdd/state.json|*/.sdd/config.json|.sdd/config.json)
    echo "BLOCKED: $file_path is SDD pipeline state. Mutate it only via m-sdd/sdd-lib.sh, never by hand." >&2
    exit 2
    ;;
  */node_modules/*|*/.git/*)
    echo "BLOCKED: $file_path is generated or VCS-internal. Edit the source instead." >&2
    exit 2
    ;;
esac

exit 0
