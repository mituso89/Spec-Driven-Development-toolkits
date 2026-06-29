#!/usr/bin/env bash
# Dependency-free unit tests for sdd-lib.sh. Run: bash test_sdd_lib.sh
#
# Devin CLI's exec tool runs commands under bash, but the suite re-execs itself under
# BOTH bash and zsh for portability — zsh-only bugs (empty-glob `nomatch`
# aborts, read-only `$status`, unset `BASH_SOURCE`) only surface in the zsh pass.
set -u

# --- dual-shell harness: re-exec this file under each available shell, then run inner ---
if [ -z "${SDD_INNER:-}" ]; then
  HERE="$(cd "$(dirname "$0")" && pwd)"
  rc=0; ran=0
  for sh in bash zsh; do
    if command -v "$sh" >/dev/null 2>&1; then
      ran=$((ran+1))
      printf '=== %s ===\n' "$sh"
      # Run from `/`, not the lib dir, so the lib must resolve its own path correctly
      # (a CWD-relative fallback would mask the unset-BASH_SOURCE bug under zsh).
      ( cd / && SDD_INNER=1 "$sh" "$HERE/$(basename "$0")" ) || rc=1
    else
      printf '=== %s: not found, skipped ===\n' "$sh"
    fi
  done
  [ "$ran" -gt 0 ] || { printf 'ERROR: neither bash nor zsh found\n' >&2; exit 1; }
  exit "$rc"
fi

HERE="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=sdd-lib.sh
source "$HERE/sdd-lib.sh"

PASS=0; FAIL=0
assert_eq() { # assert_eq <actual> <expected> <msg>
  if [ "$1" = "$2" ]; then PASS=$((PASS+1));
  else FAIL=$((FAIL+1)); printf 'FAIL: %s\n  expected: [%s]\n  actual:   [%s]\n' "$3" "$2" "$1"; fi
}
assert_file() { if [ -f "$1" ]; then PASS=$((PASS+1)); else FAIL=$((FAIL+1)); printf 'FAIL: missing file %s (%s)\n' "$1" "$2"; fi; }
newroot() { mktemp -d 2>/dev/null || mktemp -d -t sddtest; }

# --- slugify ---
assert_eq "$(sdd_slugify 'User Auth & Login!')" "user-auth-login" "slugify lowercases and dashes"
assert_eq "$(sdd_slugify '  Spaced  Out  ')" "spaced-out" "slugify trims/squeezes"

# --- next_number / scaffold ---
R="$(newroot)"
sdd_scaffold "$R"
assert_file "$R/.sdd/config.json" "scaffold writes config"
assert_file "$R/.sdd/state.json" "scaffold writes state"
assert_eq "$(jq -r '.activeFeature' "$R/.sdd/config.json")" "null" "fresh config has null activeFeature"
assert_eq "$(sdd_next_number "$R")" "001" "first number is 001"
mkdir -p "$R/specs/001-foo" "$R/specs/002-bar"
assert_eq "$(sdd_next_number "$R")" "003" "next number after 002 is 003"
rm -rf "$R"

# --- create_feature / active / next (no constitution yet) ---
R="$(newroot)"; sdd_scaffold "$R"
ID="$(sdd_create_feature "$R" 'User Auth')"
assert_eq "$ID" "001-user-auth" "create_feature returns NNN-slug id"
assert_eq "$(sdd_active_feature "$R")" "001-user-auth" "create sets active feature"
assert_eq "$(sdd_phase_status "$R" "$ID" specify)" "pending" "new feature: specify pending"
assert_eq "$(sdd_phase_status "$R" "$ID" constitution)" "pending" "no constitution file -> constitution pending"
assert_eq "$(sdd_get_next "$R" "$ID")" "constitution" "next is constitution when none exists"

# --- constitution present before create ---
R2="$(newroot)"; sdd_scaffold "$R2"; printf 'rules\n' > "$R2/.sdd/constitution.md"
ID2="$(sdd_create_feature "$R2" 'Billing')"
assert_eq "$(sdd_phase_status "$R2" "$ID2" constitution)" "done" "constitution file -> constitution done"
assert_eq "$(sdd_get_next "$R2" "$ID2")" "specify" "next is specify when constitution done"

# --- set_phase recomputes next; require gates ---
sdd_set_phase "$R2" "$ID2" specify approved
assert_eq "$(sdd_phase_status "$R2" "$ID2" specify)" "approved" "set_phase updates status"
assert_eq "$(sdd_get_next "$R2" "$ID2")" "clarify" "next advances past approved specify"
( sdd_require "$R2" "$ID2" specify "approved" ) ; assert_eq "$?" "0" "require passes when status accepted"
( sdd_require "$R2" "$ID2" plan "done,approved" 2>/dev/null ) ; assert_eq "$?" "1" "require fails when prereq unmet"
sdd_set_phase "$R2" "$ID2" clarify skipped
assert_eq "$(sdd_get_next "$R2" "$ID2")" "plan" "skipped phase is not 'next'"

