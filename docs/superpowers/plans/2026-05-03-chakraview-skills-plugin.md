# Chakraview Skills Plugin Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build `skills/` inside `chakraview-ai-dev-model` — 12 platform-agnostic source skill files and an `install.sh` that adapts them to Claude Code, Cursor, Windsurf, Copilot, Codex, and Gemini CLI.

**Architecture:** Source-first. One canonical `.md` per skill in `source/`. Platform config in `platforms/`. Install-time transformation by `install.sh`. Tests validate source format first, then each install adapter.

**Tech Stack:** Bash 5+, awk, standard POSIX tools. No external dependencies.

---

### Task 1: Directory skeleton + validation harness

**Files:**
- Create: `skills/` full directory tree
- Create: `skills/tests/validate-sources.sh`

- [ ] **Step 1: Create all directories**

```bash
cd /home/gundu/portfolio/chakraview-ai-dev-model
mkdir -p skills/source/context
mkdir -p skills/platforms/{claude-code,cursor,windsurf,copilot,codex,gemini}
mkdir -p skills/scaffold/contracts/{slas,domain-invariants,event-schemas}
mkdir -p skills/scaffold/docs/{adrs,ddd}
mkdir -p skills/scaffold/ai-agents/{tasks,context,reviews}
mkdir -p skills/tests
touch skills/scaffold/contracts/slas/.gitkeep
touch skills/scaffold/contracts/domain-invariants/.gitkeep
touch skills/scaffold/contracts/event-schemas/.gitkeep
touch skills/scaffold/docs/adrs/.gitkeep
touch skills/scaffold/docs/ddd/.gitkeep
touch skills/scaffold/ai-agents/tasks/.gitkeep
touch skills/scaffold/ai-agents/context/.gitkeep
touch skills/scaffold/ai-agents/reviews/.gitkeep
```

- [ ] **Step 2: Write `skills/tests/validate-sources.sh`**

```bash
#!/usr/bin/env bash
set -euo pipefail
SOURCE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../source" && pwd)"
ERRORS=0; FILES=0

get_fm() {
  local file="$1" field="$2"
  awk -v f="$field" 'BEGIN{c=0} /^---/{c++;next} c==1 && $0~"^"f":"{sub("^"f":[ ]*","");print;exit}' "$file"
}

for f in "$SOURCE_DIR"/task-*.md "$SOURCE_DIR"/persona-*.md "$SOURCE_DIR"/meta-*.md; do
  [[ -f "$f" ]] || continue
  FILES=$((FILES+1))
  for field in name type description triggers; do
    [[ -z "$(get_fm "$f" "$field")" ]] && echo "FAIL: $(basename "$f") missing: $field" && ERRORS=$((ERRORS+1))
  done
  name=$(get_fm "$f" "name")
  [[ "$name" != chakraview:* ]] && echo "FAIL: $(basename "$f") name '$name' must start with chakraview:" && ERRORS=$((ERRORS+1))
  type=$(get_fm "$f" "type")
  [[ ! "$type" =~ ^(task|persona|meta)$ ]] && echo "FAIL: $(basename "$f") type '$type' must be task|persona|meta" && ERRORS=$((ERRORS+1))
done

[[ $FILES -eq 0 ]] && echo "FAIL: no source files found" && exit 1
[[ $ERRORS -gt 0 ]] && echo "$ERRORS error(s) in $FILES files" && exit 1
echo "OK: $FILES source skill files valid"
```

- [ ] **Step 3: Run to verify it fails (no source files yet)**

```bash
chmod +x skills/tests/validate-sources.sh
bash skills/tests/validate-sources.sh
```

Expected: `FAIL: no source files found`

- [ ] **Step 4: Commit**

```bash
git add skills/
git commit -m "feat(skills): add directory skeleton and validation harness"
```

---

### Task 2: Persona skills + meta-workflow skill (5 files)

**Files:** Create `skills/source/persona-documentation-agent.md`, `persona-script-authoring-agent.md`, `persona-implementation-agent.md`, `persona-compliance-agent.md`, `meta-workflow.md`

- [ ] **Step 1: Write `skills/source/persona-documentation-agent.md`**

```markdown
---
name: chakraview:documentation-agent
type: persona
description: >
  Persona 2 — produce full ADRs, domain models, API contracts, migration docs,
  and runbooks from human-authored stubs and invariants
triggers:
  - need to expand an ADR stub into a full MADR
  - need to write a domain model from invariants
  - need to produce OpenAPI or AsyncAPI specs
  - need to write a runbook or migration phase doc
phases: [1, 3, 6]
personas: [2]
reads:
  - docs/adrs/
  - contracts/domain-invariants/
  - contracts/event-schemas/
  - docs/ddd/
writes:
  - docs/adrs/
  - docs/ddd/
  - docs/migration/
  - docs/runbooks/
  - api/openapi/
  - api/asyncapi/
---

# Documentation Agent (Persona 2)

**Type**: LLM
**Authority**: Prose, structured argument, and narrative only. No code, no scripts, no infrastructure manifests.

## What you produce

- Full ADRs in MADR format — rationale, consequences, alternatives considered
- `docs/ddd/{service}/domain-model.md` — aggregate structure, commands, invariant mapping
- `docs/ddd/{service}/state-machine.md` — state transitions from invariants
- `docs/migration/` — phase docs with risk assessment and rollback procedures
- `docs/runbooks/` — one runbook per failure mode referenced in the SLA
- `api/openapi/{service}-api-v1.yaml` — OpenAPI 3.1 from domain models
- `api/asyncapi/{service}-events.yaml` — AsyncAPI 3.0 from event schemas

## Before writing

Read all human-authored stubs provided. Read all existing accepted ADRs — your output must not contradict them. Your output quality is a direct function of the richness of the inputs: a two-sentence stub produces a shallow ADR; a stub that names the forces and tradeoffs produces a record worth reading.

## What you do not do

You do not write code, scripts, Helm charts, CI configs, or observability manifests. Those are produced by other personas from the documentation you produce.
```

- [ ] **Step 2: Write `skills/source/persona-script-authoring-agent.md`**

```markdown
---
name: chakraview:script-authoring-agent
type: persona
description: >
  Persona 3 — write deterministic transformation scripts in tooling/ that
  run once and execute forever via CI
triggers:
  - deterministic transformation identified — structured input to structured output
  - need to generate alerts, Helm charts, CI pipelines, or CODEOWNERS from manifests
  - script authoring needed
phases: [0, 2, 4]
personas: [3]
reads:
  - tooling/service-manifest.yaml
  - contracts/slas/
  - ai-agents/context/
writes:
  - tooling/
---

# Script Authoring Agent (Persona 3)

**Type**: LLM (one-shot per script)
**Authority**: Scripts in `tooling/` only. You do not write service source code.

## The decision rule

**Use this persona** when: input is structured data (YAML, JSON); the transformation is deterministic and mechanical; output format is fixed.

**Use `chakraview:implementation-agent` instead** when: input includes natural language (invariants, ADR rationale); output requires synthesis or tradeoff reasoning.

## What you produce

Deterministic transformation scripts in `tooling/`:
- `generate-{artifact}.py` — structured input → PrometheusRule or SLO manifests
- `generate-{artifact}.sh` — service manifest → Helm chart directory
- `generate-ci-workflow.sh` — service name + language → GitHub Actions YAML
- `validate-contracts.sh` — repo state → pass/fail coverage report

## Hard requirements

1. **Idempotent**: running the script twice produces identical output
2. **No judgment**: if a decision is needed, the input spec is incomplete — surface the gap
3. **Exit codes**: exit 0 on success, non-zero with a descriptive message on failure
4. **One run**: after this script is reviewed and merged, you are not re-invoked. Only the script runs, forever.
```

