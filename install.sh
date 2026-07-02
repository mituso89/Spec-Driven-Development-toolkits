#!/usr/bin/env bash
# Symlink every bundled skill (h-*) into ~/.config/devin/skills so Devin CLI loads them.
# NEVER clobbers an existing REAL dir — preserves a user's own hand-authored skills
# (e.g. your original h-ask); only that user's missing skills get the vendored copy.
set -euo pipefail
PROJECT_DIR=""
while [[ $# -gt 0 ]]; do
  case "$1" in
    --project) PROJECT_DIR="$2"; shift 2 ;;
    *) echo "Unknown argument: $1"; exit 1 ;;
  esac
done
SRC="$(cd "$(dirname "$0")" && pwd)"
DEST="$HOME/.config/devin/skills"
mkdir -p "$DEST"
for d in "$SRC"/h-*; do
  [ -d "$d" ] || continue
  name="$(basename "$d")"
  if [ -e "$DEST/$name" ] && [ ! -L "$DEST/$name" ]; then
    echo "skip $name (your own real skill — left untouched)"; continue
  fi
  ln -sfn "$d" "$DEST/$name"
  echo "linked $name"
done
echo "Done. Restart Devin CLI or re-scan skills if needed."

# --project: copy quality companion skills into a target project's .devin/skills/
if [ -n "$PROJECT_DIR" ]; then
  QUALITY_SKILLS="h-security-and-hardening h-performance-optimization \
h-debugging-and-error-recovery h-api-and-interface-design h-frontend-ui-engineering"
  PROJ_DEST="$PROJECT_DIR/.devin/skills"
  mkdir -p "$PROJ_DEST"
  echo "Installing quality companion skills into $PROJ_DEST"
  for skill in $QUALITY_SKILLS; do
    src="$SRC/$skill"
    target="$PROJ_DEST/$skill"
    if [ ! -d "$src" ]; then
      echo "  WARN $skill not found in toolkit — run vendor.sh first"; continue
    fi
    if [ -e "$target" ]; then
      echo "  skip $skill (already exists in project — left untouched)"; continue
    fi
    cp -R "$src" "$target"
    echo "  installed $skill -> $target"
  done
  echo "Done. Restart Devin CLI in the project to load them."
fi
