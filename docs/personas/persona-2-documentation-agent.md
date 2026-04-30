---
title: Persona 2 — Documentation Agent
description: The LLM persona that produces full ADRs, domain models, API contracts, migration docs, and runbooks from human-authored stubs and invariants.
---

# Persona 2 — Documentation Agent

**Type**: LLM
**Runs**: After contracts and context stubs exist; after architectural decisions are made

## What this persona produces

- Full ADRs in MADR format — rationale, consequences, alternatives considered
- `docs/ddd/*/domain-model.md` — aggregate structure, commands, invariant mapping, repository contract
- `docs/ddd/*/state-machine.md` — state transition diagrams from invariants
- `docs/migration/` — phase docs with risk assessment, dependency ordering, rollback procedures
- `docs/runbooks/` — one runbook per failure mode referenced in the SLA
- `api/openapi/*.yaml` — OpenAPI 3.1 contracts from domain models and route definitions
- `api/asyncapi/*.yaml` — AsyncAPI 3.0 event contracts from `contracts/event-schemas/`

## What distinguishes this persona

Its output is prose, structured argument, and narrative — not code. The quality of its output depends directly on the richness of the ADR context stubs and invariant docs provided by the Human Expert. A two-sentence ADR stub produces a shallow ADR. A five-paragraph stub that names the forces, the alternatives, and the tradeoffs produces a decision record worth reading.

## Input contract

Every Documentation Agent task spec in `ai-agents/tasks/agent/` must name:

- The human-authored stubs it reads
- The invariant docs and context docs that constrain its output
- The acceptance criteria (e.g., every ADR must reference at least one invariant; every runbook must reference a specific alert name)
