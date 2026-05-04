#!/usr/bin/env bash
set -euo pipefail
SKILLS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TMP_HOME=$(mktemp -d); TMP_PROJECT=$(mktemp -d)
ERRORS=0
cleanup() { rm -rf "$TMP_HOME" "$TMP_PROJECT"; }
trap cleanup EXIT

mkdir -p "$TMP_HOME/.claude"
HOME="$TMP_HOME"

"$SKILLS_DIR/install.sh" --target claude-code --project-dir "$TMP_PROJECT"

for slug in workflow intake-triage implement-service compliance-review write-adr \
            write-runbook write-migration-phase script-authoring \
            documentation-agent script-authoring-agent implementation-agent compliance-agent; do
  dest="$TMP_HOME/.claude/skills/chakraview/$slug/SKILL.md"
  if [[ ! -f "$dest" ]]; then
    echo "FAIL: $dest not created"; ERRORS=$((ERRORS+1))
  elif ! grep -q "^name: chakraview:$slug" "$dest"; then
    echo "FAIL: $dest missing name field"; ERRORS=$((ERRORS+1))
  else
    echo "OK: $slug"
  fi
done

# Context files must be installed to project
for ctx in coding-standards.md infra-conventions.md observability-requirements.md; do
  if [[ ! -f "$TMP_PROJECT/ai-agents/context/$ctx" ]]; then
    echo "FAIL: context/$ctx not installed to project"; ERRORS=$((ERRORS+1))
  else
    echo "OK: context/$ctx"
  fi
done

# dry-run must not write
TMP_HOME2=$(mktemp -d); mkdir -p "$TMP_HOME2/.claude"; HOME="$TMP_HOME2"
"$SKILLS_DIR/install.sh" --target claude-code --project-dir "$TMP_PROJECT" --dry-run
[[ ! -d "$TMP_HOME2/.claude/skills" ]] && echo "OK: --dry-run did not write" || { echo "FAIL: --dry-run wrote files"; ERRORS=$((ERRORS+1)); }
rm -rf "$TMP_HOME2"

[[ $ERRORS -gt 0 ]] && echo "$ERRORS error(s)" && exit 1
echo "install.sh --target claude-code: all tests passed"
