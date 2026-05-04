---
name: chakraview:compliance-review
type: task
description: >
  Run the Persona 6 architectural compliance audit — compare generated artifacts
  against ADRs and produce a structured PASS/DEVIATION report
triggers: [infrastructure generation complete (after Phase 4), service implementation complete (after Phase 5), compliance review needed before merging]
phases: [4, 5]
personas: [6]
reads:
  - docs/adrs/
  - ai-agents/context/
  - contracts/slas/
  - infrastructure/helm/charts/
  - services/
writes:
  - ai-agents/reviews/
---

# Architectural Compliance Review

Replace `{service}`, `{project}`, and `{phase}` before running.

## Goal

Compare generated artifacts against architectural decisions, principles, and coding standards. Produce a structured compliance report. **This task has no implementation authority** — it surfaces deviations, it does not fix them.

## Inputs

### Always required
| File | Why |
|---|---|
| `docs/adrs/` | Read every accepted ADR |
| `ai-agents/context/coding-standards.md` | Standards all output must follow |
| `ai-agents/context/infra-conventions.md` | IaC conventions (Phase 4 reviews) |
| `ai-agents/context/observability-requirements.md` | Required metrics and traces (Phase 5 reviews) |
| `contracts/slas/` | SLA targets that constrain HPA config, histogram buckets |

### Phase 4 — also read
All files under `infrastructure/helm/charts/{service}/templates/` and `.github/workflows/ci-{service}.yml`

### Phase 5 — also read
All files under `services/{service}/src/` and `services/{service}/tests/`
Also: `contracts/domain-invariants/{service}-invariants.md`

## Output

Write to `ai-agents/reviews/{phase}-compliance-{service}-{date}.md`.

List every check (even passing ones). For each deviation: file:line, ADR violated, classification, resolution.

## Phase 4 Checklist
| Check | Principle |
|---|---|
| NetworkPolicy in every Helm template | Principle 9 |
| IRSA-scoped ServiceAccount | Principle 9 |
| PodDisruptionBudget for min_replicas > 1 | Infrastructure ADR |
| Resource limits on all containers | Principle 9 |
| No hostNetwork/privileged | Principle 9 |
| HPA maxReplicas consistent with SLA peak_rps | contracts/slas/ |
| Image from approved registry | infra-conventions.md |
| CI triggers on contract file changes | CI/CD ADR |

## Phase 5 Checklist
| Check | Principle |
|---|---|
| No cross-service type imports in domain layer | DB-per-service ADR |
| All domain mutations through aggregate root | DDD |
| OTEL metric names match observability-requirements.md | Observability ADR |
| Histogram buckets include latency_p99_ms/1000 | contracts/slas/ |
| Events via outbox, not direct from command handlers | Event sourcing ADR |
| Zero infrastructure/ imports in domain layer | coding-standards.md |
| Every invariant ID has a named test | CI/CD ADR |
| CQRS read model not used in write decisions | CQRS ADR |
| No dynamic types in domain layer | coding-standards.md |
| Domain errors are named classes | coding-standards.md |

## Classification Guide

**Intentional**: deliberate choice differing from an ADR; would require a senior engineer to make the same tradeoff knowingly. → Human Expert writes/amends ADR before merge.

**Unintentional**: contradicts a spec it was given; omits a required element; incorrect name or pattern. → Offending persona re-runs with this report as context.

When uncertain, prefer **intentional** — this avoids spurious re-runs of implementation agents when the deviation is a conscious tradeoff.

## Acceptance Criteria
- [ ] Every checklist item appears in report (pass or deviation)
- [ ] Every deviation has a file:line location
- [ ] Every intentional deviation names a specific ADR to write or amend
- [ ] Every unintentional deviation names the persona to re-run and the specific input
- [ ] Status is PASS only if zero deviations
