# Claude Development Configuration System

A unified configuration management system for AI-powered development tools. This repository centralizes rules, permissions, and preferences across Claude Code, IDE assistants (Cursor, Copilot, Kiro), and Qwen CLI for consistent development workflows.

## 🏗️ System Architecture

This configuration system operates on three hierarchical levels:

### 📁 File Structure
```
~/.claude/
├── 📄 AGENTS.md                    # Agent-facing operating guide
├── 📄 CLAUDE.md                    # Claude's memory index
├── ⚙️  settings.json               # Personal preferences & environment
├── ⚙️  .claude/settings.json       # Cross-project shared settings
├── 🔄 sync-project-rules.sh        # Project-level Cursor & VS Code Copilot sync
├── 🔄 sync-user-rules.sh           # User-level rule sync (Qwen/Droid/Codex)
├── 🔄 sync-user-commands.sh        # Claude→Droid custom command sync
├── 📦 lib/rule-sync-common.sh      # Shared sync helper functions
├── 📊 statusline.sh                # Custom statusline script
├── 📚 docs/
│   ├── 📋 settings.md              # Settings configuration guide
│   ├── 🔐 permissions.md           # Command permissions reference
│   ├── 🔄 qwen-cli.md              # Qwen CLI usage guide
│   ├── 🔄 sync-user-rules.md       # User-level rule sync reference
│   ├── 🔄 sync-user-commands.md    # Custom command sync reference
│   └── 🔄 sync-project-rules.md    # Project-level sync reference
├── 📚 README.md                    # This file
├── 📚 .mise.toml                   # Environment configuration
└── 📚 rules/                       # Master rules library
    ├── 👤 00-user-preferences.md
    ├── 🛠️ 01-general-development.md
    ├── 🏗️ 02-architecture-patterns.md
    ├── 🔒 03-security-guidelines.md
    ├── 🧪 04-testing-strategy.md
    ├── ⚠️ 05-error-handling.md
    ├── 🐍 10-python-guidelines.md
    ├── 🐹 11-go-guidelines.md
    ├── 💻 12-shell-guidelines.md
    ├── 🐳 13-docker-guidelines.md
    ├── 🌐 14-networking-guidelines.md
    ├── 🔧 20-development-tools.md
    ├── ✨ 21-code-quality.md
    ├── 📝 22-logging-standards.md
    └── 🔄 23-workflow-patterns.md

~/.qwen/ (auto-created)
├── 📄 QWEN.md                      # Qwen's memory index
└── 📚 rules/                       # Synced rules for Qwen
```

## 🎯 Core Components

