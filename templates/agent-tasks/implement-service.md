# Agent Task: Implement {Service Name}

> **Template usage:** Replace all `{placeholder}` values with project-specific details before running.
> Required substitutions: `{service}`, `{Service Name}`, `{ext}`, `{EventName}` (one row per event),
> `{typecheck command}`, `{test command}`, `{validation library}`, `{event store}`.

**Task type**: Agent (LLM reasoning required)
**Spec version**: 1.2
**Last updated**: {date}
**Estimated tokens**: ~8,000 output

---

## Goal

Produce the skeleton for the {Service Name} service: domain layer, application layer, and infrastructure layer. The implementation must correctly express all business invariants and be wired for SLA measurement via OpenTelemetry.

---

## Inputs (read all of these before writing a single line)

| File | Why |
|---|---|
| `contracts/domain-invariants/{service}-invariants.md` | Every invariant must be enforced in the aggregate |
| `contracts/event-schemas/{EventName}.json` | Event class must match this schema exactly (add one row per event) |
| `contracts/slas/{service}-sla.yaml` | Histogram bucket boundaries and metric names derived from this |
| `docs/ddd/{service}/domain-model.md` | Aggregate structure, commands, state machine |
| `docs/ddd/{service}/state-machine.md` | State transition guard logic |
| `api/openapi/{service}-api-v1.yaml` | Route handler signatures must match this spec |
| `ai-agents/context/coding-standards.md` | All code must follow these standards |
| `ai-agents/context/observability-requirements.md` | Required metrics, traces, and logs |

---

## Outputs (produce exactly these files)

```
services/{service}/src/
├── domain/
│   ├── {Aggregate}.{ext}
│   ├── {AggregateItem}.{ext}
│   ├── {AggregateStatus}.{ext}
│   └── events/
│       ├── {EventName}.{ext}          (one file per domain event)
│       └── ...
├── application/
│   ├── {Action}Command.{ext}          (one file per command)
│   └── ...
└── infrastructure/
    ├── {Aggregate}Repository.{ext}
    ├── {EventBroker}EventPublisher.{ext}
    └── OtelInstrumentation.{ext}
services/{service}/tests/domain/
    └── {Aggregate}.test.{ext}
services/{service}/Dockerfile
services/{service}/package.json          (or equivalent build manifest)
```

---

## Constraints

1. **Typed events**: Each `{EventName}.{ext}` must implement an interface/type that is structurally compatible with `contracts/event-schemas/{EventName}.json`. Use `{validation library}` for runtime validation.
2. **Invariant enforcement**: Every invariant in `{service}-invariants.md` must be enforced in the aggregate before any event is appended. Violations throw a named domain error class (e.g., `{DomainErrorName}`).
3. **State machine**: The status type must implement the guard function from `docs/ddd/{service}/state-machine.md`. No direct enum comparisons in aggregate methods — all transitions go through the guard.
4. **OTEL instrumentation**: `OtelInstrumentation.{ext}` must register:
   - `{service}.request.duration` histogram with buckets at [50, 200, 500, 1000] ms (example; derive actual boundaries from SLA `latency_p99_ms`)
   - `{service}.errors.total` counter with `reason` label
   - `{service}.saga.compensation.duration` histogram (from SLA `saga_compensation.max_compensation_latency_ms`)
5. **No I/O in domain layer**: Domain aggregate, item, and status files must have zero imports from `infrastructure/`. Pure functions and classes only.
6. **Outbox pattern**: `{EventBroker}EventPublisher.{ext}` must publish events read from an outbox table, not directly from the command handler.

---

## Acceptance Criteria

- [ ] `{typecheck command}` passes with zero errors
- [ ] `{test command} -- tests/domain/{Aggregate}.test.{ext}` passes (tests enforce all invariants)
- [ ] `OtelInstrumentation.{ext}` imports only from the OTEL API package (no SDK or transport imports)
- [ ] `tooling/validate-contracts.sh` passes (event class types match schema)
- [ ] No `{dynamic types}` in domain layer
