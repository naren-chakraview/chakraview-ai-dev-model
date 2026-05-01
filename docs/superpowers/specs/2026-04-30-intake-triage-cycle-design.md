# Design: Continuous SDLC Intake/Triage Cycle

**Date**: 2026-04-30
**Status**: Approved
**Scope**: Add a continuous intake/triage cycle to the Chakraview AI Dev Model workflow

---

## Problem

The existing workflow starts at Phase 0 with the Human Domain Expert directly writing contracts. This assumes the team already knows what to build and how to translate it into contracts. In practice, products and services keep growing — business intent arrives continuously in the form of user stories, market signals, SLA breaches, and architectural debt. There is no defined process for how raw intent becomes the contracts that Phase 0 consumes. Teams are left to figure out that translation on their own, and the workflow has no feedback arc that brings the running system's signals back into the cycle.

---

## Goal

- Add a formal **Intake/Triage** entry point to the workflow that accepts raw business intent in any format
- Make the workflow a **closed cycle** — business intent enters at Intake, phases execute, the running system generates signals, signals re-enter as new business intent
- Make the persona dialogue **interactive**: agents ask clarifying questions, challenge assumptions, and offer alternatives from their domain perspective before any contract is written
- Produce two outputs from Intake: an **enriched interpretation document** and **draft contracts**, both ready for Phase 0
- Define a **triage routing table** that classifies intent and routes it to the right phase entry point — skipping intake dialogue for tactical changes, running the full dialogue for strategic ones

---

## Cycle Shape

The workflow becomes a closed loop. The existing phases (0–6) are preserved unchanged. Intake is the new entry point. Phase 7 / 7b become the feedback arc.

```
                    ┌──────────────────────┐
                    │   BUSINESS INTENT    │ ← market signal, new feature,
                    │   (any trigger)      │   SLA breach, tech debt
                    └──────────┬───────────┘
                               ↓
                    ┌──────────────────────┐
                    │   INTAKE / TRIAGE    │ ← persona-interactive dialogue
                    │                      │   produces: interpretation doc
                    │                      │             + draft contracts
                    └──────────┬───────────┘
                               │
                    ┌──────────▼───────────┐
                    │   TRIAGE ROUTING     │
                    │   → Phase 0          │ new feature / service
                    │   → Phase 0 (direct) │ contract patch (no dialogue)
                    │   → Phase 2          │ observability gap
                    │   → Phase 4          │ infra-only change
                    │   → Phase 5          │ implementation patch
                    └──────────┬───────────┘
                               │
                    ┌──────────▼───────────┐
                    │   PHASES 0–6         │ (existing, unchanged)
                    └──────────┬───────────┘
                               ↓
                    ┌──────────────────────┐
                    │   RUNNING SYSTEM     │
                    │                      │
                    │  Phase 7: contract   │ → signals feed
                    │  Phase 7b: new ctx   │   back as next
                    └──────────────────────┘   business intent
```

**The invariant:** every signal from the running system — regardless of source — re-enters through Intake/Triage. There is no direct path from Phase 7 to Phase 0 that bypasses Intake. This ensures the persona dialogue can surface implications before contracts are written.

---

## Intake / Triage Phase

### Input

A business intent document in any format — user story, feature brief, incident report, business case, market brief. No required structure. The intake process structures it.

### Round 1 — Implementation Agent + Compliance Agent

Both agents read the raw business intent and respond independently from their domain. The human answers their questions; the intake document is updated to reflect each resolved decision.

**Implementation Agent — asks and challenges:**

- Pattern decisions: flag any architectural patterns mandated in the intent and ask whether they require an ADR ("Strategy Pattern is specified — is this an architectural decision or an implementation detail?")
- Edge case gaps: surface unhandled error paths and boundary conditions ("What happens when `modelId` is unrecognised — 400, fallback, or error event?")
- State ownership: challenge any implicit assumptions about who owns shared state ("The Standard Plan quota — checked at request time or reconciled asynchronously? Which service owns that state?")
- Data shape completeness: identify missing fields or ambiguous cardinality ("Can a Premium request submit only prompt tokens without completion tokens?")

**Compliance Agent — asks and challenges:**

