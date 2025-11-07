# Config Sync Plugin

Centralizes Claude Code configuration synchronization flows into a single plugin that exposes a consistent `/config-sync:*` command namespace. The plugin adapts Claude’s rules, permissions, commands, memory files, and settings for other AI tooling ecosystems.

## Components

- commands/ – Slash command definitions (orchestrator, adapters, verification, analysis)
- lib/common.md – Shared helper references used by command snippets
- scripts/ – Shell helpers (`executor.sh`, `backup.sh`) invoked by automation snippets
- settings.json – Default options for sync orchestration
- .claude-plugin/plugin.json – Plugin manifest metadata

## Primary Commands

| Command | Purpose |
| --- | --- |
| `/config-sync:sync` | Core synchronization driver for all components |
| `/config-sync:sync-user-config` | High level orchestrator that coordinates adapters |
| `/config-sync:verify` | Post-sync verification and remediation |
| `/config-sync:analyze` | Capability analysis for supported targets |
| `/config-sync:adapt-commands` | Command format conversion per target |
| `/config-sync:adapt-permissions` | Permission mapping for each tool |
| `/config-sync:adapt-rules-content` | Rule content generalization |
| `/config-sync:droid` `/config-sync:qwen` `/config-sync:codex` `/config-sync:opencode` | Tool-specific adapters and flows |

## Supported Targets

- Factory/Droid CLI – Markdown commands, JSON permissions
- Qwen CLI – TOML command conversion, documentation-based permissions
- OpenAI Codex CLI – Minimal configuration with sandbox levels
- OpenCode – JSON command format with operation-based permissions

## Usage

Run commands directly from Claude Code:

```bash
/config-sync:sync --target=all --component=all
/config-sync:verify --target=droid --detailed
/config-sync:adapt-permissions --target=opencode
```

## Development Notes

- Helper scripts are intentionally minimal and should be customized per environment.
- Commands reference shared functions documented in `lib/common.md`.
- The legacy command copies in `~/.claude/commands/` remain until the new plugin suite is fully validated.
