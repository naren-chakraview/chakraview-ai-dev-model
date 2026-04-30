---
title: The Mechanism
description: How the human/agent boundary is defined and enforced.
---

# The Mechanism

The model rests on three interlocking mechanisms:

- **[Contracts](contracts.md)** — the explicit boundary between human intent and agent implementation. Every agent task has a defined set of contracts it must read; every contract has a defined set of agents that may consume it but never modify it.

- **[Agent vs Script](agent-vs-script.md)** — the decision rule that determines whether a task needs an LLM or a deterministic script. Getting this wrong in either direction is expensive.

- **[Guardrails](guardrails.md)** — the enforcement layer that prevents agent drift from contracts. Without guardrails, the boundary exists in documentation but not in practice.

These three are not independent. Contracts define what agents must produce; the agent-vs-script rule determines how they produce it; guardrails verify that what they produced matches what was specified.
