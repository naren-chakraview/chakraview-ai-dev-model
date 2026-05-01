# Intake/Triage Cycle Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add a continuous SDLC intake/triage cycle to the Chakraview AI Dev Model — a formal Intake/Triage entry point, a two-round interactive persona dialogue, a triage routing table, a feedback arc, and a worked example using the LLM API billing engine refactor.

**Architecture:** Four files change: `docs/workflow/index.md` gains an Intake/Triage block at the top of its diagram and a feedback arc at the bottom; `docs/intake/index.md` is created as the full intake reference page; `templates/agent-tasks/intake-triage.md` is a parameterised task spec template; `mkdocs.yml` gains a nav entry. No existing content is removed — only additions and the workflow diagram update.

**Tech Stack:** MkDocs Material, Markdown

---

## File Map

| File | Status | Responsibility |
|---|---|---|
| `docs/workflow/index.md` | Modify | Add Intake/Triage box to top of diagram, update intro para, add feedback arc block at bottom |
| `docs/intake/index.md` | Create | Full Intake/Triage reference — rounds, outputs, triage table, feedback arc, worked example |
| `templates/agent-tasks/intake-triage.md` | Create | Parameterised task spec for running an intake session |
| `mkdocs.yml` | Modify | Add `Intake/Triage: intake/index.md` to nav before Workflow |

---

## Task 1: Update `docs/workflow/index.md`

**Files:**
- Modify: `docs/workflow/index.md`

- [ ] **Step 1: Replace the intro paragraphs**

Open `docs/workflow/index.md`. Replace the two existing intro paragraphs:

```
The workflow sequences all six personas across eight phases. Each phase has explicit inputs, outputs, persona assignments, and a human review gate before the next phase begins.

The phases are not strictly linear — Phases 7 and 7b run continuously once the system is live. But Phases 0–6 must run in order; each phase's outputs are required inputs for the next.
```

With:

```markdown
The workflow is a **closed cycle**. Business intent enters at **Intake/Triage**, is classified and routed to the right phase entry point, executes through the relevant phases, reaches the running system, and generates signals that re-enter as the next business intent.

Phases 0–6 must run in order — each phase's outputs are required inputs for the next. Phase 7 and 7b are the **feedback arc**: they detect change signals from the running system and produce the next Intake input, closing the loop.

Full Intake/Triage documentation: [Intake/Triage](../intake/index.md)
```

- [ ] **Step 2: Add Intake/Triage block at the top of the diagram**

The diagram currently starts with:

````
```
┌─────────────────────────────────────────────────────────────────────────┐
│ PHASE 0: Bootstrap                                                      │
````

Insert the following block **before** the opening `┌` of Phase 0, inside the same code block:

```
┌─────────────────────────────────────────────────────────────────────────┐
│ INTAKE / TRIAGE  ← all business intent enters here                     │
│                                                                         │
│  Input: user story, feature brief, incident report, market signal       │
│                                                                         │
│  Round 1: [6 Compliance Agent] + [5 Implementation Agent]               │
│    Challenge: ADR conflicts, bounded context, feasibility,              │
│    state ownership, pattern decisions, edge cases                       │
│                                                                         │
│  Round 2: [2 Documentation Agent] + [3 Script Authoring Agent]          │
│    Challenge: ubiquitous language, ADR scope, scriptability,            │
│    validation needs, generation targets                                  │
│                                                                         │
│  Output: Intake Report + Draft Contracts + Triage Decision              │
│                                                                         │
│  Triage routes to entry point:                                          │
│    New feature / service ──────────────────────────────→ Phase 0       │
│    Contract patch (no dialogue) ──────────────────────→ Phase 0        │
│    Observability gap ─────────────────────────────────→ Phase 2        │
│    Infra / CI change ─────────────────────────────────→ Phase 4        │
│    Implementation patch ──────────────────────────────→ Phase 5        │
│                                                                         │
│  See: docs/intake/index.md                                              │
└──────────────────────┬──────────────────────────────────────────────────┘
                               ↓
