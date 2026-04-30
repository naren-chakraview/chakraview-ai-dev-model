---
title: Persona 4 — Script Executor
description: The deterministic automation persona that runs tooling scripts in CI to produce observability, infrastructure, and validation artifacts.
---

# Persona 4 — Script Executor

**Type**: Deterministic automation (no LLM)
**Runs**: In CI on every relevant push; manually on demand

## What this persona produces

- `observability/slos/{service}-slo.yaml` — from `contracts/slas/` via `generate-{artifact}.py`
- `observability/alerts/{service}-burnrate.yaml` — from SLO YAML via `generate-{artifact}.py`
- `infrastructure/helm/charts/{service}/` — from service manifest via `generate-{artifact}.sh`
- `.github/workflows/ci-{service}.yml` — from service manifest via `generate-ci-workflow.sh`
- `CODEOWNERS` — from team-context map via `generate-codeowners.py`
- Validation reports — from `validate-contracts.sh`

## What distinguishes this persona

No reasoning. Pure transformation. Every output is a deterministic function of its inputs; running the script twice produces identical output. Any failure is traceable to a malformed or missing contract input — not to the script itself. This property makes its output auditable as a diff: a change in a contract file produces a predictable, reviewable change in the generated artifact.

## Idempotency requirement

All scripts executed by this persona must be idempotent. This is a hard requirement enforced in the script task specs.
