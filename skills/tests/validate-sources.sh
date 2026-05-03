#!/usr/bin/env bash
set -euo pipefail
SOURCE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../source" && pwd)"
ERRORS=0; FILES=0

get_fm() {
  local file="$1" field="$2"
  awk -v f="$field" 'BEGIN{c=0} /^---/{c++;next} c==1 && $0~"^"f":"{sub("^"f":[ ]*","");print;exit}' "$file"
}

for f in "$SOURCE_DIR"/task-*.md "$SOURCE_DIR"/persona-*.md "$SOURCE_DIR"/meta-*.md; do
  [[ -f "$f" ]] || continue
  FILES=$((FILES+1))
  for field in name type description triggers; do
    [[ -z "$(get_fm "$f" "$field")" ]] && echo "FAIL: $(basename "$f") missing: $field" && ERRORS=$((ERRORS+1))
  done
  name=$(get_fm "$f" "name")
  [[ "$name" != chakraview:* ]] && echo "FAIL: $(basename "$f") name '$name' must start with chakraview:" && ERRORS=$((ERRORS+1))
  type=$(get_fm "$f" "type")
  [[ ! "$type" =~ ^(task|persona|meta)$ ]] && echo "FAIL: $(basename "$f") type '$type' must be task|persona|meta" && ERRORS=$((ERRORS+1))
done

[[ $FILES -eq 0 ]] && echo "FAIL: no source files found" && exit 1
[[ $ERRORS -gt 0 ]] && echo "$ERRORS error(s) in $FILES files" && exit 1
echo "OK: $FILES source skill files valid"
