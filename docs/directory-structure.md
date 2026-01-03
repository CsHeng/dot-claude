# Directory Structure

This document describes the complete directory structure of the Claude Code configuration system.

## Root Directory Structure

```
~/.claude/
├── 📁 .claude/                    # Internal Claude Code configuration
│   └── ⚙️ settings.json           # Shared permissions and tool access
├── 📁 backup/                     # Config-sync backup system
├── 📁 commands/                   # Custom slash commands
├── 📁 debug/                      # Runtime debugging information
├── 📁 docs/                       # Documentation files
├── 📁 file-history/               # File modification tracking
├── 📁 ide/                        # IDE integration lock files
├── 📁 lib/                        # Shared libraries (currently empty)
├── 📁 plugins/                    # Plugin system
├── 📁 projects/                   # Project-specific configurations
├── 📁 rules/                      # Development guidelines and rules
├── 📁 session-env/                # Session environment variables
├── 📁 shell-snapshots/            # Shell command history
├── 📁 statsig/                    # Analytics and metrics
├── 📁 todos/                      # Task tracking
├── 📄 AGENTS.md                   # Agent operating instructions
├── 📄 CLAUDE.md                   # Claude's memory and context
└── ⚙️ settings.json               # Global Claude Code preferences
```

## Core Configuration Files

### Settings Files

| File | Purpose | Scope |
|------|---------|-------|
| `settings.json` | Global Claude Code preferences | System-wide |
| `.claude/settings.json` | Shared permissions and tool access | Configuration system |
| `.claude/settings.local.json` | Local overrides (git-ignored) | Personal overrides |

### Memory and Instructions

| File | Purpose | Content |
|------|---------|---------|
| `CLAUDE.md` | Claude's memory and context index | Personal preferences, project context |
| `AGENTS.md` | Agent operating instructions | How AI agents should operate |

## Key Directories

### Development Guidelines

Numbered rule files that automatically load based on file patterns:

```
rules/
├── 00-memory-rules.md              # Personal preferences (all files)
├── 01-development-standards.md     # General standards (all files)
├── 02-architecture-patterns.md     # Architecture patterns
├── 03-security-standards.md        # Security practices
├── 04-testing-strategy.md          # Testing approaches
├── 05-error-patterns.md            # Error handling
├── 10-python-guidelines.md         # Python files (**/*.py)
├── 11-go-guidelines.md             # Go files (**/*.go)
├── 12-shell-guidelines.md          # Shell scripts (**/*.sh)
├── 13-docker-guidelines.md         # Docker files, Makefiles
├── 14-networking-guidelines.md     # Network patterns
├── 20-tool-standards.md            # Tool configuration
├── 21-quality-standards.md         # Code quality
├── 22-logging-standards.md         # Logging standards
├── 23-workflow-patterns.md         # Workflow patterns
├── 98-communication-protocol.md    # communication protocols
├── 99-llm-prompt-writing-rules.md  # AI/LLM agent development
```

### Commands

Custom commands that extend Claude Code functionality:

```
commands/
├── draft-commit-message.md         # Git commit helper
├── review-shell-syntax.md          # Shell script validation
└── check-secrets.md                # Security scan for credentials
```

Project-level tooling (not synced as payload):
```
.claude/commands/
├── llm-governance.md               # LLM-facing manifest audits and fixes
├── lint-markdown.md                # Markdown validation tooling
└── config-sync/                    # Multi-tool config sync implementation
    ├── sync-cli.{md,sh}            # Unified CLI orchestrator
    ├── adapters/                   # Target-specific shell adapters (*.sh)
    ├── lib/                        # Shared helpers + phase runners + planners
    └── scripts/                    # Backup management, cleanup, taxonomy sync
```

### Documentation

Comprehensive documentation for the configuration system:

```
docs/
├── commands.md                     # Command reference
├── config-sync-guide.md           # Complete sync system guide
├── config-sync-cli-sequence-diagram.puml  # CLI workflow visualization
├── directory-structure.md         # This file
├── permissions.md                  # Permission system reference
└── settings.md                     # Configuration hierarchy
```

### Backup System

Automatic backups created during sync operations:

```
backup/
├── plan-<timestamp>.json          # Execution plans for resumption
├── run-<timestamp>/               # Per-run backups, logs, metadata
│   ├── backups/                   # Target-specific configuration snapshots
│   ├── logs/                      # Run logs
│   └── metadata/                  # Summary and plan metadata
└── rollback-<timestamp>/          # Rollback candidates created by governance or sync flows
```

### Runtime Directories

These directories are created and managed automatically:

| Directory | Purpose | Content |
|-----------|---------|---------|
| `debug/` | Runtime debugging | Logs, error traces |
| `file-history/` | File tracking | Modification history |
| `ide/` | IDE integration | Lock files, state |
| `session-env/` | Session data | Environment variables |
| `shell-snapshots/` | Command history | Shell command logs |
| `statsig/` | Analytics | Usage metrics |
| `todos/` | Task tracking | Active task lists |

## Configuration Priority

1. **Global Settings**: `settings.json` (root level)
2. **Shared Permissions**: `.claude/settings.json`
3. **Local Overrides**: `.claude/settings.local.json` (git-ignored)
4. **Rules**: Numbered files in `/rules/` (auto-loaded by pattern)
5. **Commands**: Slash commands in `/commands/`
6. **Project Config**: `/projects/` (project-specific overrides)

## File Naming Conventions

### Rules Files
- Format: `XX-description.md`
- `XX`: Two-digit number for loading order
- `description`: kebab-case description
- Examples: `01-development-standards.md`, `10-python-guidelines.md`

### Command Files
- Top-level: `command-name.md`
- Nested: `category/command-name.md`
- Examples: `draft-commit-message.md`, `config-sync/sync-cli.md`

### Backup Files
- Plans: `plan-YYYYMMDD-HHMMSS.json`
- Tool backups: `toolname-YYYYMMDD-HHMMSS/`

## Git Considerations

### Tracked Files
- All configuration files except local overrides
- Rules and commands
- Documentation

### Git-Ignored Files
- `.claude/settings.local.json`
- Runtime directories (`debug/`, `session-env/`, etc.)
- Backup directories
- IDE lock files

### Recommended .gitignore Pattern
```gitignore
# Local overrides
.claude/settings.local.json

# Runtime directories
debug/
file-history/
session-env/
shell-snapshots/
statsig/
todos/

# Backup system
backup/

# IDE integration
ide/
```

## Migration Guide

When moving this configuration to a new system:

1. **Copy Core Files**:
   - `settings.json`
   - `.claude/settings.json`
   - `rules/` directory
   - `commands/` directory
   - `CLAUDE.md`, `AGENTS.md`

2. **Regenerate Runtime Files**:
   - Runtime directories will be created automatically
   - Backup system will initialize on first sync

3. **Update Local Settings**:
   - Create `.claude/settings.local.json` for system-specific preferences
   - Adjust paths and tool locations as needed

## Related Documentation

- **[Settings Reference](./settings.md)** - Configuration hierarchy and permissions
- **[Commands Reference](./commands.md)** - Available slash commands
- **[Config-Sync Guide](./config-sync-guide.md)** - Sync system documentation