```

- [ ] **Step 3: Add feedback arc block after Phase 7b**

The diagram currently ends with Phase 7b's closing line:

```
└─────────────────────────────────────────────────────────────────────────┘
```

After that final `└───...───┘`, still inside the same code block, append:

```
                               │
                               ▼
┌─────────────────────────────────────────────────────────────────────────┐
│ FEEDBACK ARC → signals re-enter as new Business Intent at INTAKE        │
│                                                                         │
│  SLA breach alert           → "Invariant gap" intent  → Intake Round 1  │
│  Contract change detected   → direct entry            → Phase 0         │
│  New bounded context        → full intake dialogue    → Phase 0         │
│  Compliance review failure  → "ADR amendment needed"  → Intake Round 1  │
│                                                                         │
│  ↑ loop back to INTAKE / TRIAGE at top                                  │
└─────────────────────────────────────────────────────────────────────────┘
```

- [ ] **Step 4: Verify the diagram renders**

```bash
cd /home/gundu/portfolio/chakraview-ai-dev-model
mkdocs build 2>&1 | grep -E "^ERROR|^WARNING.*workflow" | head -10
```

Expected: no ERROR lines related to `workflow/index.md`.

- [ ] **Step 5: Commit**

```bash
git add docs/workflow/index.md
git commit -m "docs: update workflow diagram to show closed intake/triage cycle"
```

---

## Task 2: Create `docs/intake/index.md`

**Files:**
- Create: `docs/intake/index.md`

- [ ] **Step 1: Write `docs/intake/index.md`**

Write this file verbatim:

````markdown
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
- "Monthly quota storage — which service is the quota authority? If it's shared across services, that conflicts with the DB-per-service principle."
- "AC2 returns a 'bill' object; invoice generation is scoped out. Does the bill response need to be invoice-schema-compatible (same fields, just not persisted), or is it a transient calculation response only?"

**Implementation Agent:**

- "Unknown `modelId` — is it HTTP 400 (invalid input, same as AC1) or HTTP 404 (valid request, unknown resource)? These are different error classes."
- "Standard Plan quota check — synchronous at request time (strong consistency) or async reconciliation (eventual)? If synchronous, what is the lock timeout?"
- "Can a Premium request submit only prompt tokens without completion tokens? AC3 only shows both submitted together."
- "Who submits token counts — the calling service in the request body, or does the billing service read from an event log?"

*Human resolves:*
- Strategy Pattern → new ADR required; human authors the stub
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
````

- [ ] **Step 2: Verify the file renders without errors**

```bash
cd /home/gundu/portfolio/chakraview-ai-dev-model
mkdocs build 2>&1 | grep -E "^ERROR|intake" | head -10
```

Expected: no ERROR lines. May see an INFO line about `intake/index.md` not being in the nav yet — that is resolved in Task 4.

- [ ] **Step 3: Commit**

```bash
git add docs/intake/index.md
git commit -m "docs: add intake/triage cycle page with worked example"
```

---

## Task 3: Create `templates/agent-tasks/intake-triage.md`

**Files:**
- Create: `templates/agent-tasks/intake-triage.md`

- [ ] **Step 1: Write `templates/agent-tasks/intake-triage.md`**

Write this file verbatim:

````markdown
# Agent Task: Intake / Triage — {Feature Name}

> **Template usage:** Replace all `{placeholder}` values before running.
> Required substitutions: `{Feature Name}`, `{service}`, `{context}`, `{path-to-intent}`.

**Task type**: Agent (multi-persona — run each role separately or in sequence)
**Spec version**: 1.0
**Last updated**: {date}
**Estimated tokens**: ~2,000 per round (two rounds)

---

## Goal

Analyse the business intent for `{Feature Name}` through two persona rounds. Surface architectural concerns, ambiguities, and missing decisions before any contract is written. Produce an Intake Report, Draft Contracts, and a Triage Decision.

---

## Inputs (read all before responding)

| File | Why |
|---|---|
| `{path-to-intent}` | The raw business intent to analyse |
| `docs/adrs/` | Existing ADRs — check for conflicts and extension points |
| `contracts/` | Existing contracts — identify what changes and what is new |
| `docs/ddd/bounded-contexts.md` | Bounded context map — determine if this extends or creates a context |
| `ai-agents/context/coding-standards.md` | Constraints the implementation will inherit |

---

## Round 1 — You are the Compliance Agent

Read the business intent. Respond with:

1. **ADR conflicts** — for each existing ADR this intent contradicts or extends: does the human need a new ADR stub before Phase 0?
2. **Bounded context boundary** — does this extend an existing context or require a new one? If new: flag that a context boundary review is required before Phase 0.
3. **Data consistency risks** — for each implied shared state: which service owns it, and does that conflict with the DB-per-service principle?
4. **Scope creep in ACs** — for each AC that implies excluded work: flag it explicitly.

Format each item as a direct question or challenge to the human. Do not answer your own questions.

---

## Round 1 — You are the Implementation Agent

Read the business intent. Respond with:

1. **Pattern decisions** — for each pattern mandated in the intent: architectural decision (ADR required) or implementation detail (agent decides)?
2. **Edge case gaps** — list each unhandled boundary condition: unknown enum values, empty inputs, concurrent writes, size limits.
3. **State ownership** — for each piece of mutable state: who owns it, synchronous or async, what is the consistency model?
4. **Data shape completeness** — list fields with ambiguous cardinality or missing optionality rules.

Format each item as a direct question or challenge to the human. Do not answer your own questions.

---

## [Human resolves Round 1]

Update this document with each resolved decision before proceeding to Round 2. Format:

```
**Q:** {question asked}
**A:** {decision made} — decided by {human | agent}
**Alternatives rejected:** {alternatives and why, or "none considered"}
```

Flag unresolved items as `⚠ UNRESOLVED: {question}`.

---

## Round 2 — You are the Documentation Agent

Re-read the updated document (including Round 1 resolutions). Respond with:

1. **Ubiquitous language** — list any concept with more than one name. For each: the canonical term going forward.
2. **ADR scope** — list decisions from Round 1 that need an ADR stub. For each: who authors the rationale (human or Documentation Agent)?
3. **Runbook implications** — list any new failure mode introduced. For each: the failure, the alert name that triggers it.

Format each item as a direct question or challenge to the human.

---

## Round 2 — You are the Script Authoring Agent

Re-read the updated document (including Round 1 resolutions). Respond with:

1. **Scriptability** — for each deterministic transformation: script name (`tooling/{name}.py`), inputs, output file path.
2. **Validation needs** — for each new contract artifact: file path, format, and the `validate-contracts.sh` extension required.
3. **Generation targets** — for each Helm value, CI variable, or manifest that will reference new values: the generation script needed in Phase 4.

Format each item as a direct question or challenge to the human.

---

## [Human resolves Round 2]

Update this document with each resolved decision using the same format as Round 1. All `⚠ UNRESOLVED` items must be closed before producing outputs.

---

## Outputs

### Intake Report

Append a `## Resolved Decisions` section listing all Q/A pairs from both rounds.

