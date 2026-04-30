---
title: Workflow
description: The complete 7-phase workflow — from bootstrap through continuous operation.
---

# Workflow

The workflow sequences all six personas across eight phases. Each phase has explicit inputs, outputs, persona assignments, and a human review gate before the next phase begins.

The phases are not strictly linear — Phases 7 and 7b run continuously once the system is live. But Phases 0–6 must run in order; each phase's outputs are required inputs for the next.

---

```
┌─────────────────────────────────────────────────────────────────────────┐
│ PHASE 0: Bootstrap                                                      │
│                                                                         │
│  [1 Human Expert] writes:                                               │
│    contracts/slas/*.yaml                                                │
│    contracts/domain-invariants/*.md                                     │
│    contracts/event-schemas/*.json                                       │
│    tooling/service-manifest.yaml                                        │
│    ai-agents/tasks/ (agent/ and script/ specs)                          │
│                                                                         │
│  [3 Script Authoring Agent] writes:                                     │
│    tooling/validate-contracts.sh   ← from tasks/script/validate         │
│                                                                         │
│  [4 Script Executor] runs:                                              │
│    validate-contracts.sh → baseline pass                                │
└──────────────────────────────┬──────────────────────────────────────────┘
                               ↓
┌─────────────────────────────────────────────────────────────────────────┐
│ PHASE 1: Architecture Foundation                                        │
│                                                                         │
│  [1 Human Expert] writes:                                               │
│    docs/adrs/ stubs (context + decision — the "why")                   │
│    docs/ddd/bounded-contexts.md, ubiquitous-language.md                │
│                                                                         │
│  [2 Documentation Agent] produces:                                      │
│    Full ADRs (rationale, consequences, alternatives)                    │
│    docs/ddd/*/domain-model.md                                           │
│    docs/ddd/*/state-machine.md                                          │
│                                                                         │
│  ← Human Review: ADRs correctly capture the decisions?                  │
│    Domain models faithfully express the invariants?                     │
└──────────────────────────────┬──────────────────────────────────────────┘
                               ↓
┌─────────────────────────────────────────────────────────────────────────┐
│ PHASE 2: Contract → Observability (scripted)                           │
│                                                                         │
│  [3 Script Authoring Agent] writes:                                     │
│    tooling/generate-{artifact}.py                                       │
│                                                                         │
│  [4 Script Executor] runs:                                              │
│    generate-{artifact}.py                                               │
│      → observability/slos/*.yaml                                        │
│      → observability/alerts/*-burnrate.yaml                             │
│    validate-contracts.sh → SLA↔SLO↔alert chain verified               │
│                                                                         │
│  ← Human Review: alert thresholds reflect SLA intent?                  │
└──────────────────────────────┬──────────────────────────────────────────┘
                               ↓
┌─────────────────────────────────────────────────────────────────────────┐
│ PHASE 3: Contract → API Contracts                                       │
│                                                                         │
│  [2 Documentation Agent] produces:                                      │
│    api/openapi/*.yaml (from domain models + invariants)                 │
│    api/asyncapi/*.yaml (from event schemas)                             │
│                                                                         │
│  ← Human Review: API contracts match domain model?                      │
│    Breaking-change rules clear?                                         │
└──────────────────────────────┬──────────────────────────────────────────┘
                               ↓
┌─────────────────────────────────────────────────────────────────────────┐
│ PHASE 4: Contract → Infrastructure                                      │
│                                                                         │
│  [3 Script Authoring Agent] writes:                                     │
│    tooling/generate-helm-boilerplate.sh                                 │
│    tooling/generate-ci-workflow.sh                                      │
│    tooling/generate-codeowners.py                                       │
│                                                                         │
│  [4 Script Executor] runs → produces:                                   │
│    infrastructure/helm/charts/{service}/                                │
│    .github/workflows/ci-{service}.yml                                   │
│    CODEOWNERS                                                           │
│                                                                         │
│  *** [6 Architectural Compliance Agent] reviews generated infra:        │
│    Reads: docs/adrs/ + principles.md + generated artifacts              │
│    Output: ai-agents/reviews/infra-compliance-{service}-{date}.md       │
│                                                                         │
│    PASS → proceed                                                       │
│    DEVIATION — intentional:                                             │
│      [1 Human Expert] writes/amends ADR                                 │
│      [6 Compliance Agent] second pass (scoped to deviation only)        │
│        PASS → proceed                                                   │
│        FAIL → repeat ADR cycle                                          │
│    DEVIATION — unintentional:                                           │
│      [3+4] Script Authoring Agent + Executor re-run                     │
│            with compliance report as additional context                 │
│      → loop back to compliance check                                    │
└──────────────────────────────┬──────────────────────────────────────────┘
                               ↓
┌─────────────────────────────────────────────────────────────────────────┐
│ PHASE 5: Contract → Service Implementation                              │
│                                                                         │
│  [5 Service Implementation Agent] reads:                                │
│    contracts/ + docs/ddd/ + api/openapi/ + ai-agents/context/           │
│  produces:                                                              │
│    services/*/src/domain/                                               │
│    services/*/src/application/                                          │
│    services/*/src/infrastructure/                                       │
│    services/*/tests/domain/                                             │
│                                                                         │
│  [4 Script Executor] runs:                                              │
│    validate-contracts.sh → event classes match schemas ✓                │
│                                                                         │
│  *** [6 Architectural Compliance Agent] reviews implementation:         │
│    Reads: docs/adrs/ + contracts/ + ai-agents/context/ + services/src   │
│    Output: ai-agents/reviews/impl-compliance-{service}-{date}.md        │
│                                                                         │
│    PASS → Human Review gate                                             │
│    DEVIATION — intentional:                                             │
│      [1 Human Expert] writes/amends ADR                                 │
│      [6 Compliance Agent] second pass (scoped to deviation only)        │
│        PASS → Human Review gate                                         │
│        FAIL → repeat ADR cycle                                          │
│    DEVIATION — unintentional:                                           │
│      [5 Implementation Agent] re-runs with compliance report            │
│      → loop back to compliance check                                    │
│                                                                         │
│  ← Human Review: does code express every invariant by ID?               │
│    Does OtelInstrumentation register correct names and buckets?         │
└──────────────────────────────┬──────────────────────────────────────────┘
                               ↓
┌─────────────────────────────────────────────────────────────────────────┐
│ PHASE 6: Migration + Operations Documentation                           │
│                                                                         │
│  [2 Documentation Agent] produces:                                      │
│    docs/migration/ (strategy, phase docs, rollback playbook)            │
│    docs/runbooks/ (one per failure mode referenced in SLA)              │
│                                                                         │
│  ← Human Review: rollback gates tied to measurable alert signals?       │
│    Does each runbook reference the correct alert name?                  │
└──────────────────────────────┬──────────────────────────────────────────┘
                               ↓
┌─────────────────────────────────────────────────────────────────────────┐
│ PHASE 7: Continuous — Contract Change                                   │
│                                                                         │
│  [1 Human Expert] modifies a contract file (PR with sign-off)           │
│  [4 Script Executor] validate-contracts.sh → detects gap                │
│                                                                         │
│  Gap type determines which persona re-runs:                             │
│                                                                         │
│  SLA target changed:                                                    │
│    → [4] re-runs generate-{artifact}.py                                 │
│    → [6] compliance check on updated alerts only                        │
│                                                                         │
│  Domain invariant changed:                                              │
│    → [5] Implementation Agent re-runs for affected service              │
│    → [4] validate-contracts.sh                                          │
│    → [6] impl compliance check                                          │
│                                                                         │
│  Event schema changed (additive):                                       │
│    → [5] Implementation Agent updates typed event class                 │
│    → [2] Documentation Agent updates asyncapi spec                      │
│    → [4] validate-contracts.sh                                          │
│                                                                         │
│  Event schema changed (breaking — new required field):                  │
│    → [1 Human Expert] must write migration ADR first                    │
│    → then follows event schema changed (additive) path above            │
└──────────────────────────────┬──────────────────────────────────────────┘
                               ↓
┌─────────────────────────────────────────────────────────────────────────┐
│ PHASE 7b: Continuous — New Bounded Context                              │
│                                                                         │
│  Trigger: team decides a new business domain warrants its own           │
│  bounded context (not an extension of an existing one).                 │
│                                                                         │
│  This is a larger workflow than a contract change.                      │
│  It starts with a mandatory architectural review before any             │
│  implementation persona is invoked.                                     │
│                                                                         │
│  Step 1 — Context Boundary Decision (human-only gate):                  │
│    [1 Human Expert] authors:                                            │
│      docs/ddd/bounded-contexts.md update (add new context)             │
│      docs/ddd/{new-context}/ubiquitous-language.md                      │
│      ADR stub: why this is a new context, not an extension              │
│                                                                         │
│    [6 Architectural Compliance Agent] reviews context map update:       │
│      Does the new context create unintended coupling                    │
│        with existing contexts?                                          │
│      Does it introduce a shared-DB risk? (shared-database ADR)         │
│      Is the integration pattern (event, ACL, partnership)               │
│        explicitly defined?                                              │
│      Output: ai-agents/reviews/context-boundary-{name}-{date}.md       │
│                                                                         │
│      PASS → proceed to Step 2                                           │
│      DEVIATION → [1] Human Expert revises context map; repeat           │
│                                                                         │
│  Step 2 — Contracts (same as Phase 0, scoped to new context):          │
│    [1 Human Expert] writes:                                             │
│      contracts/slas/{service}-sla.yaml                                  │
│      contracts/domain-invariants/{new-context}-invariants.md            │
│      contracts/event-schemas/{NewEvent}.json                            │
│      tooling/service-manifest.yaml update (add new service entry)       │
│      ai-agents/tasks/ specs for new context                             │
│                                                                         │
│  Step 3 — Architecture Foundation (same as Phase 1):                   │
│    [2 Documentation Agent] produces full ADR for new context            │
│    [2 Documentation Agent] produces domain-model.md, state-machine.md  │
│    ← Human Review                                                       │
│                                                                         │
│  Step 4 — Observability + API (same as Phases 2–3):                    │
│    [3+4] generate SLOs, alerts for new context                          │
│    [2] produce OpenAPI + AsyncAPI specs                                 │
│                                                                         │
│  Step 5 — Infrastructure (same as Phase 4 + compliance check):         │
│    [3+4] generate Helm chart, CI pipeline, update CODEOWNERS            │
│    [6] infra compliance check against full ADR set                      │
│         (includes cross-context coupling checks)                        │
│                                                                         │
│  Step 6 — Implementation (same as Phase 5 + compliance check):         │
│    [5] Implementation Agent for new service                             │
│    [6] impl compliance check (cross-context import check is critical)   │
│                                                                         │
│  Step 7 — Migration phase doc (if extracted from monolith):             │
│    [2] Documentation Agent writes migration phase doc                   │
│    ← Human Review: extraction order correct? rollback gate defined?     │
└─────────────────────────────────────────────────────────────────────────┘
```
