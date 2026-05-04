# Chakraview AI Dev Model — Skills Plugin

Installable AI agent skills for the [Chakraview AI Dev Model](../docs/model.md).
Supports Claude Code, Cursor, Windsurf, GitHub Copilot, OpenAI Codex, and Gemini CLI.

## Prerequisites

- Bash 4.5+
- The target platform installed (e.g., Claude Code CLI, Cursor, Windsurf)
- Run from the `skills/` directory inside the `chakraview-ai-dev-model` repo

## Quickstart

```bash
cd chakraview-ai-dev-model/skills
./install.sh --init   # install skills + scaffold project structure
```

`--init` creates `contracts/`, `docs/adrs/`, `ai-agents/`, etc. in the current directory.

## Options

```bash
./install.sh --target claude-code              # single platform
./install.sh --target cursor --project-dir /path/to/project
./install.sh --dry-run                         # preview without writing
```

Platforms: `claude-code` · `cursor` · `windsurf` · `copilot` · `codex` · `gemini`

## Invocation per platform

| Platform | How to invoke |
|---|---|
| Claude Code | `chakraview:intake-triage` via Skill tool |
| Cursor | `@chakraview-intake-triage` in chat |
| Windsurf | `@chakraview-intake-triage` in chat |
| Copilot / Codex / Gemini | Reference skill by name in chat |

## Skill reference

| Skill | When to use |
|---|---|
| `chakraview:workflow` | Orient to the current phase and route to the right skill |
| `chakraview:intake-triage` | Before any contract is written — new feature or service |
| `chakraview:implement-service` | Phase 5 — contracts and domain models exist |
| `chakraview:compliance-review` | After Phase 4 (infra) or Phase 5 (implementation) |
| `chakraview:write-adr` | Expand an ADR stub into a full MADR |
| `chakraview:write-runbook` | Produce an ops runbook for a failure mode |
| `chakraview:write-migration-phase` | Phase 6 migration sequencing |
| `chakraview:script-authoring` | Write a deterministic `tooling/` script |
| `chakraview:documentation-agent` | Persona 2 — prose, ADRs, API specs |
| `chakraview:script-authoring-agent` | Persona 3 — deterministic scripts only |
| `chakraview:implementation-agent` | Persona 5 — service source code |
| `chakraview:compliance-agent` | Persona 6 — audit only, no implementation authority |

## Updating

Re-run `./install.sh` after pulling. For Copilot/Codex/Gemini the generated block is replaced in place; your custom content outside the sentinels is preserved.

## Adding a skill

1. Add a file to `source/` with the required frontmatter (`name`, `type`, `description`, `triggers`)
2. Run `./tests/validate-sources.sh` to verify it passes validation
3. Run `./install.sh` to distribute it
