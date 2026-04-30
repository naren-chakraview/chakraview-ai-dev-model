# Script Task: Generate CI Pipeline

> **Template usage:** Replace `{placeholder}` values before running.
> Required substitutions: `{service}`, `{language}`, `{ci-system}`, `{ext}`.

**Task type**: Script (deterministic transformation)
**Script to produce**: `tooling/generate-ci-workflow.{ext}`
**Runs in**: CI on service manifest changes; manually when adding a new service

---

## Purpose

Generate a CI pipeline definition for each service from the service manifest. The pipeline must enforce the contract validation gate on every push, regardless of service language.

---

## Input Schema

Same `tooling/service-manifest.yaml` as `generate-helm-boilerplate`. Uses `name`, `language`, and `type` fields.

---

## Output

For each service: `.{ci-system}/workflows/ci-{service}.{ext}`

The pipeline must include these stages in order:

1. **Lint/type check** — language-specific; derived from `language` field
2. **Unit tests** — runs `{test command}` from service directory
3. **Contract validation** — runs `tooling/validate-contracts.sh` — always present regardless of language
4. **Build image** — only on pushes to `main`

---

## Constraints

1. **Idempotent**: Running twice produces identical output.
2. **Contract validation is mandatory**: Stage 3 must always be present. A pipeline without contract validation is a contract violation.
3. **Trigger on contract file changes**: The pipeline must trigger on changes to `contracts/` in addition to `services/{service}/`.
4. **Language-specific commands from manifest**: Do not hardcode language commands — derive them from the `language` field.

---

## Acceptance Criteria

- [ ] Produces one pipeline file per service
- [ ] Every pipeline includes the contract validation stage
- [ ] Pipelines trigger on changes to `contracts/` directory
- [ ] Output is idempotent
- [ ] Script exits non-zero if the manifest is malformed
