#!/usr/bin/env bash
# Chakraview skills installer.
# Usage: ./install.sh [--target <platform>] [--project-dir <dir>] [--init] [--dry-run]
set -euo pipefail

SKILLS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOURCE_DIR="$SKILLS_DIR/source"
PLATFORMS_DIR="$SKILLS_DIR/platforms"
PROJECT_DIR="${PWD}"
DRY_RUN=false
TARGET=""
RUN_INIT=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    --target)      TARGET="$2";      shift 2 ;;
    --project-dir) PROJECT_DIR="$2"; shift 2 ;;
    --dry-run)     DRY_RUN=true;     shift   ;;
    --init)        RUN_INIT=true;    shift   ;;
    *) echo "Unknown flag: $1"; exit 1 ;;
  esac
done

# ── helpers ───────────────────────────────────────────────────────────────────

get_fm() {
  local file="$1" field="$2"
  awk -v f="$field" '
    BEGIN{c=0; found=0}
    /^---/{c++;next}
    c==1 && $0~"^"f":" {
      sub("^"f":[ ]*","")
      if ($0 == ">" || $0 == "") { found=1; next }
      print; exit
    }
    c==1 && found && /^[[:space:]]/ {
      sub(/^[[:space:]]*/,"")
      sub(/[[:space:]]*$/,"")
      print; exit
    }
    c==1 && found { exit }
  ' "$file"
}

strip_fm() {
  local file="$1"
  awk 'BEGIN{c=0} /^---/ && c<2 {c++;next} c>=2{print}' "$file"
}

write_file() {
  local dest="$1" src="$2"
  if [[ "$DRY_RUN" == true ]]; then echo "[dry-run] Would write $dest"; return; fi
  mkdir -p "$(dirname "$dest")"
  cp "$src" "$dest"
  echo "  Wrote $(basename "$dest")"
}

confirm() {
  [[ ! -t 0 ]] && return 0  # non-interactive: auto-confirm
  read -r -p "$1 [y/N] " r; [[ "$r" =~ ^[Yy]$ ]]
}

# ── platform detection ────────────────────────────────────────────────────────
detect_claude_code() { [[ -d "$HOME/.claude" ]]; }
detect_cursor()      { [[ -d "$PROJECT_DIR/.cursor" ]]   || command -v cursor   &>/dev/null; }
detect_windsurf()    { [[ -d "$PROJECT_DIR/.windsurf" ]]  || command -v windsurf &>/dev/null; }
detect_copilot()     { [[ -d "$PROJECT_DIR/.github" ]]; }
detect_codex()       { [[ -f "$PROJECT_DIR/AGENTS.md" ]]  || command -v openai  &>/dev/null; }
detect_gemini()      { [[ -d "$PROJECT_DIR/.gemini" ]]    || command -v gemini  &>/dev/null; }

# ── ordered source file list ──────────────────────────────────────────────────
source_files() {
  for f in \
    "$SOURCE_DIR"/meta-workflow.md \
    "$SOURCE_DIR"/task-intake-triage.md \
    "$SOURCE_DIR"/task-implement-service.md \
    "$SOURCE_DIR"/task-compliance-review.md \
    "$SOURCE_DIR"/task-write-adr.md \
    "$SOURCE_DIR"/task-write-runbook.md \
    "$SOURCE_DIR"/task-write-migration-phase.md \
    "$SOURCE_DIR"/task-script-authoring.md \
    "$SOURCE_DIR"/persona-documentation-agent.md \
    "$SOURCE_DIR"/persona-script-authoring-agent.md \
    "$SOURCE_DIR"/persona-implementation-agent.md \
    "$SOURCE_DIR"/persona-compliance-agent.md; do
    [[ -f "$f" ]] && echo "$f"
  done
}

