# Agent Task: Contract Challenge Report

> **Template usage:** Fill in all four fields before submitting. Do not leave any field blank.
> Only write a CCR if the threshold is met — see the threshold check below.

**Task type**: Any agent (Personas 2, 3, 5, or 6)
**Spec version**: 1.0
**Triggered by**: Discovery that a contract is technically costly or complex to honor

---

## Threshold check

Before writing this CCR, confirm at least one condition is true:

- [ ] Resolution would amend a file in `contracts/slas/`
- [ ] Resolution would amend a file in `contracts/domain-invariants/`
- [ ] Resolution would amend a file in `contracts/event-schemas/`
- [ ] Resolution would require a new or amended ADR

If no box is checked: note the observation inline in your task output and do not write a CCR.

Reference: `docs/adrs/adr-ccr-threshold.md`

---

## Goal

Surface a contract that is technically costly or complex to honor, with enough precision that the Human Domain Expert can route it to the right product or business owner and record an auditable outcome.

---

## The four fields

Write your CCR using these four fields and no others:

```
contract: <path to the contract file>#<specific clause, SLA target, invariant ID, or schema field>

cost:     <What honoring this contract technically requires — infrastructure, algorithm,
           or architectural complexity. Be specific: "requires X" not "is expensive".
           If a cost delta is calculable, include it.>

question: <The specific choice for the product or business owner.
           Name a concrete alternative: "Would X be acceptable? That would allow Y."
           Not an open question — a decision between the current contract and a named alternative.>

phase:    <Workflow phase number where this discovery was made (0, 1, 2, 3, 4, 5, or 6)>
```

---

## Example

```
contract: contracts/slas/billing-api-sla.yaml#latency-p99-50ms

cost:     Honoring 50ms p99 requires a synchronous Redis cache layer plus a dedicated
          read replica. Estimated infra cost delta: ~$2k/month.

question: Is 50ms p99 a hard business requirement, or was it an estimate?
          Would 100ms p99 be acceptable? That eliminates the cache requirement.

phase:    5
```

---

## Output

Write to: `ai-agents/reviews/ccr-{service}-{date}.md`

After writing:
1. Halt work on the affected contract (and only the affected contract — continue other work)
2. Surface the CCR file path to the Human Domain Expert
3. Do not resume work on the affected contract until the Human Domain Expert records an outcome

---

## Outcome recording (Human Domain Expert)

The Human Domain Expert appends the outcome to the CCR file:

```
outcome: RELAX | HOLD

resolution: <RELAX: path of the amended contract file>
            <HOLD: path of the ADR written to justify holding the contract>
```

---

## Acceptance criteria

- [ ] All four fields are present and non-empty
- [ ] `contract:` references a specific file and clause (not a directory)
- [ ] `question:` names a concrete alternative, not an open-ended question
- [ ] `phase:` is a single number (0–6)
- [ ] File is written to `ai-agents/reviews/`, not anywhere else
- [ ] Threshold check was completed — at least one box was checked before filing
