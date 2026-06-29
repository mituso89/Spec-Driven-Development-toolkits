#!/usr/bin/env bash
# Install the bundled skills (h-*) into ~/.config/devin/skills so Devin CLI loads them.
#
# Prefers symlinks (so maintainers can edit the repo in place). Falls back to
# copies where symlinks need extra privileges — notably Windows / Git Bash
# without Developer Mode — so non-developers can install with zero extra setup.
#
# NEVER clobbers a skill you wrote yourself: an existing real directory we didn't
# create is left untouched. Our own copies carry a hidden .sdd-vendored marker so
# re-running this script can safely update them.
set -euo pipefail
SRC="$(cd "$(dirname "$0")" && pwd)"
DEST="$HOME/.config/devin/skills"
mkdir -p "$DEST"

case "$(uname -s 2>/dev/null)" in
  MINGW*|MSYS*|CYGWIN*) METHOD="copy" ;;   # Windows/Git Bash: symlinks need Developer Mode
  *)                    METHOD="symlink" ;;
esac
echo "Installing skills into $DEST (method: $METHOD)"

install_one() { # <src> <dest>
  local src="$1" dest="$2"
  if [ "$METHOD" = symlink ] && ln -sfn "$src" "$dest" 2>/dev/null; then
    return 0
  fi
  rm -rf "$dest"
  cp -R "$src" "$dest"
  : > "$dest/.sdd-vendored"   # mark as ours so a later run can update it
}

for d in "$SRC"/h-*; do
  [ -d "$d" ] || continue
  name="$(basename "$d")"
  target="$DEST/$name"
  # Skip a real directory we didn't create (the user's own hand-authored skill).
  if [ -e "$target" ] && [ ! -L "$target" ] && [ ! -f "$target/.sdd-vendored" ]; then
    echo "  skip      $name  (your own skill — left untouched)"; continue
  fi
  install_one "$d" "$target"
  echo "  installed $name"
done
echo "Done. Restart Devin CLI (or re-scan skills) to load them."
