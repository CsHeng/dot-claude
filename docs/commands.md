# Command Layout Overview (`~/.claude/commands/`)

The commands directory contains slash commands for various workflows including config-sync, governance optimization, code review, security checks, and utility operations.

## Directory Structure
```
~/.claude/commands/
├── config-sync/                    # Config-sync command suite
│   ├── README.md                   # Config-sync system reference
│   ├── sync-cli.md/.sh             # Main orchestrator for CLI tool sync
│   ├── sync-project-rules.md/.sh   # Project rules sync for IDEs
│   ├── adapters/                   # Target-specific shell adapters
│   │   ├── droid.sh
│   │   ├── qwen.sh
│   │   ├── codex.sh
│   │   ├── opencode.sh
│   │   ├── amp.sh
│   │   ├── adapt-permissions.sh
│   │   └── sync-memory.sh
│   ├── lib/                        # Shared utilities
│   │   ├── common.sh               # Shared shell helpers
│   │   ├── phases/                 # Phase execution runners
│   │   │   ├── collect.sh
│   │   │   ├── analyze.sh
│   │   │   ├── plan.sh
│   │   │   ├── prepare.sh
│   │   │   ├── adapt.sh
│   │   │   ├── execute.sh
│   │   │   ├── verify.sh
│   │   │   ├── report.sh
│   │   │   └── cleanup.sh
│   │   └── planners/               # Plan generation logic
│   │       ├── adapt_plan.sh
│   │       └── sync_plan.sh
│   └── scripts/                    # Bash helpers
│       ├── backup.sh               # Backup management
│       ├── backup-cleanup.sh       # Automatic cleanup
│       ├── executor.sh             # Phase execution
│       └── sync-taxonomy-component.sh
├── llm-governance/optimize-prompts.md    # LLM-facing manifest optimization
│   └── README.md                         # Implementation details
├── agent-ops/                     # AgentOps utilities
│   ├── health-report.md           # Agent and skill health reporting
│   ├── agent-matrix.md            # Agent capability matrix view
│   ├── skill-matrix.md            # Skill capability matrix view
│   └── scripts/                   # Utility scripts
│       ├── agent-matrix.sh
│       └── skill-matrix.sh
├── draft-commit-message.md        # Git commit message drafting
├── review-shell-syntax.md         # Shell script validation
└── check-secrets.md               # Security scan for credentials
```

## Available Commands

### Config-Sync Commands

| Command | Purpose | Key Features |
|---------|---------|--------------|
| `/config-sync:sync-cli` | Unified orchestrator for config-sync workflows | Multi-target support (droid, qwen, codex, opencode, amp), 9-phase pipeline, plan generation, verification, rollback |
| `/config-sync:sync-project-rules` | Sync shared Claude rules to project IDE directories | Cursor (`.cursor/rules`), VS Code Copilot (`.github/instructions`), auto-detection, header processing |

### LLM Governance Commands

| Command | Purpose | Scope |
|---------|---------|-------|
| `/llm-governance/optimize-prompts` | Design-time audits and fixes for LLM-facing files | All LLM-facing files (commands, skills, agents, rules, settings), dependency analysis, specification validation |

### AgentOps Commands

| Command | Purpose | Scope |
|---------|---------|-------|
| `/agent-ops:health-report` | Read-only health report for agents, skills, backups, and governance runs | `.claude/backup` metadata, agent/skill matrices, governance validation |
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
- Use hyphens for multi-word command names (e.g., `sync-project-rules`)

### Development Best Practices
- Tool adapters exclude internal `config-sync/` module when syncing to external CLIs
- Use `commands/config-sync/lib/common.sh` for shared utilities
- Include parameter tables, usage examples, and error handling documentation
- Follow `rules/99-llm-prompt-writing-rules.md` for LLM-facing content
- Implement proper error handling with descriptive exit codes
- Maintain strict shell mode (`set -euo pipefail`) in all bash scripts

### Config-Sync System Integration
- Target systems: Droid CLI, Qwen CLI, OpenAI Codex CLI, OpenCode, Amp CLI
- Components: commands, rules, skills, agents, output_styles, settings, permissions, memory
- Phase execution: collect → analyze → plan → prepare → adapt → execute → [verify] → cleanup → report
- Backup retention: Automatic backups before modifications, configurable retention policies

## Related Documentation

- **[Config-Sync Guide](./config-sync-guide.md)** - Complete sync system documentation
- **[Config-Sync README](../commands/config-sync/README.md)** - Technical reference and architecture
- **[LLM Governance README](../commands/llm-governance/optimize-prompts/README.md)** - Implementation details
- **[Settings Reference](./settings.md)** - Configuration hierarchy and permissions
- **[Directory Structure](./directory-structure.md)** - Detailed file organization