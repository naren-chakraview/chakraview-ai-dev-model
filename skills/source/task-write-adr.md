---
name: chakraview:write-adr
type: task
description: >
  Phase 1 — expand a human-authored ADR stub into a complete MADR with
  rationale, rejected alternatives, and split consequences
triggers: [ADR stub exists and needs to be expanded, architectural decision needs to be documented, write-adr mentioned]
phases: [1]
personas: [2]
reads:
  - docs/adrs/
  - docs/ddd/bounded-contexts.md
  - contracts/domain-invariants/
writes:
  - docs/adrs/
---

# Write Architecture Decision Record

Replace `{adr-number}`, `{decision-title}`, and `{service or context}` before running.

## Goal

Produce a complete ADR in MADR format from the human-authored context stub. The record must allow a new team member to understand the reasoning without asking anyone.

## Inputs (read all before writing)

| File | Why |
|---|---|
| `docs/adrs/{adr-number}-{decision-title}-stub.md` | Human-authored context: the decision and the "why" |
| `docs/ddd/bounded-contexts.md` | Which domains are affected |
| `contracts/domain-invariants/{service or context}-invariants.md` | Constraints the decision must respect |
| All accepted ADRs in `docs/adrs/` | Decisions must not contradict accepted ADRs |

## Output

```
docs/adrs/{adr-number}-{decision-title}.md
```

After writing the full ADR, the human-authored stub (`{adr-number}-{decision-title}-stub.md`) should be deleted — the completed ADR is the canonical record.

## Constraints

1. **MADR format**: title, status, date, deciders, context, decision, consequences, alternatives considered.
2. **Every alternative rejected with reasoning**: at least two alternatives; explain why each was not chosen — not just that it was considered.
3. **Split consequences**: list positive AND negative consequences. An ADR with only positive consequences was not written honestly.
4. **Cross-reference existing ADRs**: if this decision depends on or constrains another, reference it by name and number.
5. **No implementation detail**: the ADR documents the decision, not the implementation.

## Acceptance Criteria
- [ ] ADR follows MADR format exactly
- [ ] At least two alternatives documented and rejected with reasoning
- [ ] Both positive and negative consequences listed
- [ ] Every referenced ADR exists in `docs/adrs/`
- [ ] Status is `Accepted`
