---
title: Contracts
description: What contracts are, why they are the boundary between human and agent.
---

# Contracts

## What Humans Author

Contracts are the human-authored source of truth. They are the only inputs agents are permitted to trust. Every contract artifact must be:

- **Versioned** in source control alongside the code it governs
- **Owned** by a human (or a human-approved review gate) — no agent may modify a contract
- **Complete before implementation begins** — an agent that starts before a contract exists will hallucinate domain behaviour

| Contract type | Why a human, not an agent |
|---|---|
| SLA targets | Business commitment to users; requires stakeholder negotiation |
| Domain invariants | Business rules that encode years of operational learning |
| Event schemas | The shared language between teams; breaking changes have production consequences |
| Architecture Decision Records | Tradeoff reasoning requires context, history, and judgment |
| Bounded context maps | Organisational and domain boundaries are political as much as technical |
| Migration phase docs | Risk sequencing requires knowledge of operational constraints and team capacity |
| Agent task specs | The spec is itself the human judgment artifact — it defines what "correct" means |

## What AI Agents Build

Agents consume contracts to produce implementation artifacts. Every agent output is traceable to one or more contracts that authorised it.

| Artifact type | Consumed contracts |
|---|---|
| Service domain logic | Domain invariants, domain models |
| Typed event classes | Event schemas |
| Command handlers | Domain models + API contracts |
| OTEL instrumentation | SLA targets + observability requirements |
| Infrastructure manifests | Service manifest + ADRs + infra conventions |
| CI/CD pipelines | Service manifest + coding standards |
| Observability alerts | SLO definitions (derived from SLA targets) |
| Automation scripts | Script task specs |

## The Contract → Implementation Flow

```mermaid
flowchart TD
    H["HUMAN LAYER<br/><br/>contracts/slas/&lt;service&gt;-sla.yaml<br/>availability: 99.95% · latency_p99_ms: 500 · throughput_rps: 1000<br/><br/>contracts/domain-invariants/&lt;service&gt;-invariants.md<br/>contracts/event-schemas/&lt;EventName&gt;.json<br/>docs/ddd/&lt;service&gt;/domain-model.md"]

    A["AGENT LAYER<br/><br/>ai-agents/tasks/agent/implement-&lt;service&gt;.md<br/>ai-agents/context/coding-standards.md<br/>ai-agents/context/observability-requirements.md"]

    I["IMPLEMENTATION LAYER<br/><br/>services/&lt;service&gt;/src/domain/<br/>services/&lt;service&gt;/src/domain/events/<br/>services/&lt;service&gt;/src/infrastructure/OtelInstrumentation<br/><br/>observability/slos/&lt;service&gt;-slo.yaml<br/>observability/alerts/&lt;service&gt;-burnrate.yaml"]

    H -- "consumed by" --> A
    A -- "produces" --> I
```