- [ ] **Step 3: Write `skills/source/persona-implementation-agent.md`**

```markdown
---
name: chakraview:implementation-agent
type: persona
description: >
  Persona 5 — synthesize service source code and invariant tests from contracts,
  domain models, API specs, and infrastructure scaffolding
triggers:
  - Phase 5 entry — contracts, ADRs, domain models, and infra scaffold all exist
  - implement a service from contracts
phases: [5]
personas: [5]
reads:
  - contracts/domain-invariants/
  - contracts/event-schemas/
  - contracts/slas/
  - docs/ddd/
  - api/openapi/
  - ai-agents/context/coding-standards.md
  - ai-agents/context/observability-requirements.md
writes:
  - services/
---

# Implementation Agent (Persona 5)

**Type**: LLM
**Authority**: Service source code and tests under `services/`. Nothing else.

## Must read before writing a single line

1. `contracts/domain-invariants/{service}-invariants.md` — every invariant must be enforced
2. `contracts/event-schemas/{EventName}.json` — event classes must match exactly
3. `contracts/slas/{service}-sla.yaml` — histogram bucket boundaries and metric names
4. `docs/ddd/{service}/domain-model.md` — aggregate structure and commands
5. `docs/ddd/{service}/state-machine.md` — state transition guard logic
6. `api/openapi/{service}-api-v1.yaml` — route handler signatures
7. `ai-agents/context/coding-standards.md`
8. `ai-agents/context/observability-requirements.md`

## Hard constraints

1. **No I/O in domain layer**: zero imports from `infrastructure/` in domain files
2. **Invariant enforcement**: every invariant enforced before any event appended; violations throw a named domain error class
3. **Outbox pattern**: events published from outbox, not directly from command handlers
4. **OTEL**: histogram buckets include the SLA `latency_p99_ms` value; metric names match `observability-requirements.md` exactly
5. **Typed events**: event classes structurally compatible with their JSON Schema counterparts

## Cannot run before Phase 4

Helm chart scaffold and CI pipeline must exist before service code is written.

## Correctness signal

`tooling/validate-contracts.sh` passes AND every invariant ID from `contracts/domain-invariants/{service}-invariants.md` has a named test that would fail if the invariant were violated.
```

- [ ] **Step 4: Write `skills/source/persona-compliance-agent.md`**

```markdown
---
name: chakraview:compliance-agent
type: persona
description: >
  Persona 6 — audit generated artifacts against architectural decisions and
  produce structured PASS/DEVIATION compliance reports
triggers:
  - infrastructure generation complete (Phase 4)
  - service implementation complete (Phase 5)
  - need to check agent output against ADRs before merging
phases: [4, 5]
personas: [6]
reads:
  - docs/adrs/
  - ai-agents/context/
  - contracts/slas/
  - infrastructure/helm/charts/
  - services/
writes:
  - ai-agents/reviews/
---

# Compliance Agent (Persona 6)

**Type**: LLM (auditor)
**Authority**: You surface deviations. You do not fix them. You have no implementation authority.

## What you produce

Write to `ai-agents/reviews/{phase}-compliance-{service}-{date}.md`:

```markdown
# Compliance Report: {phase} — {service} — {date}

**Status**: PASS | DEVIATION
**Persona reviewed**: Persona 4 | Persona 5
**ADRs consulted**: ...

## Checklist
| Check | Result | Notes |
|---|---|---|

## Deviations
### DEV-001 — {title}
**Classification**: intentional | unintentional
**ADR violated**: ...
**Location**: file:line
**Resolution**: ...
```

## Deviation classification

**Intentional**: artifact makes a deliberate architectural choice that differs from an existing ADR; cannot be explained by a misread spec. → Human Expert writes/amends an ADR; Compliance Agent runs a scoped second pass.

**Unintentional**: artifact contradicts a spec it was given; omits a required element; uses incorrect names or patterns. → Offending persona re-runs with this report as context.

When uncertain, prefer **intentional**.

## Phase 4 checklist (infrastructure)

- NetworkPolicy present in every Helm chart template
- IRSA-scoped ServiceAccount (no wildcard IAM)
- PodDisruptionBudget for services with min_replicas > 1
- Resource limits set on all containers
- No `hostNetwork: true` or `privileged: true`
- HPA maxReplicas consistent with SLA `peak_rps`
- Image from approved registry, not Docker Hub
- CI pipeline triggers on contract file changes

## Phase 5 checklist (implementation)

- No cross-service type imports in domain layer
- All domain mutations through aggregate root
- OTEL metric names match `observability-requirements.md` exactly
- Histogram buckets include SLA `latency_p99_ms / 1000` as a boundary
- Events published via outbox, not directly from command handlers
- Zero imports from `infrastructure/` in domain layer
- Every invariant ID has a named test
- CQRS read model not used as input to write decisions
- No dynamic types in domain layer
- Domain errors are named classes, not generic Error
```

- [ ] **Step 5: Write `skills/source/meta-workflow.md`**

