#!/usr/bin/env bash
# Dependency-free unit tests for repo-map.sh. Run: bash test_repo_map.sh
# Re-execs under bash AND zsh (runtime shell is zsh) to catch zsh-only bugs.
set -u

if [ -z "${RM_INNER:-}" ]; then
  HERE="$(cd "$(dirname "$0")" && pwd)"
  rc=0; ran=0
  for sh in bash zsh; do
    if command -v "$sh" >/dev/null 2>&1; then
      ran=$((ran+1)); printf '=== %s ===\n' "$sh"
      ( cd / && RM_INNER=1 "$sh" "$HERE/$(basename "$0")" ) || rc=1
    else
      printf '=== %s: not found, skipped ===\n' "$sh"
    fi
  done
  [ "$ran" -gt 0 ] || { printf 'ERROR: neither bash nor zsh found\n' >&2; exit 1; }
  exit "$rc"
fi

HERE="$(cd "$(dirname "$0")" && pwd)"
REPO_MAP_SOURCED=1 . "$HERE/repo-map.sh"   # source functions, do not run main

PASS=0; FAIL=0
assert_eq()   { if [ "$1" = "$2" ]; then PASS=$((PASS+1)); else FAIL=$((FAIL+1)); printf 'FAIL: %s\n  expected: [%s]\n  actual:   [%s]\n' "$3" "$2" "$1"; fi; }
assert_file() { if [ -f "$1" ]; then PASS=$((PASS+1)); else FAIL=$((FAIL+1)); printf 'FAIL: missing file %s (%s)\n' "$1" "$2"; fi; }
assert_has()  { if printf '%s' "$1" | grep -qF "$2"; then PASS=$((PASS+1)); else FAIL=$((FAIL+1)); printf 'FAIL: %s\n  expected to contain: [%s]\n  actual:\n%s\n' "$3" "$2" "$1"; fi; }
assert_not()  { if printf '%s' "$1" | grep -qF "$2"; then FAIL=$((FAIL+1)); printf 'FAIL: %s\n  expected NOT to contain: [%s]\n  actual:\n%s\n' "$3" "$2" "$1"; else PASS=$((PASS+1)); fi; }
newroot()     { mktemp -d 2>/dev/null || mktemp -d -t rmtest; }

make_fixture() {
  local r="$1"
  mkdir -p "$r/src/contract" "$r/api" "$r/node_modules/junk"
  cat > "$r/src/contract/contract.controller.ts" <<'TS'
export const create = makeCreationHandler({});
export const list = makeGetListHandler(ContractModel, {});
export class ContractService {}
TS
  cat > "$r/api/billing.py" <<'PY'
class BillingService:
    pass
def make_invoice(contract_id):
    return None
PY
  cat > "$r/node_modules/junk/leak.ts" <<'TS'
export const SHOULD_NOT_APPEAR = 1;
TS
}

R="$(newroot)"; make_fixture "$R"
SRC="$(_rm_find_sources "$R")"
assert_has "$SRC" "contract.controller.ts" "finder includes TS source"
assert_has "$SRC" "billing.py"             "finder includes Python source"
assert_not "$SRC" "leak.ts"                "finder prunes node_modules"
rm -rf "$R"

R="$(newroot)"; make_fixture "$R"
LANGS="$(_rm_find_sources "$R" | _rm_detect_langs)"
assert_has "$LANGS" "TypeScript-JavaScript" "detects TS/JS"
assert_has "$LANGS" "Python"                "detects Python"
assert_not "$LANGS" "Swift"                 "does not invent absent languages"
rm -rf "$R"

( _rm_has_universal_ctags ); rc=$?
assert_eq "$([ "$rc" = 0 ] || [ "$rc" = 1 ] && echo ok)" "ok" "ctags probe returns 0 or 1, never errors"

R="$(newroot)"; make_fixture "$R"
TS_OUT="$(_rm_extract_grep "$R/src/contract/contract.controller.ts")"
assert_has "$TS_OUT" "makeCreationHandler" "grep surfaces the TS factory call"
assert_has "$TS_OUT" "ContractService"     "grep surfaces the TS class"
assert_has "$TS_OUT" "L1"                  "grep keeps line numbers"
PY_OUT="$(_rm_extract_grep "$R/api/billing.py")"
assert_has "$PY_OUT" "BillingService"      "grep surfaces the Python class"
assert_has "$PY_OUT" "make_invoice"        "grep surfaces the Python def"
rm -rf "$R"

if _rm_has_universal_ctags; then
  R="$(newroot)"; make_fixture "$R"
  CT="$(_rm_extract_ctags "$R")"
  assert_has "$CT" "ContractService" "ctags surfaces the TS class"
  assert_has "$CT" "BillingService"  "ctags surfaces the Python class"
  rm -rf "$R"
else
  printf 'note: universal-ctags absent — ctags path test skipped (grep path covers fallback)\n'
fi

R="$(newroot)"; make_fixture "$R"
( cd / && RM_INNER= bash "$HERE/repo-map.sh" "$R" >/dev/null )
assert_file "$R/.sdd/repo-map.md" "main writes .sdd/repo-map.md"
MAP="$(cat "$R/.sdd/repo-map.md")"
assert_has "$MAP" "# Repo Map"                "map has a header"
assert_has "$MAP" "src/contract/contract.controller.ts" "map lists the TS file (relative path)"
assert_has "$MAP" "makeCreationHandler"       "map surfaces a TS convention"
assert_has "$MAP" "api/billing.py"            "map lists the Python file"
assert_has "$MAP" "make_invoice"              "map surfaces a Python def"
assert_not "$MAP" "SHOULD_NOT_APPEAR"         "map excludes node_modules"
assert_has "$MAP" "Languages:"                "map records detected languages"

( cd / && bash "$HERE/repo-map.sh" "$R" --out "$R/custom-map.md" >/dev/null )
assert_file "$R/custom-map.md" "--out writes to the given path"
rm -rf "$R"

printf '\n%d passed, %d failed\n' "$PASS" "$FAIL"
[ "$FAIL" -eq 0 ]
