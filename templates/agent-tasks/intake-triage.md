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
