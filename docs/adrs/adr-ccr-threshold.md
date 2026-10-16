---
title: ADR — CCR Threshold Rule
description: When a Contract Challenge Report is required versus when an inline note suffices.
date: 2026-10-16
status: accepted
---

# ADR: CCR Threshold Rule

## Status

Accepted

## Context

The Contract Challenge Report (CCR) is the formal mechanism for the phase-agnostic Loop C feedback path — cases where honoring a contract is technically costly or complex and the resolution may require relaxing the contract rather than implementing harder.

All agent personas (2, 3, 5, 6) have authority to write a CCR. Without a documented threshold, two failure modes emerge:

- **Over-reporting**: agents file CCRs for minor observations, flooding the artifact trail and causing the Human Domain Expert to treat CCRs as noise
- **Under-reporting**: agents skip CCRs for decisions that genuinely warrant contract amendment; the conversation happens informally with no audit trail

## Decision

A CCR is **required** when resolving the challenge would:

1. Amend a file in `contracts/slas/`
2. Amend a file in `contracts/domain-invariants/`
3. Amend a file in `contracts/event-schemas/`
4. Require a new or amended ADR

If none of the four conditions is met, the agent notes the observation inline in its existing task output and continues. No CCR is written, no halt, no routing.

## Rationale

The formal CCR path exists to make contract amendments auditable. Routing minor observations through the same path degrades the CCR signal — practitioners either ignore CCRs or bypass the path informally, reproducing the problem the CCR was designed to solve.

The four-condition threshold is intentionally binary: the question is not "how significant is this?" but "would resolution produce a changed contract artifact or a new ADR?" This makes classification a check, not a judgment.

## Consequences

**Positive:**

- Every CCR reliably signals a decision that requires product/business owner input
- The Human Domain Expert can treat every CCR as a routing task, not a triage task
- Contract amendments are auditable — every amended contract has a CCR that records why

**Negative:**

- Agents must still apply judgment at the threshold boundary; an agent might note inline when a CCR was warranted
- Misclassified bypasses only surface at Compliance Review (see below)

## Misclassification detection

If a Compliance Agent review discovers that an agent continued past a contract challenge without writing a CCR — evidenced by an implementation that implies a contract was too costly to honor, but no matching CCR exists in `ai-agents/reviews/` — the Compliance Agent flags this as a **process deviation** in the compliance report. This is the enforcement backstop for the threshold rule.
