---
title: Persona 1 — Human Domain Expert
description: The human author of all contracts, ADR stubs, and task specifications — the correctness anchor for every downstream artifact.
---

# Persona 1 — Human Domain Expert

**Type**: Human
**Accountable for**: Correctness. If a contract is wrong, every downstream artifact is wrong.

## What this persona authors

- `contracts/slas/` — SLA targets negotiated with stakeholders
- `contracts/domain-invariants/` — business rules the domain must never violate
- `contracts/event-schemas/` — canonical JSON Schemas for every domain event
- `tooling/service-manifest.yaml` — authoritative list of services, owners, resources
- `docs/adrs/` — decision context and rationale stubs (the *why*, not the full MADR)
- `docs/ddd/bounded-contexts.md`, `ubiquitous-language.md` — context boundaries and shared language
- `ai-agents/tasks/` — task specifications that instruct every other persona

## What this persona does not author

Code, infrastructure manifests, observability artifacts, full ADRs, runbooks, migration docs. Those are produced by agents from the contracts this persona writes.

## Review responsibility

This persona performs the final review gate after each agent phase. The review question is always the same: *does this artifact correctly express the contract?* Not: *is this good code?*

## Guardrails

`CODEOWNERS` maps `contracts/` to `@{project}/senior-engineers`. No agent-initiated PR may modify a contract file.

## Contract Challenge Review

Review incoming Contract Challenge Reports (CCRs) in `ai-agents/reviews/ccr-*.md`. Route each to the relevant product or business owner with the cost signal. Record the outcome directly in the CCR file:

- **Relax**: amend the contract file in `contracts/` and re-enter Phase 0 for the affected contract.
- **Hold**: write an ADR in `docs/adrs/` documenting why the contract stands at this cost. Resume the originating phase once the ADR is written and reviewed.

Neither outcome is undocumented. Every CCR resolution produces a written artifact.