# ── context file install (all platforms) ─────────────────────────────────────
install_context_files() {
  local ctx_src="$SOURCE_DIR/context"
  local ctx_dest="$PROJECT_DIR/ai-agents/context"
  [[ -d "$ctx_src" ]] || return 0
  if [[ "$DRY_RUN" == true ]]; then
    echo "[dry-run] Would copy context files to $ctx_dest"
    return
  fi
  mkdir -p "$ctx_dest"
  for f in "$ctx_src"/*.md; do
    [[ -f "$f" ]] || continue
    local dest="$ctx_dest/$(basename "$f")"
    [[ -f "$dest" ]] || { cp "$f" "$dest"; echo "  Wrote ai-agents/context/$(basename "$f")"; }
  done
}

# ── Claude Code adapter ───────────────────────────────────────────────────────
install_claude_code() {
  local root="$HOME/.claude/skills/chakraview"
  echo "→ Claude Code: $root"
  [[ "$DRY_RUN" == false ]] && ! confirm "  Install to $root?" && return
  install_context_files
  while IFS= read -r f; do
    local name slug
    name=$(get_fm "$f" "name"); slug="${name#chakraview:}"
    write_file "$root/$slug/SKILL.md" "$f"
  done < <(source_files)
  echo "  Claude Code install complete."
}

# ── Cursor adapter ────────────────────────────────────────────────────────────
install_cursor() {
  local rules="$PROJECT_DIR/.cursor/rules"
  echo "→ Cursor: $rules"
  [[ "$DRY_RUN" == false ]] && ! confirm "  Install to $rules?" && return
  install_context_files
  local tmp; tmp=$(mktemp)
  while IFS= read -r f; do
    local name slug desc
    name=$(get_fm "$f" "name"); slug="${name#chakraview:}"; desc=$(get_fm "$f" "description")
    { echo "---"; echo "description: \"$name — $desc\""; echo "alwaysApply: false"; echo "---"; echo ""; strip_fm "$f"; } > "$tmp"
    write_file "$rules/chakraview-$slug.mdc" "$tmp"
  done < <(source_files)
  rm -f "$tmp"
  echo "  Cursor install complete."
}

# ── Windsurf adapter ──────────────────────────────────────────────────────────
install_windsurf() {
  local rules="$PROJECT_DIR/.windsurf/rules"
  echo "→ Windsurf: $rules"
  [[ "$DRY_RUN" == false ]] && ! confirm "  Install to $rules?" && return
  install_context_files
  local tmp; tmp=$(mktemp)
  while IFS= read -r f; do
    local name slug desc
    name=$(get_fm "$f" "name"); slug="${name#chakraview:}"; desc=$(get_fm "$f" "description")
    { echo "---"; echo "description: \"$name — $desc\""; echo "alwaysApply: false"; echo "---"; echo ""; strip_fm "$f"; } > "$tmp"
    write_file "$rules/chakraview-$slug.md" "$tmp"
  done < <(source_files)
  rm -f "$tmp"
  echo "  Windsurf install complete."
}

# ── aggregate helpers ─────────────────────────────────────────────────────────
SENTINEL_START="<!-- Generated by chakraview install.sh — do not edit manually -->"
SENTINEL_END="<!-- /Generated by chakraview -->"

generate_block() {
  local platform="$1"
  local preamble="$PLATFORMS_DIR/$platform/preamble.md"
  echo "$SENTINEL_START"; echo ""
  [[ -f "$preamble" ]] && cat "$preamble" && echo ""
  while IFS= read -r f; do
    echo "## $(get_fm "$f" "name")"; echo ""; strip_fm "$f"; echo ""; echo "---"; echo ""
  done < <(source_files)
  echo "$SENTINEL_END"
}

replace_block() {
  local file="$1" new_block="$2"
  local tmp; tmp=$(mktemp)
  awk -v start="$SENTINEL_START" -v end="$SENTINEL_END" -v nb="$new_block" '
    $0==start { in_b=1; while((getline line < nb)>0){print line}; close(nb); next }
    $0==end   { if(in_b){in_b=0;next} }
    in_b      { next }
    { print }
  ' "$file" > "$tmp"
  mv "$tmp" "$file"
}

install_aggregate() {
  local platform="$1" dest="$2"
  echo "→ $platform: $dest"
  [[ "$DRY_RUN" == false ]] && ! confirm "  Install to $dest?" && return
  if [[ "$DRY_RUN" == true ]]; then echo "[dry-run] Would write/update $dest"; return; fi
  install_context_files
  local block; block=$(mktemp)
  generate_block "$platform" > "$block"
  mkdir -p "$(dirname "$dest")"
  if [[ -f "$dest" ]] && grep -qF "$SENTINEL_START" "$dest"; then
    replace_block "$dest" "$block"; echo "  Updated $dest (sentinel replaced)"
  else
    cat "$block" >> "$dest"; echo "  Wrote $dest"
  fi
  rm -f "$block"
  echo "  $platform install complete."
}

install_copilot() { install_aggregate "copilot" "$PROJECT_DIR/.github/copilot-instructions.md"; }
install_codex()   { install_aggregate "codex"   "$PROJECT_DIR/AGENTS.md"; }
install_gemini()  { install_aggregate "gemini"  "$PROJECT_DIR/GEMINI.md"; }

# ── dispatch ──────────────────────────────────────────────────────────────────
run_platform() {
  case "$1" in
    claude-code) install_claude_code ;;
    cursor)      install_cursor      ;;
    windsurf)    install_windsurf    ;;
    copilot)     install_copilot     ;;
    codex)       install_codex       ;;
    gemini)      install_gemini      ;;
    *) echo "Unknown platform: $1"; exit 1 ;;
  esac
}

detect_platform() {
  case "$1" in
    claude-code) detect_claude_code ;;
    cursor)      detect_cursor      ;;
    windsurf)    detect_windsurf    ;;
    copilot)     detect_copilot     ;;
    codex)       detect_codex       ;;
    gemini)      detect_gemini      ;;
    *) return 1 ;;
  esac
}

[[ "$RUN_INIT" == true ]] && "$SKILLS_DIR/scaffold.sh" --project-dir "$PROJECT_DIR"

if [[ -n "$TARGET" ]]; then
  run_platform "$TARGET"
else
  echo "Auto-detecting installed platforms..."
  FOUND=0
  for p in claude-code cursor windsurf copilot codex gemini; do
    if detect_platform "$p" 2>/dev/null; then
      FOUND=$((FOUND+1)); run_platform "$p"
    fi
  done
  if [[ $FOUND -eq 0 ]]; then
    echo "No platforms detected. Use --target <platform> to install manually."
    echo "Platforms: claude-code cursor windsurf copilot codex gemini"
    exit 1
  fi
fi
