# Claude Code Configuration System

Claude Code rules, permissions, and agent configuration with sync capabilities for IDE and CLI coding assistants.

## 🎯 Core Concept

This system treats **Claude Code as the primary source of truth** for:
- **Rules**: Development guidelines in `rules/`
- **Permissions**: Command execution control in settings files
- **Agent Instructions**: Operating procedures in `AGENTS.md` and `CLAUDE.md`

From this central configuration, we sync to:
- **IDE Tools**: Cursor, VS Code Copilot (via `/config-sync/sync-project-rules`)
- **CLI Tools**: Qwen, Factory/Droid, Codex, OpenCode (via `/config-sync/sync-cli`)

## 📁 Essential Files

```
.claude/
├── 📁 .claude/
│   └── ⚙️ settings.json           # Shared permissions
├── 📁 commands/                   # Custom slash commands
│   └── 📁 config-sync/            # Multi-tool sync utilities (`sync-cli.{md,sh}`, `sync-project-rules.{md,sh}`)
├── 📁 docs/                       # Detailed documentation
├── 📁 rules/                      # Development guidelines by category
├── 📄 AGENTS.md                   # Agent operating instructions
├── 📄 CLAUDE.md                   # Claude's memory and context
├── ⚙️ settings.json               # Global preferences
```

## 🚀 Quick Start

### 1. Set up Claude Code Configuration
```bash
git clone <repository-url> ~/.claude
cd ~/.claude

# Generate your settings
# Ask: "Create settings.json for my development environment"
claude /doctor  # Verify configuration
```

### 2. Sync to IDE Tools (Project Level)
```bash
# From inside the project (or set CLAUDE_PROJECT_DIR)
/config-sync/sync-project-rules --all

```

### 3. Sync to CLI Tools (Optional)
```bash
# Analyze available CLI tools
/config-sync/sync-cli --action=analyze --target=all

# Sync configuration to installed tools
/config-sync/sync-cli --action=sync --target=all

# Verify sync worked
/config-sync/sync-cli --action=verify --target=all
```

## 🔧 Configuration Components

### **Rules Library** (`rules/`)
Automatically loaded by Claude Code:

**Core Rules:**
- `00-memory-rules.md` - Personal preferences (all files)
- `01-development-standards.md` - General standards (all files)
- `02-architecture-patterns.md` - Architecture patterns
- `03-security-standards.md` - Security practices
- `04-testing-strategy.md` - Testing approaches
- `05-error-patterns.md` - Error handling

**Language-Specific Rules:**
- `10-python-guidelines.md` - Python (`**/*.py`)
- `11-go-guidelines.md` - Go (`**/*.go`)
- `12-shell-guidelines.md` - Shell (`**/*.sh`)
- `13-docker-guidelines.md` - Docker (docker files, Makefiles)
- `14-networking-guidelines.md` - Network patterns

**Tool & Process Rules:**
- `20-tool-standards.md` - Tool configuration
- `21-quality-standards.md` - Code quality
- `22-logging-standards.md` - Logging standards
- `23-workflow-patterns.md` - Workflow patterns

**AI & LLM Rules:**
- `98-communication-protocol.md` - Default ABSOLUTE MODE communication standards
- `99-llm-prompt-writing-rules.md` - AI/LLM agent development

Rules auto-apply by file patterns. See `rules/00-memory-rules.md` for details.

### **Permission System**
Three-tier command control in settings files:
- **allow**: Runs automatically
- **ask**: Requires confirmation
- **deny**: Blocked completely

📖 **[Permissions Reference](docs/permissions.md)**

### **Agent Instructions**
- **AGENTS.md**: How AI agents should operate
- **CLAUDE.md**: Claude's memory and context index

## 🔄 Sync Capabilities

### IDE Plugin Sync
- **Target**: Cursor, VS Code Copilot
- **Method**: `/config-sync/sync-project-rules`
- **Scope**: Project-level rules distribution
- **Usage**: Run in each project directory

