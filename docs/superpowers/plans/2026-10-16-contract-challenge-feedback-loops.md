# Contract Challenge Feedback Loops Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add three named workflow feedback loops (P3→P1, P5→P2, and the phase-agnostic Contract Challenge Report) to the Chakraview AI Dev Model — workflow diagram, persona docs, skill source files, a new ADR, and a new CCR template.

**Architecture:** Documentation-only change. No code is written or modified. Two parallel content layers must stay in sync: `docs/personas/` (human-readable site pages) and `skills/source/` (skill files agents load at runtime). Both describe the same personas; changes to persona responsibilities must appear in both. The workflow diagram is Mermaid inside a markdown file rendered by MkDocs Material.

**Tech Stack:** MkDocs Material, Mermaid (flowchart TD), Markdown, Bash (MkDocs build validation, skills validation script)

**Spec:** `docs/superpowers/specs/2026-10-16-contract-challenge-feedback-loops-design.md`

## Global Constraints

- All new markdown files must have valid YAML frontmatter with at least `title` and `description`
- Skill source files must pass `skills/tests/validate-sources.sh` after modification — do not remove or rename frontmatter fields (`name`, `type`, `description`, `triggers`, `phases`, `personas`, `reads`, `writes`)
- Mermaid syntax in `docs/workflow/index.md` must compile without error (`mkdocs build --strict`)
- New nav entries in `mkdocs.yml` must reference files that exist
- Follow existing heading style in each file — no heading level changes, no added horizontal rules unless the surrounding file uses them

## Review Focus

- **CCR threshold mis-stated**: the threshold rule in `docs/adrs/adr-ccr-threshold.md` must exactly match the rule in the spec (`contracts/slas/`, `contracts/domain-invariants/`, `contracts/event-schemas/`, or a new ADR) — a partial list would silently mis-define the threshold. Verify by diffing the four conditions in the ADR against the spec.
- **Skill/docs drift**: the CCR section added to `skills/source/persona-*.md` must say the same thing as the matching section in `docs/personas/persona-*.md`. A reviewer reading the site and an agent reading the skill must receive identical instructions. Verify by comparing the two sections side by side after Task 4 and Task 5.
- **Compliance Agent over-expanded**: the spec explicitly says Persona 6 does not own CCRs and does not write them. Any wording that implies the Compliance Agent initiates CCRs or takes authority over them contradicts the spec. The only new Persona 6 responsibility is flagging CCR bypasses as a process deviation.
- **Broken nav**: adding `docs/adrs/` to `mkdocs.yml` before creating the files will fail the build. Task 2 creates both files and the nav entry in the same commit — do not split them.
- **Loop A directionality**: Loop A is P3 → P1 (API contract reveals domain model gap). The arrow points backwards in the phase sequence. Mermaid flowchart TD renders top-to-bottom; a backwards edge will create a visible upward arrow. Confirm the diagram still renders legibly after adding it — run `mkdocs build` and inspect the output HTML.

---

### Task 1: Workflow diagram — three feedback loops

**Files:**
- Modify: `docs/workflow/index.md`

**Interfaces:**
- Consumes: existing Mermaid `flowchart TD` block in `docs/workflow/index.md`
- Produces: three new feedback paths visible in the rendered diagram (Loop A: P3→P1, Loop B: P5→P2, Loop C: CCR node)

- [ ] **Step 1: Read the existing diagram**

