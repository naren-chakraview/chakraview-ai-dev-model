# Agent Task: Write Architecture Decision Record

> **Template usage:** Replace all `{placeholder}` values before running.
> Required substitutions: `{adr-number}`, `{decision-title}`, `{service or context}`.

**Task type**: Agent (LLM reasoning required — Persona 2)
**Spec version**: 1.0
**Runs after**: Phase 1 (Architecture Foundation), or any time a new architectural decision is made

---

## Goal

Produce a complete Architecture Decision Record in MADR format from the human-authored context stub. The ADR must document the decision, the forces that shaped it, the alternatives considered, and the consequences — at a level of detail that allows a new team member to understand the reasoning without asking anyone.

---

## Inputs (read all of these before writing a single line)

| File | Why |
|---|---|
| `docs/adrs/{adr-number}-{decision-title}-stub.md` | Human-authored context: the decision and the "why" |
| `docs/ddd/bounded-contexts.md` | Understand which domains are affected |
| `contracts/domain-invariants/{service}-invariants.md` | Understand constraints the decision must respect |
| All previously accepted ADRs in `docs/adrs/` | Ensure consistency; decisions must not contradict accepted ADRs |

---

## Outputs (produce exactly these files)

```
docs/adrs/{adr-number}-{decision-title}.md
```

---

## Constraints

1. **MADR format**: Use the MADR template (title, status, date, deciders, context, decision, consequences, alternatives considered).
2. **Every alternative must be explained and rejected**: List at least two alternatives. For each, explain why it was not chosen — not just that it was considered.
3. **Consequences must be split**: List both positive and negative consequences. An ADR with only positive consequences was not written honestly.
4. **Cross-reference existing ADRs**: If this decision depends on or constrains another ADR, reference it by name and number.
5. **No implementation detail**: The ADR documents the decision, not the implementation. Helm chart structure belongs in infra conventions, not an ADR.

---

## Acceptance Criteria

- [ ] ADR follows MADR format exactly
- [ ] At least two alternatives documented and rejected with reasoning
- [ ] Both positive and negative consequences listed
- [ ] Every ADR referenced in the body exists in `docs/adrs/`
- [ ] Status is `Accepted`