- ADR conflicts: identify any existing ADRs that the intent may contradict or extend ("Does model-aware pricing imply a new pricing ADR, or does it fall under an existing one?")
- Bounded context boundaries: determine whether this extends an existing context or requires a new one — if new, Phase 7b context boundary review is required before Phase 0 ("Does this create a new billing-strategy context, or extend the existing billing context?")
- Data consistency risks: flag any shared-state patterns that violate architectural principles ("If monthly quota is stored in a shared table, that conflicts with the DB-per-service ADR — who owns this state?")
- Scope creep: challenge any acceptance criteria that imply out-of-scope architectural work ("AC 3 implies invoice generation — but the scope-out section excludes it. Clarify whether the data model must support it in Phase 2 even if not implemented now.")

### Round 2 — Documentation Agent + Script Authoring Agent

Both agents re-read the **updated** intake document (post-Round 1) and respond. The human answers; the intake document is updated again.

**Documentation Agent — asks and challenges:**

- Ubiquitous language: enforce one name per concept across the domain ("Is it 'plan type' or 'subscription tier'? 'Prompt tokens' or 'input tokens'? The domain model uses whichever term is chosen here — pick one.")
- ADR scope: identify which decisions need ADR stubs and who authors the 'why' ("The Strategy Pattern routing decision needs an ADR stub — does the human author the rationale, or does the Documentation Agent draft it from the intent?")
- Documentation gaps: flag runbook implications ("The overage billing path — does it need a runbook for the case where the quota service is unavailable at request time?")

**Script Authoring Agent — asks and challenges:**

- Scriptability: assess whether any calculation is deterministic enough to script vs. requiring an agent ("Is billing calculation deterministic given modelId + tokens + plan type? If yes, this is a script task, not an agent task — which is faster and auditable in CI.")
- Validation needs: identify contract validation requirements ("Should `modelId` be validated against an allowlist defined in `contracts/`? If so, `validate-contracts.sh` needs to be extended.")
- Generation targets: identify any new artifact types that will need generation scripts ("The new plan types — will Helm values or CI environment variables need to reference them? If so, a generation script is needed.")

### Outputs

**1. Intake Report** — the business intent document, updated through both rounds. Each resolved decision is annotated with the decision made and who made it. Open risks that were not resolved are flagged explicitly. This document becomes the authoritative record of what was agreed before contracts were written.

**2. Draft Contracts** — agent-produced drafts of the contracts that Phase 0 will formalise:
- `contracts/slas/{service}-sla.yaml` — latency, availability, throughput targets surfaced during intake
- `contracts/domain-invariants/{context}-invariants.md` — business rules extracted from ACs and resolved edge cases
- `contracts/event-schemas/{Event}.json` — if the intent implies new events

The Human Domain Expert reviews draft contracts and either accepts, amends, or rejects each one. Accepted drafts become the Phase 0 input.

**3. Triage Decision** — the classification and phase entry point (see Routing Table below).

---

## Triage Routing Table

| Intent type | Entry point | Intake dialogue | Draft contracts |
|---|---|---|---|
| New feature / new service | Phase 0 | Full (both rounds) | Yes |
| New bounded context | Context boundary review → Phase 0 | Full (both rounds) | Yes |
| SLA target change | Phase 0 (contracts only) | None — direct | Updated SLA YAML |
| Domain invariant change | Phase 0 (contracts only) | None — direct | Updated invariants |
| Event schema change (additive) | Phase 0 → Phase 3 | None — direct | Updated schema |
| Event schema change (breaking) | ADR first → Phase 0 | Round 1 only (Compliance + Implementation) | Updated schema |
| Observability / alerting gap | Phase 2 | None — direct | None |
| API contract change | Phase 1 (ADR) → Phase 3 | Round 1 only (Compliance) | None |
| Infrastructure / Helm / CI change | Phase 4 | None — direct | None |
| Implementation bug / patch | Phase 5 | None — direct | None |

**The rule:** full intake dialogue runs when the intent could introduce new contracts or new architectural decisions. Tactical changes that touch only one phase skip intake and enter directly.

---

## Feedback Arc

The running system generates the next business intent. Phase 7 (Contract Change) and Phase 7b (New Bounded Context) are the feedback arc — they detect change signals and produce the next Intake input.

