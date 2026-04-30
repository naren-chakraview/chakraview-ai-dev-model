---
title: Guardrails
description: How to enforce the human/agent boundary and prevent contract drift.
---

# Guardrails

The model only works if guardrails prevent agent drift from contracts. Without enforcement, the boundary exists in documentation but not in practice.

## Core Guardrails

| Guardrail | Mechanism |
|---|---|
| Event schema conformance | Generate typed classes from schema definitions; type errors = contract violations |
| SLA↔SLO traceability | Validation script checks every SLA has a matching SLO definition and a burn rate alert |
| ADR coverage | Validation script checks no service pattern is deployed that contradicts an accepted ADR |
| Metric naming | Observability requirements doc mandates metric names; SLO queries depend on them |
| Contract ownership | CODEOWNERS maps `contracts/` to senior engineers; no agent-initiated PR may modify contracts |

## The Validation Script

The validation script is the primary enforcement mechanism. It runs on every CI push and:

- Fails if implementation exists without a corresponding contract
- Fails if a SLA file exists without a matching SLO definition
- Fails if a SLO file exists without a matching burn rate alert
- Fails if a service is deployed with a pattern that contradicts an accepted ADR

This script is itself produced by the Script Authoring Agent (Persona 3) from a task spec. It runs in CI via the Script Executor (Persona 4).

## Contract Immutability

No agent-produced PR may modify files under `contracts/`. CODEOWNERS maps the contracts directory to senior engineers who must approve any change. This is the hardest guardrail — it makes the boundary structural, not cultural.

## PR Review as Guardrail

Agents produce PRs; humans review them. The review question is always: *does this artifact correctly express the contract?* Not: *is this idiomatic code?*

This reframe is important. The reviewer is not judging the agent's style — they are verifying the agent's fidelity to the contract. A reviewer who cannot answer "which contract authorised this line of code?" should request changes.
