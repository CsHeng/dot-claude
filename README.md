# Claude Code Configuration System

Claude Code rules, permissions, and agent configuration with sync capabilities for IDE and CLI coding assistants.

## 🎯 Core Concept

This system treats **Claude Code as the primary source of truth** for:
- **Rules**: Development guidelines in `rules/`
- **Permissions**: Command execution control in settings files
- **Agent Instructions**: Operating procedures in `AGENTS.md` and `CLAUDE.md`

From this central configuration, we sync to:
- **IDE Tools**: Cursor, VS Code Copilot (via `sync-project-rules.sh`)
- **CLI Tools**: Qwen, Factory/Droid, Codex, OpenCode (via `/config-sync:*` commands)

## 📁 Essential Files

```
.claude/
├── 📁 .claude/
│   └── ⚙️ settings.json           # Shared permissions
├── 📁 commands/                   # Custom slash commands
│   └── 📁 config-sync/            # Multi-tool sync utilities
├── 📁 docs/                       # Detailed documentation
├── 📁 rules/                      # Development guidelines by category
├── 📄 AGENTS.md                   # Agent operating instructions
├── 📄 CLAUDE.md                   # Claude's memory and context
├── ⚙️ settings.json               # Global preferences
└── 🔄 sync-project-rules.sh       # IDE tool synchronization
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
# Copy sync script to your project
cp ~/.claude/sync-project-rules.sh /path/to/project/.claude/

# Run sync in project directory
cd /path/to/project
.claude/sync-project-rules.sh
```

### 3. Sync to CLI Tools (Optional)
```bash
# Analyze available CLI tools
/config-sync:analyze --target=all

# Sync configuration to installed tools
/config-sync:sync-user-config --target=all

# Verify sync worked
/config-sync:verify --target=all
```

## 🔧 Configuration Components

### **Rules Library** (`rules/`)
Automatically loaded by Claude Code:

**Core Rules:**
- `00-user-preferences.md` - Personal preferences (all files)
- `01-general-development.md` - General standards (all files)
- `02-architecture-patterns.md` - Architecture patterns
- `03-security-guidelines.md` - Security practices
- `04-testing-strategy.md` - Testing approaches
- `05-error-handling.md` - Error handling

**Language-Specific Rules:**
- `10-python-guidelines.md` - Python (`**/*.py`)
- `11-go-guidelines.md` - Go (`**/*.go`)
- `12-shell-guidelines.md` - Shell (`**/*.sh`)
- `13-docker-guidelines.md` - Docker (docker files, Makefiles)
- `14-networking-guidelines.md` - Network patterns

**Tool & Process Rules:**
- `20-development-tools.md` - Tool configuration
- `21-code-quality.md` - Code quality
- `22-logging-standards.md` - Logging standards
- `23-workflow-patterns.md` - Workflow patterns

Rules auto-apply by file patterns. See `rules/00-user-preferences.md` for details.

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
- **Method**: `sync-project-rules.sh` script
- **Scope**: Project-level rules distribution
- **Usage**: Run in each project directory

📖 **[IDE Sync Guide](docs/sync-project-rules.md)**

### CLI Tool Sync
- **Target**: Qwen, Factory/Droid, Codex, OpenCode
- **Method**: `/config-sync:*` slash commands
- **Scope**: Full configuration (rules, permissions, commands, memory)
- **Usage**: One-time setup per tool

📖 **[CLI Sync Commands](docs/config-sync-commands.md)**

## 📋 Daily Usage

### For Claude Code Development
```bash
# Edit rules (Claude loads automatically)
vim ~/.claude/rules/01-general-development.md

# Update permissions
vim ~/.claude/.claude/settings.json

# Claude automatically uses updated configuration
```

### For IDE Integration
```bash
# After updating rules, sync to project IDEs
/path/to/project/.claude/sync-project-rules.sh
```

### For CLI Tools
```bash
# After major configuration changes
/config-sync:sync-user-config --target=all
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
/path/to/project/.claude/sync-project-rules.sh --verify-only

# Verify CLI sync
/config-sync:verify --target=all
```

## 🔍 Troubleshooting

| Issue | Solution |
|-------|----------|
| Rules not loading | Check file naming, run `claude /doctor` |
| IDE sync not working | Verify script location, check project structure |
| CLI sync failed | Run `/config-sync:analyze --target=<tool>` |
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