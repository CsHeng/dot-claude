# Config Sync Plugin (Unified CLI)

The config-sync suite now centers on a single slash command, `/config-sync/sync-cli`, which owns parameter parsing, plan generation, phase gating, and reporting for every workflow (sync, analyze, verify, adapt, plan, report).

## Layout

- `sync-cli.{md,sh}` – Unified slash command manifest plus entrypoint script
- `sync-project-rules.{md,sh}` – Standalone slash command for syncing the shared rule library into IDE-facing directories
- `adapters/` – Target-specific automation invoked during the `adapt` phase
- `lib/common.*` – Shared helpers (parsing, logging, path resolution)
- `lib/phases/` – Phase runners (`collect`, `analyze`, `plan`, `prepare`, `adapt`, `execute`, `verify`, `report`)
- `lib/planners/` – Plan builders for sync/adapt flows
- `scripts/` – Reusable shell helpers (`executor.sh`, `backup.sh`, `backup-cleanup.sh`)
- `settings.json` – Default target/component selections, verify/dry-run preferences, backup retention settings

## Primary Slash Command

| Command | Purpose |
| --- | --- |
| `/config-sync/sync-cli` | Unified entrypoint (`--action=<sync|analyze|verify|adapt|plan|report>`) with support for `--target`, `--components`, `--profile`, `--plan-file`, `--from-phase`, `--until-phase`, `--dry-run`, `--force`, `--adapter`, and `--format`. |
| `/config-sync/sync-project-rules` | IDE helper that copies `~/.claude/rules` (plus project overrides) into `.cursor/rules` and `.github/instructions`, supporting `--target`, `--dry-run`, `--verify-only`, and `--project-root` or `CLAUDE_PROJECT_DIR`. The old `/config-sync:sync-project-rules` alias has been removed—use the slash command directly. |

Adapters such as `/config-sync:adapt-permissions` or `/config-sync:droid` remain for direct tooling control, but the orchestration layer no longer exposes per-phase wrappers like `/config-sync:sync` or `/config-sync:verify`.

## Supported Targets

- Factory/Droid CLI – Markdown commands, JSON permissions
- Qwen CLI – TOML command conversion, JSON permission manifest
- OpenAI Codex CLI – Minimal configuration with sandbox levels
- OpenCode – JSON command format with operation-based permissions

## Usage Examples

```bash
# Full sync with defaults
/config-sync/sync-cli --action=sync

# Analyze opencode in table format
/config-sync/sync-cli --action=analyze --target=opencode --format=table

# Verify commands + permissions for droid and qwen
/config-sync/sync-cli --action=verify --target=droid,qwen --components=commands,permissions

# Re-run plan from prepare onwards
/config-sync/sync-cli --action=sync --plan-file=~/.claude/backup/plan-20250205-120210.json --from-phase=prepare
```

## Backup Retention

The config-sync system includes automatic backup retention management to prevent unlimited disk usage. After each successful sync operation, the system automatically cleans up old backup runs based on configurable retention settings.

### Features
- **Automatic Cleanup**: Runs after successful sync operations
- **Configurable Retention**: Keep the latest N runs (default: 5)
- **Safe Deletion**: Dry-run mode and integrity verification
- **Simple Policy**: Always delete everything beyond the N most recent runs
- **Detailed Logging**: Track all cleanup actions

### Configuration
Backup retention is configured in `settings.json`:

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

# Preview cleanup actions
~/.claude/commands/config-sync/scripts/backup-cleanup.sh --dry-run

# Manual cleanup
~/.claude/commands/config-sync/scripts/backup-cleanup.sh
```

### Pipeline Integration
The cleanup phase is automatically integrated into the sync pipeline:
```
collect → analyze → plan → prepare → adapt → execute → [verify] → cleanup → report
```

Use `--until-phase=execute` to skip cleanup or `--from-phase=cleanup` to run only cleanup.

## Development Notes

- Always run phase scripts via `sync-cli.sh`; do not invoke `lib/phases/*.sh` directly.
- Maintain strict mode (`set -euo pipefail`) in every helper per `rules/12-shell-guidelines.md`.
- Update documentation when adding phases, planner fields, or CLI arguments so downstream tools (sequence diagrams, plan docs) stay accurate.
- Qwen command verification requires the Python `toml` module (install with `python3 -m pip install --user toml` or ensure the module exists in the CLI’s runtime).

## Agentization Mapping

| Agent | Commands | Default Skills | Optional Skills |
| --- | --- | --- | --- |
| `agent:config-sync` | `/config-sync/sync-cli`, `/config-sync/sync-project-rules`, `/config-sync:adapt-*` | `skill:toolchain-baseline`, `skill:workflow-discipline`, `skill:security-logging` | `skill:language-python`, `skill:language-go`, `skill:language-shell` |

Agent metadata lives in `agents/config-sync/AGENT.md`. Make sure command logs include the agent/skill versions so future audits can trace each run.
