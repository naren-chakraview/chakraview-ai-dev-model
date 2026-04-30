---
title: The Model
description: The core principle of the Chakraview AI Dev Model — humans for correctness, agents for volume.
---

# The Model

## The Core Principle

> **Humans are accountable for correctness. Agents are accountable for volume.**

Humans author *contracts* — the precise, versioned expression of business intent. Agents implement from those contracts. An agent that drifts from a contract produces a defect traceable to a missing or ambiguous contract, not to the agent itself.

---

## Why Agents, Not Just Scripts

Scripts handle *transformation*: structured input → structured output, no judgment required. Agents handle *synthesis*: natural-language intent + multiple inputs → correct, idiomatic, contextually appropriate output.

Generating a deployment manifest from a service descriptor is transformation — scriptable. Implementing domain logic from a business invariant document is synthesis — agent required.

The model uses both. Agents write the scripts; scripts run forever. Agent time is spent on design and judgment; machine time is spent on execution.

See [Agent vs Script](mechanism/agent-vs-script.md) for the decision rule.

---

## Two Tiers

**Tier 1 — Human-authored contracts** (what the system must do):

- SLA targets and error budgets
- Domain invariants — business rules that encode operational knowledge
- Event schemas — the shared language between teams
- Architecture Decision Records — tradeoff reasoning
- Domain models — bounded context structure, ubiquitous language
- Task specifications — what "correct" means for each agent invocation

**Tier 2 — Agent-built implementations** (how the system does it):

- Service source code
- Infrastructure manifests (Terraform, Helm, Kubernetes)
- Observability artifacts (SLO definitions, burn rate alerts, dashboards)
- CI/CD pipelines
- Automation scripts

---

## Consequences

**Positive:**

- Senior engineers focus on contract quality and architectural judgment — the highest-leverage work
- Implementation is consistent across services (agents follow the same standards every time)
- New services can be scaffolded in hours rather than days
- Onboarding is faster: read the contracts, understand the system

**Negative:**

- Contract authoring requires investment and skill development
- Agent output must still be reviewed; review is a different skill from writing
- Poorly specified contracts produce incorrect agent output; the model amplifies specification quality in both directions
- Some engineers resist the transition from "I write the code" to "I specify what the code must do"

---

## Alternatives Considered

**Pure scripting (no agents):** Covers boilerplate but cannot handle tasks requiring judgment. Domain logic is the irreducible complexity that requires understanding natural-language business rules.

**Traditional development (no agents):** Valid, but wastes senior engineer time on low-judgment implementation tasks. The bottleneck is specification quality, not implementation volume.

**Full autonomy (agents without human contracts):** Produces code that is locally coherent but globally inconsistent. Agents hallucinate domain behaviour without invariants to constrain them.

---

## How This Changes the Engineering Role

The team's most valuable time is spent on:

1. **Contract authoring** — writing precise, unambiguous invariants and SLAs
2. **ADR reasoning** — documenting architectural decisions so agents can implement consistently
3. **Task spec quality** — the more precise the spec, the better the output
4. **Contract review** — reviewing diffs to contracts with the same rigour as production code changes
5. **SLA governance** — owning the dashboards that prove the system meets its commitments

Implementation becomes a review task, not a writing task. The engineer reads agent output and asks: *does this correctly express the contract?*
