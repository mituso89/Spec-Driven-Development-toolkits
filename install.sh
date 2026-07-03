#!/usr/bin/env bash
# install.sh — SDD toolkit installer
#
# Usage:
#   bash install.sh
#     → Global Devin install: symlink all m-* skills into ~/.config/devin/skills/
#
#   bash install.sh --quality --project <path>
#     → Copy quality companion skills into <path>/.devin/skills/
#
#   bash install.sh --tool <name> --project <path>
#     → Write SDD pipeline adapter + copy ALL m-* skills into <path>
#       Supported tools: claude, cursor, windsurf, agents
#
#   bash install.sh --tool <name> --quality --project <path>
#     → Adapter + quality companion skills only (subset of all skills)
#
# NEVER clobbers existing skills or adapter files you already have.
set -euo pipefail
PROJECT_DIR=""
TOOL_NAME=""
INSTALL_QUALITY=0
while [[ $# -gt 0 ]]; do
  case "$1" in
    --project) PROJECT_DIR="$2"; shift 2 ;;
    --tool)    TOOL_NAME="$2";    shift 2 ;;
    --quality) INSTALL_QUALITY=1; shift ;;
    *) echo "Unknown argument: $1"; exit 1 ;;
  esac
done

# Validate: --tool and --quality require --project
if [ -n "$TOOL_NAME" ] && [ -z "$PROJECT_DIR" ]; then
  echo "Error: --tool requires --project <path>."
  echo "Example: bash install.sh --tool claude --project /path/to/your-project"
  exit 1
fi
if [ "$INSTALL_QUALITY" -eq 1 ] && [ -z "$PROJECT_DIR" ]; then
  echo "Error: --quality requires --project <path>."
  echo "Example: bash install.sh --quality --project /path/to/your-project"
  exit 1
fi
SRC="$(cd "$(dirname "$0")" && pwd)"

# Global Devin install — only when no --project or --tool flag given
if [ -z "$PROJECT_DIR" ] && [ -z "$TOOL_NAME" ]; then
  DEST="$HOME/.config/devin/skills"
  mkdir -p "$DEST"
  for d in "$SRC"/m-*; do
    [ -d "$d" ] || continue
    name="$(basename "$d")"
    if [ -e "$DEST/$name" ] && [ ! -L "$DEST/$name" ]; then
      echo "skip $name (your own real skill — left untouched)"; continue
    fi
    ln -sfn "$d" "$DEST/$name"
    echo "linked $name"
  done
  echo "Done. Restart Devin CLI or re-scan skills if needed."
fi

# --quality: copy quality companion skills into the right skills dir for the target tool
if [ "$INSTALL_QUALITY" -eq 1 ]; then
  QUALITY_SKILLS="m-security-and-hardening m-performance-optimization \
m-debugging-and-error-recovery m-api-and-interface-design m-frontend-ui-engineering"
  # Route to the correct skills directory based on the target tool
  case "$TOOL_NAME" in
    claude)            PROJ_DEST="$PROJECT_DIR/.claude/skills" ;;
    cursor|windsurf)   PROJ_DEST="$PROJECT_DIR/.cursor/skills" ;;
    agents|"")         PROJ_DEST="$PROJECT_DIR/.devin/skills" ;;
    *)                 PROJ_DEST="$PROJECT_DIR/.devin/skills" ;;
  esac
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
  echo "Done. Restart your AI tool in the project to load them."
fi

