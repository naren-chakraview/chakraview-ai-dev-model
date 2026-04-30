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
