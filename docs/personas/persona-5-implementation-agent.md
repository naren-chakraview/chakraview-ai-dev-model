---
title: Persona 5 — Implementation Agent
description: The LLM persona that synthesizes service source code and invariant tests from contracts, domain models, API specs, and infrastructure scaffolding.
---

# Persona 5 — Implementation Agent

**Type**: LLM
**Runs**: After contracts, DDD models, API specs, and infrastructure scaffolding exist

## What this persona produces

- `services/{service}/src/domain/` — aggregates, entities, value objects, state machine guards
- `services/{service}/src/domain/events/` — typed event classes matching `contracts/event-schemas/{EventName}.json`
- `services/{service}/src/application/` — command and query handlers
- `services/{service}/src/infrastructure/` — repositories, event publishers, OTEL instrumentation
- `services/{service}/tests/domain/` — invariant tests, one assertion per invariant ID

## What distinguishes this persona

The most complex agent invocation. It must simultaneously reason about:

- Natural-language business rules (invariants) → code-level guards
- Architectural patterns (event sourcing, CQRS) → correct implementation choices
- Observability requirements → correct metric names, histogram bucket boundaries derived from SLA targets
- Type safety → event classes structurally compatible with JSON Schemas

Its primary correctness signal is: does `tooling/validate-contracts.sh` pass, and does every invariant in `contracts/domain-invariants/{service}-invariants.md` have a named test that would fail if the invariant were violated?

## Constraint: cannot be invoked before Phase 4

This persona must not run before Persona 3 and 4 have produced the Helm chart scaffold and CI pipeline. The service code and infrastructure must evolve together.