```markdown
---
name: chakraview:workflow
type: meta
description: >
  Read current project state, identify the correct Chakraview workflow phase,
  and route to the right task skill
triggers:
  - unsure which phase to start in
  - beginning work on an existing chakraview project
  - need to orient to the current workflow position
phases: [0, 1, 2, 3, 4, 5, 6]
personas: [1, 2, 3, 4, 5, 6]
reads:
  - contracts/
  - docs/adrs/
  - ai-agents/tasks/
  - ai-agents/reviews/
writes: []
---

# Chakraview Workflow Router

## Core Principle

> **Humans are accountable for correctness. Agents are accountable for volume.**

Humans author *contracts* — versioned expressions of business intent. Agents implement from those contracts. Every artifact is traceable to a contract that authorised it.

## Phase Map

| Phase | Name | Entry condition | Skill |
|---|---|---|---|
| Intake | Intake / Triage | New business intent in any format | `chakraview:intake-triage` |
| 0 | Bootstrap | Contracts authored; baseline validation needed | Human + scripts |
| 1 | Architecture Foundation | Contracts complete; ADR stubs exist | `chakraview:write-adr` |
| 2 | Contract → Observability | ADRs accepted; SLO/alert generation needed | Scripts |
| 3 | Contract → API Contracts | Domain models exist | `chakraview:documentation-agent` |
| 4 | Contract → Infrastructure | API specs exist; Helm and CI needed | Scripts + `chakraview:compliance-review` |
| 5 | Contract → Implementation | Infra scaffold exists | `chakraview:implement-service` |
| 6 | Migration + Operations | Implementation complete | `chakraview:write-migration-phase`, `chakraview:write-runbook` |

## How to identify your current phase

```bash
ls contracts/                          # empty → start at Intake
ls docs/adrs/*.md 2>/dev/null | wc -l  # 0 → Phase 0/1
ls observability/slos/ 2>/dev/null     # empty → Phase 2 incomplete
ls services/ 2>/dev/null               # empty → Phase 5 not run
ls ai-agents/reviews/ 2>/dev/null      # empty → compliance not run
```

## Triage routing

| Intent | Action |
|---|---|
| New feature or service | `chakraview:intake-triage` |
| Architecture decision needed | `chakraview:write-adr` |
| Implementation needed | `chakraview:implement-service` |
| Compliance review needed | `chakraview:compliance-review` |
| Documentation / runbook needed | `chakraview:write-runbook` or `chakraview:write-migration-phase` |
| Deterministic transformation identified | `chakraview:script-authoring` |
```

- [ ] **Step 6: Run validation**

```bash
bash skills/tests/validate-sources.sh
```

Expected: `OK: 5 source skill files valid`

- [ ] **Step 7: Commit**

```bash
git add skills/source/
git commit -m "feat(skills): add persona skills and meta-workflow skill"
```

---

### Task 3: Task skills — intake-triage, implement-service, compliance-review

**Files:** Create `skills/source/task-intake-triage.md`, `task-implement-service.md`, `task-compliance-review.md`

- [ ] **Step 1: Write `skills/source/task-intake-triage.md`**

```markdown
---
name: chakraview:intake-triage
type: task
description: >
  Run the 4-persona intake/triage dialogue — surfaces architectural conflicts,
  edge cases, ADR needs, and scriptability before any contract is written
triggers:
  - starting a new feature or service
  - business intent needs review before contracts are written
  - intake or triage needed
phases: [0]
personas: [2, 3, 5, 6]
reads:
  - docs/adrs/
  - contracts/
  - docs/ddd/bounded-contexts.md
  - ai-agents/context/coding-standards.md
writes:
  - docs/intake/
  - contracts/slas/
  - contracts/domain-invariants/
  - contracts/event-schemas/
---

# Intake / Triage

Replace `{Feature Name}`, `{service}`, `{context}`, and `{path-to-intent}` with actual values.

## Goal

Analyse business intent through two persona rounds. Surface architectural concerns, ambiguities, and missing decisions before any contract is written. Produce an Intake Report, Draft Contracts, and a Triage Decision.

## Inputs (read all before responding)

| File | Why |
|---|---|
| `{path-to-intent}` | The raw business intent to analyse |
| `docs/adrs/` | Existing ADRs — check for conflicts and extension points |
| `contracts/` | Existing contracts — identify what changes and what is new |
| `docs/ddd/bounded-contexts.md` | Bounded context map |
| `ai-agents/context/coding-standards.md` | Constraints the implementation will inherit |

## Round 1a — You are the Compliance Agent

Read the business intent. Respond with direct questions (do not answer your own questions):

1. **ADR conflicts** — does this intent contradict or extend any existing ADR? Does the human need a new ADR stub before Phase 0?
2. **Bounded context boundary** — does this extend an existing context or require a new one?
3. **Data consistency risks** — for each implied shared state: which service owns it? Does that conflict with DB-per-service?
4. **Scope creep in ACs** — does any AC imply work the scope-out section excludes?

## Round 1b — You are the Implementation Agent

Read the business intent. Respond with direct questions:

1. **Pattern decisions** — is each mandated pattern an architectural decision (ADR required) or an implementation detail?
2. **Edge case gaps** — what happens at boundaries: unknown enum values, empty inputs, concurrent writes, max payload sizes?
3. **State ownership** — who owns each piece of mutable state? Synchronous or async?
4. **Data shape completeness** — which fields are optional vs required? What does omitting an optional field mean?

## Human Resolution — Round 1

Record each resolved decision before Round 2:

```
**Q:** {question asked}
**A:** {decision} — decided by {human | agent}
**Alternatives rejected:** {alternatives and why, or "none considered"}
```

Flag unresolved items as `⚠ UNRESOLVED: {question}`. Phase 0 cannot begin until all are closed.

## Round 2a — You are the Documentation Agent

Re-read the updated document (Round 1 resolutions included). Respond with direct questions:

1. **Ubiquitous language** — list any concept with more than one name; for each: the canonical term.
2. **ADR scope** — which Round 1 decisions need an ADR stub? Who authors the rationale?
3. **Runbook implications** — any new failure mode? Name it and the alert that triggers it.

## Round 2b — You are the Script Authoring Agent

Re-read the updated document. Respond with direct questions:

1. **Scriptability** — for each deterministic transformation: script name (`tooling/{name}`), inputs, output file.
2. **Validation needs** — for each new contract artifact: file path, format, `validate-contracts.sh` extension needed.
3. **Generation targets** — will Helm values, CI variables, or manifests reference new values in Phase 4?

## Human Resolution — Round 2

Same format as Round 1. Do not re-ask questions resolved in Round 1.

## Outputs

### Intake Report
Save to `docs/intake/{feature-slug}-intake-report.md`. Append `## Resolved Decisions` with all Q/A pairs.

### Draft Contracts
| File | Produced from |
|---|---|
| `contracts/slas/{service}-sla.yaml` | Latency, availability, throughput from intake |
| `contracts/domain-invariants/{context}-invariants.md` | Business rules from ACs and resolved edge cases |
| `contracts/event-schemas/{Event}.json` | If new domain events identified |

### Triage Decision
```yaml
classification: # new feature | contract patch | observability gap | infra change | implementation patch
entry_point: # Phase 0, 1, 2, 4, or 5
intake_dialogue: # full | round-1-only | none
adr_stubs_required: # yes | no
new_scripts_needed: # yes | no
draft_contracts:
  - # contracts/{path}
```

## Acceptance Criteria
- [ ] Round 1 questions from both agents present and addressed
- [ ] All Round 1 resolutions recorded before Round 2 begins
- [ ] Round 2 questions from both agents present and addressed
- [ ] Zero `⚠ UNRESOLVED` items remain
- [ ] Draft contracts present for human review
- [ ] Triage decision YAML complete
```

- [ ] **Step 2: Write `skills/source/task-implement-service.md`**

```markdown
---
name: chakraview:implement-service
type: task
description: >
  Phase 5 — synthesize service domain, application, and infrastructure layers
  from contracts; wire OTEL instrumentation from SLA targets
triggers:
  - Phase 5 entry — contracts, domain models, and infra scaffold all exist
  - implement a service from contracts
phases: [5]
personas: [5, 6]
reads:
  - contracts/domain-invariants/
  - contracts/event-schemas/
  - contracts/slas/
  - docs/ddd/
  - api/openapi/
  - ai-agents/context/coding-standards.md
  - ai-agents/context/observability-requirements.md
writes:
  - services/
---

# Implement Service

Replace `{service}`, `{Service Name}`, `{ext}`, `{EventName}`, `{typecheck command}`, `{test command}`, `{validation library}`, and `{event store}` with project-specific values.

## Goal

Produce the skeleton for the {Service Name} service: domain layer, application layer, and infrastructure layer. The implementation must correctly express all business invariants and be wired for SLA measurement via OpenTelemetry.

## Inputs (read all before writing a single line)

| File | Why |
|---|---|
| `contracts/domain-invariants/{service}-invariants.md` | Every invariant must be enforced in the aggregate |
| `contracts/event-schemas/{EventName}.json` | Event class must match this schema exactly |
| `contracts/slas/{service}-sla.yaml` | Histogram bucket boundaries and metric names |
| `docs/ddd/{service}/domain-model.md` | Aggregate structure, commands, state machine |
| `docs/ddd/{service}/state-machine.md` | State transition guard logic |
| `api/openapi/{service}-api-v1.yaml` | Route handler signatures |
| `ai-agents/context/coding-standards.md` | All code must follow these |
| `ai-agents/context/observability-requirements.md` | Required metrics, traces, logs |

## Outputs

```
services/{service}/src/
├── domain/
│   ├── {Aggregate}.{ext}
│   ├── {AggregateStatus}.{ext}
│   └── events/{EventName}.{ext}
├── application/{Action}Command.{ext}
└── infrastructure/
    ├── {Aggregate}Repository.{ext}
    ├── {EventBroker}EventPublisher.{ext}
    └── OtelInstrumentation.{ext}
services/{service}/tests/domain/{Aggregate}.test.{ext}
services/{service}/Dockerfile
```

## Constraints

1. **Typed events**: each event class structurally compatible with its JSON Schema. Use `{validation library}` for runtime validation.
2. **Invariant enforcement**: every invariant enforced before any event appended; violations throw a named domain error class.
3. **State machine**: status type implements the guard function from `state-machine.md`; no direct enum comparisons.
4. **OTEL**: histogram buckets include `latency_p99_ms` from SLA; metric names match `observability-requirements.md` exactly.
5. **No I/O in domain layer**: zero imports from `infrastructure/` in domain files.
6. **Outbox pattern**: events published from outbox, not directly from command handlers.

## Acceptance Criteria
- [ ] `{typecheck command}` passes with zero errors
- [ ] `{test command}` passes for all domain tests
- [ ] `tooling/validate-contracts.sh` passes
- [ ] No dynamic types in domain layer
```

- [ ] **Step 3: Write `skills/source/task-compliance-review.md`**

```markdown
---
name: chakraview:compliance-review
type: task
description: >
  Run the Persona 6 architectural compliance audit — compare generated artifacts
  against ADRs and produce a structured PASS/DEVIATION report
triggers:
  - infrastructure generation complete (after Phase 4)
  - service implementation complete (after Phase 5)
  - compliance review needed before merging
phases: [4, 5]
personas: [6]
reads:
  - docs/adrs/
  - ai-agents/context/
  - contracts/slas/
  - infrastructure/helm/charts/
  - services/
writes:
  - ai-agents/reviews/
---

# Architectural Compliance Review

Replace `{service}`, `{project}`, and `{phase}` before running.

## Goal

Compare generated artifacts against architectural decisions, principles, and coding standards. Produce a structured compliance report. **This task has no implementation authority** — it surfaces deviations, it does not fix them.

## Inputs

### Always required
| File | Why |
|---|---|
| `docs/adrs/` | Read every accepted ADR |
| `ai-agents/context/coding-standards.md` | Standards all output must follow |
| `ai-agents/context/infra-conventions.md` | IaC conventions (Phase 4 reviews) |
| `ai-agents/context/observability-requirements.md` | Required metrics and traces (Phase 5 reviews) |
| `contracts/slas/` | SLA targets that constrain HPA config, histogram buckets |

### Phase 4 — also read
All files under `infrastructure/helm/charts/{service}/templates/` and `.github/workflows/ci-{service}.yml`

### Phase 5 — also read
All files under `services/{service}/src/` and `services/{service}/tests/`
Also: `contracts/domain-invariants/{service}-invariants.md`

## Output

Write to `ai-agents/reviews/{phase}-compliance-{service}-{date}.md`.

List every check (even passing ones). For each deviation: file:line, ADR violated, classification, resolution.

## Phase 4 Checklist
| Check | Principle |
|---|---|
| NetworkPolicy in every Helm template | Principle 9 |
| IRSA-scoped ServiceAccount | Principle 9 |
| PodDisruptionBudget for min_replicas > 1 | Infrastructure ADR |
| Resource limits on all containers | Principle 9 |
| No hostNetwork/privileged | Principle 9 |
| HPA maxReplicas consistent with SLA peak_rps | contracts/slas/ |
| Image from approved registry | infra-conventions.md |
| CI triggers on contract file changes | CI/CD ADR |

## Phase 5 Checklist
| Check | Principle |
|---|---|
| No cross-service type imports in domain layer | DB-per-service ADR |
| All domain mutations through aggregate root | DDD |
| OTEL metric names match observability-requirements.md | Observability ADR |
| Histogram buckets include latency_p99_ms/1000 | contracts/slas/ |
| Events via outbox, not direct from command handlers | Event sourcing ADR |
| Zero infrastructure/ imports in domain layer | coding-standards.md |
| Every invariant ID has a named test | CI/CD ADR |
| CQRS read model not used in write decisions | CQRS ADR |
| No dynamic types in domain layer | coding-standards.md |
| Domain errors are named classes | coding-standards.md |

## Classification Guide

**Intentional**: deliberate choice differing from an ADR; would require a senior engineer to make the same tradeoff knowingly. → Human Expert writes/amends ADR before merge.

**Unintentional**: contradicts a spec it was given; omits a required element; incorrect name or pattern. → Offending persona re-runs with this report as context.

When uncertain, prefer **intentional**.

## Acceptance Criteria
- [ ] Every checklist item appears in report (pass or deviation)
- [ ] Every deviation has a file:line location
- [ ] Every intentional deviation names a specific ADR to write or amend
- [ ] Every unintentional deviation names the persona to re-run and the specific input
- [ ] Status is PASS only if zero deviations
```

- [ ] **Step 4: Run validation**

```bash
bash skills/tests/validate-sources.sh
```

Expected: `OK: 8 source skill files valid`

- [ ] **Step 5: Commit**

```bash
git add skills/source/task-intake-triage.md skills/source/task-implement-service.md skills/source/task-compliance-review.md
git commit -m "feat(skills): add intake-triage, implement-service, compliance-review task skills"
```

---

### Task 4: Task skills — write-adr, write-runbook, write-migration-phase, script-authoring

**Files:** Create `skills/source/task-write-adr.md`, `task-write-runbook.md`, `task-write-migration-phase.md`, `task-script-authoring.md`

- [ ] **Step 1: Write `skills/source/task-write-adr.md`**

```markdown
---
name: chakraview:write-adr
type: task
description: >
  Phase 1 — expand a human-authored ADR stub into a complete MADR with
  rationale, rejected alternatives, and split consequences
triggers:
  - ADR stub exists and needs to be expanded
  - architectural decision needs to be documented
  - write-adr mentioned
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
| `contracts/domain-invariants/{service}-invariants.md` | Constraints the decision must respect |
| All accepted ADRs in `docs/adrs/` | Decisions must not contradict accepted ADRs |

## Output

```
docs/adrs/{adr-number}-{decision-title}.md
```

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
```

- [ ] **Step 2: Write `skills/source/task-write-runbook.md`**

```markdown
---
name: chakraview:write-runbook
type: task
description: >
  Phase 6 — produce an operational runbook for a specific failure mode,
  executable by an on-call engineer at 3am with no additional context
triggers:
  - SLA and alerts exist; runbook needed for a failure mode
  - Phase 6 operations documentation
  - write-runbook mentioned
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

Replace `{service}`, `{failure-mode}`, and `{alert-name}` before running.

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

1. **Exact alert name in title**: must match the name in `observability/alerts/{service}-burnrate.yaml`. On-call engineers find this runbook via the alert's `runbook_url` annotation.
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
```

- [ ] **Step 3: Write `skills/source/task-write-migration-phase.md`**

```markdown
---
name: chakraview:write-migration-phase
type: task
description: >
  Phase 6 — write a migration phase document covering what changes, what risks
  exist, how to validate cutover, and how to roll back if it fails
triggers:
  - Phase 6 entry — implementation complete, migration sequencing needed
  - write-migration-phase mentioned
phases: [6]
personas: [2]
reads:
  - docs/migration/strategy.md
  - docs/adrs/
  - contracts/slas/
  - observability/slos/
  - contracts/domain-invariants/
  - docs/ddd/bounded-contexts.md
writes:
  - docs/migration/
---

# Write Migration Phase Document

Replace `{phase-number}`, `{phase-name}`, and `{service}` before running.

## Goal

Produce a migration phase document for extracting `{service}`. Cover: what changes, what risks exist, how to validate the cutover, and how to roll back if it fails.

## Inputs (read all before writing)

| File | Why |
|---|---|
| `docs/migration/strategy.md` | This phase must fit the overall strategy |
| `docs/adrs/` | All accepted ADRs — the phase must not violate any |
| `contracts/slas/{service}-sla.yaml` | SLA targets constrain go/no-go criteria |
| `observability/slos/{service}-slo.yaml` | SLO definitions that must be hit before cutover |
| `contracts/domain-invariants/{service}-invariants.md` | Invariants that must hold throughout migration |
| `docs/ddd/bounded-contexts.md` | Dependencies affect sequencing |

## Output

```
docs/migration/phase-{phase-number}-{phase-name}.md
```

## Constraints

1. **Rollback gate is mandatory**: explicit go/no-go criteria — observable, measurable signals. Rollback procedure specific enough to execute without asking anyone.
2. **Risk per step**: each migration step identifies its primary risk and mitigation.
3. **Traffic routing explicit**: document which routing component changes and traffic split percentages at each step.
4. **Data migration steps reversible**: every data step has a corresponding reversion step.
5. **SLA impact documented**: expected SLA impact during cutover and monitoring procedure to confirm recovery.

## Acceptance Criteria
- [ ] Rollback procedure complete (executable without additional context)
- [ ] Go/no-go criteria are measurable (queryable metrics or test commands)
- [ ] Every migration step has an identified risk and mitigation
- [ ] Phase fits strategy in `docs/migration/strategy.md`
- [ ] SLA impact and recovery monitoring documented
```

- [ ] **Step 4: Write `skills/source/task-script-authoring.md`**

```markdown
---
name: chakraview:script-authoring
type: task
description: >
  Write a deterministic transformation script for tooling/ — authored once by
  the agent, executed forever by CI
triggers:
  - deterministic transformation identified — structured input to structured output
  - need a script to generate alerts, Helm charts, CI pipelines, or CODEOWNERS
  - script-authoring needed
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
2. **No judgment**: if the script needs to make a decision, the input spec is incomplete — surface the gap.
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
```

- [ ] **Step 5: Run validation**

```bash
bash skills/tests/validate-sources.sh
```

Expected: `OK: 12 source skill files valid`

- [ ] **Step 6: Commit**

```bash
git add skills/source/task-write-adr.md skills/source/task-write-runbook.md skills/source/task-write-migration-phase.md skills/source/task-script-authoring.md
git commit -m "feat(skills): add write-adr, write-runbook, write-migration-phase, script-authoring task skills"
```

---

### Task 5: Context files + platform configs

**Files:** Copy 3 context files; create 6 platform config files.

- [ ] **Step 1: Copy context files from templates**

```bash
cp templates/context/coding-standards.md       skills/source/context/coding-standards.md
cp templates/context/infra-conventions.md      skills/source/context/infra-conventions.md
cp templates/context/observability-requirements.md skills/source/context/observability-requirements.md
```

- [ ] **Step 2: Write `skills/platforms/claude-code/plugin.json`**

```json
{
  "namespace": "chakraview",
  "skills": {
    "chakraview:workflow": "workflow",
    "chakraview:intake-triage": "intake-triage",
    "chakraview:implement-service": "implement-service",
    "chakraview:compliance-review": "compliance-review",
    "chakraview:write-adr": "write-adr",
    "chakraview:write-runbook": "write-runbook",
    "chakraview:write-migration-phase": "write-migration-phase",
    "chakraview:script-authoring": "script-authoring",
    "chakraview:documentation-agent": "documentation-agent",
    "chakraview:script-authoring-agent": "script-authoring-agent",
    "chakraview:implementation-agent": "implementation-agent",
    "chakraview:compliance-agent": "compliance-agent"
  }
}
```

- [ ] **Step 3: Write Cursor and Windsurf defaults**

`skills/platforms/cursor/defaults.yaml`:
```yaml
alwaysApply: false
globs: []
```

`skills/platforms/windsurf/defaults.yaml`:
```yaml
alwaysApply: false
globs: []
```

- [ ] **Step 4: Write platform preambles**

`skills/platforms/copilot/preamble.md`:
```markdown
This project uses the Chakraview AI Dev Model — a contracts-first development methodology
where humans author contracts (correctness) and AI agents implement from those contracts (volume).
The skills below define the personas and task workflows. Invoke the relevant skill when the user's
request matches a skill's trigger conditions.
```

`skills/platforms/codex/preamble.md`:
```markdown
This repository follows the Chakraview AI Dev Model. Humans author contracts; agents implement
from contracts. The skills below define the agent personas and task workflows available in this
project. Follow the relevant skill when a task matches its trigger conditions.
```

`skills/platforms/gemini/preamble.md`:
```markdown
This project follows the Chakraview AI Dev Model — a contracts-first SDLC where human-authored
contracts (SLAs, domain invariants, event schemas, ADRs) are the only inputs agents may trust.
The skills below define the personas and workflow phases. Follow the relevant skill when the
user's request matches its trigger conditions.
```

- [ ] **Step 5: Commit**

```bash
git add skills/source/context/ skills/platforms/
git commit -m "feat(skills): add context files and platform configs"
```

---

### Task 6: scaffold.sh + tests

**Files:** Create `skills/tests/test-scaffold.sh`, `skills/scaffold.sh`

- [ ] **Step 1: Write `skills/tests/test-scaffold.sh`**

```bash
#!/usr/bin/env bash
set -euo pipefail
SKILLS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TMP=$(mktemp -d)
ERRORS=0
cleanup() { rm -rf "$TMP"; }
trap cleanup EXIT

"$SKILLS_DIR/scaffold.sh" --project-dir "$TMP"

for dir in contracts/slas contracts/domain-invariants contracts/event-schemas \
           docs/adrs docs/ddd ai-agents/tasks ai-agents/context ai-agents/reviews; do
  if [[ ! -d "$TMP/$dir" ]]; then
    echo "FAIL: $dir not created"; ERRORS=$((ERRORS+1))
  else
    echo "OK: $dir"
  fi
done

# Idempotency: re-run must not fail
"$SKILLS_DIR/scaffold.sh" --project-dir "$TMP"
echo "OK: re-run idempotent"

# Must not overwrite existing files
echo "existing" > "$TMP/contracts/slas/keep.yaml"
"$SKILLS_DIR/scaffold.sh" --project-dir "$TMP"
[[ "$(cat "$TMP/contracts/slas/keep.yaml")" == "existing" ]] && echo "OK: existing file preserved" || { echo "FAIL: file overwritten"; ERRORS=$((ERRORS+1)); }

[[ $ERRORS -gt 0 ]] && echo "$ERRORS error(s)" && exit 1
echo "scaffold.sh: all tests passed"
```

- [ ] **Step 2: Run to verify it fails**

```bash
chmod +x skills/tests/test-scaffold.sh
bash skills/tests/test-scaffold.sh
```

Expected: `scaffold.sh: No such file or directory`

- [ ] **Step 3: Write `skills/scaffold.sh`**

```bash
#!/usr/bin/env bash
# Creates the Chakraview project directory structure. Idempotent.
set -euo pipefail

PROJECT_DIR="${PWD}"
while [[ $# -gt 0 ]]; do
  case "$1" in
    --project-dir) PROJECT_DIR="$2"; shift 2 ;;
    *) echo "Unknown flag: $1"; exit 1 ;;
  esac
done

DIRS=(
  contracts/slas contracts/domain-invariants contracts/event-schemas
  docs/adrs docs/ddd docs/intake docs/migration docs/runbooks
  ai-agents/tasks ai-agents/context ai-agents/reviews
  tooling services infrastructure/helm/charts
  observability/slos observability/alerts
  api/openapi api/asyncapi
)

for dir in "${DIRS[@]}"; do
  target="$PROJECT_DIR/$dir"
  if [[ ! -d "$target" ]]; then
    mkdir -p "$target"
    touch "$target/.gitkeep"
    echo "Created $dir/"
  fi
done

echo "Scaffold complete in $PROJECT_DIR"
```

- [ ] **Step 4: Run test**

```bash
chmod +x skills/scaffold.sh
bash skills/tests/test-scaffold.sh
```

Expected: `scaffold.sh: all tests passed`

- [ ] **Step 5: Commit**

```bash
git add skills/scaffold.sh skills/tests/test-scaffold.sh
git commit -m "feat(skills): add scaffold.sh with tests"
```

---

### Task 7: install.sh — shared utilities + Claude Code + context file install

**Files:** Create `skills/tests/test-install-claude.sh`, `skills/install.sh`

- [ ] **Step 1: Write `skills/tests/test-install-claude.sh`**

```bash
#!/usr/bin/env bash
set -euo pipefail
SKILLS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TMP_HOME=$(mktemp -d); TMP_PROJECT=$(mktemp -d)
ERRORS=0
cleanup() { rm -rf "$TMP_HOME" "$TMP_PROJECT"; }
trap cleanup EXIT

mkdir -p "$TMP_HOME/.claude"
HOME="$TMP_HOME"

"$SKILLS_DIR/install.sh" --target claude-code --project-dir "$TMP_PROJECT"

for slug in workflow intake-triage implement-service compliance-review write-adr \
            write-runbook write-migration-phase script-authoring \
            documentation-agent script-authoring-agent implementation-agent compliance-agent; do
  dest="$TMP_HOME/.claude/skills/chakraview/$slug/SKILL.md"
  if [[ ! -f "$dest" ]]; then
    echo "FAIL: $dest not created"; ERRORS=$((ERRORS+1))
  elif ! grep -q "^name: chakraview:$slug" "$dest"; then
    echo "FAIL: $dest missing name field"; ERRORS=$((ERRORS+1))
  else
    echo "OK: $slug"
  fi
done

# Context files must be installed to project
for ctx in coding-standards.md infra-conventions.md observability-requirements.md; do
  if [[ ! -f "$TMP_PROJECT/ai-agents/context/$ctx" ]]; then
    echo "FAIL: context/$ctx not installed to project"; ERRORS=$((ERRORS+1))
  else
    echo "OK: context/$ctx"
  fi
done

# dry-run must not write
TMP_HOME2=$(mktemp -d); mkdir -p "$TMP_HOME2/.claude"; HOME="$TMP_HOME2"
"$SKILLS_DIR/install.sh" --target claude-code --project-dir "$TMP_PROJECT" --dry-run
[[ ! -d "$TMP_HOME2/.claude/skills" ]] && echo "OK: --dry-run did not write" || { echo "FAIL: --dry-run wrote files"; ERRORS=$((ERRORS+1)); }
rm -rf "$TMP_HOME2"

[[ $ERRORS -gt 0 ]] && echo "$ERRORS error(s)" && exit 1
echo "install.sh --target claude-code: all tests passed"
```

- [ ] **Step 2: Run to verify it fails**

```bash
chmod +x skills/tests/test-install-claude.sh
bash skills/tests/test-install-claude.sh
```

Expected: `install.sh: No such file or directory`

- [ ] **Step 3: Write `skills/install.sh`**

```bash
#!/usr/bin/env bash
# Chakraview skills installer.
# Usage: ./install.sh [--target <platform>] [--project-dir <dir>] [--init] [--dry-run]
set -euo pipefail

SKILLS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOURCE_DIR="$SKILLS_DIR/source"
PLATFORMS_DIR="$SKILLS_DIR/platforms"
PROJECT_DIR="${PWD}"
DRY_RUN=false
TARGET=""
RUN_INIT=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    --target)      TARGET="$2";      shift 2 ;;
    --project-dir) PROJECT_DIR="$2"; shift 2 ;;
    --dry-run)     DRY_RUN=true;     shift   ;;
    --init)        RUN_INIT=true;    shift   ;;
    *) echo "Unknown flag: $1"; exit 1 ;;
  esac
done

# ── helpers ───────────────────────────────────────────────────────────────────

get_fm() {
  local file="$1" field="$2"
  awk -v f="$field" 'BEGIN{c=0} /^---/{c++;next} c==1 && $0~"^"f":"{sub("^"f":[ ]*","");print;exit}' "$file"
}

strip_fm() {
  local file="$1"
  awk 'BEGIN{c=0} /^---/{c++;next} c>=2{print}' "$file"
}

write_file() {
  local dest="$1" src="$2"
  if [[ "$DRY_RUN" == true ]]; then echo "[dry-run] Would write $dest"; return; fi
  mkdir -p "$(dirname "$dest")"
  cp "$src" "$dest"
  echo "  Wrote $(basename "$dest")"
}

confirm() { read -r -p "$1 [y/N] " r; [[ "$r" =~ ^[Yy]$ ]]; }

# ── platform detection ────────────────────────────────────────────────────────
detect_claude_code() { [[ -d "$HOME/.claude" ]]; }
detect_cursor()      { [[ -d "$PROJECT_DIR/.cursor" ]]   || command -v cursor   &>/dev/null; }
detect_windsurf()    { [[ -d "$PROJECT_DIR/.windsurf" ]]  || command -v windsurf &>/dev/null; }
detect_copilot()     { [[ -d "$PROJECT_DIR/.github" ]]; }
detect_codex()       { [[ -f "$PROJECT_DIR/AGENTS.md" ]]  || command -v openai  &>/dev/null; }
detect_gemini()      { [[ -d "$PROJECT_DIR/.gemini" ]]    || command -v gemini  &>/dev/null; }

# ── ordered source file list ──────────────────────────────────────────────────
source_files() {
  for f in \
    "$SOURCE_DIR"/meta-workflow.md \
    "$SOURCE_DIR"/task-intake-triage.md \
    "$SOURCE_DIR"/task-implement-service.md \
    "$SOURCE_DIR"/task-compliance-review.md \
    "$SOURCE_DIR"/task-write-adr.md \
    "$SOURCE_DIR"/task-write-runbook.md \
    "$SOURCE_DIR"/task-write-migration-phase.md \
    "$SOURCE_DIR"/task-script-authoring.md \
    "$SOURCE_DIR"/persona-documentation-agent.md \
    "$SOURCE_DIR"/persona-script-authoring-agent.md \
    "$SOURCE_DIR"/persona-implementation-agent.md \
    "$SOURCE_DIR"/persona-compliance-agent.md; do
    [[ -f "$f" ]] && echo "$f"
  done
}

# ── context file install (all platforms) ─────────────────────────────────────
install_context_files() {
  local ctx_src="$SOURCE_DIR/context"
  local ctx_dest="$PROJECT_DIR/ai-agents/context"
  [[ -d "$ctx_src" ]] || return 0
  if [[ "$DRY_RUN" == true ]]; then
    echo "[dry-run] Would copy context files to $ctx_dest"
    return
  fi
  mkdir -p "$ctx_dest"
  for f in "$ctx_src"/*.md; do
    [[ -f "$f" ]] || continue
    local dest="$ctx_dest/$(basename "$f")"
    [[ -f "$dest" ]] || { cp "$f" "$dest"; echo "  Wrote ai-agents/context/$(basename "$f")"; }
  done
}

# ── Claude Code adapter ───────────────────────────────────────────────────────
install_claude_code() {
  local root="$HOME/.claude/skills/chakraview"
  echo "→ Claude Code: $root"
  [[ "$DRY_RUN" == false ]] && ! confirm "  Install to $root?" && return
  install_context_files
  while IFS= read -r f; do
    local name slug
    name=$(get_fm "$f" "name"); slug="${name#chakraview:}"
    write_file "$root/$slug/SKILL.md" "$f"
  done < <(source_files)
  echo "  Claude Code install complete."
}

# ── Cursor adapter ────────────────────────────────────────────────────────────
install_cursor() {
  local rules="$PROJECT_DIR/.cursor/rules"
  echo "→ Cursor: $rules"
  [[ "$DRY_RUN" == false ]] && ! confirm "  Install to $rules?" && return
  install_context_files
  local tmp; tmp=$(mktemp)
  while IFS= read -r f; do
    local name slug desc
    name=$(get_fm "$f" "name"); slug="${name#chakraview:}"; desc=$(get_fm "$f" "description")
    { echo "---"; echo "description: \"$name — $desc\""; echo "alwaysApply: false"; echo "---"; echo ""; strip_fm "$f"; } > "$tmp"
    write_file "$rules/chakraview-$slug.mdc" "$tmp"
  done < <(source_files)
  rm -f "$tmp"
  echo "  Cursor install complete."
}

# ── Windsurf adapter ──────────────────────────────────────────────────────────
install_windsurf() {
  local rules="$PROJECT_DIR/.windsurf/rules"
  echo "→ Windsurf: $rules"
  [[ "$DRY_RUN" == false ]] && ! confirm "  Install to $rules?" && return
  install_context_files
  local tmp; tmp=$(mktemp)
  while IFS= read -r f; do
    local name slug desc
    name=$(get_fm "$f" "name"); slug="${name#chakraview:}"; desc=$(get_fm "$f" "description")
    { echo "---"; echo "description: \"$name — $desc\""; echo "alwaysApply: false"; echo "---"; echo ""; strip_fm "$f"; } > "$tmp"
    write_file "$rules/chakraview-$slug.md" "$tmp"
  done < <(source_files)
  rm -f "$tmp"
  echo "  Windsurf install complete."
}

# ── aggregate helpers ─────────────────────────────────────────────────────────
SENTINEL_START="<!-- Generated by chakraview install.sh — do not edit manually -->"
SENTINEL_END="<!-- /Generated by chakraview -->"

generate_block() {
  local platform="$1"
  local preamble="$PLATFORMS_DIR/$platform/preamble.md"
  echo "$SENTINEL_START"; echo ""
  [[ -f "$preamble" ]] && cat "$preamble" && echo ""
  while IFS= read -r f; do
    echo "## $(get_fm "$f" "name")"; echo ""; strip_fm "$f"; echo ""; echo "---"; echo ""
  done < <(source_files)
  echo "$SENTINEL_END"
}

replace_block() {
  local file="$1" new_block="$2"
  local tmp; tmp=$(mktemp)
  awk -v start="$SENTINEL_START" -v end="$SENTINEL_END" -v nb="$new_block" '
    $0==start { in_b=1; while((getline line < nb)>0){print line}; close(nb); next }
    $0==end   { if(in_b){in_b=0;next} }
    in_b      { next }
    { print }
  ' "$file" > "$tmp"
  mv "$tmp" "$file"
}

install_aggregate() {
  local platform="$1" dest="$2"
  echo "→ $platform: $dest"
  [[ "$DRY_RUN" == false ]] && ! confirm "  Install to $dest?" && return
  if [[ "$DRY_RUN" == true ]]; then echo "[dry-run] Would write/update $dest"; return; fi
  install_context_files
  local block; block=$(mktemp)
  generate_block "$platform" > "$block"
  mkdir -p "$(dirname "$dest")"
  if [[ -f "$dest" ]] && grep -qF "$SENTINEL_START" "$dest"; then
    replace_block "$dest" "$block"; echo "  Updated $dest (sentinel replaced)"
  else
    cat "$block" >> "$dest"; echo "  Wrote $dest"
  fi
  rm -f "$block"
  echo "  $platform install complete."
}

install_copilot() { install_aggregate "copilot" "$PROJECT_DIR/.github/copilot-instructions.md"; }
install_codex()   { install_aggregate "codex"   "$PROJECT_DIR/AGENTS.md"; }
install_gemini()  { install_aggregate "gemini"  "$PROJECT_DIR/GEMINI.md"; }

# ── dispatch ──────────────────────────────────────────────────────────────────
run_platform() {
  case "$1" in
    claude-code) install_claude_code ;;
    cursor)      install_cursor      ;;
    windsurf)    install_windsurf    ;;
    copilot)     install_copilot     ;;
    codex)       install_codex       ;;
    gemini)      install_gemini      ;;
    *) echo "Unknown platform: $1"; exit 1 ;;
  esac
}

detect_platform() {
  case "$1" in
    claude-code) detect_claude_code ;;
    cursor)      detect_cursor      ;;
    windsurf)    detect_windsurf    ;;
    copilot)     detect_copilot     ;;
    codex)       detect_codex       ;;
    gemini)      detect_gemini      ;;
    *) return 1 ;;
  esac
}

[[ "$RUN_INIT" == true ]] && "$SKILLS_DIR/scaffold.sh" --project-dir "$PROJECT_DIR"

if [[ -n "$TARGET" ]]; then
  run_platform "$TARGET"
else
  echo "Auto-detecting installed platforms..."
  FOUND=0
  for p in claude-code cursor windsurf copilot codex gemini; do
    if detect_platform "$p" 2>/dev/null; then
      FOUND=$((FOUND+1)); run_platform "$p"
    fi
  done
  if [[ $FOUND -eq 0 ]]; then
    echo "No platforms detected. Use --target <platform> to install manually."
    echo "Platforms: claude-code cursor windsurf copilot codex gemini"
    exit 1
  fi
fi
```

- [ ] **Step 4: Make executable and run Claude Code test**

```bash
chmod +x skills/install.sh
bash skills/tests/test-install-claude.sh
```

Expected: `install.sh --target claude-code: all tests passed`

- [ ] **Step 5: Commit**

```bash
git add skills/install.sh skills/tests/test-install-claude.sh
git commit -m "feat(skills): add install.sh — full implementation with all platform adapters"
```

---

### Task 8: Cursor, Windsurf, and aggregate platform tests

**Files:** Create `skills/tests/test-install-cursor.sh`, `skills/tests/test-install-aggregate.sh`

- [ ] **Step 1: Write `skills/tests/test-install-cursor.sh`**

```bash
#!/usr/bin/env bash
set -euo pipefail
SKILLS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SLUGS=(workflow intake-triage implement-service compliance-review write-adr write-runbook write-migration-phase script-authoring documentation-agent script-authoring-agent implementation-agent compliance-agent)
ERRORS=0

# Cursor
TMP=$(mktemp -d); mkdir -p "$TMP/.cursor"; trap "rm -rf $TMP" EXIT
"$SKILLS_DIR/install.sh" --target cursor --project-dir "$TMP"
for slug in "${SLUGS[@]}"; do
  dest="$TMP/.cursor/rules/chakraview-$slug.mdc"
  if [[ ! -f "$dest" ]]; then
    echo "FAIL cursor: $slug not created"; ERRORS=$((ERRORS+1))
  elif ! grep -q "^description:" "$dest" || ! grep -q "^alwaysApply:" "$dest"; then
    echo "FAIL cursor: $slug missing frontmatter"; ERRORS=$((ERRORS+1))
  else
    echo "OK cursor: $slug"
  fi
done

# Windsurf
TMP2=$(mktemp -d); mkdir -p "$TMP2/.windsurf"
"$SKILLS_DIR/install.sh" --target windsurf --project-dir "$TMP2"
for slug in "${SLUGS[@]}"; do
  [[ -f "$TMP2/.windsurf/rules/chakraview-$slug.md" ]] && echo "OK windsurf: $slug" || { echo "FAIL windsurf: $slug"; ERRORS=$((ERRORS+1)); }
done
rm -rf "$TMP2"

[[ $ERRORS -gt 0 ]] && echo "$ERRORS error(s)" && exit 1
echo "Cursor/Windsurf: all tests passed"
```

- [ ] **Step 2: Write `skills/tests/test-install-aggregate.sh`**

```bash
#!/usr/bin/env bash
set -euo pipefail
SKILLS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ERRORS=0

run_test() {
  local platform="$1" flag_dir="$2" dest_rel="$3"
  local TMP; TMP=$(mktemp -d)
  mkdir -p "$TMP/$flag_dir"
  "$SKILLS_DIR/install.sh" --target "$platform" --project-dir "$TMP"
  local dest="$TMP/$dest_rel"
  if [[ ! -f "$dest" ]]; then
    echo "FAIL [$platform]: $dest not created"; ERRORS=$((ERRORS+1)); rm -rf "$TMP"; return
  fi
  grep -qF "<!-- Generated by chakraview" "$dest"  || { echo "FAIL [$platform]: missing start sentinel"; ERRORS=$((ERRORS+1)); }
  grep -qF "<!-- /Generated by chakraview -->" "$dest" || { echo "FAIL [$platform]: missing end sentinel"; ERRORS=$((ERRORS+1)); }
  grep -q "## chakraview:workflow" "$dest"         || { echo "FAIL [$platform]: missing workflow section"; ERRORS=$((ERRORS+1)); }

  # Sentinel update preserves user content
  echo -e "\n## My custom section\nkeep me" >> "$dest"
  "$SKILLS_DIR/install.sh" --target "$platform" --project-dir "$TMP"
  grep -q "## My custom section" "$dest" && echo "OK [$platform]: user content preserved" || { echo "FAIL [$platform]: user content removed on update"; ERRORS=$((ERRORS+1)); }

  rm -rf "$TMP"
}

run_test copilot ".github"  ".github/copilot-instructions.md"
run_test codex   "."        "AGENTS.md"
run_test gemini  "."        "GEMINI.md"

[[ $ERRORS -gt 0 ]] && echo "$ERRORS error(s)" && exit 1
echo "Aggregate platforms: all tests passed"
```

- [ ] **Step 3: Run all tests**

```bash
chmod +x skills/tests/test-install-cursor.sh skills/tests/test-install-aggregate.sh
bash skills/tests/test-install-cursor.sh
bash skills/tests/test-install-aggregate.sh
```

Expected: both print "all tests passed"

- [ ] **Step 4: Run full test suite**

```bash
bash skills/tests/validate-sources.sh
bash skills/tests/test-scaffold.sh
bash skills/tests/test-install-claude.sh
bash skills/tests/test-install-cursor.sh
bash skills/tests/test-install-aggregate.sh
```

All five should succeed.

- [ ] **Step 5: Commit**

```bash
git add skills/tests/test-install-cursor.sh skills/tests/test-install-aggregate.sh
git commit -m "feat(skills): add Cursor, Windsurf, and aggregate platform tests"
```

---

### Task 9: Auto-detection integration test + README

**Files:** Create `skills/tests/test-install-autodetect.sh`, `skills/README.md`

- [ ] **Step 1: Write `skills/tests/test-install-autodetect.sh`**

```bash
#!/usr/bin/env bash
set -euo pipefail
SKILLS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TMP_HOME=$(mktemp -d); TMP_PROJECT=$(mktemp -d)
ERRORS=0
cleanup() { rm -rf "$TMP_HOME" "$TMP_PROJECT"; }
trap cleanup EXIT

mkdir -p "$TMP_HOME/.claude" "$TMP_PROJECT/.cursor" "$TMP_PROJECT/.github"
HOME="$TMP_HOME"

"$SKILLS_DIR/install.sh" --project-dir "$TMP_PROJECT"

[[ -d "$TMP_HOME/.claude/skills/chakraview" ]] && echo "OK: Claude Code" || { echo "FAIL: Claude Code not installed"; ERRORS=$((ERRORS+1)); }
[[ -d "$TMP_PROJECT/.cursor/rules" ]]          && echo "OK: Cursor"      || { echo "FAIL: Cursor not installed";     ERRORS=$((ERRORS+1)); }
[[ -f "$TMP_PROJECT/.github/copilot-instructions.md" ]] && echo "OK: Copilot" || { echo "FAIL: Copilot not installed"; ERRORS=$((ERRORS+1)); }

[[ $ERRORS -gt 0 ]] && echo "$ERRORS error(s)" && exit 1
echo "Auto-detection: all tests passed"
```

- [ ] **Step 2: Run**

```bash
chmod +x skills/tests/test-install-autodetect.sh
bash skills/tests/test-install-autodetect.sh
```

Expected: `Auto-detection: all tests passed`

- [ ] **Step 3: Write `skills/README.md`**

```markdown
# Chakraview AI Dev Model — Skills Plugin

Installable AI agent skills for the [Chakraview AI Dev Model](../docs/model.md).
Supports Claude Code, Cursor, Windsurf, GitHub Copilot, OpenAI Codex, and Gemini CLI.

## Quickstart

```bash
cd chakraview-ai-dev-model/skills
./install.sh --init   # install skills + scaffold project structure
```

`--init` creates `contracts/`, `docs/adrs/`, `ai-agents/`, etc. in the current directory.

## Options

```bash
./install.sh --target claude-code              # single platform
./install.sh --target cursor --project-dir /path/to/project
./install.sh --dry-run                         # preview without writing
```

Platforms: `claude-code` · `cursor` · `windsurf` · `copilot` · `codex` · `gemini`

## Invocation per platform

| Platform | How to invoke |
|---|---|
| Claude Code | `chakraview:intake-triage` via Skill tool |
| Cursor | `@chakraview-intake-triage` in chat |
| Windsurf | `@chakraview-intake-triage` in chat |
| Copilot / Codex / Gemini | Reference skill by name in chat |

## Skill reference

| Skill | When to use |
|---|---|
| `chakraview:workflow` | Orient to the current phase and route to the right skill |
| `chakraview:intake-triage` | Before any contract is written — new feature or service |
| `chakraview:implement-service` | Phase 5 — contracts and domain models exist |
| `chakraview:compliance-review` | After Phase 4 (infra) or Phase 5 (implementation) |
| `chakraview:write-adr` | Expand an ADR stub into a full MADR |
| `chakraview:write-runbook` | Produce an ops runbook for a failure mode |
| `chakraview:write-migration-phase` | Phase 6 migration sequencing |
| `chakraview:script-authoring` | Write a deterministic `tooling/` script |
| `chakraview:documentation-agent` | Persona 2 — prose, ADRs, API specs |
| `chakraview:script-authoring-agent` | Persona 3 — deterministic scripts only |
| `chakraview:implementation-agent` | Persona 5 — service source code |
| `chakraview:compliance-agent` | Persona 6 — audit only, no implementation authority |

## Updating

Re-run `./install.sh` after pulling. For Copilot/Codex/Gemini the generated block is replaced in place; your custom content outside the sentinels is preserved.

## Adding a skill

1. Add a file to `source/` with the required frontmatter (`name`, `type`, `description`, `triggers`)
2. Run `./tests/validate-sources.sh` to verify it passes validation
3. Run `./install.sh` to distribute it
```

- [ ] **Step 4: Run the complete test suite one final time**

```bash
bash skills/tests/validate-sources.sh
bash skills/tests/test-scaffold.sh
bash skills/tests/test-install-claude.sh
bash skills/tests/test-install-cursor.sh
bash skills/tests/test-install-aggregate.sh
bash skills/tests/test-install-autodetect.sh
```

All six should succeed.

- [ ] **Step 5: Final commit**

```bash
git add skills/tests/test-install-autodetect.sh skills/README.md
git commit -m "feat(skills): add auto-detection test and README — skills plugin complete"
```
