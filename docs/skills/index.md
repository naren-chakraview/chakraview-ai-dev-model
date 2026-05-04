---
title: Skills Plugin
description: Installable AI agent skills for Claude Code, Cursor, Windsurf, GitHub Copilot, OpenAI Codex, and Gemini CLI.
---

# Skills Plugin

The Chakraview AI Dev Model ships as installable skills for six AI coding platforms. One `install.sh` script detects your environment and writes the right format to the right place.

**Supported platforms:** Claude Code · Cursor · Windsurf · GitHub Copilot · OpenAI Codex · Gemini CLI

---

## Quickstart

```bash
git clone https://github.com/naren-chakraview/chakraview-ai-dev-model
cd chakraview-ai-dev-model/skills
./install.sh --init
```

`--init` installs skills for all detected platforms and scaffolds your project directory structure (`contracts/`, `docs/adrs/`, `ai-agents/`, etc.).

---

## Install Options

```bash
./install.sh                                       # auto-detect all platforms
./install.sh --target claude-code                  # single platform
./install.sh --target cursor --project-dir /path/to/project
./install.sh --dry-run                             # preview without writing
```

Platforms: `claude-code` · `cursor` · `windsurf` · `copilot` · `codex` · `gemini`

---

## How to Invoke Skills

| Platform | Invocation |
|---|---|
| Claude Code | `chakraview:intake-triage` via Skill tool |
| Cursor | `@chakraview-intake-triage` in chat |
| Windsurf | `@chakraview-intake-triage` in chat |
| GitHub Copilot / Codex / Gemini | Reference skill by name in chat |

---

## Skill Reference

### Task skills — enter by workflow step

| Skill | When to use | Phases |
|---|---|---|
| `chakraview:intake-triage` | Before any contract is written — new feature or service | 0 |
| `chakraview:implement-service` | Phase 5 — contracts, domain models, and infra scaffold exist | 5 |
| `chakraview:compliance-review` | After Phase 4 (infra) or Phase 5 (implementation) | 4, 5 |
| `chakraview:write-adr` | Expand an ADR stub into a full MADR | 1 |
| `chakraview:write-runbook` | Produce an ops runbook for a failure mode | 6 |
| `chakraview:write-migration-phase` | Phase 6 migration sequencing and rollback gates | 6 |
| `chakraview:script-authoring` | Write a deterministic `tooling/` script | 0–6 |

### Persona skills — summon a single role directly

| Skill | Persona | Authority |
|---|---|---|
| `chakraview:documentation-agent` | Persona 2 | Prose, ADRs, domain models, API specs, runbooks |
| `chakraview:script-authoring-agent` | Persona 3 | Deterministic scripts in `tooling/` only |
| `chakraview:implementation-agent` | Persona 5 | Service source code and tests |
| `chakraview:compliance-agent` | Persona 6 | Audit only — no implementation authority |

### Meta skill — orientation

| Skill | What it does |
|---|---|
| `chakraview:workflow` | Reads current project state, identifies the phase, routes to the right task skill |

---

## Platform Install Locations

| Platform | Install location | Scope |
|---|---|---|
| Claude Code | `~/.claude/skills/chakraview/<skill>/SKILL.md` | Global (user) |
| Cursor | `.cursor/rules/chakraview-<skill>.mdc` | Project |
| Windsurf | `.windsurf/rules/chakraview-<skill>.md` | Project |
| GitHub Copilot | `.github/copilot-instructions.md` | Project |
| OpenAI Codex | `AGENTS.md` | Project |
| Gemini CLI | `GEMINI.md` | Project |

For Copilot, Codex, and Gemini the installer concatenates all skills into a single file wrapped in sentinel comments. Re-running `install.sh` replaces only the generated block — your custom content outside the sentinels is preserved.

---

## Updating

```bash
cd chakraview-ai-dev-model/skills
git pull
./install.sh
```

---

## Adding a Skill

1. Add a file to `source/` with the required frontmatter (`name`, `type`, `description`, `triggers`)
2. Run `./tests/validate-sources.sh` to verify it passes validation
3. Run `./install.sh` to distribute it to all platforms
