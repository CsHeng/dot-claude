---
name: "config-sync/sync-cli"
description: "Unified orchestrator for config-sync workflows (sync, analyze, verify, adapt, report)"
command: "~/.claude/commands/config-sync/sync-cli.sh"
argument-hint: "--action=<sync|analyze|verify|adapt|plan|report> --target=<list|all> --components=<list|all> [--adapter=<name>] [--profile=<fast|full|custom>] [--plan-file=<path>] [--from-phase=<phase>] [--until-phase=<phase>] [--dry-run] [--force] [--no-verify]"
allowed-tools:
  - Read
  - Write
  - ApplyPatch
  - Bash(rg:*)
  - Bash(ls:*)
  - Bash(find:*)
  - Bash(cat:*)
---

## Purpose
`sync-cli` replaces the scattered `/config-sync:*` commands with a single coordinator that parses parameters once, builds a declarative plan, and enforces the collect→analyze→plan→prepare→adapt→execute→[verify]→cleanup→report pipeline. Every invocation persists its plan and run metadata under `~/.claude/backup/` so runs can be inspected or replayed with phase gating. The cleanup phase automatically manages backup retention based on configurable settings.

## Usage
```bash
/config-sync/sync-cli \
  --action=<sync|analyze|verify|adapt|plan|report> \
  --target=<droid,qwen,codex,opencode|all> \
  --components=<rules,permissions,commands,settings,memory|all> \
  [--adapter=<commands|permissions|rules|memory|settings>] \
  [--profile=<fast|full|custom>] \
  [--plan-file=<path>] \
  [--from-phase=<phase>] \
  [--until-phase=<phase>] \
  [--dry-run] [--force] [--no-verify] [--verbose]
```

## Key behaviors
- Single parsing surface – All arguments are normalized up front using helpers in `lib/common.sh`, merged with `settings.json` defaults, and persisted into `plan.json`.
- Phase enforcement – Each action maps to a phase sequence. Use `--from-phase`/`--until-phase` to resume partially completed runs while keeping ordering guarantees.
- Planner outputs – Default plan path: `~/.claude/backup/plan-<timestamp>.json`. Override via `--plan-file` or point to an existing plan when resuming.
- Profiles – `full` (default) runs every available phase; `fast` skips verification and limits backups; `custom` defers to explicit flags.
- Adapters – During the `adapt`/`execute` phases the CLI calls the existing adapters in `commands/config-sync/adapters/` with consolidated flags.
- Backup Retention – The `cleanup` phase automatically removes old backup runs based on retention settings in `settings.json` (default: keep latest 5 runs).
- Reporting – Each run writes phase logs (`run-<timestamp>/logs/*.log`) plus a structured summary (`run-<timestamp>/metadata/report.json`). Failures keep the pipeline in fail-fast mode but still emit a report.

## Examples
- Full sync with verification (default):
  ```bash
  /config-sync/sync-cli --action=sync --target=all --components=all
  ```
- Analyze only (table format) without touching targets:
  ```bash
  /config-sync/sync-cli --action=analyze --target=opencode --format=table
  ```
- Verify commands + permissions across multiple targets:
  ```bash
  /config-sync/sync-cli --action=verify --target=droid,qwen --components=commands,permissions
  ```
- Run only the permissions adapter in dry-run mode:
  ```bash
  /config-sync/sync-cli --action=adapt --adapter=permissions --target=qwen --dry-run
  ```
- Resume a partial plan from `prepare` onward:
  ```bash
  /config-sync/sync-cli --action=sync --plan-file=~/.claude/backup/plan-20250205-120210.json --from-phase=prepare
  ```
- Skip cleanup phase:
  ```bash
  /config-sync/sync-cli --action=sync --target=all --until-phase=execute
  ```
- Run only cleanup phase:
  ```bash
  /config-sync/sync-cli --action=sync --target=all --from-phase=cleanup --until-phase=cleanup
  ```

## Backup Retention Configuration

Backup retention is controlled via the `settings.json` file:

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

### Retention Settings
- **maxRuns**: Maximum number of backup runs to keep (default: 5)
- **enabled**: Whether automatic cleanup is enabled (default: true)
- **dryRun**: Preview what would be deleted without actually deleting (default: false)

### Backup Management Commands
- Check backup status and what would be cleaned up:
  ```bash
  ~/.claude/commands/config-sync/scripts/backup-cleanup.sh --status
  ```
- Preview cleanup actions:
  ```bash
  ~/.claude/commands/config-sync/scripts/backup-cleanup.sh --dry-run
  ```
- Manually run cleanup:
  ```bash
  ~/.claude/commands/config-sync/scripts/backup-cleanup.sh
  ```
