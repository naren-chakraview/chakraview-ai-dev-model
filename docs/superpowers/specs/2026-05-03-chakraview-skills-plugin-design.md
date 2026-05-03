---
title: Chakraview AI Dev Model — Skills Plugin Design
description: Design spec for codifying the Chakraview AI Dev Model as installable AI agent skills across Claude Code, Cursor, Windsurf, GitHub Copilot, Codex, and Gemini CLI.
date: 2026-05-03
status: approved
---

# Chakraview Skills Plugin Design

## Overview

The Chakraview AI Dev Model defines 6 personas, an 8-phase workflow, and a contracts-first development methodology. This spec covers codifying that model as installable AI agent skills — 12 skills in a source-first layout, adapted at install time to 6 target platforms.

**Core principle**: one source file per skill, one install script that transforms and distributes to all platforms. No platform-specific content in `source/`.

---

## Directory Layout

```
chakraview-ai-dev-model/
└── skills/
    ├── source/
    │   ├── task-intake-triage.md
    │   ├── task-implement-service.md
    │   ├── task-compliance-review.md
    │   ├── task-write-adr.md
    │   ├── task-write-runbook.md
    │   ├── task-write-migration-phase.md
    │   ├── task-script-authoring.md
    │   ├── persona-documentation-agent.md
    │   ├── persona-script-authoring-agent.md
    │   ├── persona-implementation-agent.md
    │   ├── persona-compliance-agent.md
    │   ├── meta-workflow.md
    │   └── context/
    │       ├── coding-standards.md
    │       ├── infra-conventions.md
    │       └── observability-requirements.md
    ├── platforms/
    │   ├── claude-code/plugin.json
    │   ├── cursor/defaults.yaml
    │   ├── windsurf/defaults.yaml
    │   ├── copilot/preamble.md
    │   ├── codex/preamble.md
    │   └── gemini/preamble.md
    ├── scaffold/
    │   ├── contracts/slas/.gitkeep
    │   ├── contracts/domain-invariants/.gitkeep
    │   ├── contracts/event-schemas/.gitkeep
    │   ├── docs/adrs/.gitkeep
    │   ├── docs/ddd/.gitkeep
    │   ├── ai-agents/tasks/.gitkeep
    │   ├── ai-agents/context/.gitkeep
    │   └── ai-agents/reviews/.gitkeep
    ├── install.sh
    ├── scaffold.sh
    └── README.md
```

`source/` is the single source of truth. `platforms/` holds only config that cannot be derived from source files (frontmatter defaults, preamble headers). `scaffold/` is the blank project skeleton created by `install.sh --init`.

`source/context/` files are reference docs, not skills. At install time they are copied to `ai-agents/context/` in the project directory (all platforms). They are not registered as invokable skills — they exist to be read by skills at runtime.

---

## Skill Inventory

### Task skills — invoked by workflow step (7)

| Skill | Trigger | Personas invoked | Phases |
|---|---|---|---|
| `chakraview:intake-triage` | Starting a new feature/service; business intent needs architectural review | 2, 3, 5, 6 | 0 |
| `chakraview:implement-service` | Phase 5 entry; contracts, domain models, and infra scaffold exist | 5, 6 | 5 |
| `chakraview:compliance-review` | After Phase 4 (infrastructure) or Phase 5 (implementation) | 6 | 4, 5 |
| `chakraview:write-adr` | ADR stub exists; full MADR needed | 2 | 1 |
| `chakraview:write-runbook` | SLA and alerts exist; failure mode needs documented response | 2 | 6 |
| `chakraview:write-migration-phase` | Phase 6 entry; migration sequencing and rollback gates needed | 2 | 6 |
| `chakraview:script-authoring` | Deterministic transformation identified during intake or any phase | 3 | 0–6 |

### Persona skills — summon a single role directly (4)

| Skill | Persona | Authority |
|---|---|---|
| `chakraview:documentation-agent` | Persona 2 | Prose, ADRs, domain models, API specs, runbooks |
| `chakraview:script-authoring-agent` | Persona 3 | Deterministic scripts in `tooling/` only |
| `chakraview:implementation-agent` | Persona 5 | Service source code and tests |
| `chakraview:compliance-agent` | Persona 6 | Audit only — no implementation authority |

### Meta skill — orientation (1)

| Skill | What it does |
|---|---|
| `chakraview:workflow` | Reads current project state, identifies the correct workflow phase, routes to the right task skill |

---

## Source File Format

Every file in `source/` uses this frontmatter schema:

```yaml
---
name: chakraview:<slug>
type: task | persona | meta
description: >
  One-sentence description — used in platform registrations and skill indexes
triggers:
  - natural language condition under which this skill applies
phases: [N]                     # workflow phases this skill operates in
personas: [N]                   # persona numbers invoked inside this skill
reads:                          # project paths this skill expects to exist
  - path/to/dir/
  - path/to/file.yaml
writes:                         # project paths this skill produces
  - path/to/output/
---

# Skill body — platform-agnostic markdown
```

