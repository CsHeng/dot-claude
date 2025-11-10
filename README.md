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
├── 📁 .claude/                   # Shared permissions
│   └── ⚙️ settings.json          # Tool access control
├── 📁 commands/                  # Custom slash commands
│   └── 📁 config-sync/           # Multi-tool sync utilities
├── 📁 docs/                      # Complete documentation
├── 📁 rules/                     # Development guidelines
├── 📄 AGENTS.md                  # Agent instructions
├── 📄 CLAUDE.md                  # Claude's memory
└── ⚙️ settings.json              # Global preferences
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
claude /config-sync:sync-project-rules --all

```

### 3. Sync to CLI Tools (Optional)
```bash
# Analyze available CLI tools
claude /config-sync:sync-cli --action=analyze --target=all

# Sync configuration to installed tools
claude /config-sync:sync-cli --action=sync --target=all

# Verify sync worked
claude /config-sync:sync-cli --action=verify --target=all
```

## 🔧 Configuration Components

### **Rules Library** (`rules/`)
Development guidelines automatically loaded by Claude Code. Core files include:
- `00-memory-rules.md` - Personal preferences
- `01-development-standards.md` - General standards
- `02-architecture-patterns.md` - Architecture patterns
- `10-*.md` - Language-specific guidelines (Python, Go, Shell, etc.)
- `99-llm-prompt-writing-rules.md` - AI development guidelines

📖 **[Complete Rules List](./directory-structure.md#development-guidelines)**

### **Permission System**
Three-tier command control in settings files:
- **allow**: Runs automatically
- **ask**: Requires confirmation
- **deny**: Blocked completely

📖 **[Permissions Reference](docs/permissions.md)**

### **Settings Hierarchy**
1. **Local overrides** (`.claude/settings.local.json`) - Personal (git-ignored)
2. **Project settings** (`.claude/settings.json`) - Team configuration
3. **Shared settings** (`.claude/.claude/settings.json`) - Cross-project
4. **Global settings** (`settings.json`) - Personal preferences

📖 **[Settings Guide](docs/settings.md)** index

## 🔄 Sync Capabilities

### IDE Plugin Sync
- **Target**: Cursor, VS Code Copilot
- **Method**: `/config-sync/sync-project-rules`
- **Scope**: Project-level rules distribution
- **Usage**: Run in each project directory

📖 **[Config-Sync Guide](docs/config-sync-guide.md#project-rules-integration)**

### CLI Tool Sync
- **Target**: Qwen, Factory/Droid, Codex, OpenCode
- **Method**: `/config-sync/sync-cli --action=<sync|analyze|verify|adapt|plan|report>`
- **Scope**: Full configuration (rules, permissions, commands, memory)
- **Features**: 8-phase pipeline, backup system, PlantUML integration

📖 **[Config-Sync Guide](docs/config-sync-guide.md)**

### **Available Commands**

| Category | Commands | Purpose |
|----------|----------|---------|
| **Config-Sync** | `/config-sync/sync-cli`, `/config-sync/sync-project-rules`, `/config-sync:*` | Multi-tool configuration synchronization |
| **Documentation** | `/doc-gen:*` | Generate project documentation |
| **Code Review** | `/review-shell-syntax`, `/review-llm-prompts` | Validate compliance with guidelines |
| **Utilities** | `/draft-commit-message` | Git workflow helpers |

📖 **[Complete Command Reference](docs/commands.md)**

## 📋 Daily Usage

### For Claude Code Development
```bash
# Edit rules (Claude loads automatically)
vim ~/.claude/rules/01-development-standards.md

# Update permissions
vim ~/.claude/settings.json

# Claude automatically uses updated configuration
```

### For IDE Integration
```bash
# After updating rules, sync to project IDEs
claude /config-sync:sync-project-rules --all
```

### For CLI Tools
```bash
# After major configuration changes
claude /config-sync:sync-cli --action=sync --target=all
```

## 🛠️ Maintenance

### Configuration Validation
```bash
# Check Claude configuration
claude /doctor

# Verify IDE sync
claude /config-sync:sync-project-rules --verify-only

# Verify CLI sync
claude /config-sync:sync-cli --action=verify --target=all
```

### Adding New Content
1. **Rules**: Create `XX-description.md` in `rules/`
2. **Commands**: Add `.md` file in `commands/`
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