# --- invalid inputs rejected ---
( sdd_set_phase "$R2" "$ID2" bogus done 2>/dev/null ) ; assert_eq "$?" "1" "unknown phase rejected"
( sdd_set_phase "$R2" "$ID2" plan bogus 2>/dev/null ) ; assert_eq "$?" "1" "invalid status rejected"
rm -rf "$R" "$R2"

# --- set_active switches the active feature; list reflects it ---
R4="$(newroot)"; sdd_scaffold "$R4"
IA="$(sdd_create_feature "$R4" 'Alpha')"
IB="$(sdd_create_feature "$R4" 'Beta')"
assert_eq "$(sdd_active_feature "$R4")" "$IB" "create switches active to newest feature"
sdd_set_active "$R4" "$IA"
assert_eq "$(sdd_active_feature "$R4")" "$IA" "set_active switches active back to Alpha"
( sdd_set_active "$R4" "999-nope" 2>/dev/null ) ; assert_eq "$?" "1" "set_active rejects unknown id"
assert_eq "$(sdd_list "$R4" | grep -c .)" "2" "list prints one line per feature"
assert_eq "$(sdd_list "$R4" | grep -c '^\* ')" "1" "list marks exactly one active feature"
assert_eq "$(sdd_list "$R4" | grep '^\* ' | grep -c "$IA")" "1" "list marks the active feature (Alpha)"
rm -rf "$R4"

# --- end-to-end fresh scaffold: the exact paths the two zsh bugs lived on ---
# 1) sdd_scaffold copies templates via `find | while read` (empty-glob `nomatch` bug)
#    and resolves its own dir via _sdd_lib_home (unset BASH_SOURCE under zsh `set -u`).
# 2) sdd_set_phase mutates state with a local named `newstatus` (read-only `$status` in zsh).
R3="$(newroot)"; sdd_scaffold "$R3"
assert_file "$R3/.sdd/templates/spec-template.md" "scaffold copies templates (find|read + zsh BASH_SOURCE path)"
assert_eq "$(find "$R3/.sdd/templates" -name '*.md' -type f | wc -l | tr -d ' ')" \
          "$(find "$HERE/templates" -name '*.md' -type f | wc -l | tr -d ' ')" \
          "scaffold copies every template, none dropped"
ID3="$(sdd_create_feature "$R3" 'Zsh Smoke')"
assert_eq "$ID3" "001-zsh-smoke" "create_feature in fresh scaffold returns id"
sdd_set_phase "$R3" "$ID3" specify done
assert_eq "$(sdd_phase_status "$R3" "$ID3" specify)" "done" "set_phase persists status (zsh \$status rename)"
assert_eq "$(sdd_get_next "$R3" "$ID3")" "constitution" "set_phase recomputes next in fresh scaffold"
rm -rf "$R3"

# --- constitution derives from disk: out-of-band authoring flips ALL features ---
R5="$(newroot)"; sdd_scaffold "$R5"
IC="$(sdd_create_feature "$R5" 'Gamma')"
ID5="$(sdd_create_feature "$R5" 'Delta')"
assert_eq "$(sdd_get_next "$R5" "$IC")" "constitution" "pre-constitution feature: next is constitution"
printf 'rules\n' > "$R5/.sdd/constitution.md"   # out-of-band: no skill, no marking loop
assert_eq "$(sdd_phase_status "$R5" "$IC" constitution)" "done" "out-of-band constitution.md -> existing feature reads done"
assert_eq "$(sdd_get_next "$R5" "$IC")" "specify" "next recomputes live after out-of-band constitution"
assert_eq "$(sdd_get_next "$R5" "$ID5")" "specify" "every pre-existing feature sees the constitution"
assert_eq "$(sdd_list "$R5" | grep -c 'next: specify')" "2" "sdd_list shows live next for every feature"
assert_eq "$(sdd_get_next "$R5" "999-nope")" "" "get_next is empty for unknown feature"
rm -rf "$R5"

# --- constitution skip flag + set_phase guard + terminal 'complete' ---
R6="$(newroot)"; sdd_scaffold "$R6"
IE="$(sdd_create_feature "$R6" 'Epsilon')"
( sdd_set_phase "$R6" "$IE" constitution done 2>/dev/null ) ; assert_eq "$?" "1" "marking constitution done without the file is rejected"
sdd_set_phase "$R6" "$IE" constitution skipped
assert_eq "$(sdd_phase_status "$R6" "$IE" constitution)" "skipped" "constitution skip is recorded project-wide"
assert_eq "$(sdd_get_next "$R6" "$IE")" "specify" "skipped constitution unblocks next"
printf 'rules\n' > "$R6/.sdd/constitution.md"
assert_eq "$(sdd_phase_status "$R6" "$IE" constitution)" "done" "file presence overrides the skip flag"
( sdd_set_phase "$R6" "$IE" constitution done ) ; assert_eq "$?" "0" "marking done with file present is an accepted no-op"
for p in specify clarify plan tasks analyze implement issues; do sdd_set_phase "$R6" "$IE" "$p" done; done
assert_eq "$(sdd_get_next "$R6" "$IE")" "complete" "all phases finished -> next is complete"
rm -rf "$R6"

printf '\n%d passed, %d failed\n' "$PASS" "$FAIL"
[ "$FAIL" -eq 0 ]
