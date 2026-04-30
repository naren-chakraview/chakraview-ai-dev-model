# Agent Task: Write Migration Phase Document

> **Template usage:** Replace all `{placeholder}` values before running.
> Required substitutions: `{phase-number}`, `{phase-name}`, `{service}`, `{pattern}`.

**Task type**: Agent (LLM reasoning required — Persona 2)
**Spec version**: 1.0
**Runs after**: Phase 6 (Migration + Operations Documentation)

---

## Goal

Produce a migration phase document for extracting `{service}` from the monolith. The document must cover: what changes, what risks exist, how to validate the cutover, and how to roll back if it fails.

---

## Inputs (read all of these before writing a single line)

| File | Why |
|---|---|
| `docs/migration/strategy.md` | Overall migration sequencing; this phase must fit the strategy |
| `docs/adrs/` | All accepted ADRs — the phase must not violate any |
| `contracts/slas/{service}-sla.yaml` | SLA targets constrain go/no-go criteria |
| `observability/slos/{service}-slo.yaml` | SLO definitions that must be hit before cutover |
| `contracts/domain-invariants/{service}-invariants.md` | Invariants that must hold throughout migration |
| `docs/ddd/bounded-contexts.md` | Dependencies between contexts affect sequencing |

---

## Outputs

```
docs/migration/phase-{phase-number}-{phase-name}.md
```

---

## Constraints

1. **Rollback gate is mandatory**: Every phase doc must define explicit go/no-go criteria — observable, measurable signals (not "team feels ready"). The rollback procedure must be specific enough to execute without asking anyone.
2. **Risk per step**: Each migration step must identify its primary risk and mitigation.
3. **Traffic routing must be explicit**: If traffic shifts during this phase, document which routing component changes and what the traffic split percentages are at each step.
4. **Data migration steps must be reversible**: Every data migration step must have a corresponding reversion step.
5. **SLA impact**: Document the expected SLA impact during cutover and the monitoring procedure to confirm recovery.

---

## Acceptance Criteria

- [ ] Rollback procedure is complete (executable without additional context)
- [ ] Go/no-go criteria are measurable (queryable metrics or test commands)
- [ ] Every migration step has an identified risk and mitigation
- [ ] Phase fits the overall strategy in `docs/migration/strategy.md`
- [ ] SLA impact and recovery monitoring documented
