# chakraview-ai-dev-model

> A 6-persona framework for human-AI collaborative software development — where humans define correctness and AI agents handle volume.

---

## The Core Claim

Modern software delivery has a bottleneck problem: the people who understand the domain deeply are not bottlenecked on *thinking* — they are bottlenecked on *typing*. AI agents can close that gap, but only if the division of responsibility is explicit and enforced.

This framework operationalises one principle:

> **Humans are accountable for correctness. Agents are accountable for volume.**

Humans author *contracts* — the precise, versioned expression of business intent. Agents implement from those contracts. An agent that drifts from a contract produces a defect traceable to a missing or ambiguous contract, not to the agent itself.

---

## The Six Personas

| # | Persona | Type | Primary output |
|---|---|---|---|
| 1 | Human Domain Expert | Human | Contracts, ADR stubs, task specs |
| 2 | Documentation Agent | LLM | Architecture docs, ADRs, runbooks |
| 3 | Script Authoring Agent | LLM (one-shot) | Deterministic scripts in `tooling/` |
| 4 | Script Executor | Automation | Generated artifacts (alerts, Helm, CI) |
| 5 | Service Implementation Agent | LLM | Service source code and tests |
| 6 | Architectural Compliance Agent | LLM (auditor) | Compliance reports |

Full persona definitions: [docs/personas/](docs/personas/index.md)

---

## Repository Map

```
docs/
  model.md          The core principle and why it works
  personas/         All 6 personas — inputs, outputs, constraints
  mechanism/        Contract boundaries, agent-vs-script decision rule, guardrails
  workflow/         Complete 7-phase workflow (bootstrap → continuous)
  task-specs/       How to write task specs; compliance report format
  case-studies/     Projects built with this model
templates/
  agent-tasks/      Parameterised task spec templates for LLM agents
  script-tasks/     Task spec templates for deterministic scripts
  context/          Context document templates (coding standards, infra, observability)
```

---

## See It In Practice

[chakraview-enterprise-modernization](https://github.com/naren-chakraview/chakraview-enterprise-modernization) — modernising a Java EE monolith to cloud-native microservices using all 6 personas.

Read the case study: [How That Project Was Built](https://naren-chakraview.github.io/chakraview-enterprise-modernization/how-this-was-built/)
