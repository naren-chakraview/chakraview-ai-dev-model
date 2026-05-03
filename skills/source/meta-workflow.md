---
name: chakraview:workflow
type: meta
description: >
  Read current project state, identify the correct Chakraview workflow phase,
  and route to the right task skill
triggers: [unsure which phase to start in, beginning work on an existing chakraview project, need to orient to the current workflow position]
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
