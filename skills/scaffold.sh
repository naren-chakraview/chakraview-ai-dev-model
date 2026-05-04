#!/usr/bin/env bash
# Creates the Chakraview project directory structure. Idempotent.
set -euo pipefail

PROJECT_DIR="${PWD}"
while [[ $# -gt 0 ]]; do
  case "$1" in
    --project-dir) PROJECT_DIR="$2"; shift 2 ;;
    *) echo "Unknown flag: $1"; exit 1 ;;
  esac
done

DIRS=(
  contracts/slas contracts/domain-invariants contracts/event-schemas
  docs/adrs docs/ddd docs/intake docs/migration docs/runbooks
  ai-agents/tasks ai-agents/context ai-agents/reviews
  tooling services infrastructure/helm/charts
  observability/slos observability/alerts
  api/openapi api/asyncapi
)

for dir in "${DIRS[@]}"; do
  target="$PROJECT_DIR/$dir"
  if [[ ! -d "$target" ]]; then
    mkdir -p "$target"
    touch "$target/.gitkeep"
    echo "Created $dir/"
  fi
done

echo "Scaffold complete in $PROJECT_DIR"
