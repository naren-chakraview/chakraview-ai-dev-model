---
name: chakraview:write-migration-phase
type: task
description: >
  Phase 6 — write a migration phase document covering what changes, what risks
  exist, how to validate cutover, and how to roll back if it fails
triggers: [Phase 6 entry — implementation complete/migration sequencing needed, write-migration-phase mentioned]
phases: [6]
personas: [2]
reads:
  - docs/migration/strategy.md
  - docs/adrs/
  - contracts/slas/
  - observability/slos/
  - contracts/domain-invariants/
  - docs/ddd/bounded-contexts.md
writes:
  - docs/migration/
---

# Write Migration Phase Document

Replace `{phase-number}`, `{phase-name}`, and `{service}` before running.

## Goal

Produce a migration phase document for extracting `{service}`. Cover: what changes, what risks exist, how to validate the cutover, and how to roll back if it fails.

## Inputs (read all before writing)

| File | Why |
|---|---|
| `docs/migration/strategy.md` | This phase must fit the overall strategy |
| `docs/adrs/` | All accepted ADRs — the phase must not violate any |
| `contracts/slas/{service}-sla.yaml` | SLA targets constrain go/no-go criteria |
| `observability/slos/{service}-slo.yaml` | SLO definitions that must be hit before cutover |
| `contracts/domain-invariants/{service}-invariants.md` | Invariants that must hold throughout migration |
| `docs/ddd/bounded-contexts.md` | Dependencies affect sequencing |

## Output

```
docs/migration/phase-{phase-number}-{phase-name}.md
```

## Constraints

1. **Rollback gate is mandatory**: explicit go/no-go criteria — observable, measurable signals. Rollback procedure specific enough to execute without asking anyone.
2. **Risk per step**: each migration step identifies its primary risk and mitigation.
3. **Traffic routing explicit**: document which routing component changes and traffic split percentages at each step.
4. **Data migration steps reversible**: every data step has a corresponding reversion step.
5. **SLA impact documented**: expected SLA impact during cutover and monitoring procedure to confirm recovery.

## Acceptance Criteria
- [ ] Rollback procedure complete (executable without additional context)
- [ ] Go/no-go criteria are measurable (queryable metrics or test commands)
- [ ] Every migration step has an identified risk and mitigation
- [ ] Phase fits strategy in `docs/migration/strategy.md`
- [ ] SLA impact and recovery monitoring documented
