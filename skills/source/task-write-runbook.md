---
name: chakraview:write-runbook
type: task
description: >
  Phase 6 — produce an operational runbook for a specific failure mode,
  executable by an on-call engineer at 3am with no additional context
triggers: [SLA and alerts exist; runbook needed for a failure mode, Phase 6 operations documentation, write-runbook mentioned]
phases: [6]
personas: [2]
reads:
  - contracts/slas/
  - observability/slos/
  - observability/alerts/
  - docs/adrs/
  - services/
writes:
  - docs/runbooks/
---

# Write Runbook

Replace `{service}` and `{failure-mode}` before running.

## Goal

Produce an operational runbook for the `{failure-mode}` failure mode in `{service}`. Executable at 3am with no additional context.

## Inputs (read all before writing)

| File | Why |
|---|---|
| `contracts/slas/{service}-sla.yaml` | What SLA is at risk |
| `observability/slos/{service}-slo.yaml` | Alert thresholds and burn rate model |
| `observability/alerts/{service}-burnrate.yaml` | Exact alert names that trigger this runbook |
| `docs/adrs/` | Architecture decisions that constrain recovery options |
| `services/{service}/src/` | What can fail and why |

## Output

```
docs/runbooks/{failure-mode}-{service}.md
```

## Constraints

1. **Exact alert name in title**: read `observability/alerts/{service}-burnrate.yaml` and use the alert's exact `alert:` name field as the runbook H1 heading. On-call engineers find this runbook via the alert's `runbook_url` annotation.
2. **Diagnosis before remediation**: walk through diagnosis before any remediation step.
3. **No "contact the team" steps**: all steps self-contained. A step that says "contact the service owner" is useless at 3am.
4. **SLA budget context**: include approximate error budget remaining at typical alert thresholds.
5. **Escalation only as last resort**: acceptable at the end if preceding steps genuinely cannot resolve the issue.

## Acceptance Criteria
- [ ] Alert name in title matches exact name in `observability/alerts/{service}-burnrate.yaml`
- [ ] Diagnosis section precedes remediation
- [ ] No "contact X" steps without preceding self-contained diagnosis
- [ ] SLA budget context included
- [ ] Runbook completable in under 15 minutes of reading
