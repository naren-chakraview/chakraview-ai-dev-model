---
name: chakraview:script-authoring
type: task
description: >
  Write a deterministic transformation script for tooling/ — authored once by
  the agent, executed forever by CI
triggers: [deterministic transformation identified — structured input to structured output, need a script to generate alerts/Helm charts/CI pipelines/CODEOWNERS, script-authoring needed]
phases: [0, 2, 4]
personas: [3]
reads:
  - tooling/service-manifest.yaml
  - contracts/slas/
  - ai-agents/context/coding-standards.md
writes:
  - tooling/
---

# Script Authoring

Replace `{script-name}`, `{input-files}`, and `{output-path}` before running.

## The decision rule

**Use this task** when: input is structured data (YAML, JSON); transformation is deterministic and mechanical; output format is fixed.

**Use `chakraview:implement-service` instead** when: input includes natural language (invariants, ADR rationale); output requires synthesis or judgment.

## Goal

Write `tooling/{script-name}` — a deterministic script that transforms `{input-files}` into `{output-path}`.

## Inputs (read before writing)

| File | Why |
|---|---|
| `tooling/service-manifest.yaml` | Authoritative service registry; source of truth for names and owners |
| `contracts/slas/{service}-sla.yaml` | SLA values that parameterise generated artifacts |
| `ai-agents/context/coding-standards.md` | Language and style constraints |

## Hard requirements

1. **Idempotent**: running the script twice on the same input produces identical output.
2. **No judgment**: if the script needs to make a decision, the input spec is incomplete — surface the gap and exit non-zero.
3. **Exit codes**: exit 0 on success, non-zero with a descriptive message on failure.
4. **One run**: after review and merge, you are not re-invoked. Only the script runs, in CI, indefinitely.
5. **`--help` flag**: documents inputs, outputs, and usage.

## Output

```
tooling/{script-name}
```

If this script introduces a new contract artifact, extend `tooling/validate-contracts.sh` to validate it.

## Acceptance Criteria
- [ ] Script exits 0 on valid inputs
- [ ] Script exits non-zero with descriptive message on invalid inputs
- [ ] Running twice produces identical output (idempotency)
- [ ] `--help` flag documented
- [ ] `validate-contracts.sh` extended if a new contract artifact is introduced
