#!/usr/bin/env bash
# One-shot vendoring: copy delegated skills into the toolkit as an h-* bundle,
# rewrite references to the h- names. Idempotent-ish (lookbehind prevents double-prefix).
set -euo pipefail
SRC="$HOME/.config/devin/skills"
DEST="$(cd "$(dirname "$0")" && pwd)"

# Upstream skills -> vendored as h-<name>
UPSTREAM="brainstorming writing-plans executing-plans subagent-driven-development \
finishing-a-development-branch using-git-worktrees test-driven-development \
requesting-code-review receiving-code-review"
# Already-h skills -> vendored as-is (own names)
HSK="h-ask h-worktree h-git-commit h-story-breakdown"

echo "== 1. copy =="
for s in $UPSTREAM; do
  if [ -d "$SRC/$s" ]; then rm -rf "$DEST/h-$s"; cp -R "$SRC/$s" "$DEST/h-$s"; echo "  vendored $s -> h-$s"
  else echo "  WARN missing $s"; fi
done
for s in $HSK; do
  if [ -d "$SRC/$s" ]; then rm -rf "$DEST/$s"; cp -R "$SRC/$s" "$DEST/$s"; echo "  vendored $s (as-is)"
  else echo "  WARN missing $s"; fi
done

# agent-skills quality companions -> vendored as h-<name>
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

echo "== 2. rewrite references across all .md (h-sdd* + vendored) =="
# For each vendored upstream name: superpowers:<n> -> h-<n>, then bare <n> -> h-<n>
# (the (?<!h-) lookbehind avoids turning h-<n> into h-h-<n>).
find "$DEST" -name '*.md' -type f ! -path "$DEST/docs/*" -print0 | while IFS= read -r -d '' f; do
  for n in $UPSTREAM; do
    perl -i -pe "s/\bsuperpowers:\Q$n\E\b/h-$n/g" "$f"
    perl -i -pe "s/(?<!h-)\b\Q$n\E\b/h-$n/g" "$f"
  done
done

echo "== 2b. scrub upstream paths/branding to this toolkit's conventions =="
# Keeps the bundle self-contained: no upstream-collection paths or names survive
# a re-vendor. NOTE: the "superpowers" literals below are the scrub TARGETS this
# script deletes from vendored files — they must stay (vendor.sh excludes itself).
# docs/superpowers/* -> docs/*; ~/.config/superpowers -> ~/.config/sdd-toolkit;
# .superpowers session dirs -> .sdd/brainstorm; the brand word -> "this toolkit".
find "$DEST" \( -name '*.md' -o -name '*.sh' \) -type f ! -name 'vendor.sh' ! -path "$DEST/docs/*" -print0 | while IFS= read -r -d '' f; do
  perl -i -pe 's{docs/superpowers/}{docs/}g;
               s{\.config/superpowers/}{.config/sdd-toolkit/}g;
               s{\.superpowers/brainstorm/}{.sdd/brainstorm/}g;
               s{\.superpowers/}{.sdd/brainstorm/}g;
               s/\bSuperpowers\b/this toolkit/g' "$f"
done

echo "== 3. rewrite install.sh (symlink h-*, never clobber a real skill dir) =="
cat > "$DEST/install.sh" <<'EOF'
#!/usr/bin/env bash
# Symlink every bundled skill (h-*) into ~/.config/devin/skills so Devin CLI loads them.
# NEVER clobbers an existing REAL dir — preserves a user's own hand-authored skills
# (e.g. your original h-ask); only that user's missing skills get the vendored copy.
set -euo pipefail
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
EOF
chmod +x "$DEST/install.sh"
echo "== DONE =="
