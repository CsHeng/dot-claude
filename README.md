# Claude Code Configuration System

Unified Memory → Agent → Skill architecture for Claude Code plus tooling to sync rules and commands into IDEs and external CLIs.

## Overview
- **Memory files** (`CLAUDE.md`, `AGENTS.md`) route every task to an agent, which in turn loads the required skills.
- **Skills** (`skills/<name>/SKILL.md`) package single capabilities (toolchain checks, workflow rules, LLM governance, etc.).
- **Agents** (`agents/<name>/AGENT.md`) describe how slash commands should run: inputs, outputs, permissions, fail-fast rules.
- **Commands** (`commands/**`) remain pure tools (shell scripts, documentation prompts). They rely on agents/skills for policy.
- **Config-sync** copies the configuration into IDE workspaces or CLI tools.

## Repository Layout
```
.claude/
├── agents/                 # Agent manifests (execution contracts)
├── commands/               # Slash commands (config-sync, doc-gen, etc.)
├── docs/                   # Documentation and guides
├── rules/                  # Development standards referenced by skills
├── skills/                 # Skill manifests (single capability)
├── AGENTS.md               # Operator guide (this repo)
├── CLAUDE.md               # Memory routing table for Claude Code
└── settings.json           # Global preferences / permissions
```

## Quick Start
```bash
git clone <repo> ~/.claude
cd ~/.claude

# Verify base configuration
claude /doctor
```

### Sync to IDE (project) tools
```bash
# From inside a project (or set CLAUDE_PROJECT_DIR)
claude /config-sync:sync-project-rules --all --project-root=/path/to/project
```

### Sync to CLI tools
```bash
claude /config-sync:sync-cli --action=sync --target=all --components=all
```

## Memory → Agent → Skill
- **CLAUDE.md** lists agents and their default/optional skills; Memory no longer enumerates rule files directly.
- **Agents** (e.g., `agent:config-sync`, `agent:doc-gen`, `agent:workflow-helper`) describe responsibilities, required inputs, permissions, fallback behavior.
- **Skills** (e.g., `skill:toolchain-baseline`, `skill:workflow-discipline`, `skill:llm-governance`, `skill:language-python`) cite the relevant `rules/` sections and provide validation steps.
- Commands reference agents in their README to show which skills are active.

## Key Commands
| Category | Commands | Purpose |
| --- | --- | --- |
| Config Sync | `/config-sync/sync-cli`, `/config-sync/sync-project-rules`, `/config-sync:*` | Sync rules/commands/memory to IDE and CLI targets |
| Documentation | `/doc-gen:*` | Generate architecture/integration docs via adapters |
| Reviews | `/review-llm-prompts`, `/review-shell-syntax` | LLM prompt governance and shell linting |
| Workflow Helpers | `/commands:draft-commit-message` | Git helper |

See `docs/commands.md` for the complete list.

## Rules & Settings
- `rules/00-memory-rules.md`: personal preferences, shell strict-mode, communication style
- `rules/01-23`: development, architecture, security, logging, workflow standards
- `rules/99-llm-prompt-writing-rules.md`: ABSOLUTE-mode instructions for all LLM-facing files
- `settings.json` plus `.claude/settings.json` control tool permissions (allow/ask/deny)

## Config-Sync Overview
- Targets: `droid`, `qwen`, `codex`, `opencode`, `claude`, and IDE project directories
- Components: `rules`, `permissions`, `commands`, `settings`, `memory`
- Pipeline: collect → analyze → plan → prepare → adapt → execute → verify → report
- Backups: `~/.claude/backup/run-<timestamp>/`
- Logs and plans show agent/skill versions for auditing

### Examples
```bash
# Analyze without changes
claude /config-sync:sync-cli --action=analyze --target=qwen

# Sync only rules + commands for Codex
claude /config-sync:sync-cli --action=sync --target=codex --components=rules,commands

# Project-level rules copy
claude /config-sync:sync-project-rules --all --project-root=/repo/path
```

## Daily Workflow
- Edit rules/skills/agents; CLAUDE automatically loads them
- Run `/config-sync:sync-project-rules` after rule updates to push to IDE directories
- Run `/config-sync:sync-cli --action=sync` to push to CLI targets
- Use `/review-llm-prompts` to audit commands/skills/docs after changes

## Maintenance
```bash
# Validate configuration
claude /doctor

# Verify IDE sync without changes
claude /config-sync:sync-project-rules --verify-only --project-root=/repo/path

# Verify CLI targets
claude /config-sync:sync-cli --action=verify --target=all
```

### Extending the System
1. **New skill**: create `skills/<category>-<name>/SKILL.md`, cite rule sections, run `/review-llm-prompts --target=skills/<name>`.
2. **New agent**: create `agents/<domain>-<role>/AGENT.md`, hook it up to commands in their README, and add it to CLAUDE.md.
3. **New command**: add `commands/<name>.md`, describe agent mapping, and follow the slash-command spec.

Refer to `requirements/01-claude.md` for the complete taxonomy, workflows, and action plan. 
3. **Settings**: Update appropriate settings file

📖 **[Maintenance Guide](docs/directory-structure.md#migration-guide)**

## 🔍 Quick Troubleshooting

| Issue | Solution |
|-------|----------|
| Rules not loading | Check file naming, run `claude /doctor` |
| IDE sync not working | Verify project structure, check permissions |
| CLI sync failed | Run `/config-sync/sync-cli --action=analyze --target=<tool>` |
| Permission denied | Check settings hierarchy and syntax |

📖 **[Complete Troubleshooting Guide](docs/troubleshooting.md)**

## 📚 Documentation

- **[Settings Guide](docs/settings.md)** – Configuration hierarchy
- **[Permissions Reference](docs/permissions.md)** – Command control
- **[Config-Sync Guide](docs/config-sync-guide.md)** – Complete sync system documentation
- **[CLI Sequence Diagram](docs/config-sync-cli-sequence-diagram.puml)** – CLI workflow visualization
- **[Project Rules Sequence Diagram](docs/config-sync-project-sequence-diagram.puml)** – IDE integration workflow

## 🎯 Benefits

- **Claude Code First**: Optimize for Claude Code, extend to other tools
- **Consistent Standards**: Same rules across all development environments
- **Single Source of Truth**: Update once, sync everywhere
- **Tool Flexibility**: Use Claude Code alone or with IDE/CLI assistants
- **Project Isolation**: Project-specific overrides when needed

This system ensures your development standards follow you everywhere—whether using Claude Code directly, IDE plugins, or CLI assistants—all managed from one central configuration.
