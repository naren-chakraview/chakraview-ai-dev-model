# Agent Task: Architectural Compliance Review

> **Template usage:** Replace `{service}`, `{project}`, `{phase}` before running.
> Adapt ADR numbers and checklist items to your project's ADR index.

**Task type**: Agent (LLM reasoning required — Persona 2)
**Spec version**: 1.0
**Runs after**: Phase 4 (infrastructure generation) OR Phase 5 (service implementation)

---

## Goal

Compare generated artifacts against the established architectural decisions, principles, and coding standards. Produce a structured compliance report. Classify each deviation as intentional or unintentional and specify the resolution path.

This agent has no implementation authority. It does not fix deviations. It surfaces them.

---

## Inputs

### Always required

| File | Why |
|---|---|
| `docs/adrs/README.md` | Index of all accepted ADRs — read every linked ADR |
| `docs/architecture/principles.md` | Principles that govern every decision |
| `ai-agents/context/coding-standards.md` | Standards all agent output must follow |
| `ai-agents/context/infra-conventions.md` | IaC conventions (for Phase 4 reviews) |
| `ai-agents/context/observability-requirements.md` | Required metrics, traces, logs (for Phase 5 reviews) |
| `contracts/slas/` | SLA targets that constrain HPA config, histogram buckets |

### Phase 4 (infrastructure) — also read

All files under `infrastructure/helm/charts/{service}/templates/` and `.github/workflows/ci-{service}.yml`

### Phase 5 (implementation) — also read

All files under `services/{service}/src/` and `services/{service}/tests/`
Also read: `contracts/domain-invariants/{service}-invariants.md`

---

## Output

Write to `ai-agents/reviews/{phase}-compliance-{service}-{date}.md`

Use the compliance report format defined in `docs/architecture/agent-personas.md`.

The report must:
- List every check performed (even passing ones)
- For each deviation: state the location (file:line), the ADR or principle violated, the classification, and the specific resolution instruction
- For intentional deviations: specify which ADR the Human Expert should write or amend, and what it must address
- For unintentional deviations: specify which persona re-runs, with what additional context

---

## Phase 4 Checklist

| Check | ADR / Principle |
|---|---|
| NetworkPolicy present in every Helm template | Principle 9 (adapt to your project's ADR index) |
| IRSA-scoped ServiceAccount (not wildcard IAM) | Principle 9 |
| PodDisruptionBudget for services with min_replicas > 1 | ADR-0009 (adapt to your project's ADR index) |
| Resource limits set on all containers | Principle 9 |
| No hostNetwork: true or privileged: true | Principle 9 |
| HPA maxReplicas ≥ peak_rps / (limits.cpu / request.cpu) | contracts/slas/ |
| Image from approved registry, not Docker Hub | infra-conventions.md |
| CI pipeline triggers on contract file changes | ADR-0001 (adapt to your project's ADR index) |
| PodSecurity namespace label is "restricted" | Principle 9 |
| ServiceMonitor present for Prometheus scraping | ADR-0008 (adapt to your project's ADR index) |
| `sidecar.istio.io/inject: "true"` annotation present in every Deployment | ADR-0014 (adapt to your project's ADR index) |
| DestinationRule present for every service with an external HTTP dependency | ADR-0012 (adapt to your project's ADR index) |
| outlierDetection block present in every external-dependency DestinationRule | ADR-0012 (adapt to your project's ADR index) |
| ResourceQuota present in every {project}-* namespace | ADR-0013 (adapt to your project's ADR index) |
| LimitRange present in every {project}-* namespace | ADR-0013 (adapt to your project's ADR index) |
| PeerAuthentication mode is STRICT in every {project}-* namespace | ADR-0014 (adapt to your project's ADR index) |

---

## Phase 5 Checklist

| Check | ADR / Principle |
|---|---|
| No cross-service type imports in domain layer | ADR-0005 (adapt to your project's ADR index) |
| All domain mutations through aggregate root | DDD (docs/ddd/*/domain-model.md) |
| OTEL metric names match observability-requirements.md exactly | ADR-0008 (adapt to your project's ADR index) |
| Histogram buckets include SLA latency_p99_ms / 1000 as a boundary | contracts/slas/ |
| Events published via outbox, not directly from command handlers | ADR-0004, ADR-0006 (adapt to your project's ADR index) |
| Zero imports from infrastructure/ in domain layer files | coding-standards.md |
| Every invariant ID in domain-invariants/*.md has a named test | ADR-0001 (adapt to your project's ADR index) |
| Event store used only in the appropriate domain (per your architecture) | ADR-0006 (adapt to your project's ADR index) |
| Leave-and-layer services import no types from the legacy system they wrap | ADR-0011 (adapt to your project's ADR index) |
| Choreography consumers do not import from producer service directories | ADR-0005, ADR-0015 (adapt to your project's ADR index) |
| Application code contains no TLS handshake or metrics transport code | ADR-0014 (adapt to your project's ADR index) |
| circuit_breaker_state gauge registered in every service with external calls | ADR-0012 (adapt to your project's ADR index) |
| CQRS read model not used as input to write decisions | ADR-0007 (adapt to your project's ADR index) |
| No dynamic types in domain layer | coding-standards.md |
| Domain errors are named classes, not generic Error | coding-standards.md |

---

## Context Boundary Checklist (Phase 7b — New Bounded Context only)

| Check | ADR / Principle |
|---|---|
| New context has no shared DB with existing contexts | ADR-0005 (adapt to your project's ADR index) |
| Integration pattern (event / ACL / open host) explicitly defined | docs/ddd/bounded-contexts.md |
| New context does not import types from existing service directories | ADR-0005 (adapt to your project's ADR index) |
| Context map updated in docs/ddd/bounded-contexts.md | ADR-0001 (adapt to your project's ADR index) |
| SLA defined before any implementation started | ADR-0001, ADR-0002 (adapt to your project's ADR index) |
| CODEOWNERS updated to include new context paths | Principle 9 |

---

## Classification Guide

Use this rubric to classify a deviation:

**Intentional** — the generated artifact makes a deliberate choice that:
- Is technically correct in a way that differs from an existing ADR
- Would require a senior engineer to have made the same tradeoff knowingly
- Cannot be explained by a misread spec or a missed constraint

**Unintentional** — the generated artifact:
- Contradicts a spec it was given as input
- Reuses a pattern from outside its bounded context
- Omits a required element (missing NetworkPolicy, missing metric registration)
- Uses a type, pattern, or name that is incorrect relative to its inputs

When uncertain, prefer **intentional** — it forces a human to make the architectural decision explicit rather than silently accepting a deviation.

---

## Acceptance Criteria for the Report Itself

- [ ] Every check in the relevant checklist appears in the report (pass or deviation)
- [ ] Every deviation has a file:line location
- [ ] Every intentional deviation names a specific ADR to write or amend
- [ ] Every unintentional deviation names the specific persona to re-run and the specific input to provide
- [ ] Report status is `PASS` only if zero deviations found