| Signal source | Signal type | Re-enters Intake as |
|---|---|---|
| Phase 7 — SLA target changed | Contract change detected | "SLA adjustment needed" → Intake (direct to Phase 0) |
| Phase 7 — Invariant violated in prod | Monitoring alert | "Invariant gap — quota not enforced under concurrency" → Intake (Round 1) |
| Phase 7b — New bounded context decided | Architectural decision | "New context: {name}" → Intake (full dialogue) |
| External market signal | Product decision | New feature brief → Intake (full dialogue) |
| Compliance review failure | Architectural debt | "ADR amendment needed" → Intake (Compliance Round 1) |

---

## Worked Example: LLM API Billing Engine Refactor

**Business intent submitted:**

> Refactor the billing engine to support Standard and Premium plans, with model-aware pricing based on `modelId`. Standard Plan has a monthly global quota; overage rates depend on the model. Premium Plan has no quota; prompt and completion tokens are billed separately at model-specific rates.

### Round 1

**Implementation Agent challenges:**

- "Strategy Pattern is mandated in the scope — is this an architectural decision that needs an ADR, or an implementation detail the agent decides?"
- "What happens when `modelId` is unrecognised — HTTP 400, a default pricing fallback, or an error event emitted?"
- "Standard Plan quota: is it checked synchronously at request time, or reconciled asynchronously? If synchronous, which service is the quota authority?"
- "Can a Premium request submit only prompt tokens (no completion tokens)? The AC only shows both submitted together."

**Compliance Agent challenges:**

- "Does model-aware pricing extend an existing billing ADR or imply a new one? If new, the human must author the ADR stub before Phase 0."
- "Monthly quota storage — if this lives in a shared table accessible by multiple services, that conflicts with ADR-0005 (DB-per-service). Clarify ownership."
- "The scope-out section defers invoice generation, but AC 2 implies a bill object is returned in the response. Does the data model need to be invoice-compatible now, or is the response a transient calculation?"

*Human resolves: Strategy Pattern → new ADR required; unknown modelId → 400; quota is synchronous, owned by billing service; Premium always submits both token types; data model is transient, no invoice compatibility required.*

### Round 2

**Documentation Agent challenges:**

- "Ubiquitous language: 'plan type' or 'subscription tier'? The AC uses 'Standard Plan' and 'Premium Plan' — confirm these are the canonical terms for the domain model."
- "The new Strategy Pattern ADR — does the human author the rationale stub, or does the Documentation Agent draft it from the intent? This determines the Phase 0 task spec."

**Script Authoring Agent challenges:**

- "Billing calculation is deterministic given plan type + modelId + tokens — this is a script task, not an agent task. Confirm: `tooling/calculate-billing.py` reads a model-rates config file and produces the charge. Does such a config file exist, or does it need to be a new contract artifact?"
- "Should `modelId` be validated against an allowlist? If so, `validate-contracts.sh` needs extension and the allowlist must be a versioned contract file."

*Human resolves: 'Plan Type' is canonical; human authors ADR stub; billing calculation is a script task; model rates live in `contracts/model-rates.yaml` (new contract artifact); modelId validated against that file.*

### Triage Decision

- **Classification:** New feature, extending existing billing bounded context
- **Entry point:** Phase 0
- **Intake dialogue:** Full (both rounds completed)
- **Draft contracts produced:**
  - `contracts/slas/billing-api-sla.yaml` (latency p99, availability for POST /api/usage)
  - `contracts/domain-invariants/billing-invariants.md` (quota logic, overage calculation rules, premium split rates, modelId validation rule)
  - `contracts/model-rates.yaml` (new — allowlist of valid modelIds with per-model prompt/completion rates)

---

## Out of Scope

- Changes to any existing phase (0–6) structure or persona definitions
- Tooling to automate the intake dialogue (this is a documented process, not a software implementation)
- A UI or CLI for submitting business intent documents

---

## Success Criteria

1. The workflow diagram in `docs/workflow/index.md` shows the closed cycle with Intake/Triage as the entry point and Phase 7/7b as the feedback arc.
2. A new `docs/intake/index.md` page documents the Intake/Triage phase with the two-round structure, persona questions, and output formats.
3. The triage routing table is present in the intake page and cross-referenced from the workflow.
4. The billing engine worked example is present in `docs/intake/index.md` as the reference template.
5. A task spec template for the intake process is present in `templates/agent-tasks/intake-triage.md`.
