---
title: Contract Challenge Feedback Loops Design
description: Design spec for formalising the three undocumented feedback loops in the Chakraview AI Dev Model workflow — named phase loops and the Contract Challenge Report (CCR) mechanism.
date: 2026-10-16
status: approved
---

# Contract Challenge Feedback Loops Design

## Problem

The current workflow is documented as mostly linear (Phases 0–6) with compliance loops only at P4 and P5. In practice, three feedback loops occur regularly but have no documented path:

1. **P3 → P1**: API contract authoring reveals a domain model gap that must be resolved before Phase 3 can continue.
2. **P5 → P2**: Implementation discovers that the approach changes latency, throughput, or error budget characteristics, invalidating the Phase 2 observability artifacts.
3. **Contract negotiation (phase-agnostic)**: Any agent at any phase discovers that honoring a contract is technically costly or complex. The resolution may be relaxing the contract rather than implementing harder — but this conversation currently bypasses the model entirely, producing untracked, unauditable amendments.

The third loop is the most significant gap. The model treats contracts as immutable top-down inputs. In practice, technical reality feeds back into contracts, and that feedback needs a formal path.

---

## Goal

- Add three named feedback loops to the workflow with explicit triggers and completion conditions
- Define the **Contract Challenge Report (CCR)** as a formal artifact for surfacing contract-vs-cost conflicts
- Define a **threshold rule** that determines when a CCR is required vs. an inline note
- Capture the threshold rule as an ADR so the bypass criterion is itself auditable
- Update all four agent persona definitions to include CCR responsibilities
- Add a CCR template to `templates/agent-tasks/`

---

## Named Feedback Loops

### Loop A — P3 → P1: API contract reveals domain model gap

**Trigger:** Documentation Agent, while authoring API specs in Phase 3, discovers that the contract implies a concept, relationship, or state transition not present in the domain model.

**Action:** Agent flags the gap. Phase 3 pauses on the affected spec. Phase 1 re-runs scoped to the missing domain model element.

**Completion:** Domain model updated, ADR amended if required. Phase 3 resumes from the point it paused.

---

### Loop B — P5 → P2: Implementation changes SLO assumptions

**Trigger:** Implementation Agent, during Phase 5, discovers that the implemented approach changes latency, throughput, or error budget characteristics relative to what the Phase 2 observability artifacts assume.

**Action:** Agent surfaces the delta. Phase 2 re-runs scoped to the affected SLO/alert chain. `validate-contracts.sh` re-runs after.

**Completion:** SLO definitions and burn rate alerts updated to match implementation reality. Phase 5 resumes.

---

### Loop C — Any phase → Phase 0: Contract challenge

**Trigger:** Any agent at any phase discovers a contract that is technically costly or complex to honor, where a relaxed contract would permit a simpler or cheaper design.

**Action:** Agent halts work on the affected contract and writes a Contract Challenge Report (CCR). See CCR section below.

**Completion:** Product/business owner decision recorded. Either the contract is amended (re-enter Phase 0) or a hold ADR is written (resume from originating phase).

---

## Contract Challenge Report (CCR)

### Purpose

A CCR is the formal mechanism for surfacing Loop C. It translates a technical cost/complexity discovery into a question the product or business owner can answer. It replaces the informal conversation that currently bypasses the model.

### Format

Four fields:

```
contract: <path to contract file>#<specific clause or target>
cost:     <what honoring this contract technically requires, and the estimated cost or complexity>
question: <the specific question for the product/business owner — framed as a choice>
phase:    <workflow phase where the discovery was made>
```

**Example:**

```
contract: contracts/slas/billing-api-sla.yaml#latency-p99-50ms
cost:     Honoring 50ms p99 requires a synchronous Redis cache layer plus a
          dedicated read replica. Estimated infra cost delta: ~$2k/month.
question: Is 50ms p99 a hard business requirement, or was it an estimate?
          Would 100ms p99 be acceptable? That eliminates the cache requirement.
phase:    5
```

### Location

`ai-agents/reviews/ccr-{service}-{date}.md`

Same directory as Compliance Reports. Naming convention mirrors compliance review files.

### Routing path

