#!/usr/bin/env bash
set -euo pipefail
SKILLS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TMP_HOME=$(mktemp -d); TMP_PROJECT=$(mktemp -d)
ERRORS=0
cleanup() { rm -rf "$TMP_HOME" "$TMP_PROJECT"; }
trap cleanup EXIT

mkdir -p "$TMP_HOME/.claude" "$TMP_PROJECT/.cursor" "$TMP_PROJECT/.github"
HOME="$TMP_HOME"

"$SKILLS_DIR/install.sh" --project-dir "$TMP_PROJECT"

[[ -d "$TMP_HOME/.claude/skills/chakraview" ]] && echo "OK: Claude Code" || { echo "FAIL: Claude Code not installed"; ERRORS=$((ERRORS+1)); }
[[ -d "$TMP_PROJECT/.cursor/rules" ]]          && echo "OK: Cursor"      || { echo "FAIL: Cursor not installed";     ERRORS=$((ERRORS+1)); }
[[ -f "$TMP_PROJECT/.github/copilot-instructions.md" ]] && echo "OK: Copilot" || { echo "FAIL: Copilot not installed"; ERRORS=$((ERRORS+1)); }

[[ $ERRORS -gt 0 ]] && echo "$ERRORS error(s)" && exit 1
echo "Auto-detection: all tests passed"
