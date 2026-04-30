---
title: Task Specs
description: How to write task specs that produce reliable agent output — and the compliance report format.
---

# Task Specs

A task spec is the interface between human intent and agent output. It is the artifact that makes the difference between an agent that produces correct output on first review and one that requires three rounds of correction.

---

## What Makes a Good Task Spec

A task spec must be:

1. **Self-contained**: The agent reads only the files listed in the spec. Do not assume the agent has context from previous runs or conversations.
2. **Explicit about inputs**: List every file the agent must read, with repo-relative paths. Do not say "read the relevant contracts" — name them.
3. **Explicit about outputs**: Specify every file the agent must produce, with exact paths and expected structure.
4. **Acceptance-criteria-driven**: List the checks the output must pass. These checks should be runnable (not "looks correct" but "type check passes", "validate-contracts.sh passes").
5. **Standards-referenced**: Name which context documents (`ai-agents/context/`) apply to this task.

---

## Task Spec Structure

```markdown
# Agent Task: {Task Name}

**Task type**: Agent | Script
**Spec version**: {N.N}
**Runs after**: {Phase N or trigger condition}

## Goal

One paragraph. What does this task produce, and why?

## Inputs (read all of these before writing a single line)

| File | Why |
|---|---|
| `path/to/contract.yaml` | What the agent uses this for |
| `path/to/invariants.md` | What the agent uses this for |

## Outputs (produce exactly these files)

List every file with its exact path. Use a tree structure for directory output.

## Constraints

Numbered list of implementation constraints the agent must not violate.

## Acceptance Criteria

- [ ] {Runnable check 1}
- [ ] {Runnable check 2}
```

---

## Compliance Report Format

The Architectural Compliance Agent (Persona 6) writes reports to `ai-agents/reviews/`. Each report uses this format:

```markdown
# Compliance Report: {phase} — {service} — {date}

**Status**: PASS | DEVIATION
**Persona reviewed**: Persona 4 (Script Executor) | Persona 5 (Implementation Agent)
**ADRs consulted**: {list of ADR names}
**Principles consulted**: {list of principle names}

## Checklist

| Check | Result | Notes |
|---|---|---|
| {Check name} | ✓ PASS | |
| {Check name} | ✗ DEVIATION | {Brief note} |

## Deviations

### DEV-001 — {Deviation name}
**Classification**: intentional | unintentional
**Principle/ADR violated**: {Name}
**Location**: {file:line}
**Resolution**: {Specific instruction — which persona re-runs, with what context, OR which ADR the human must write}
```

**Classification rules:**

- **Intentional** — the agent made a deliberate architectural choice that differs from an existing decision. A human must write or amend an ADR before the artifact merges. A second scoped compliance pass then confirms coverage.
- **Unintentional** — the agent misread a spec, missed a constraint, or drifted from standards. The offending persona re-runs with the compliance report as additional context.

When uncertain, prefer **intentional** — it forces a human to make the decision explicit.

---

## Templates

Ready-to-use parameterised templates for all task types: [`templates/`](../templates/)
