# Command Layout Overview

This repo has two command scopes:

- **User-level commands**: `~/.claude/commands/` (synced to other tools)
- **Project-level commands/tools**: `.claude/commands/` (implementation tooling; must not be part of the synced payload)

## Directory Structure
```
~/.claude/commands/
├── draft-commit-message.md        # Git commit message drafting
├── review-shell-syntax.md         # Shell script validation
└── check-secrets.md               # Security scan for credentials
```

Project-level config-sync implementation (not synced as payload):
```
<project>/.claude/commands/
├── llm-governance.md              # LLM-facing manifest audits and fixes
├── lint-markdown.md               # Markdown validation tooling
└── config-sync/                   # Multi-target config sync implementation

<project>/.claude/commands/config-sync/
├── README.md
├── sync-cli.md
├── sync-cli.sh
├── adapters/                      # Target-specific shell adapters
├── lib/                           # Shared shell helpers + planners + Python modules
└── scripts/                       # Backup/phase helpers + taxonomy sync
```

## Available Commands

### Config-Sync Commands

| Command | Purpose | Key Features |
|---------|---------|--------------|
| `/config-sync/sync-cli` | Unified orchestrator for config-sync workflows | Multi-target support (droid, qwen, codex, opencode, amp), 9-phase pipeline, plan generation, verification, rollback |

### LLM Governance Commands

| Command | Purpose | Scope |
|---------|---------|-------|
| `/llm-governance` | Design-time audits and fixes for LLM-facing files | All LLM-facing files (commands, skills, agents, rules, settings), dependency analysis, specification validation |

### AgentOps Commands

| Command | Purpose | Scope |
|---------|---------|-------|
| `/agent-ops:health-report` | Read-only health report for agents, skills, backups, and governance runs | `backup/` metadata, agent/skill matrices, governance validation |
| `/agent-ops:agent-matrix` | Capability matrix for all agents | Agent identifiers, capability levels, loop styles, style labels, default/optional skills |
| `/agent-ops:skill-matrix` | Capability matrix for all skills | Skill identifiers, capability levels, modes, style labels, tags |

### Workflow and Review Commands

| Command | Purpose | Scope |
|---------|---------|-------|
| `/draft-commit-message` | Generate commit messages from git status | Current repository, directory filtering, staged/unstaged change analysis |
| `/review-shell-syntax` | Validate shell script compliance | Rules from `rules/12-shell-guidelines.md`, ShellCheck integration, auto-fix patches |
| `/check-secrets` | Scan for credentials and sensitive data | API keys, passwords, private keys, connection strings, environment variables |

## Command Guidelines

### Frontmatter Requirements
Each command file must include YAML frontmatter with:
- `name`: Command name (used for slash command registration)
- `description`: Brief purpose description
- `argument-hint`: Usage syntax (optional)
- `allowed-tools`: Permitted tool permissions (optional)
- `style`: Output style preference (minimal-chat, tool-first, reasoning-first)

### Naming Conventions
- Use slash-style names for top-level handlers
- Reference other commands via published slash form, not file paths
- Use hyphens for multi-word command names

### Development Best Practices
- Tool adapters exclude internal `config-sync/` module when syncing to external CLIs
- Use `.claude/commands/config-sync/lib/common.sh` for shared utilities
- Include parameter tables, usage examples, and error handling documentation
- Follow `.claude/skills/llm-governance/rules/99-llm-prompt-writing-rules.md` for LLM-facing content
- Implement proper error handling with descriptive exit codes
- Maintain strict shell mode (`set -euo pipefail`) in all bash scripts

### Config-Sync System Integration
- Target systems: Droid CLI, Qwen CLI, OpenAI Codex CLI, OpenCode, Amp CLI
- Components: commands, rules, skills, agents, output_styles, settings, permissions, memory
- Phase execution: collect → analyze → plan → prepare → adapt → execute → [verify] → cleanup → report
- Backup retention: Automatic backups before modifications, configurable retention policies

## Related Documentation

- **[Config-Sync Guide](./config-sync-guide.md)** - Complete sync system documentation
- **[Config-Sync README](../.claude/commands/config-sync/README.md)** - Technical reference and architecture
- **[LLM Governance Scripts README](../.claude/skills/llm-governance/scripts/README.md)** - Implementation details and usage
- **[Settings Reference](./settings.md)** - Configuration hierarchy and permissions
- **[Directory Structure](./directory-structure.md)** - Detailed file organization
