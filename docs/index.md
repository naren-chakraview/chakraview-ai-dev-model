---
title: Chakraview AI Dev Model
description: A 6-persona framework for human-AI collaborative software development.
---

# Chakraview AI Dev Model

> **Humans are accountable for correctness. Agents are accountable for volume.**

---

## What This Framework Solves

Most AI-assisted development fails at the same place: engineers give agents vague instructions and get inconsistent, unmaintainable output. The root cause is not the agent — it is the missing contract between human intent and agent implementation.

This framework makes that contract explicit. Humans author *contracts* — precise, versioned specifications of business intent. Agents receive task specs that enumerate exactly which contracts to read and exactly what to produce. The line between what humans wrote and what agents built is structural, not informal.

---

## At a Glance

<div class="grid cards" markdown>

-   :material-account-hard-hat:{ .lg .middle } __6 Personas__

    ---

    Human Domain Expert, Documentation Agent, Script Authoring Agent, Script Executor, Implementation Agent, and Compliance Agent — each with explicit inputs, outputs, and constraints.

    [:octicons-arrow-right-24: Browse Personas](personas/index.md)

-   :material-file-document-check:{ .lg .middle } __The Mechanism__

    ---

    Contracts define the boundary. The agent-vs-script decision rule keeps judgment separate from transformation. Guardrails prevent drift.

    [:octicons-arrow-right-24: Understand the Mechanism](mechanism/index.md)

-   :material-source-branch:{ .lg .middle } __7-Phase Workflow__

    ---

    From bootstrap (contracts + validation script) through continuous operation (contract change response, new bounded context). Each phase has explicit persona sequencing and human review gates.

    [:octicons-arrow-right-24: See the Workflow](workflow/index.md)

-   :material-file-code:{ .lg .middle } __Ready-to-Use Templates__

    ---

    Parameterised task spec templates for all agent and script tasks. Drop them in, fill in your domain specifics, and run.

    [:octicons-arrow-right-24: Browse Templates](../templates/)

</div>

---

## The Model in One Diagram

```
Human authors                    AI agents build
─────────────────────────        ──────────────────────────────────
contracts/slas/              →   observability/slos/ + alerts/
contracts/event-schemas/     →   services/*/src/domain/events/
contracts/domain-invariants/ →   services/*/src/domain/ (aggregates)
docs/adrs/                   →   services/ + infrastructure/
ai-agents/tasks/agent/       →   everything in services/, infrastructure/
tooling/service-manifest.yaml→   tooling/*.py / *.sh (scripts)
```

This is not automation for its own sake. It is a deliberate separation: humans hold accountability for correctness; agents handle volume and consistency.

---

## See It In Practice

[chakraview-enterprise-modernization](https://github.com/naren-chakraview/chakraview-enterprise-modernization) used all 6 personas to modernise a Java EE monolith to cloud-native microservices. Read [how it was built](https://naren-chakraview.github.io/chakraview-enterprise-modernization/how-this-was-built/).
