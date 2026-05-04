---
name: chakraview:intake-triage
type: task
description: >
  Run the 4-persona intake/triage dialogue — surfaces architectural conflicts,
  edge cases, ADR needs, and scriptability before any contract is written
triggers: [starting a new feature or service, business intent needs review before contracts are written, intake or triage needed]
phases: [0]
personas: [6, 5, 2, 3]
reads:
  - docs/adrs/
  - contracts/
  - docs/ddd/bounded-contexts.md
  - ai-agents/context/coding-standards.md
writes:
  - docs/intake/
  - contracts/slas/
  - contracts/domain-invariants/
  - contracts/event-schemas/
---

# Intake / Triage

Replace `{Feature Name}`, `{service}`, `{context}`, and `{path-to-intent}` with actual values.

## Goal

Analyse business intent through two persona rounds. Surface architectural concerns, ambiguities, and missing decisions before any contract is written. Produce an Intake Report, Draft Contracts, and a Triage Decision.

## Inputs (read all before responding)

| File | Why |
|---|---|
| `{path-to-intent}` | The raw business intent to analyse |
| `docs/adrs/` | Existing ADRs — check for conflicts and extension points |
| `contracts/` | Existing contracts — identify what changes and what is new |
| `docs/ddd/bounded-contexts.md` | Bounded context map |
| `ai-agents/context/coding-standards.md` | Constraints the implementation will inherit |

## Round 1a — You are the Compliance Agent

Read the business intent. Respond with direct questions (do not answer your own questions):

1. **ADR conflicts** — does this intent contradict or extend any existing ADR? Does the human need a new ADR stub before Phase 0?
2. **Bounded context boundary** — does this extend an existing context or require a new one?
3. **Data consistency risks** — for each implied shared state: which service owns it? Does that conflict with DB-per-service?
4. **Scope creep in ACs** — does any AC imply work the scope-out section excludes?

## Round 1b — You are the Implementation Agent

Read the business intent. Respond with direct questions:

1. **Pattern decisions** — is each mandated pattern an architectural decision (ADR required) or an implementation detail?
2. **Edge case gaps** — what happens at boundaries: unknown enum values, empty inputs, concurrent writes, max payload sizes?
3. **State ownership** — who owns each piece of mutable state? Synchronous or async?
4. **Data shape completeness** — which fields are optional vs required? What does omitting an optional field mean?

## Human Resolution — Round 1

Record each resolved decision before Round 2:

```
**Q:** {question asked}
**A:** {decision} — decided by {human | agent}
**Alternatives rejected:** {alternatives and why, or "none considered"}
```

Flag unresolved items as `⚠ UNRESOLVED: {question}`. Phase 0 cannot begin until all are closed.

## Round 2a — You are the Documentation Agent

Re-read the updated document (Round 1 resolutions included). Respond with direct questions:

1. **Ubiquitous language** — list any concept with more than one name; for each: the canonical term.
2. **ADR scope** — which Round 1 decisions need an ADR stub? Who authors the rationale?
3. **Runbook implications** — any new failure mode? Name it and the alert that triggers it.

## Round 2b — You are the Script Authoring Agent

Re-read the updated document. Respond with direct questions:

1. **Scriptability** — for each deterministic transformation: script name (`tooling/{name}`), inputs, output file.
2. **Validation needs** — for each new contract artifact: file path, format, `validate-contracts.sh` extension needed.
3. **Generation targets** — will Helm values, CI variables, or manifests reference new values in Phase 4?

## Human Resolution — Round 2

Same format as Round 1. Do not re-ask questions resolved in Round 1.

## Outputs

### Intake Report
Save to `docs/intake/{feature-slug}-intake-report.md`. Append `## Resolved Decisions` with all Q/A pairs.

### Draft Contracts
| File | Produced from |
|---|---|
| `contracts/slas/{service}-sla.yaml` | Latency, availability, throughput from intake |
| `contracts/domain-invariants/{context}-invariants.md` | Business rules from ACs and resolved edge cases |
| `contracts/event-schemas/{Event}.json` | If new domain events identified |

### Triage Decision
```yaml
classification: # new feature | contract patch | observability gap | infra change | implementation patch
entry_point: # Phase 0, 1, 2, 4, or 5
intake_dialogue: # full | round-1-only | none
adr_stubs_required: # yes | no
new_scripts_needed: # yes | no
draft_contracts:
  - # contracts/{path}
```

## Acceptance Criteria
- [ ] Round 1 questions from both agents present and addressed
- [ ] All Round 1 resolutions recorded before Round 2 begins
- [ ] Round 2 questions from both agents present and addressed
- [ ] Zero `⚠ UNRESOLVED` items remain
- [ ] Draft contracts present for human review
- [ ] Triage decision YAML complete