Open `docs/workflow/index.md` and locate the Mermaid fenced code block (` ```mermaid `). It ends with the line `FEEDBACK -->|re-enters as next intent| INTAKE`. Note that line — the new node definitions and edges are appended before the closing ` ``` `.

- [ ] **Step 2: Add CCR node definitions**

Inside the Mermaid block, after the `FEEDBACK[...]` node definition and before the existing edge definitions, add these four nodes:

```
    CCR["CONTRACT CHALLENGE REPORT — Loop C<br/><br/>Any agent, any phase<br/>Trigger: contract is technically costly or complex to honor<br/><br/>Output: ai-agents/reviews/ccr-{service}-{date}.md<br/><br/>Routing: Agent halts on affected contract<br/>Human Expert → Product/business owner<br/>RELAX: amend contract → re-enter Phase 0<br/>HOLD: write hold ADR → resume originating phase"]

    CCRD{"Relax or Hold?"}

    CCR_RELAX["Amend contract<br/>Re-enter Phase 0"]
    CCR_HOLD["Write hold ADR<br/>Resume originating phase"]
```

- [ ] **Step 3: Add loop edges**

After the existing final edge (`FEEDBACK -->|re-enters as next intent| INTAKE`), add:

```
    P3 --"Loop A: API contract reveals domain model gap<br/>Phase 3 pauses"--> P1
    P5 --"Loop B: Implementation changes SLO assumptions<br/>Phase 5 pauses"--> P2
    P1 -.->|"Loop C"| CCR
    P3 -.->|"Loop C"| CCR
    P5 -.->|"Loop C"| CCR
    CCR --> CCRD
    CCRD -->|RELAX| CCR_RELAX
    CCRD -->|HOLD| CCR_HOLD
    CCR_RELAX --> P0
```

Dashed arrows (`-.->`) distinguish Loop C triggering (any phase → CCR) from the main workflow flow. Solid arrows (`-->`) are used for the CCR's internal routing (CCR → CCRD → outcome) because those steps always happen once a CCR is filed.

- [ ] **Step 4: Build and inspect**

```bash
cd /home/gundu/portfolio/chakraview-ai-dev-model
pip install -q -r requirements-docs.txt
mkdocs build --strict 2>&1 | tail -20
```

Expected: build completes with no errors. A warning about unrecognised Mermaid syntax is a failure — fix the syntax before continuing.

- [ ] **Step 5: Commit**

```bash
git add docs/workflow/index.md
git commit -m "docs(workflow): add three named feedback loops (A, B, C) to diagram"
```

---

### Task 2: CCR threshold ADR and MkDocs nav

**Files:**
- Create: `docs/adrs/index.md`
- Create: `docs/adrs/adr-ccr-threshold.md`
- Modify: `mkdocs.yml`

**Interfaces:**
- Consumes: spec section "New ADR: CCR Threshold Rule"; spec section "CCR threshold rule"
- Produces: `docs/adrs/` directory with one ADR, wired into site nav; all nav entries point to existing files

- [ ] **Step 1: Create the ADRs index page**

Create `docs/adrs/index.md` with this exact content:

```markdown
---
title: Model ADRs
description: Architectural decisions made about the Chakraview AI Dev Model itself — distinct from ADRs produced by projects that use the model.
---

# Model ADRs

This section documents architectural decisions made *about the Chakraview AI Dev Model itself*.

These are not ADRs for projects built with the model. Those live in the target project's `docs/adrs/` directory. This section records the model's own design decisions.

| ADR | Decision |
|---|---|
| [CCR Threshold Rule](adr-ccr-threshold.md) | When a Contract Challenge Report is required versus an inline note |
```

- [ ] **Step 2: Create the CCR threshold ADR**

Create `docs/adrs/adr-ccr-threshold.md` with this exact content:

```markdown
---
title: ADR — CCR Threshold Rule
description: When a Contract Challenge Report is required versus when an inline note suffices.
date: 2026-10-16
status: accepted
---

# ADR: CCR Threshold Rule

## Status

Accepted

## Context

The Contract Challenge Report (CCR) is the formal mechanism for the phase-agnostic Loop C feedback path — cases where honoring a contract is technically costly or complex and the resolution may require relaxing the contract rather than implementing harder.

All agent personas (2, 3, 5, 6) have authority to write a CCR. Without a documented threshold, two failure modes emerge:

- **Over-reporting**: agents file CCRs for minor observations, flooding the artifact trail and causing the Human Domain Expert to treat CCRs as noise
- **Under-reporting**: agents skip CCRs for decisions that genuinely warrant contract amendment; the conversation happens informally with no audit trail

## Decision

A CCR is **required** when resolving the challenge would:

1. Amend a file in `contracts/slas/`
2. Amend a file in `contracts/domain-invariants/`
3. Amend a file in `contracts/event-schemas/`
4. Require a new or amended ADR

If none of the four conditions is met, the agent notes the observation inline in its existing task output and continues. No CCR is written, no halt, no routing.

## Rationale

The formal CCR path exists to make contract amendments auditable. Routing minor observations through the same path degrades the CCR signal — practitioners either ignore CCRs or bypass the path informally, reproducing the problem the CCR was designed to solve.

The four-condition threshold is intentionally binary: the question is not "how significant is this?" but "would resolution produce a changed contract artifact or a new ADR?" This makes classification a check, not a judgment.

## Consequences

**Positive:**

- Every CCR reliably signals a decision that requires product/business owner input
- The Human Domain Expert can treat every CCR as a routing task, not a triage task
- Contract amendments are auditable — every amended contract has a CCR that records why

**Negative:**

- Agents must still apply judgment at the boundary; an agent might note inline when a CCR was warranted
- Misclassified bypasses only surface at Compliance Review (see below)

## Misclassification detection

If a Compliance Agent review discovers that an agent continued past a contract challenge without writing a CCR — evidenced by an implementation that implies a contract was too costly to honor but no matching CCR exists in `ai-agents/reviews/` — the Compliance Agent flags this as a **process deviation** in the compliance report. This is the enforcement backstop for the threshold rule.
```

- [ ] **Step 3: Add ADRs section to mkdocs nav**

Open `mkdocs.yml`. Locate the `nav:` block. After the `- Skills Plugin: skills/index.md` line and before `- Case Studies: case-studies/index.md`, add:

```yaml
  - ADRs:
    - adrs/index.md
    - "CCR Threshold Rule": adrs/adr-ccr-threshold.md
```

- [ ] **Step 4: Build and verify nav**

```bash
mkdocs build --strict 2>&1 | tail -20
```

Expected: build completes with no errors. If you see "Doc file not found", the file path in `mkdocs.yml` does not match the actual file path — fix the path.

- [ ] **Step 5: Commit**

```bash
git add docs/adrs/index.md docs/adrs/adr-ccr-threshold.md mkdocs.yml
git commit -m "docs(adrs): add CCR threshold rule ADR and model ADRs section"
```

---

### Task 3: CCR template

**Files:**
- Create: `templates/agent-tasks/contract-challenge.md`

**Interfaces:**
- Consumes: spec section "Contract Challenge Report — Format"; spec section "Routing path"
- Produces: a parameterised CCR template following the same structure as `templates/agent-tasks/compliance-review.md`

- [ ] **Step 1: Review the existing template pattern**

Open `templates/agent-tasks/compliance-review.md`. Note the structure: usage banner at the top, task type/spec version/trigger header, then Goal → Inputs → Output → Checklist → Acceptance Criteria sections.

- [ ] **Step 2: Create the CCR template**

Create `templates/agent-tasks/contract-challenge.md` with this exact content:

```markdown
# Agent Task: Contract Challenge Report

> **Template usage:** Fill in all four fields before submitting. Do not leave any field blank.
> Only write a CCR if the threshold is met — see the threshold check below.

**Task type**: Any agent (Personas 2, 3, 5, or 6)
**Spec version**: 1.0
**Triggered by**: Discovery that a contract is technically costly or complex to honor

---

## Threshold check

Before writing this CCR, confirm at least one condition is true:

- [ ] Resolution would amend a file in `contracts/slas/`
- [ ] Resolution would amend a file in `contracts/domain-invariants/`
- [ ] Resolution would amend a file in `contracts/event-schemas/`
- [ ] Resolution would require a new or amended ADR

If no box is checked: note the observation inline in your task output and do not write a CCR.

Reference: `docs/adrs/adr-ccr-threshold.md`

---

## Goal

Surface a contract that is technically costly or complex to honor, with enough precision that the Human Domain Expert can route it to the right product or business owner and record an auditable outcome.

---

## The four fields

Write your CCR using these four fields and no others:

```
contract: <path to the contract file>#<specific clause, SLA target, invariant ID, or schema field>

cost:     <What honoring this contract technically requires — infrastructure, algorithm,
           or architectural complexity. Be specific: "requires X" not "is expensive".
           If a cost delta is calculable, include it.>

question: <The specific choice for the product or business owner.
           Name a concrete alternative: "Would X be acceptable? That would allow Y."
           Not an open question — a decision between the current contract and a named alternative.>

phase:    <Workflow phase number where this discovery was made (0, 1, 2, 3, 4, 5, or 6)>
```

---

## Example

```
contract: contracts/slas/billing-api-sla.yaml#latency-p99-50ms

cost:     Honoring 50ms p99 requires a synchronous Redis cache layer plus a dedicated
          read replica. Estimated infra cost delta: ~$2k/month.

question: Is 50ms p99 a hard business requirement, or was it an estimate?
          Would 100ms p99 be acceptable? That eliminates the cache requirement.

phase:    5
```

---

## Output

Write to: `ai-agents/reviews/ccr-{service}-{date}.md`

After writing:
1. Halt work on the affected contract (and only the affected contract — continue other work)
2. Surface the CCR file path to the Human Domain Expert
3. Do not resume work on the affected contract until the Human Domain Expert records an outcome

---

## Outcome recording (Human Domain Expert)

The Human Domain Expert appends the outcome to the CCR file:

```
outcome: RELAX | HOLD

resolution: <RELAX: path of the amended contract file>
            <HOLD: path of the ADR written to justify holding the contract>
```

---

## Acceptance criteria

- [ ] All four fields are present and non-empty
- [ ] `contract:` references a specific file and clause (not a directory)
- [ ] `question:` names a concrete alternative, not an open-ended question
- [ ] `phase:` is a single number (0–6)
- [ ] File is written to `ai-agents/reviews/`, not anywhere else
- [ ] Threshold check was completed — at least one box was checked before filing
```

- [ ] **Step 3: Verify the four required fields are present**

```bash
grep -c "^contract:\|^cost:\|^question:\|^phase:" templates/agent-tasks/contract-challenge.md
```

Expected output: `8` (four fields appear twice — once in the template body, once in the example).

- [ ] **Step 4: Commit**

```bash
git add templates/agent-tasks/contract-challenge.md
git commit -m "docs(templates): add contract-challenge CCR template"
```

---

### Task 4: Persona doc pages — all five

**Files:**
- Modify: `docs/personas/persona-1-human-domain-expert.md`
- Modify: `docs/personas/persona-2-documentation-agent.md`
- Modify: `docs/personas/persona-3-script-authoring-agent.md`
- Modify: `docs/personas/persona-5-implementation-agent.md`
- Modify: `docs/personas/persona-6-compliance-agent.md`

**Interfaces:**
- Consumes: spec section "Persona Updates"
- Produces: each persona page has a CCR section; the content must match the corresponding skill source file updated in Task 5

The CCR section content for each persona is defined below. Add each section at the end of the file, after all existing content.

- [ ] **Step 1: Update Persona 1 — Human Domain Expert**

Append to `docs/personas/persona-1-human-domain-expert.md`:

```markdown

## Contract Challenge Review

Review incoming Contract Challenge Reports (CCRs) in `ai-agents/reviews/ccr-*.md`. Route each to the relevant product or business owner with the cost signal. Record the outcome directly in the CCR file:

- **Relax**: amend the contract file in `contracts/` and re-enter Phase 0 for the affected contract.
- **Hold**: write an ADR in `docs/adrs/` documenting why the contract stands at this cost. Resume the originating phase once the ADR is written and reviewed.

Neither outcome is undocumented. Every CCR resolution produces a written artifact.
```

- [ ] **Step 2: Update Persona 2 — Documentation Agent**

Append to `docs/personas/persona-2-documentation-agent.md`:

```markdown

## Contract Challenge Responsibility

When executing a task, if a contract is discovered to be technically costly or complex to honor, apply the threshold rule:

- **Write a CCR** when resolution would amend a file in `contracts/slas/`, `contracts/domain-invariants/`, or `contracts/event-schemas/`, or require a new or amended ADR. Halt work on the affected contract. Write to `ai-agents/reviews/ccr-{service}-{date}.md`. Surface to the Human Domain Expert before continuing.
- **Note inline** when the observation does not meet the above threshold. Continue work.

Reference: `docs/adrs/adr-ccr-threshold.md`
```

- [ ] **Step 3: Update Persona 3 — Script Authoring Agent**

Append to `docs/personas/persona-3-script-authoring-agent.md`:

```markdown

## Contract Challenge Responsibility

When executing a task, if a contract is discovered to be technically costly or complex to honor, apply the threshold rule:

- **Write a CCR** when resolution would amend a file in `contracts/slas/`, `contracts/domain-invariants/`, or `contracts/event-schemas/`, or require a new or amended ADR. Halt work on the affected contract. Write to `ai-agents/reviews/ccr-{service}-{date}.md`. Surface to the Human Domain Expert before continuing.
- **Note inline** when the observation does not meet the above threshold. Continue work.

Reference: `docs/adrs/adr-ccr-threshold.md`
```

- [ ] **Step 4: Update Persona 5 — Implementation Agent**

Append to `docs/personas/persona-5-implementation-agent.md`:

```markdown

## Contract Challenge Responsibility

When executing a task, if a contract is discovered to be technically costly or complex to honor, apply the threshold rule:

- **Write a CCR** when resolution would amend a file in `contracts/slas/`, `contracts/domain-invariants/`, or `contracts/event-schemas/`, or require a new or amended ADR. Halt work on the affected contract. Write to `ai-agents/reviews/ccr-{service}-{date}.md`. Surface to the Human Domain Expert before continuing.
- **Note inline** when the observation does not meet the above threshold. Continue work.

Reference: `docs/adrs/adr-ccr-threshold.md`
```

- [ ] **Step 5: Update Persona 6 — Compliance Agent**

Append to `docs/personas/persona-6-compliance-agent.md`:

```markdown

## Relationship to Contract Challenge Reports

This persona does not own CCRs and does not write them. CCR authority belongs to all agent personas equally (Personas 2, 3, 5, and 6).

If a compliance review discovers that an agent continued past a contract challenge without writing a CCR — evidenced by an implementation that implies a contract was too costly to honor, but no matching CCR exists in `ai-agents/reviews/` — flag this as a **process deviation** in the compliance report. It is a distinct finding class from a technical deviation and follows the same intentional/unintentional classification:

- **Intentional**: the agent made a deliberate judgment that the observation was below the CCR threshold. The Human Domain Expert must confirm this judgment or request a CCR retroactively.
- **Unintentional**: the agent overlooked the threshold rule. Re-run the originating persona with the compliance report as context.
```

- [ ] **Step 6: Verify all five sections were appended**

```bash
grep -l "Contract Challenge" docs/personas/persona-{1,2,3,5,6}.md
```

Expected: all five filenames printed.

- [ ] **Step 7: Build**

```bash
mkdocs build --strict 2>&1 | tail -10
```

Expected: no errors.

- [ ] **Step 8: Commit**

```bash
git add docs/personas/persona-1-human-domain-expert.md \
        docs/personas/persona-2-documentation-agent.md \
        docs/personas/persona-3-script-authoring-agent.md \
        docs/personas/persona-5-implementation-agent.md \
        docs/personas/persona-6-compliance-agent.md
git commit -m "docs(personas): add CCR responsibilities to all five persona pages"
```

---

### Task 5: Skill source files — four agent personas

**Files:**
- Modify: `skills/source/persona-documentation-agent.md`
- Modify: `skills/source/persona-script-authoring-agent.md`
- Modify: `skills/source/persona-implementation-agent.md`
- Modify: `skills/source/persona-compliance-agent.md`

**Interfaces:**
- Consumes: persona doc pages updated in Task 4 — the CCR section content must match exactly
- Produces: four skill source files with CCR sections; all pass `skills/tests/validate-sources.sh`

The CCR section content for each skill file is identical to the corresponding doc page from Task 4. Add the section at the end of the file body, after all existing content, before the final newline.

- [ ] **Step 1: Update persona-documentation-agent.md**

Append to `skills/source/persona-documentation-agent.md` (after the "What you do not do" section):

```markdown

## Contract Challenge Responsibility

When executing a task, if a contract is discovered to be technically costly or complex to honor, apply the threshold rule:

- **Write a CCR** when resolution would amend a file in `contracts/slas/`, `contracts/domain-invariants/`, or `contracts/event-schemas/`, or require a new or amended ADR. Halt work on the affected contract. Write to `ai-agents/reviews/ccr-{service}-{date}.md`. Surface to the Human Domain Expert before continuing.
- **Note inline** when the observation does not meet the above threshold. Continue work.

Threshold reference: `ai-agents/context/` — the CCR threshold ADR is installed there by `install.sh`.
```

- [ ] **Step 2: Update persona-script-authoring-agent.md**

Open `skills/source/persona-script-authoring-agent.md`. Append after the final existing section:

```markdown

## Contract Challenge Responsibility

When executing a task, if a contract is discovered to be technically costly or complex to honor, apply the threshold rule:

- **Write a CCR** when resolution would amend a file in `contracts/slas/`, `contracts/domain-invariants/`, or `contracts/event-schemas/`, or require a new or amended ADR. Halt work on the affected contract. Write to `ai-agents/reviews/ccr-{service}-{date}.md`. Surface to the Human Domain Expert before continuing.
- **Note inline** when the observation does not meet the above threshold. Continue work.

Threshold reference: `ai-agents/context/` — the CCR threshold ADR is installed there by `install.sh`.
```

- [ ] **Step 3: Update persona-implementation-agent.md**

Open `skills/source/persona-implementation-agent.md`. Append after the "Correctness signal" section:

```markdown

## Contract Challenge Responsibility

When executing a task, if a contract is discovered to be technically costly or complex to honor, apply the threshold rule:

- **Write a CCR** when resolution would amend a file in `contracts/slas/`, `contracts/domain-invariants/`, or `contracts/event-schemas/`, or require a new or amended ADR. Halt work on the affected contract. Write to `ai-agents/reviews/ccr-{service}-{date}.md`. Surface to the Human Domain Expert before continuing.
- **Note inline** when the observation does not meet the above threshold. Continue work.

Threshold reference: `ai-agents/context/` — the CCR threshold ADR is installed there by `install.sh`.
```

- [ ] **Step 4: Update persona-compliance-agent.md**

Open `skills/source/persona-compliance-agent.md`. Append after the "Phase 5 checklist" section:

```markdown

## Relationship to Contract Challenge Reports

You do not own CCRs and do not write them. CCR authority belongs to all agent personas equally.

If your review discovers that an agent continued past a contract challenge without writing a CCR — evidenced by an implementation that implies a contract was too costly to honor, but no matching `ccr-*.md` exists in `ai-agents/reviews/` — flag this as a **process deviation** in your compliance report, distinct from technical deviations:

- **Intentional**: agent judged the observation was below the CCR threshold. Human Expert must confirm or request a retroactive CCR.
- **Unintentional**: agent overlooked the threshold rule. Re-run the originating persona with this report as context.
```

- [ ] **Step 5: Run the skills validation script**

```bash
bash skills/tests/validate-sources.sh
```

Expected: all source files pass. If a file fails, the error will name the failing field — check that you did not accidentally modify the frontmatter block (the `---` ... `---` section at the top of the file).

- [ ] **Step 6: Verify CCR section present in all four skill files**

```bash
grep -l "Contract Challenge" skills/source/persona-{documentation,script-authoring,implementation,compliance}-agent.md
```

Expected: all four filenames printed.

- [ ] **Step 7: Commit**

```bash
git add skills/source/persona-documentation-agent.md \
        skills/source/persona-script-authoring-agent.md \
        skills/source/persona-implementation-agent.md \
        skills/source/persona-compliance-agent.md
git commit -m "feat(skills): add CCR responsibilities to all four agent persona skill files"
```
