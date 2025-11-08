---
name: "config-sync:cli"
description: Unified orchestrator for config-sync workflows (sync, analyze, verify, adapt, report)
argument-hint: --action=<sync|analyze|verify|adapt|plan|report> --target=<list|all> --components=<list|all> [--adapter=<name>] [--profile=<fast|full|custom>] [--plan-file=<path>] [--from-phase=<phase>] [--until-phase=<phase>] [--dry-run] [--force] [--fix] [--no-verify]
allowed-tools: Read, Write, ApplyPatch, Bash(rg:*), Bash(ls:*), Bash(find:*), Bash(cat:*)
---

## Purpose
`config-sync-cli` replaces the scattered `/config-sync:*` commands with a single coordinator that parses parameters once, builds a declarative plan, and enforces the collect→analyze→plan→prepare→adapt→execute→verify→report pipeline. Every invocation persists its plan and run metadata under `~/.claude/config-sync/` so runs can be inspected or replayed with phase gating.

## Usage
```bash
/config-sync:cli \
  --action=<sync|analyze|verify|adapt|plan|report> \
  --target=<droid,qwen,codex,opencode|all> \
  --components=<rules,permissions,commands,settings,memory|all> \
  [--adapter=<commands|permissions|rules|memory|settings>] \
  [--profile=<fast|full|custom>] \
  [--plan-file=<path>] \
  [--from-phase=<phase>] \
  [--until-phase=<phase>] \
  [--dry-run] [--force] [--fix] [--no-verify] [--verbose]
```

## Key behaviors
- **Single parsing surface** – All arguments are normalized up front using helpers in `lib/common.sh`, merged with `settings.json` defaults, and persisted into `plan.json`.
- **Phase enforcement** – Each action maps to a phase sequence. Use `--from-phase`/`--until-phase` to resume partially completed runs while keeping ordering guarantees.
- **Planner outputs** – Default plan path: `~/.claude/config-sync/plan-<timestamp>.json`. Override via `--plan-file` or point to an existing plan when resuming.
- **Profiles** – `full` (default) runs every available phase; `fast` skips verification and limits backups; `custom` defers to explicit flags.
- **Adapters** – During the `adapt`/`execute` phases the CLI calls the existing adapters in `commands/config-sync/adapters/` with consolidated flags.
- **Reporting** – Each run writes phase logs (`run-<timestamp>/logs/*.log`) plus a structured summary (`run-<timestamp>/metadata/report.json`). Failures keep the pipeline in fail-fast mode but still emit a report.

## Examples
- Full sync with verification (default):  
  ```bash
  /config-sync:cli --action=sync --target=all --components=all
  ```
- Analyze only (table format) without touching targets:  
  ```bash
  /config-sync:cli --action=analyze --target=opencode --format=table
  ```
- Verify commands + permissions and auto-fix common issues:  
  ```bash
  /config-sync:cli --action=verify --target=droid,qwen --components=commands,permissions --fix
  ```
- Run only the permissions adapter in dry-run mode:  
  ```bash
  /config-sync:cli --action=adapt --adapter=permissions --target=qwen --dry-run
  ```
- Resume a partial plan from `prepare` onward:  
  ```bash
  /config-sync:cli --action=sync --plan-file=~/.claude/config-sync/plan-20250205-120210.json --from-phase=prepare
  ```
