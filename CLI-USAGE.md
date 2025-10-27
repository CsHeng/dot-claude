# Qwen CLI Rules Usage Guide

This guide explains how to use your unified rules system with Qwen CLI for consistent behavior and productivity.

## Quick Start

### 1. Sync Rules to Qwen CLI

```bash
# Sync rules to Qwen CLI
./sync-rules-for-qwen.sh
```

### 2. Use Rules with Qwen CLI

#### Claude Code (Built-in)
Rules are automatically loaded from `rules/` directory. CLAUDE.md serves as memory index.

#### Qwen CLI
```bash
# Use specific rule file
qwen -p "$(cat ~/.qwen/rules/00-user-preferences.md)"

# Use general development guidelines
qwen -p "$(cat ~/.qwen/rules/01-general-development.md)"

# Interactive mode with rules
qwen -i -p "$(cat ~/.qwen/rules/10-python-guidelines.md)"

# Qwen automatically recognizes QWEN.md as memory index
```

## Available Rule Files

### Core Rules
- `00-user-preferences.md` - Personal preferences and tool configurations
- `01-general-development.md` - General coding standards and practices
- `02-architecture-patterns.md` - Architecture and design patterns
- `03-security-guidelines.md` - Security practices and guidelines
- `04-testing-strategy.md` - Testing approaches and strategies
- `05-error-handling.md` - Error handling patterns

### Language-Specific Rules
- `10-python-guidelines.md` - Python-specific guidelines
- `11-go-guidelines.md` - Go-specific guidelines
- `12-shell-guidelines.md` - Shell scripting guidelines
- `13-docker-guidelines.md` - Docker and containerization guidelines
- `14-networking-guidelines.md` - Network programming patterns

### Tool and Quality Rules
- `20-development-tools.md` - Development tool configuration
- `21-code-quality.md` - Code quality standards
- `22-logging-standards.md` - Logging and monitoring standards
- `23-workflow-patterns.md` - Development workflow patterns

## Workflow Examples

### Python Development
```bash
# Sync rules first
./sync-rules-for-qwen.sh

# Start Qwen with Python guidelines
qwen -i -p "$(cat ~/.qwen/rules/10-python-guidelines.md)

# Now interact with Qwen following your Python standards"
```

### Code Review
```bash
# Use general development guidelines for code review
qwen -p "Please review this code following these guidelines: $(cat ~/.qwen/rules/01-general-development.md)

[Paste your code here]"
```

### Debugging Session
```bash
# Use error handling patterns
qwen -p "I'm debugging an issue. Follow these error handling patterns: $(cat ~/.qwen/rules/05-error-handling.md)

[Describe your issue]"
```

## Sync Script Options

### Qwen Sync Script
```bash
# Show help
./sync-rules-for-qwen.sh --help

# Preview what will be synced
./sync-rules-for-qwen.sh --dry-run

# Verify existing sync
./sync-rules-for-qwen.sh --verify-only
```

## Best Practices

### 1. Keep Rules Updated
When you modify rules in `~/.claude/rules/`, remember to sync them:
```bash
./sync-rules-for-qwen.sh
```

### 2. Choose Appropriate Rules
- Use `00-user-preferences.md` for general sessions
- Use language-specific rules for language tasks
- Use `01-general-development.md` for code reviews

### 3. Combine Multiple Rules
For complex tasks, you can combine multiple rule files:
```bash
qwen -p "$(cat ~/.qwen/rules/00-user-preferences.md ~/.qwen/rules/10-python-guidelines.md)"
```

### 4. Interactive Mode
For longer sessions, use interactive mode (`-i`) with your preferred rules:
```bash
qwen -i -p "$(cat ~/.qwen/rules/01-general-development.md)"
```

## Directory Structure

```
~/.claude/
├── rules/                    # Source rules (master copy)
│   ├── 00-user-preferences.md
│   ├── 01-general-development.md
│   └── ...
├── CLAUDE.md                 # Claude memory index
├── sync-rules-for-qwen.sh   # Qwen sync script
└── CLI-USAGE.md             # This file

~/.qwen/
├── QWEN.md                  # Qwen memory index (auto-created)
└── rules/                   # Synced rules for Qwen
```

## Troubleshooting

### Rules Not Found
```bash
# Check if rules are synced
./sync-rules-for-qwen.sh --verify-only

# Check memory files exist
ls -la ~/.qwen/QWEN.md
```

### Permission Issues
```bash
# Make sure scripts are executable
chmod +x sync-rules-for-qwen.sh
```

### CLI Tool Not Found
```bash
# Check if tool is installed
which qwen
```

### Memory Files Not Recognized
If CLI tools don't automatically recognize memory files:
```bash
# Manually load memory file content
qwen -p "$(cat ~/.qwen/QWEN.md)"
```

## Future Enhancements

Potential improvements to consider:
1. **Automatic sync when rules change** - Use file watchers or git hooks
2. **Combined sync script** - Single script to sync to all CLI tools
3. **Wrapper scripts** - Common rule combinations for quick access
4. **IDE integration** - Better integration with Cursor, Copilot, Kiro
5. **More CLI tools** - Add support for other AI CLI tools (codex, aider, etc.)

## System Overview

This unified rules system provides:

- **Single Source of Truth**: All rules managed in `~/.claude/rules/`
- **Automatic Synchronization**: One-click sync to Qwen CLI
- **Memory Index Files**: Each CLI tool has its own memory index (CLAUDE.md, QWEN.md)
- **Consistent Behavior**: All AI assistants follow the same guidelines
- **Lightweight Architecture**: Simple scripts, no complex dependencies

The system ensures that whether you use Claude Code or Qwen, they will both follow your established coding standards and preferences.