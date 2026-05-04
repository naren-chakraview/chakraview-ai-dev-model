---
name: chakraview:implement-service
type: task
description: >
  Phase 5 — synthesize service domain, application, and infrastructure layers
  from contracts; wire OTEL instrumentation from SLA targets
triggers: [Phase 5 entry — contracts/domain models/infra scaffold all exist, implement a service from contracts]
phases: [5]
personas: [5]
reads:
  - contracts/domain-invariants/
  - contracts/event-schemas/
  - contracts/slas/
  - docs/ddd/
  - api/openapi/
  - api/asyncapi/
  - ai-agents/context/coding-standards.md
  - ai-agents/context/observability-requirements.md
writes:
  - services/
---

# Implement Service

Replace `{service}`, `{Service Name}`, `{ext}`, `{EventName}`, `{typecheck command}`, and `{test command}` with project-specific values.

## Goal

Produce the skeleton for the {Service Name} service: domain layer, application layer, and infrastructure layer. The implementation must correctly express all business invariants and be wired for SLA measurement via OpenTelemetry.

## Inputs (read all before writing a single line)

| File | Why |
|---|---|
| `contracts/domain-invariants/{service}-invariants.md` | Every invariant must be enforced in the aggregate |
| `contracts/event-schemas/{EventName}.json` | Event class must match this schema exactly |
| `contracts/slas/{service}-sla.yaml` | Histogram bucket boundaries and metric names |
| `docs/ddd/{service}/domain-model.md` | Aggregate structure, commands, state machine |
| `docs/ddd/{service}/state-machine.md` | State transition guard logic |
| `api/openapi/{service}-api-v1.yaml` | Route handler signatures |
| `api/asyncapi/{service}-events.yaml` | Event channel schemas for async consumers |
| `ai-agents/context/coding-standards.md` | All code must follow these |
| `ai-agents/context/observability-requirements.md` | Required metrics, traces, logs |

## Outputs

```
services/{service}/src/
├── domain/
│   ├── {Aggregate}.{ext}
│   ├── {AggregateStatus}.{ext}
│   └── events/{EventName}.{ext}
├── application/{Action}Command.{ext}
└── infrastructure/
    ├── {Aggregate}Repository.{ext}
    ├── {EventBroker}EventPublisher.{ext}
    └── OtelInstrumentation.{ext}
services/{service}/tests/domain/{Aggregate}.test.{ext}
services/{service}/Dockerfile
```

## Procedure

1. Read all inputs listed above before writing any code.
2. Implement domain layer: aggregate root, status type, domain error classes, event classes.
3. Implement application layer: command handler(s) that delegate to the aggregate.
4. Implement infrastructure layer: repository, event publisher, OTEL instrumentation.
5. Write domain tests: one test per invariant ID from `contracts/domain-invariants/`.
6. Run `{typecheck command}` — fix all type errors before proceeding.
7. Run `{test command}` — all domain tests must pass.
8. Run `tooling/validate-contracts.sh` — must exit 0.

## Constraints

1. **Typed events**: each event class structurally compatible with its JSON Schema. Use `{validation library}` for runtime validation.
2. **Invariant enforcement**: every invariant enforced before any event appended; violations throw a named domain error class.
3. **State machine**: status type implements the guard function from `state-machine.md`; no direct enum comparisons.
4. **OTEL**: histogram buckets include `latency_p99_ms / 1000` (seconds) as a boundary; metric names match `observability-requirements.md` exactly.
5. **No I/O in domain layer**: zero imports from `infrastructure/` in domain files.
6. **Outbox pattern**: events published from outbox, not directly from command handlers.

## Acceptance Criteria
- [ ] `{typecheck command}` passes with zero errors
- [ ] `{test command}` passes for all domain tests
- [ ] `tooling/validate-contracts.sh` passes
- [ ] No dynamic types in domain layer