The body is written once. The `reads` and `writes` fields also drive `scaffold.sh` — the scaffold script creates every directory referenced across all source files.

---

## Install Script

### Invocation

```
./skills/install.sh [--target <platform>] [--project-dir <dir>] [--init] [--dry-run]
```

| Flag | Behaviour |
|---|---|
| `--target <platform>` | Install for one platform only; skip auto-detection |
| `--project-dir <dir>` | Project root for project-local platforms (default: `$PWD`) |
| `--init` | Run `scaffold.sh` to create the Chakraview project directory structure |
| `--dry-run` | Print every action without writing anything |

### Auto-detection

When `--target` is omitted, the script detects installed platforms and asks for confirmation before writing to each:

| Platform | Detection signal |
|---|---|
| Claude Code | `~/.claude/` exists |
| Cursor | `.cursor/` in project dir OR `cursor` in PATH |
| Windsurf | `.windsurf/` in project dir OR `windsurf` in PATH |
| GitHub Copilot | `.github/` exists in project dir |
| Codex | `AGENTS.md` exists OR `openai` in PATH |
| Gemini CLI | `.gemini/` exists OR `gemini` in PATH |

For each detected platform: show destination path, ask for confirmation, then write.

### Install targets

| Platform | Install location | Scope |
|---|---|---|
| Claude Code | `~/.claude/skills/chakraview/<skill-name>/SKILL.md` | Global (user) |
| Cursor | `.cursor/rules/chakraview-<skill-name>.mdc` | Project |
| Windsurf | `.windsurf/rules/chakraview-<skill-name>.md` | Project |
| GitHub Copilot | `.github/copilot-instructions.md` | Project |
| Codex | `AGENTS.md` | Project |
| Gemini CLI | `GEMINI.md` | Project |

---

## Platform Adaptation Rules

### Claude Code

`platforms/claude-code/plugin.json` maps each source file's `name` slug to the install subdirectory name. Used by the install script to resolve `chakraview:intake-triage` → `intake-triage/SKILL.md` without parsing source filenames.

One subdirectory per skill. Frontmatter preserved verbatim (Claude Code reads it natively):

```
~/.claude/skills/chakraview/intake-triage/SKILL.md
~/.claude/skills/chakraview/implement-service/SKILL.md
...
```

### Cursor and Windsurf

Chakraview frontmatter stripped. Platform frontmatter injected. Body preserved as-is. Saved as `.mdc` (Cursor) or `.md` (Windsurf).

```yaml
---
description: "chakraview:intake-triage — Run intake/triage dialogue before writing contracts"
alwaysApply: false
---
```

Invocation in chat: `@chakraview-intake-triage`

Platform-specific frontmatter defaults (e.g., `alwaysApply`, `globs`) stored in `platforms/cursor/defaults.yaml` and `platforms/windsurf/defaults.yaml`.

### GitHub Copilot, Codex, Gemini CLI

Single concatenated file per platform. Skills ordered by: workflow phase ascending → persona skills → meta skill.

```markdown
<!-- Generated by chakraview install.sh — do not edit manually -->
<!-- Re-run install.sh to update -->

## chakraview:workflow
{body}

---
## chakraview:intake-triage
{body}

---
## chakraview:implement-service
{body}
...
```

**Sentinel-based update**: if the target file already exists, the script replaces only the block between `<!-- Generated by chakraview -->` and `<!-- /Generated by chakraview -->` sentinels. Content outside the sentinels is left untouched.

Platform-specific preambles (e.g., framing context for Copilot vs. Codex) stored in `platforms/<platform>/preamble.md` and prepended inside the sentinel block.

---

## Scaffold Script

`scaffold.sh` creates the Chakraview project directory structure. Called by `install.sh --init` or standalone.

Directories are derived from the union of all `reads` and `writes` entries across `source/*.md`. The script is idempotent — safe to re-run; never overwrites existing files, only creates missing directories and `.gitkeep` files.

```
./skills/scaffold.sh [--project-dir <dir>]
```

---

## README

`skills/README.md` covers:

1. Prerequisites (which tools must already be installed)
2. Quickstart: `git clone` → `cd chakraview-ai-dev-model/skills` → `./install.sh --init`
3. Per-platform invocation examples (how to call each skill in each tool)
4. How to update after a new version: re-run `install.sh`
5. How to add a new skill: add a file to `source/`, re-run `install.sh`

---

## Out of Scope

- Publishing to a package registry (npm, PyPI, Homebrew) — follow-on after this version is stable
- GUI installer or web-based setup wizard
- Per-skill version pinning
- Automatic update checking
