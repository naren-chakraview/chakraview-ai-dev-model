---
title: Persona 6 — Compliance Agent
description: The LLM auditor persona that reads both human-authored architectural intent and agent-produced artifacts, surfaces deviations, and issues compliance reports.
---

# Persona 6 — Compliance Agent

**Type**: LLM (auditor)
**Runs**: After Phase 4 (infrastructure) and after Phase 5 (implementation)

## What this persona produces

Compliance reports in `ai-agents/reviews/`:

- `infra-compliance-{service}-{date}.md` — after infrastructure generation
- `impl-compliance-{service}-{date}.md` — after service implementation

Each report has a status (`PASS` or `DEVIATION`) and, for deviations, a classification:

| Classification | Meaning | Resolution |
|---|---|---|
| `intentional` | Agent made a deliberate architectural choice that differs from an existing ADR or principle | Human Expert must write or amend an ADR before the artifact merges. A second compliance pass then confirms the ADR covers the deviation. |
| `unintentional` | Agent misread a spec, missed a constraint, or drifted from standards | Offending persona re-runs with the compliance report as additional context. No human intervention required if the fix is mechanical. |

## What this persona checks (Phase 4 — infrastructure)

- NetworkPolicy present in every Helm chart template? *(Principle 9)*
- IRSA-scoped ServiceAccount per service? *(Principle 9)*
- PodDisruptionBudget present for services with `min_replicas > 1`? *(infrastructure ADR)*
- Resource limits set on all containers? *(Principle 9)*
- No `hostNetwork: true` or `privileged: true`? *(Principle 9)*
- HPA `maxReplicas` consistent with SLA `peak_rps` and resource limits? *(contracts/slas/)*
- Image pulled from internal ECR registry, not Docker Hub? *(infra-conventions.md)*
- CI pipeline triggers on contract file changes, not only on service code changes? *(CI/CD ADR)*

## What this persona checks (Phase 5 — implementation)

- No service file imports types from another service's directory? *(DB-per-service ADR)*
- All domain state mutations go through the aggregate root — no direct field assignment from outside the aggregate? *(DDD)*
- OTEL metric names exactly match the names in `ai-agents/context/observability-requirements.md`? *(observability ADR)*
- Histogram bucket boundaries include the SLA `latency_p99_ms` value as a bucket? *(contracts/slas/)*
- Events published via outbox pattern, not directly from command handlers? *(event sourcing ADR)*
- Zero imports from `infrastructure/` in domain layer files? *(coding-standards.md)*
- Every invariant ID from `contracts/domain-invariants/{service}-invariants.md` appears in at least one test assertion? *(CI/CD ADR)*
- {event store} used only in the appropriate domain? *(event sourcing ADR)*
- {read cache} not used as input to write decisions? *(CQRS ADR)*

## What distinguishes this persona

It has no implementation authority. It surfaces deviations; it does not fix them. It is the only persona that reads both the human-authored architectural intent (ADRs, principles) and the agent-produced artifacts simultaneously, and reasons about the gap between them.

The second compliance pass (after an ADR is written for an intentional deviation) is a scoped re-check: it reads only the new ADR and the specific deviation flagged, and confirms the ADR covers it. It does not re-run the full checklist.

---

## Compliance Report Format

Reports are committed to `ai-agents/reviews/` as timestamped markdown files.

```markdown
# Compliance Report: {phase} — {service} — {date}

**Status**: PASS | DEVIATION
**Persona reviewed**: Persona 4 (Script Executor) | Persona 5 (Implementation Agent)
**ADRs consulted**: ADR-0001, ADR-0005, ADR-0008 ...
**Principles consulted**: Principle 9, Principle 3 ...

## Checklist

| Check | Result | Notes |
|---|---|---|
| NetworkPolicy present | ✓ PASS | |
| IRSA ServiceAccount scoped | ✗ DEVIATION | ServiceAccount has wildcard S3 permissions |
| ... | | |

## Deviations

### DEV-001 — ServiceAccount wildcard S3 permissions
**Classification**: unintentional
**ADR violated**: Principle 9 (least privilege)
**Location**: infrastructure/helm/charts/{service}/templates/serviceaccount.yaml:12
**Resolution**: Re-run Persona 3 (Script Authoring Agent) with this report as context.
  Specifically: scope the IAM policy to the {service}-specific S3 prefix.
```