### Draft Contracts

Produce draft files for human review. Name each file using the project's contract naming convention:

- `contracts/slas/{service}-sla.yaml`
- `contracts/domain-invariants/{context}-invariants.md`
- `contracts/event-schemas/{EventName}.json` (if new events identified)
- Any additional artifacts identified by Script Authoring Agent

### Triage Decision

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

## Acceptance Criteria

- [ ] Round 1 questions from Compliance Agent are present and addressed
- [ ] Round 1 questions from Implementation Agent are present and addressed
- [ ] All Round 1 resolutions are recorded before Round 2 begins
- [ ] Round 2 questions from Documentation Agent are present and addressed
- [ ] Round 2 questions from Script Authoring Agent are present and addressed
- [ ] Zero `⚠ UNRESOLVED` items remain
- [ ] Draft contracts are present for human review
- [ ] Triage decision YAML block is complete with no `{placeholder}` values
````

- [ ] **Step 2: Verify the file is clean (no unintended placeholders left from template writing)**

```bash
grep -n "^> \*\*Template" /home/gundu/portfolio/chakraview-ai-dev-model/templates/agent-tasks/intake-triage.md | head -3
```

Expected: one line found (the template usage note at the top — this is intentional).

- [ ] **Step 3: Commit**

```bash
git add templates/agent-tasks/intake-triage.md
git commit -m "docs: add intake-triage agent task spec template"
```

