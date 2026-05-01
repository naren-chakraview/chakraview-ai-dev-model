---
title: Intake / Triage
description: How raw business intent becomes contracts — the entry point to the continuous SDLC cycle.
---

# Intake / Triage

Every change to the system begins here. Intake accepts raw business intent in any format and produces three things: an enriched interpretation document, draft contracts ready for Phase 0, and a triage decision that routes the change to the right phase entry point.

Intake is the entry point to the [closed SDLC cycle](../workflow/index.md). Every signal from the running system — SLA breach, new feature request, architectural debt — re-enters here before any contract is written.

---

## Input

Any document that expresses what the business wants the system to do. No required format. Accepted formats include:

- User stories with acceptance criteria
- Feature briefs or product requirement documents
- Incident reports with root cause analysis
- Architecture review findings
- SLA breach postmortems
- Market requirement documents

---

## Round 1 — Compliance Agent + Implementation Agent

Both agents read the raw business intent and respond independently. The human answers both sets of questions; the intake document is updated to record each resolved decision before Round 2 begins.

### Compliance Agent

Reads from the perspective of the existing architecture: existing ADRs, bounded context map, and architectural principles.

**ADR conflicts:**
> "Does this intent contradict or extend any existing ADR? If it introduces a new architectural pattern, does the human need to author an ADR stub before Phase 0?"

**Bounded context boundary:**
> "Does this extend an existing bounded context, or does it warrant a new one? If new, a context boundary review is required before Phase 0."

**Data consistency risks:**
> "Does the intent imply shared state across services? Which service should own it, and does that ownership conflict with the DB-per-service principle?"

**Scope creep in acceptance criteria:**
> "Do any ACs imply work the scope-out section excludes? If the data model must support deferred features, say so now — not in Phase 5."

### Implementation Agent

Reads from the perspective of what will be built: design patterns, data shapes, edge cases, service contracts.

**Pattern decisions:**
> "Any pattern mandated in the intent — is it an architectural decision (ADR required) or an implementation detail (agent decides)?"

**Edge case gaps:**
> "What happens at the boundaries: unknown enum values, empty inputs, concurrent writes, maximum payload sizes? Each unaddressed edge case becomes a bug in Phase 5."

**State ownership:**
> "Who owns each piece of mutable state? Synchronous at request time or asynchronous reconciliation? The answer determines which service gets which contract."

**Data shape completeness:**
> "Are all field cardinalities explicit? Which fields are optional vs required? What does omitting an optional field mean for the calculation or response?"

---

## Round 2 — Documentation Agent + Script Authoring Agent

Both agents re-read the **updated** intake document — after Round 1 resolutions are recorded — and respond. The human answers; the intake document is updated again.

### Documentation Agent

Reads from the perspective of what must be documented: domain language, ADRs, runbooks.

**Ubiquitous language:**
> "Is there exactly one name per concept? List any synonyms in the intent. Pick one canonical term — the domain model, API spec, and code all use it."

**ADR scope:**
> "Which decisions made during Round 1 need an ADR stub? Who authors the rationale — the human or the Documentation Agent from the intake document?"

**Runbook implications:**
> "Does this intent introduce a new failure mode? Name it and the alert that would trigger it."

### Script Authoring Agent

Reads from the perspective of what can be automated: deterministic transformations, validation scripts, generation pipelines.

**Scriptability:**
> "Is any calculation or transformation in this intent deterministic — given fixed inputs, always produces the same output? If yes, it is a script task, not an agent task. Name the script, its inputs, and its output file."

**Validation needs:**
> "Does this intent introduce a new contract artifact (config file, allowlist, rates table)? If so, `validate-contracts.sh` needs extension. Confirm the file path and format."

**Generation targets:**
> "Will Helm values, CI environment variables, or generated manifests need to reference new values from this intent? If yes, a generation script will be needed in Phase 4."

---

## Outputs

### 1. Intake Report

The business intent document, updated through both rounds. Each resolved decision is annotated with:

- The question asked
- The decision made
- Who made it
- Alternatives rejected and why

Open risks not resolved during intake are flagged as `⚠ UNRESOLVED: {question}`. Phase 0 cannot begin until all `⚠ UNRESOLVED` items are closed.

### 2. Draft Contracts

Agent-produced contract drafts for Human Domain Expert review:

| Contract file | Produced from |
|---|---|
| `contracts/slas/{service}-sla.yaml` | Latency, availability, throughput targets from intake |
| `contracts/domain-invariants/{context}-invariants.md` | Business rules from ACs and resolved edge cases |
| `contracts/event-schemas/{Event}.json` | If the intent implies new domain events |
| Additional artifacts | Any new config/allowlist identified by Script Authoring Agent |

The Human Domain Expert reviews each draft: accept as-is, amend, or reject and write from scratch. Accepted drafts become Phase 0 inputs.

### 3. Triage Decision

```yaml
classification: {new feature | contract patch | observability gap | infra change | implementation patch}
entry_point: Phase {N}
intake_dialogue: {full | round-1-only | none}
adr_stubs_required: {yes | no}
new_scripts_needed: {yes | no}
draft_contracts:
  - contracts/{path}
```

---

## Triage Routing Table

| Intent type | Entry point | Intake dialogue | Draft contracts |
|---|---|---|---|
| New feature / new service | Phase 0 | Full (both rounds) | Yes |
| New bounded context | Context boundary review → Phase 0 | Full (both rounds) | Yes |
| SLA target change | Phase 0 (contracts only) | None — direct | Updated SLA YAML |
| Domain invariant change | Phase 0 (contracts only) | None — direct | Updated invariants |
| Event schema change (additive) | Phase 0 → Phase 3 | None — direct | Updated schema |
| Event schema change (breaking) | ADR first → Phase 0 | Round 1 only | Updated schema |
| Observability / alerting gap | Phase 2 | None — direct | None |
| API contract change | Phase 1 (ADR) → Phase 3 | Round 1 only | None |
| Infrastructure / Helm / CI change | Phase 4 | None — direct | None |
| Implementation bug / patch | Phase 5 | None — direct | None |

