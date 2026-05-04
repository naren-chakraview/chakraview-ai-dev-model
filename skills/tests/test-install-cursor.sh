#!/usr/bin/env bash
set -euo pipefail
SKILLS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SLUGS=(workflow intake-triage implement-service compliance-review write-adr write-runbook write-migration-phase script-authoring documentation-agent script-authoring-agent implementation-agent compliance-agent)
ERRORS=0

# Cursor
TMP=$(mktemp -d); TMP2=""; mkdir -p "$TMP/.cursor"; trap 'rm -rf "$TMP" "${TMP2:-}"' EXIT
"$SKILLS_DIR/install.sh" --target cursor --project-dir "$TMP"
for slug in "${SLUGS[@]}"; do
  dest="$TMP/.cursor/rules/chakraview-$slug.mdc"
  if [[ ! -f "$dest" ]]; then
    echo "FAIL cursor: $slug not created"; ERRORS=$((ERRORS+1))
  elif ! grep -q "^description:" "$dest" || ! grep -q "^alwaysApply:" "$dest"; then
    echo "FAIL cursor: $slug missing frontmatter"; ERRORS=$((ERRORS+1))
  else
    echo "OK cursor: $slug"
  fi
done

# Windsurf
TMP2=$(mktemp -d); mkdir -p "$TMP2/.windsurf"
"$SKILLS_DIR/install.sh" --target windsurf --project-dir "$TMP2"
for slug in "${SLUGS[@]}"; do
  [[ -f "$TMP2/.windsurf/rules/chakraview-$slug.md" ]] && echo "OK windsurf: $slug" || { echo "FAIL windsurf: $slug"; ERRORS=$((ERRORS+1)); }
done

[[ $ERRORS -gt 0 ]] && echo "$ERRORS error(s)" && exit 1
echo "Cursor/Windsurf: all tests passed"
