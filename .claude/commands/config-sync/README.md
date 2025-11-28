---
description: Configuration synchronization plugin documentation and reference
name: config-sync-readme
argument-hint: ''
allowed-tools: []
metadata:
  is_background: false
  related-agents:
    - agent:config-sync
  related-commands:
    - /config-sync/sync-cli
  related-skills:
    - skill:environment-validation
    - skill:workflow-discipline
    - skill:security-logging
---

## Usage

Reference documentation for the config-sync plugin system. View configuration layouts, command mappings, and development guidelines.

## Arguments

None - This is a documentation file. Use `/config-sync/sync-cli` for operations.

## Workflow

1. Read configuration layouts and component mappings
2. Identify target-specific adapter requirements
3. Reference backup retention policies and management
4. Follow development guidelines for extensions

## Output

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
├── adapters/                     # Target-specific automation modules
├── lib/common.*                  # Shared shell helpers
├── lib/phases/                   # Phase execution runners
├── lib/planners/                 # Plan generation logic
├── lib/python/config_sync/       # Python modules (validation, path resolution, converters)
├── scripts/                      # Reusable shell helpers
└── settings.json                 # Default configuration and policies
```

### Command Mappings

| Command | Purpose | Required Skills |
| --- | --- | --- |
| `/config-sync/sync-cli` | Unified orchestration entrypoint for CLI targets | `skill:environment-validation`, `skill:workflow-discipline`, `skill:security-logging`, `skill:config-sync-cli-workflow`, `skill:config-sync-target-adaptation` |

### Supported Targets

| Target CLI       | Config Resolver                    | Components                                      | Special Requirements |
|------------------|------------------------------------|------------------------------------------------|----------------------|
| Droid CLI        | `get_target_config_dir droid`      | `commands`, `rules`, `skills`, `agents`, `memory` | Full YAML frontmatter support |
| Qwen CLI         | `get_target_config_dir qwen`       | `commands`, `rules`, `skills`, `agents`, `memory` | Python `toml` module required (for commands TOML) |
| OpenAI Codex CLI | `get_target_config_dir codex`      | `commands`, `rules`, `skills`, `agents`, `memory` | Minimal configuration |
| OpenCode         | `get_target_config_dir opencode`   | `commands`, `rules`, `skills`, `agents`, `memory` | JSON command format |
| Amp CLI          | `get_target_config_dir amp`        | `commands`, `rules`, `skills`, `agents`, `memory` | Global memory support via `AGENTS.md` |

Key Implementation Details:
- All target config directories are resolved via `lib/common.sh` helpers
  (`get_target_config_dir`, `get_target_commands_dir`, `get_target_rules_dir`,
  `get_target_path`).
- Taxonomy components (`rules/`, `agents/`, `skills/`, `output-styles/`) are
  synchronized by shared Shell scripts in `scripts/` using the manifest.
- Per-target adapters in `adapters/` are commands-only; they handle command
  format and tool-specific nuances and are invoked indirectly via
  `/config-sync/sync-cli` and the `skill:config-sync-target-adaptation` skill.

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
/config-sync/sync-cli --action=sync --plan-file=~/.claude/.claude/backup/plan-20250205-120210.json --from-phase=prepare
```

## shared-utilities

### Validation Helpers

Use the following helper signatures across adapters and scripts:

```bash
validate_target <name>          # allowed targets: droid, qwen, codex, opencode, amp, all
validate_component <name>       # allowed components: rules, permissions, commands, settings, memory
check_tool_installed <tool>     # ensure required CLI exists in PATH
```

### Path Resolution

All target-aware scripts should call the shared path helpers from `lib/common.sh`:

```bash
get_target_config_dir <tool>    # base config dir per target
get_target_rules_dir <tool>     # destination for rules
get_target_commands_dir <tool>  # destination for commands
```

### Logging and Environment Setup

```bash
log_info <message>
log_success <message>
log_warning <message>
log_error <message>

setup_plugin_environment        # exports shared paths, validates scripts/, prepares temp dirs
```

### Backup and Executor Utilities

```bash
create_backup <path> <dest_root>        # timestamped backups before destructive ops
write_with_checksum <src> <dst>         # copy with checksum verification
render_template <template> <output> <vars>
sync_with_sanitization <src> <dst>      # rsync-like helper with sanitization hooks
```

Implementation guidelines:
- Keep helpers language-agnostic but enforce strict exit codes (0 success, non-zero failure).
- Resolve absolute paths, validate permissions, and keep file operations atomic.
- Use consistent logging prefixes so `/config-sync/sync-cli` output stays machine-parseable.
- Verify external tool dependencies before invoking helpers; integrate with `skill:environment-validation` checks.

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
~/.claude/.claude/commands/config-sync/scripts/backup-cleanup.sh --status

# Preview cleanup actions without execution
~/.claude/.claude/commands/config-sync/scripts/backup-cleanup.sh --dry-run

# Execute manual backup cleanup
~/.claude/.claude/commands/config-sync/scripts/backup-cleanup.sh
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

## reference-links

### Config Sync System Documentation
- User Guide: `docs/config-sync-guide.md` - Complete system overview and usage
- CLI Reference: `sync-cli.md` - Command line interface documentation  
- Sequence Diagram: `docs/config-sync-cli-sequence-diagram.puml` - Workflow visualization

### Original Reference Sources (for mapping rules)
- [Claude Code Subagents](https://code.claude.com/docs/en/sub-agents) - Source configuration format
- [Claude Code Slash Commands](https://code.claude.com/docs/en/slash-commands) - Source command format
- [Claude Code Agent Skills](https://code.claude.com/docs/en/skills) - Claude Code specific features
- [Factory Custom Droids](https://docs.factory.ai/cli/configuration/custom-droids) - Droid target format
- [Factory Custom Commands](https://docs.factory.ai/cli/configuration/custom-slash-commands) - Droid command format
- [Factory AGENTS.md](https://docs.factory.ai/cli/configuration/agents-md) - AGENTS.md reference
