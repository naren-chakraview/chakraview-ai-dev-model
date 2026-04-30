---
title: Personas
description: The six personas that participate in the AI dev model workflow.
---

# Personas

This document defines the six personas that participate in the development workflow. Every artifact in this repository was produced by one of these personas. The line between them is explicit and enforced.

---

## Overview

| # | Persona | Type | Primary output |
|---|---|---|---|
| 1 | [Human Domain Expert](persona-1-human-domain-expert.md) | Human | Contracts, ADR stubs, task specs |
| 2 | [Documentation Agent](persona-2-documentation-agent.md) | LLM | ADRs, domain models, migration docs, runbooks |
| 3 | [Script Authoring Agent](persona-3-script-authoring-agent.md) | LLM (one-shot) | Deterministic scripts in `tooling/` |
| 4 | [Script Executor](persona-4-script-executor.md) | Automation | Generated artifacts (alerts, Helm, CI, validation reports) |
| 5 | [Implementation Agent](persona-5-implementation-agent.md) | LLM | Service source code and tests |
| 6 | [Compliance Agent](persona-6-compliance-agent.md) | LLM (auditor) | Compliance reports in `ai-agents/reviews/` |

---

## Persona Interaction Map

```mermaid
flowchart TD
    H([1 Human Expert])
    D([2 Documentation Agent])
    S([3 Script Authoring Agent])
    E([4 Script Executor])
    I([5 Implementation Agent])
    C([6 Compliance Agent])

    H -->|"contract files\n+ task specs"| D
    H -->|"contract files\n+ task specs"| S
    H -->|"contract files\n+ task specs"| I
    S -->|"scripts"| E
    E -->|"generated artifacts"| C
    I -->|"service code"| C
    D -->|"ADRs + domain models"| I
    D -->|"ADRs + domain models"| C
    C -->|"PASS"| H
    C -->|"intentional deviation\n→ write ADR"| H
    C -->|"unintentional deviation\n+ compliance report"| S
    C -->|"unintentional deviation\n+ compliance report"| I
    H -->|"amended ADR"| C

    style H fill:#dbeafe,stroke:#3b82f6
    style C fill:#fef9c3,stroke:#eab308
    style E fill:#f3f4f6,stroke:#9ca3af
```
