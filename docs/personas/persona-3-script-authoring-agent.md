---
title: Persona 3 — Script Authoring Agent
description: The LLM persona that writes deterministic transformation scripts in tooling/ — run once, used forever by the Script Executor.
---

# Persona 3 — Script Authoring Agent

**Type**: LLM (one-shot per script)
**Runs**: Once, when a new deterministic transformation task is identified

## What this persona produces

Deterministic transformation scripts in `tooling/`:

- `generate-{artifact}.py` — SLO YAML → PrometheusRule manifests
- `generate-{artifact}.sh` — service manifest → Helm chart directory
- `generate-ci-workflow.sh` — service name + language → GitHub Actions YAML
- `generate-codeowners.py` — team-context map → CODEOWNERS
- `validate-contracts.sh` — repo state → pass/fail coverage report

## What distinguishes this persona

Its output is not a deliverable — it is the *next persona's input*. The agent runs exactly once per script. After the script is reviewed and merged, the agent is never re-invoked for that task. Only the script runs, forever.

This persona is the bridge between LLM reasoning and machine execution. It crystallizes judgment into repeatable automation.

## When to invoke this persona vs. Persona 5

If the task requires reading structured data and producing structured output through a deterministic algorithm: invoke this persona. If the task requires reading natural language (invariants, ADR rationale) and producing idiomatic code through synthesis: invoke Persona 5.
