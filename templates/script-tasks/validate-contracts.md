# Script Task: Validate Contracts

> **Template usage:** Replace `{placeholder}` values before running.
> Required substitutions: `{project}`, `{ext}`.

**Task type**: Script (deterministic validation)
**Script to produce**: `tooling/validate-contracts.{ext}`
**Runs in**: CI on every push; manually before any agent invocation

---

## Purpose

Validate the integrity of the contract→implementation chain. The script is the primary guardrail that prevents agents from being invoked before their required contracts exist, and prevents implementation from existing without a corresponding contract.

---

## Checks to Implement

| Check | Description |
|---|---|
| SLA coverage | Every service in `tooling/service-manifest.yaml` has a file in `contracts/slas/` |
| SLO coverage | Every SLA file has a corresponding SLO definition in `observability/slos/` |
| Alert coverage | Every SLO file has a corresponding burn rate alert in `observability/alerts/` |
| Event schema coverage | Every event referenced in `contracts/domain-invariants/` exists in `contracts/event-schemas/` |
| Invariant test coverage | Every invariant ID in `contracts/domain-invariants/` appears in at least one test file under `services/` |
| ADR status | No ADR in `docs/adrs/` has status `Proposed` for more than 30 days (warning, not failure) |

---

## Output Format

```
[PASS] SLA coverage: 5/5 services have SLA files
[PASS] SLO coverage: 5/5 SLA files have matching SLO definitions
[PASS] Alert coverage: 5/5 SLO files have matching burn rate alerts
[FAIL] Event schema coverage: {EventName} referenced in {service}-invariants.md but no schema found
[PASS] Invariant test coverage: 10/10 invariant IDs found in test files
[WARN] {ADR-name} has been in Proposed status for 45 days

Exit code: 1 (due to FAIL)
```

---

## Constraints

1. **Idempotent**: Running twice produces identical output.
2. **No side effects**: The script only reads files — it never writes, deletes, or modifies anything.
3. **Explicit failure messages**: Every FAIL line must name the specific file and the specific missing or mismatched element.
4. **Fast**: Must complete in under 10 seconds on a repo with 20 services.

---

## Acceptance Criteria

- [ ] Script runs from repo root with no arguments
- [ ] All checks implemented and producing PASS/FAIL/WARN output
- [ ] Exit code is non-zero on any FAIL
- [ ] Exit code is zero when all checks pass (WARNs do not fail)
- [ ] Idempotent
- [ ] Completes in under 10 seconds