# --tool without --quality: copy ALL m-* skills into the project's skills dir
if [ -n "$TOOL_NAME" ] && [ "$INSTALL_QUALITY" -eq 0 ]; then
  case "$TOOL_NAME" in
    claude)            ALL_SKILLS_DEST="$PROJECT_DIR/.claude/skills" ;;
    cursor|windsurf)   ALL_SKILLS_DEST="$PROJECT_DIR/.cursor/skills" ;;
    agents|*)          ALL_SKILLS_DEST="$PROJECT_DIR/.devin/skills" ;;
  esac
  mkdir -p "$ALL_SKILLS_DEST"
  echo "Installing all skills into $ALL_SKILLS_DEST"
  for d in "$SRC"/m-*; do
    [ -d "$d" ] || continue
    name="$(basename "$d")"
    target="$ALL_SKILLS_DEST/$name"
    if [ -e "$target" ]; then
      echo "  skip $name (already exists — left untouched)"; continue
    fi
    cp -R "$d" "$target"
    echo "  installed $name"
  done
  echo "Done."
fi

# --tool: write a non-Devin adapter + .sdd/pipeline.md into a target project
if [ -n "$TOOL_NAME" ]; then
  # Map tool name to target file path
  case "$TOOL_NAME" in
    claude)   ADAPTER_REL=".claude/CLAUDE.md" ;;
    cursor)   ADAPTER_REL=".cursorrules" ;;
    windsurf) ADAPTER_REL=".windsurfrules" ;;
    agents)   ADAPTER_REL="AGENTS.md" ;;
    *)
      echo "Error: unknown tool '$TOOL_NAME'. Supported: claude, cursor, windsurf, agents"
      exit 1
      ;;
  esac

  ADAPTER_PATH="$PROJECT_DIR/$ADAPTER_REL"
  ADAPTER_DIR="$(dirname "$ADAPTER_PATH")"

  echo "Installing SDD adapter for '$TOOL_NAME' into $PROJECT_DIR"

  # Create target dir if needed (e.g. .claude/)
  mkdir -p "$ADAPTER_DIR"

  # Never clobber an existing adapter file
  if [ -e "$ADAPTER_PATH" ]; then
    echo "  skip $ADAPTER_REL (already exists — delete it to regenerate)"
  else
    # Assemble adapter: header + shared rules + each phase in pipeline order
    {
      echo "# SDD Pipeline — $TOOL_NAME"
      echo ""
      echo "> Read this before running any SDD phase. This file was generated by"
      echo "> \`bash install.sh --tool $TOOL_NAME --project <path>\` from the SDD toolkit."
      echo ""
      echo "---"
      echo ""
      cat "$SRC/m-sdd/phase-instructions.md"
      echo ""
      for phase in constitution specify clarify plan tasks analyze implement; do
        pi="$SRC/m-sdd-$phase/phase-instructions.md"
        if [ -f "$pi" ]; then
          echo ""
          echo "---"
          echo ""
          cat "$pi"
        else
          echo ""
          echo "---"
          echo ""
          echo "# SDD — $phase phase"
          echo ""
          echo "> phase-instructions.md not found for this phase. Run vendor.sh to update."
        fi
      done
    } > "$ADAPTER_PATH"
    echo "  installed $ADAPTER_REL"
  fi

  # Write .sdd/pipeline.md if absent
  PIPELINE_DIR="$PROJECT_DIR/.sdd"
  PIPELINE_FILE="$PIPELINE_DIR/pipeline.md"
  mkdir -p "$PIPELINE_DIR"
  if [ -e "$PIPELINE_FILE" ]; then
    echo "  skip .sdd/pipeline.md (already exists)"
  else
    cat > "$PIPELINE_FILE" <<'PIPELINE_EOF'
# SDD Pipeline State

<!-- Managed by the SDD toolkit. Update phase rows as you work through the pipeline. -->
<!-- Status values: pending | in_progress | done | approved | skipped -->

## Feature: <!-- replace with your feature name -->  <!-- active -->

| Phase        | Status  |
|--------------|---------|
| constitution | pending |
| specify      | pending |
| clarify      | pending |
| plan         | pending |
| tasks        | pending |
| analyze      | pending |
| implement    | pending |
| issues       | pending |
PIPELINE_EOF
    echo "  installed .sdd/pipeline.md"
  fi

  echo "Done. Restart your AI tool in the project to load the adapter."
fi
