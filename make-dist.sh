#!/usr/bin/env bash
# Build a clean, recipient-ready ZIP of the toolkit for handoff (Bitbucket / direct).
#
# Ships exactly what an installer needs — install.sh, README.md, and every m-*
# skill folder — and drops maintainer-only files (.git/, docs/, vendor.sh, tests,
# this script). Staged via rsync so excludes are reliable and the source tree is
# never touched. Output contains a top-level sdd-toolkit/ folder, so a recipient
# just unzips and follows the README.
#
# Usage:  bash make-dist.sh            # -> ./sdd-toolkit.zip
#         bash make-dist.sh /path/out.zip
set -euo pipefail

command -v zip   >/dev/null || { echo "need 'zip' (preinstalled on macOS)"; exit 1; }
command -v rsync >/dev/null || { echo "need 'rsync' (preinstalled on macOS)"; exit 1; }

HERE="$(cd "$(dirname "$0")" && pwd)"
NAME="$(basename "$HERE")"
OUT="${1:-$HERE/$NAME.zip}"
case "$OUT" in /*) ;; *) OUT="$PWD/$OUT" ;; esac   # make relative output absolute

STAGE_ROOT="$(mktemp -d)"
STAGE="$STAGE_ROOT/$NAME"
mkdir -p "$STAGE"

rsync -a \
  --exclude='.git/' \
  --exclude='.gitattributes' \
  --exclude='.gitignore' \
  --exclude='.devin/' \
  --exclude='.DS_Store' \
  --exclude='docs/' \
  --exclude='vendor.sh' \
  --exclude='make-dist.sh' \
  --exclude='test_*.sh' \
  --exclude='*.zip' \
  "$HERE"/ "$STAGE"/

rm -f "$OUT"
( cd "$STAGE_ROOT" && zip -r -q "$OUT" "$NAME" )
rm -rf "$STAGE_ROOT"

echo "Built: $OUT"
echo "  $(unzip -l "$OUT" | tail -1 | awk '{print $2}') files, $(du -h "$OUT" | awk '{print $1}')"
echo "Share this ZIP — recipients unzip it and follow the README's 'Install it' steps."
