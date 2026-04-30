# Agent Task: Write Runbook

> **Template usage:** Replace all `{placeholder}` values before running.
> Required substitutions: `{service}`, `{failure-mode}`, `{alert-name}`.

**Task type**: Agent (LLM reasoning required — Persona 2)
**Spec version**: 1.0
**Runs after**: Phase 6 (Migration + Operations Documentation)

---

## Goal

Produce an operational runbook for the `{failure-mode}` failure mode in the `{service}` service. The runbook must be executable by an on-call engineer at 3am with no additional context.

---

## Inputs (read all of these before writing a single line)

| File | Why |
|---|---|
| `contracts/slas/{service}-sla.yaml` | Understand what SLA is at risk during this failure |
| `observability/slos/{service}-slo.yaml` | Alert thresholds and burn rate model |
| `observability/alerts/{service}-burnrate.yaml` | Alert names that trigger this runbook |
| `docs/adrs/` | Architecture decisions that constrain the recovery options |
| `services/{service}/src/` | Service code — understand what can fail and why |

---

## Outputs

```
docs/runbooks/{failure-mode}-{service}.md
```

---

## Constraints

1. **Reference the alert by exact name**: The runbook must start with the exact alert name that triggers it. An on-call engineer finds this runbook via the alert's `runbook_url` annotation.
2. **Diagnosis steps before remediation**: The runbook must walk through diagnosis before remediation. Do not jump to "restart the pod" — explain how to confirm the diagnosis first.
3. **No "contact the team" steps**: A runbook that says "contact the service owner" is useless at 3am. All steps must be self-contained.
4. **SLA budget context**: Include how much error budget remains (approximate) at typical alert thresholds, to calibrate urgency.
5. **Escalation path only as last resort**: An escalation step is acceptable at the end only if the preceding steps genuinely cannot resolve the issue.

---

## Acceptance Criteria

- [ ] Alert name in the title matches the exact alert name in `observability/alerts/{service}-burnrate.yaml`
- [ ] Diagnosis section precedes remediation section
- [ ] No "contact X" steps without a preceding self-contained diagnosis path
- [ ] SLA budget context included
- [ ] Runbook is complete in under 15 minutes of reading