---

## Task 4: Update `mkdocs.yml` nav and verify build

**Files:**
- Modify: `mkdocs.yml`

- [ ] **Step 1: Add `Intake/Triage` nav entry**

Open `mkdocs.yml`. In the `nav:` section, find:

```yaml
  - Workflow: workflow/index.md
```

Add a new entry **before** it:

```yaml
  - Intake/Triage: intake/index.md
  - Workflow: workflow/index.md
```

The full nav block should now read:

```yaml
nav:
  - Home: index.md
  - Model: model.md
  - Personas:
    - personas/index.md
    - "1 — Human Domain Expert": personas/persona-1-human-domain-expert.md
    - "2 — Documentation Agent": personas/persona-2-documentation-agent.md
    - "3 — Script Authoring Agent": personas/persona-3-script-authoring-agent.md
    - "4 — Script Executor": personas/persona-4-script-executor.md
    - "5 — Implementation Agent": personas/persona-5-implementation-agent.md
    - "6 — Compliance Agent": personas/persona-6-compliance-agent.md
  - Mechanism:
    - mechanism/index.md
    - Contracts: mechanism/contracts.md
    - Agent vs Script: mechanism/agent-vs-script.md
    - Guardrails: mechanism/guardrails.md
  - Intake/Triage: intake/index.md
  - Workflow: workflow/index.md
  - Task Specs: task-specs/index.md
  - Case Studies: case-studies/index.md
```

- [ ] **Step 2: Run full strict build**

```bash
cd /home/gundu/portfolio/chakraview-ai-dev-model
mkdocs build --strict 2>&1
echo "Exit code: $?"
```

Expected: exit code 0. The two INFO lines about unrecognised relative links to `../templates/` (in `index.md` and `task-specs/index.md`) are pre-existing and acceptable — they are not errors.

- [ ] **Step 3: Verify the intake page is in the build output**

```bash
ls /home/gundu/portfolio/chakraview-ai-dev-model/site/intake/
```

Expected: `index.html` present.

- [ ] **Step 4: Verify no domain-specific references leaked into the new files**

```bash
grep -ri "chakra commerce\|orders service\|billing engine" \
  /home/gundu/portfolio/chakraview-ai-dev-model/docs/intake/ \
  /home/gundu/portfolio/chakraview-ai-dev-model/templates/agent-tasks/intake-triage.md \
  || echo "CLEAN"
```

Expected: matches only the worked example section in `docs/intake/index.md` (the billing engine example is intentional domain content there) — or `CLEAN` if the grep finds nothing. The template file must be clean.

- [ ] **Step 5: Commit**

```bash
git add mkdocs.yml
git commit -m "docs: add intake/triage to nav"
```

---

## Self-Review

**Spec coverage check:**

| Spec requirement | Task |
|---|---|
| Closed SDLC cycle diagram | Task 1 |
| Intake/Triage box in workflow | Task 1 |
| Feedback arc in workflow | Task 1 |
| `docs/intake/index.md` — full reference page | Task 2 |
| Two-round structure (Round 1: Compliance + Implementation) | Task 2 |
| Two-round structure (Round 2: Documentation + Script) | Task 2 |
| Persona questions for each role | Task 2 |
| Output formats (intake report, draft contracts, triage decision) | Task 2 |
| Triage routing table | Task 2 |
| Feedback arc table | Task 2 |
| Billing engine worked example | Task 2 |
| `templates/agent-tasks/intake-triage.md` | Task 3 |
| `mkdocs.yml` nav entry | Task 4 |
| `mkdocs build --strict` passes | Task 4 |