📖 **[IDE Sync Guide](docs/sync-project-rules.md)**

### CLI Tool Sync
- **Target**: Qwen, Factory/Droid, Codex, OpenCode
- **Method**: `/config-sync/sync-cli --action=<sync|analyze|verify|adapt|plan|report>`
- **Scope**: Full configuration (rules, permissions, commands, memory)
- **Features**: PlantUML integration, documentation generation
- **Command Files**: `commands/config-sync/sync-cli.{md,sh}`
- **Usage**: One-time setup per tool

📖 **[CLI Sync Commands](docs/config-sync-commands.md)**

### **Command Library (`commands/`)**

| Slash command | Location | Purpose |
| --- | --- | --- |
| `/config-sync/sync-cli`, `/config-sync/sync-project-rules` | `commands/config-sync/sync-cli.{md,sh}`, `commands/config-sync/sync-project-rules.{md,sh}`, adapters under `commands/config-sync/adapters/` | Multi-target sync orchestrator plus IDE rule distribution helpers. |
| `/doc-gen:*` | `commands/doc-gen/` (core orchestrator, adapters, lib) | Documentation generation workflows for SDK/demo deliverables. |
| `/draft-commit-message` | `commands/draft-commit-message.md` | Proposes commit subjects + bullet points from current git status/diffs. |
| `/review-shell-syntax` | `commands/review-shell-syntax.md` | Validates shell scripts against `rules/12-shell-guidelines.md` and runs syntax checks. |
| `/review-llm-prompts` | `commands/review-llm-prompts.md`, helpers in `commands/review-llm-prompts/` | Audits LLM-facing prompts for `rules/99-llm-prompt-writing-rules.md` compliance. |

## 📋 Daily Usage

### For Claude Code Development
```bash
# Edit rules (Claude loads automatically)
vim ~/.claude/rules/01-development-standards.md

# Update permissions
vim ~/.claude/.claude/settings.json

# Claude automatically uses updated configuration
```

### For IDE Integration
```bash
# After updating rules, sync to project IDEs
/config-sync/sync-project-rules --all
```

### For CLI Tools
```bash
# After major configuration changes
/config-sync/sync-cli --action=sync --target=all
```

## 🛠️ Maintenance

### Adding New Rules
1. Create `XX-description.md` in `rules/`
2. Follow naming convention
3. Claude automatically loads new rules

### Updating Permissions
1. Edit appropriate settings file
2. Use `Bash(command:*)` syntax
3. Verify with `claude /doctor`

### Configuration Validation
```bash
# Check Claude configuration
claude /doctor

# Verify IDE sync
/config-sync/sync-project-rules --verify-only

# Verify CLI sync
/config-sync/sync-cli --action=verify --target=all
```

## 🔍 Troubleshooting

| Issue | Solution |
|-------|----------|
| Rules not loading | Check file naming, run `claude /doctor` |
| IDE sync not working | Verify slash command usage and project structure |
| CLI sync failed | Run `/config-sync/sync-cli --action=analyze --target=<tool>` |
| Permission denied | Check `Bash(command:*)` syntax in settings |

## 📚 Documentation

- **[Settings Guide](docs/settings.md)** – Configuration hierarchy
- **[Permissions Reference](docs/permissions.md)** – Command control
- **[IDE Sync Guide](docs/sync-project-rules.md)** – Cursor/Copilot integration
- **[CLI Sync Commands](docs/config-sync-commands.md)** – Multi-tool commands

## 🎯 Benefits

- **Claude Code First**: Optimize for Claude Code, extend to other tools
- **Consistent Standards**: Same rules across all development environments
- **Single Source of Truth**: Update once, sync everywhere
- **Tool Flexibility**: Use Claude Code alone or with IDE/CLI assistants
- **Project Isolation**: Project-specific overrides when needed

This system ensures your development standards follow you everywhere—whether using Claude Code directly, IDE plugins, or CLI assistants—all managed from one central configuration.
