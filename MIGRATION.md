# Migration Notice

Skills, commands, and agents have been migrated to the Claude Code plugin system.

## New Location

- **Plugin Repository**: https://github.com/CsHeng/csheng-skills
- **Plugin Name**: `coding`
- **Installation**: `claude plugin install coding`

## Why Plugin?

- **Hot-swappable updates**: Update skills without touching user config
- **Better dependency management**: Plugin-level isolation
- **Integrated with Claude Code marketplace**: Discoverable and installable
- **Automatic discovery**: No manual configuration needed

## What Moved

The following components have been migrated to the plugin:

### Skills
- `python-guidelines`, `go-guidelines`, `shell-guidelines`, `powershell-guidelines`, `lua-guidelines`
- `tool-decision-tree`, `language-decision-tree`
- `architecture-patterns`, `clean-architecture`
- `development-standards`, `quality-standards`, `testing-strategy`
- `security-guardrails`, `security-logging`, `logging-standards`
- `error-patterns`, `documentation-structure`
- `docker-multiarch-build`, `context7-registry`
- `smart-commit`, `smart-squash`
- `review-design`, `review-plan`, `review-code-impl`
- `web-fetch`

### Commands
- Cross-model review commands
- Language-specific review commands

### Agents
- Review agents (Python, Shell, Go, PowerShell)
- Cross-model review agents

## What Remains in ~/.claude

This repository (`~/.claude/`) now contains:

- **User-level configuration**: `settings.json`, `CLAUDE.md`, `AGENTS.md`
- **User-level agents**: Personal agent definitions in `agents/`
- **User-level rules**: Development standards in `rules/`
- **Output styles**: Named output style manifests in `output-styles/`
- **Memory**: Auto memory directory in `projects/*/memory/`

## Migration Path

1. Install the plugin:
   ```bash
   claude plugin install coding
   ```

2. Remove local skill references (if any) from your `settings.json`

3. Skills are now available via the plugin system

## AgentSkills.io Compatibility

The plugin follows the [agentskills.io](https://agentskills.io) standard:
- ✅ Portable across AI agent products
- ✅ Progressive disclosure (metadata → instructions → resources)
- ✅ Standard SKILL.md format with YAML frontmatter

## Questions?

- Plugin issues: https://github.com/CsHeng/csheng-skills/issues
- User config issues: This repository
