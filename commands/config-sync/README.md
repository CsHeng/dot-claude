---
command: /config-sync/README
description: Configuration synchronization plugin documentation and reference
related-commands:
  - /config-sync/sync-cli
  - /config-sync/sync-project-rules
related-agents:
  - agent:config-sync
related-skills:
  - skill:environment-validation
  - skill:workflow-discipline
  - skill:security-logging
---

## usage

Reference documentation for the config-sync plugin system. View configuration layouts, command mappings, and development guidelines.

## arguments

None - This is a documentation file. Use `/config-sync/sync-cli` for operations.

## workflow

1. Read configuration layouts and component mappings
2. Identify target-specific adapter requirements
3. Reference backup retention policies and management
4. Follow development guidelines for extensions

## output

Complete reference documentation including:
- Directory structure and component responsibilities
- Command-to-agent mappings and skill requirements
- Target system support matrix
- Usage examples and configuration patterns
- Backup retention management specifications
- Development and integration guidelines

## configuration

### Directory Layout

```
commands/config-sync/
├── README.md                     # This reference documentation
├── sync-cli.{md,sh}             # Unified slash command and implementation
├── sync-project-rules.{md,sh}   # IDE rule synchronization
├── adapters/                     # Target-specific automation modules
├── lib/common.*                  # Shared utility functions
├── lib/phases/                   # Phase execution runners
├── lib/planners/                 # Plan generation logic
├── scripts/                      # Reusable shell helpers
└── settings.json                 # Default configuration and policies
```

### Command Mappings

| Command | Purpose | Required Skills |
| --- | --- | --- |
| `/config-sync/sync-cli` | Unified orchestration entrypoint | `skill:environment-validation`, `skill:workflow-discipline`, `skill:security-logging` |
| `/config-sync/sync-project-rules` | IDE rule directory synchronization | `skill:workflow-discipline`, `skill:security-logging` |
| `/config-sync:adapt-*` | Target-specific configuration adaptation | Language skills based on target |

### Supported Targets

- Factory/Droid CLI: Markdown commands, JSON permissions
- Qwen CLI: TOML command conversion, JSON permission manifest
- OpenAI Codex CLI: Minimal configuration with sandbox levels
- OpenCode: JSON command format with operation-based permissions
- Amp CLI: AGENTS.md guidance, `.agents/commands` mirroring, `amp.permissions` array

### Usage Examples

```bash
# Full synchronization with default targets
/config-sync/sync-cli --action=sync

# Analyze opencode target configuration
/config-sync/sync-cli --action=analyze --target=opencode --format=table

# Synchronize specific Amp CLI components
/config-sync/sync-cli --action=sync --target=amp --components=commands,settings,permissions

# Verify commands and permissions for multiple targets
/config-sync/sync-cli --action=verify --target=droid,qwen --components=commands,permissions

# Execute from specific plan phase
/config-sync/sync-cli --action=sync --plan-file=~/.claude/backup/plan-20250205-120210.json --from-phase=prepare
```

## backup-retention

### Configuration

Backup retention policies are configured in `commands/config-sync/settings.json`:

```json
{
  "backup": {
    "retention": {
      "maxRuns": 5,
      "enabled": true,
      "dryRun": false
    }
  }
}
```

### Management Commands

```bash
# Check current backup status
~/.claude/commands/config-sync/scripts/backup-cleanup.sh --status

# Preview cleanup actions without execution
~/.claude/commands/config-sync/scripts/backup-cleanup.sh --dry-run

# Execute manual backup cleanup
~/.claude/commands/config-sync/scripts/backup-cleanup.sh
```

### Pipeline Integration

Backup cleanup automatically integrates into the synchronization pipeline:
```
collect → analyze → plan → prepare → adapt → execute → [verify] → cleanup → report
```

Control cleanup execution with phase controls:
- `--until-phase=execute`: Skip cleanup phase
- `--from-phase=cleanup`: Execute only cleanup phase

## development-guidelines

1. Phase Execution: Always invoke phase scripts through `sync-cli.sh`. Never call `lib/phases/*.sh` directly
2. Shell Standards: Maintain strict mode (`set -euo pipefail`) in all helper scripts per `rules/12-shell-guidelines.md`
3. Documentation Updates: Update documentation when adding phases, planner fields, or CLI arguments to maintain downstream tool accuracy
4. Dependency Management: Qwen command verification requires Python `toml` module. Install with `python3 -m pip install --user toml`
5. Agent Integration: Ensure command logs include agent/skill versions for audit traceability
6. Error Handling: Implement comprehensive error handling with proper logging and rollback mechanisms