**The rule:** full intake dialogue runs when the intent could introduce new contracts or new architectural decisions. Tactical changes that touch only one phase skip intake and enter directly.

---

## Feedback Arc

The running system generates the next business intent. Phase 7 and Phase 7b detect change signals and produce the next Intake input. No signal from the running system reaches Phase 0 without passing through Intake first.

| Signal source | Signal type | Re-enters Intake as |
|---|---|---|
| Phase 7 — SLA target changed | Contract change detected | "SLA adjustment needed" → direct to Phase 0 |
| Phase 7 — Invariant violated in prod | Monitoring alert | "Invariant gap" → Intake Round 1 |
| Phase 7b — New bounded context decided | Architectural decision | "New context: {name}" → full intake dialogue |
| External market signal | Product decision | New feature brief → full intake dialogue |
| Compliance review failure | Architectural debt | "ADR amendment needed" → Intake Round 1 |

---

## Worked Example: LLM API Billing Engine Refactor

### Business Intent Submitted

> Refactor the billing engine to support Standard and Premium plans with model-aware pricing based on `modelId`.
>
> **Standard Plan:** Has a monthly global quota. Overage rates depend on the `modelId`.
> **Premium Plan:** No quota. Prompt and completion tokens are billed separately; rates vary by `modelId`.
>
> **Acceptance Criteria:**
>
> - AC1 (Validation): Missing `modelId` or negative tokens → HTTP 400
> - AC2 (Standard): Customer with 100K quota, 90K used, submits 30K tokens for `fast-model` at $0.01/1K overage → bill shows 10K from quota, 20K overage, $0.20 charge
> - AC3 (Premium): Customer submits 10K prompt + 20K completion for `reasoning-model` at $0.03/1K prompt + $0.06/1K completion → $0.30 + $1.20 = $1.50 total
>
> **Scope out:** Invoice generation, subscription CRUD, tiered discounts.

### Round 1

**Compliance Agent:**

- "Strategy Pattern is specified in scope — is this an architectural decision that needs an ADR, or an implementation detail the agent decides? If architectural, a stub is needed before Phase 0."
- "The billing engine refactor — does this stay within the existing billing bounded context, or does model-aware pricing warrant its own pricing context with separate invariants and ownership?"
- "Monthly quota storage — which service is the quota authority? If it's shared across services, that conflicts with the DB-per-service principle."
- "AC2 returns a 'bill' object; invoice generation is scoped out. Does the bill response need to be invoice-schema-compatible (same fields, just not persisted), or is it a transient calculation response only?"

**Implementation Agent:**

- "Unknown `modelId` — is it HTTP 400 (invalid input, same as AC1) or HTTP 404 (valid request, unknown resource)? These are different error classes."
- "Standard Plan quota check — synchronous at request time (strong consistency) or async reconciliation (eventual)? If synchronous, what is the lock timeout?"
- "Can a Premium request submit only prompt tokens without completion tokens? AC3 only shows both submitted together."
- "Who submits token counts — the calling service in the request body, or does the billing service read from an event log?"

*Human resolves:*
- Strategy Pattern → new ADR required; human authors the stub
- Billing refactor stays within the existing billing bounded context; no new context warranted
- Quota owned exclusively by the billing service; no sharing across services
- Bill object is transient; no invoice schema compatibility required
- Unknown `modelId` → HTTP 400 (same as AC1 — treated as invalid input)
- Quota check is synchronous; 200ms timeout derived from latency SLA
- Premium always requires both token types; prompt-only is HTTP 400
- Calling service submits token counts in the request body

### Round 2

**Documentation Agent:**

- "The intent uses 'plan type', 'plan', and 'subscription' interchangeably. Confirm the canonical term. Also: 'prompt tokens' vs 'input tokens' — which is canonical for the domain model?"
- "The Strategy Pattern ADR stub — does the Documentation Agent draft the rationale from the resolved intake document, or does the human write the 'why' from scratch?"
- "The 200ms quota-check timeout — does this become an SLA invariant requiring a runbook, or an implementation constraint only?"

**Script Authoring Agent:**

- "Billing calculation is deterministic: plan type + modelId + token counts → charge amount. This qualifies as a script task — `tooling/calculate-billing.py` reading a model-rates contract file. Does `contracts/model-rates.yaml` exist, or is it a new artifact?"
- "Should `modelId` be validated against `contracts/model-rates.yaml`? If yes, `validate-contracts.sh` needs extension."
- "Will Helm values or CI environment variables reference plan types or model IDs in Phase 4? If yes, a generation script is needed."

*Human resolves:*
- 'Plan Type' is canonical; 'Prompt Tokens' is canonical
- Documentation Agent drafts ADR rationale from intake; human reviews
- 200ms timeout is an SLA invariant; a runbook entry is needed
- `contracts/model-rates.yaml` is a new contract artifact; billing calculation is a script task
- `modelId` validated against model-rates.yaml; `validate-contracts.sh` will be extended
- No Helm/CI generation needed for plan types in this phase

### Triage Decision

```yaml
classification: new feature — extending existing billing bounded context
entry_point: Phase 0
intake_dialogue: full
adr_stubs_required: yes  # Strategy Pattern routing mechanism
new_scripts_needed: yes  # tooling/calculate-billing.py
draft_contracts:
  - contracts/slas/billing-api-sla.yaml
  - contracts/domain-invariants/billing-invariants.md
  - contracts/model-rates.yaml
```
