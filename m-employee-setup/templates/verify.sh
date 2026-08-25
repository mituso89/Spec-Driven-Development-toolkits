#!/usr/bin/env bash
# verify.sh — the "eyes": the single command that proves the project works.
#
# A starting point. Replace the three layers with YOUR project's real commands.
# The contract: exit 0 only when the change is actually demonstrated — lint
# clean, tests green, and a live end-to-end check passing (including at least one
# negative case, because a change that cannot be made to fail was never tested).
#
# Keep it fast (seconds, not minutes) so it is cheap to run on every change.

set -uo pipefail
fail=0
step() { printf '\n--- %s ---\n' "$1"; }

step "lint"
# e.g. npm run lint  |  ruff check .  |  golangci-lint run
<LINT COMMAND> || { echo "lint: FAIL"; fail=1; }

step "tests"
# e.g. npm test  |  pytest -q  |  go test ./...
<TEST COMMAND> || { echo "tests: FAIL"; fail=1; }

step "smoke"
# Boot the real thing, hit it, assert on the real response, then tear it down.
# e.g. start the server on an ephemeral port, curl an endpoint AND a bad request.
<SMOKE COMMAND> || { echo "smoke: FAIL"; fail=1; }

echo
if [ "$fail" -ne 0 ]; then echo "VERIFY: FAIL"; exit 1; fi
echo "VERIFY: PASS"
