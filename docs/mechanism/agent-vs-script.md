---
title: Agent vs Script
description: The decision rule — when to use an LLM agent and when to write a deterministic script.
---

# Agent vs Script

The boundary is: **does the task require judgment?**

## Use an AI Agent when:

- The input is natural language (invariants, ADR context, domain descriptions)
- The output requires interpretation, synthesis, or tradeoff reasoning
- Multiple inputs must be reconciled into a coherent whole
- The task would require a senior engineer to do well

## Use a Script when:

- The input is structured data (YAML, JSON, manifests)
- The transformation is deterministic and mechanical
- The output format is fixed and well-defined
- A diff on the script tells you exactly what changed and why

## The Meta-Rule

**Agents write the scripts.**

The script runs ten thousand times; the agent runs once. This means agent time is spent on design and judgment; machine time is spent on execution and repetition.

A script is an agent's judgment, crystallised and made reproducible. Once the script is reviewed and merged, the agent is never re-invoked for that task. Only the script runs, forever.

## Examples

| Task | Use |
|---|---|
| Transform SLA YAML → alert YAML | Script — deterministic, structured → structured |
| Implement domain aggregate from invariant doc | Agent — synthesis from natural language |
| Generate infrastructure template from service manifest | Script — mechanical, structured → structured |
| Write Architecture Decision Record from ADR stub | Agent — argument + prose requiring judgment |
| Generate CI pipeline from service name + language | Script — template instantiation |
| Produce OpenAPI spec from domain model | Agent — multiple inputs reconciled into coherent whole |