1. Agent writes CCR and halts work on the affected contract.
2. Human Domain Expert reviews. Routes to product/business owner with the cost signal.
3. Product/business owner decides:
   - **Relax**: amend the contract file, re-enter Phase 0 for the affected contract.
   - **Hold**: write an ADR documenting why the contract stands at this cost, then resume from the originating phase.
4. Either outcome produces a written artifact: amended contract or ADR. No decision is undocumented.

### Threshold rule — CCR vs. inline note

A CCR is required when resolving the challenge would:
- Amend a contract artifact (`contracts/slas/`, `contracts/domain-invariants/`, `contracts/event-schemas/`)
- Require a new or amended ADR

Below that threshold, agents note the observation inline in their existing task output and continue. No CCR, no routing, no halt.

The threshold rule is itself captured as an ADR (see below) so teams adopting the model have a documented standard rather than applying judgment ad-hoc.

---

## Persona Updates

### All agent personas (2, 3, 5, 6) — new responsibility

> When executing a task, if a contract is discovered to be technically costly or complex to honor, evaluate against the CCR threshold. If the threshold is met: halt work on the affected contract, write a CCR to `ai-agents/reviews/`, and surface it to the Human Domain Expert before continuing. If below the threshold: note the observation inline in the task output and continue.

### Human Domain Expert (Persona 1) — new responsibility

> Review incoming CCRs. Route each to the relevant product/business owner with the cost signal. Record the outcome: either amend the contract (update the relevant file in `contracts/`) and re-enter Phase 0, or commission a hold ADR documenting why the contract stands at this cost.

### Compliance Agent (Persona 6) — no change to role

The Compliance Agent remains an auditor of agent output vs. contracts. It does not own CCRs. Any agent can issue a CCR; the Compliance Agent's existing audit mandate is unchanged.

---

## Workflow Diagram Changes

`docs/workflow/index.md` Mermaid diagram additions:

1. `P3 --"API contract reveals domain model gap"--> P1` (Loop A)
2. `P5 --"Implementation changes SLO assumptions"--> P2` (Loop B)
3. A `CCR` node showing the contract challenge path from any phase to Phase 0 or resume (Loop C)

---

## New ADR: CCR Threshold Rule

**File:** `docs/adrs/adr-ccr-threshold.md`

> Note: `docs/adrs/` does not currently exist in the model's own doc structure — this implementation creates it. It is distinct from `skills/scaffold/docs/adrs/`, which is for target projects. `docs/adrs/` in the model is for the model's own architectural decisions.

**Decision:** A CCR is required when resolving a contract challenge would amend a contract artifact or produce an ADR. Below that threshold, inline note and continue.

**Rationale:** The formal CCR path exists to make contract amendments auditable. Routing minor observations through the same path would degrade the CCR signal — practitioners would either ignore CCRs or bypass the path informally. The threshold reserves the formal path for decisions that change contracts, where auditability matters.

**Consequences:** Teams must apply judgment at the boundary. This ADR is the shared reference for that judgment. Misclassification (inline note when a CCR was warranted) will surface at Compliance Review — the agent will have continued past a contract challenge without a CCR, which the Compliance Agent can flag.

---

## New Template: `templates/agent-tasks/contract-challenge.md`

A parameterised CCR template for agents — the four fields with fill-in markers, matching the pattern of existing task templates.

---

## Artifacts Produced by This Design

| Artifact | Location | Type |
|---|---|---|
| Updated workflow diagram | `docs/workflow/index.md` | Doc update |
| Updated persona definitions | `docs/personas/persona-{2,3,5,6}.md` | Doc update |
| CCR threshold ADR | `docs/adrs/adr-ccr-threshold.md` | New ADR (new directory) |
| CCR template | `templates/agent-tasks/contract-challenge.md` | New template |
| Scaffold entry | `skills/scaffold/ai-agents/reviews/` | Already exists |

---

## Out of Scope

- Tooling to automate CCR routing or notification
- Changes to the Compliance Report format or Compliance Agent task spec
- Changes to any Phase 0–6 structure beyond the three named loop additions
- Per-service CCR history tracking or dashboards
