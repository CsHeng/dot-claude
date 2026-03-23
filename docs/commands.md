# Command Layout Overview

This repo has two command scopes:

- **User-level commands**: `~/.claude/commands/` (synced to other tools)
- **Project-level commands/tools**: `.claude/commands/` (implementation tooling; must not be part of the synced payload)

## Directory Structure
```
~/.claude/commands/
├── draft-commit-message.md        # Git commit message drafting
├── review-shell-syntax.md         # Shell script validation
├── review-python-syntax.md        # Python script validation
└── check-secrets.md               # Security scan for credentials
```

Project-level implementation tooling (not synced as payload):
```
<project>/.claude/commands/
├── llm-governance.md              # LLM-facing manifest audits and fixes
└── lint-markdown.md               # Markdown validation tooling
```

## Available Commands

### LLM Governance Commands

| Command | Purpose | Scope |
|---------|---------|-------|
| `/llm-governance` | Design-time audits and fixes for LLM-facing files | All LLM-facing files (commands, skills, agents, rules, settings), dependency analysis, specification validation |

### Workflow and Review Commands

| Command | Purpose | Scope |
|---------|---------|-------|
| `/draft-commit-message` | Generate commit messages from git status | Current repository, directory filtering, staged/unstaged change analysis |
| `/review-shell-syntax` | Validate shell script compliance | `skill:shell-guidelines`, ShellCheck integration, auto-fix patches |
| `/review-python-syntax` | Validate Python script compliance | `skill:python-guidelines`, Ruff + ty integration, auto-fix patches |
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
- Include parameter tables, usage examples, and error handling documentation
- Follow `.claude/skills/llm-governance/rules/99-llm-prompt-writing-rules.md` for LLM-facing content
- Implement proper error handling with descriptive exit codes
- Maintain strict shell mode (`set -euo pipefail`) in all bash scripts

## Related Documentation

- **[Docs Index](./README.md)** - Start here
- **[LLM Governance Scripts README](../.claude/skills/llm-governance/scripts/README.md)** - Implementation details and usage
- **[Permissions](./permissions.md)** - Permission system reference
- **[Execution Model](./model.md)** - Boundaries and layering
