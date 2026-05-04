#!/usr/bin/env bash
set -euo pipefail
SKILLS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TMP=$(mktemp -d)
ERRORS=0
cleanup() { rm -rf "$TMP"; }
trap cleanup EXIT

"$SKILLS_DIR/scaffold.sh" --project-dir "$TMP"

for dir in contracts/slas contracts/domain-invariants contracts/event-schemas \
           docs/adrs docs/ddd ai-agents/tasks ai-agents/context ai-agents/reviews; do
  if [[ ! -d "$TMP/$dir" ]]; then
    echo "FAIL: $dir not created"; ERRORS=$((ERRORS+1))
  else
    echo "OK: $dir"
  fi
done

# Idempotency: re-run must not fail
"$SKILLS_DIR/scaffold.sh" --project-dir "$TMP"
echo "OK: re-run idempotent"

# Must not overwrite existing files
echo "existing" > "$TMP/contracts/slas/keep.yaml"
"$SKILLS_DIR/scaffold.sh" --project-dir "$TMP"
[[ "$(cat "$TMP/contracts/slas/keep.yaml")" == "existing" ]] && echo "OK: existing file preserved" || { echo "FAIL: file overwritten"; ERRORS=$((ERRORS+1)); }

[[ $ERRORS -gt 0 ]] && echo "$ERRORS error(s)" && exit 1
echo "scaffold.sh: all tests passed"