### 1. **Agent vs Human Documentation**
- **AGENTS.md**: Agent-focused operating guide. Load this with the relevant files in `rules/` to keep automated assistants aligned with the latest standards.
- **README.md & docs/**: Human-facing documentation covering configuration, maintenance, and extension of this environment.

### 2. **Hierarchical Settings System**
- **Global Settings** (`~/.claude/settings.json`): Personal preferences, timeouts, environment variables
- **Shared Settings** (`~/.claude/.claude/settings.json`): Cross-project permissions and safety rules
- **Project Settings** (`{project}/.claude/settings.json`): Project-specific overrides (committed to git)

### 3. **Unified Rules Library** (`rules/`)
Central collection of development guidelines automatically loaded by AI assistants:
- **User Preferences**: Personal development settings and tool configurations
- **Language Guidelines**: Python, Go, Shell, Docker, Networking standards
- **Development Practices**: Architecture, security, testing, error handling patterns
- **Tool Configuration**: Development tools, code quality, logging, workflow standards

### 4. **Sync Utilities**
- **Project IDE Tools**: `sync-project-rules.sh` → Cursor & VS Code Copilot (per-project execution)
- **User Rules**: `sync-user-rules.sh` → Qwen CLI, Factory/Droid CLI, Codex CLI (interactive multi-select)
- **User Commands**: `sync-user-commands.sh` → Mirrors personal Claude custom commands into Droid CLI with compatibility sanitization
- **Shared Helpers**: `lib/rule-sync-common.sh` centralizes logging and copy logic

### 5. **Permission Management**
Three-tier permission system for command execution:
- **allow**: Safe commands that run automatically
- **ask**: Commands requiring user confirmation (network operations, package management)
- **deny**: Dangerous commands that are completely blocked

## 🚀 Quick Start

### Initial Setup
```bash
# 1. Clone this configuration system
git clone <repository-url> ~/.claude
cd ~/.claude

# 2. Generate settings configuration
# Ask Claude: "Generate settings.json based on docs/settings.md and docs/permissions.md"
# Verify with: claude /doctor

# 3. Synchronize rule and command context
./sync-user-rules.sh               # Prompts for Qwen/Droid/Codex targets
./sync-user-commands.sh            # Mirrors personal Claude commands into Droid CLI
# (copy sync-project-rules.sh into each project and run there)

# 4. Start using unified configuration
qwen -p "$(cat ~/.qwen/rules/00-user-preferences.md)"
```

### New Project Integration
```bash
# 1. Copy project sync script to project
cp ~/.claude/sync-project-rules.sh /path/to/project/.claude/

# 2. Create project-specific settings
cat > /path/to/project/.claude/settings.json << 'EOF'
{
  "permissions": {
    "allow": ["Bash(project-specific-tool:*)"],
    "ask": ["Bash(deploy:*)"]
  },
  "env": {
    "PROJECT_ENV": "development"
  }
}
EOF

# 3. Run synchronization
cd /path/to/project && .claude/sync-project-rules.sh
```

## 🔧 Configuration Management

### Settings Precedence (Highest → Lowest)
1. **Project Settings** (`.claude/settings.json`) - Team collaboration, committed to git
2. **Shared Settings** (`~/.claude/.claude/settings.json`) - Cross-project rules
3. **Global Settings** (`~/.claude/settings.json`) - Personal preferences

### Environment Variables
```toml
# .mise.toml - Performance and behavior tuning
API_TIMEOUT_MS = "3000000"
BASH_DEFAULT_TIMEOUT_MS = "60000"
BASH_MAX_OUTPUT_LENGTH = "10000"
CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC = "1"
```

### Custom Status Line
```bash
# statusline.sh - Enhanced status information
# Displays: model name, current directory, project context, git status
```

## 📋 Usage Patterns

### Daily Development
```bash
# Edit rules globally
vim ~/.claude/rules/01-general-development.md

# Update permissions
vim ~/.claude/.claude/settings.json

# Sync to IDE tools (run inside project)
/path/to/project/.claude/sync-project-rules.sh

# Sync to CLI tools
cd ~/.claude && ./sync-user-rules.sh
cd ~/.claude && ./sync-user-commands.sh --verify-only
```

### CLI Tool Usage
```bash
# Interactive session with guidelines
qwen -i -p "$(cat ~/.qwen/rules/10-python-guidelines.md)"

# Code review with standards
qwen -p "Review this code following: $(cat ~/.qwen/rules/01-general-development.md)
[Paste code]"

# Debugging with error handling patterns
qwen -p "Debug issue using: $(cat ~/.qwen/rules/05-error-handling.md)
[Describe issue]"
```

## 🛠️ Maintenance

### Adding New Rules
1. Create numbered file in `~/.claude/rules/`
2. Follow naming convention (`XX-description.md`)
3. Add appropriate AI tool headers
4. Run sync scripts to distribute

### Permission Updates
1. Edit appropriate settings file based on hierarchy
2. Use `Bash(command:*)` syntax (not `Bash(command :*)`)
3. Validate with `claude /doctor`
4. Test command execution

### Configuration Validation
```bash
# Check JSON syntax
cat ~/.claude/settings.json | jq .

# Verify sync status
./sync-user-rules.sh --verify-only
/path/to/project/.claude/sync-project-rules.sh --verify-only

# Doctor check
claude /doctor
```

## 🔍 Troubleshooting

### Common Issues
- **Rules not loading**: Check file naming and sync status
- **Permissions denied**: Verify `Bash(command:*)` syntax in settings
- **Sync failures**: Check target directory permissions
- **CLI tools not working**: Verify tool installation and PATH

### Debug Commands
```bash
# Check rules existence
ls ~/.claude/rules/
ls ~/.qwen/rules/

# Verify settings
jq . ~/.claude/settings.json
jq . ~/.claude/.claude/settings.json

# Test sync
./sync-user-rules.sh --dry-run
/path/to/project/.claude/sync-project-rules.sh --dry-run
```

## 📚 Documentation

- **[Settings Guide](docs/settings.md)** – Configuration hierarchy and precedence
- **[Permissions Reference](docs/permissions.md)** – Command allow/ask/deny catalogs
- **[Qwen CLI Usage](docs/qwen-cli.md)** – How to run Qwen with synced rules
- **[User Rule Sync](docs/sync-user-rules.md)** – Targets, flags, and behavior
- **[User Command Sync](docs/sync-user-commands.md)** – Droid-compatible command mirroring
- **[Project Rule Sync](docs/sync-project-rules.md)** – IDE-focused distribution
- **[Individual Rules](rules/)** – Language and workflow-specific guidance

## 🎯 Benefits

- **Single Source of Truth**: All preferences defined once in `rules/`
- **Cross-Tool Consistency**: Same behavior across Claude, IDEs, and CLI tools
- **Team Collaboration**: Project settings can be committed to git
- **Security Control**: Granular permission management for command execution
- **Performance Tuning**: Environment variables for optimal behavior
- **Easy Maintenance**: Update once, sync everywhere automatically

This system ensures that whether you're using Claude Code, IDE assistants, or CLI tools, you'll have consistent development standards, permissions, and workflows across all your projects.