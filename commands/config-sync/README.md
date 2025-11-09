# Config Sync Plugin (Unified CLI)

The config-sync suite now centers on a single slash command, `/config-sync/sync-cli`, which owns parameter parsing, plan generation, phase gating, and reporting for every workflow (sync, analyze, verify, adapt, plan, report).

## Layout

- `cli/` – Command manifests + `sync-cli.sh` entrypoint (plus `config-sync-cli.sh` legacy shim)
- `adapters/` – Target-specific automation invoked during the `adapt` phase
- `sync-project-rules.{md,sh}` – Standalone slash command for syncing the shared rule library into IDE-facing directories
- `lib/common.*` – Shared helpers (parsing, logging, path resolution)
- `lib/phases/` – Phase runners (`collect`, `analyze`, `plan`, `prepare`, `adapt`, `execute`, `verify`, `report`)
- `lib/planners/` – Plan builders for sync/adapt flows
- `scripts/` – Reusable shell helpers (`executor.sh`, `backup.sh`)
- `settings.json` – Default target/component selections, verify/dry-run preferences

## Primary Slash Command

| Command | Purpose |
| --- | --- |
| `/config-sync/sync-cli` | Unified entrypoint (`--action=<sync|analyze|verify|adapt|plan|report>`) with support for `--target`, `--components`, `--profile`, `--plan-file`, `--from-phase`, `--until-phase`, `--dry-run`, `--force`, `--fix`, `--adapter`, and `--format`. |
| `/config-sync/sync-project-rules` | IDE helper that copies `~/.claude/rules` (plus project overrides) into `.cursor/rules` and `.github/instructions`, supporting `--target`, `--dry-run`, `--verify-only`, and `--project-root` or `CLAUDE_PROJECT_DIR`. The old `/config-sync:sync-project-rules` alias has been removed—use the slash command directly. |

Adapters such as `/config-sync:adapt-permissions` or `/config-sync:droid` remain for direct tooling control, but the orchestration layer no longer exposes per-phase wrappers like `/config-sync:sync` or `/config-sync:verify`.

## Supported Targets

- Factory/Droid CLI – Markdown commands, JSON permissions
- Qwen CLI – TOML command conversion, documentation-based permissions
- OpenAI Codex CLI – Minimal configuration with sandbox levels
- OpenCode – JSON command format with operation-based permissions

## Usage Examples

```bash
# Full sync with defaults
/config-sync/sync-cli --action=sync

# Analyze opencode in table format
/config-sync/sync-cli --action=analyze --target=opencode --format=table

# Verify commands + permissions for droid and qwen
/config-sync/sync-cli --action=verify --target=droid,qwen --components=commands,permissions --fix

# Re-run plan from prepare onwards
/config-sync/sync-cli --action=sync --plan-file=~/.claude/backup/plan-20250205-120210.json --from-phase=prepare
```

## Development Notes

- Always run phase scripts via `sync-cli.sh`; do not invoke `lib/phases/*.sh` directly (the `config-sync-cli.sh` shim merely execs the renamed entrypoint).
- Maintain strict mode (`set -euo pipefail`) in every helper per `rules/12-shell-guidelines.md`.
- Update documentation when adding phases, planner fields, or CLI arguments so downstream tools (sequence diagrams, plan docs) stay accurate.
- Qwen command verification requires the Python `toml` module (install with `python3 -m pip install --user toml` or ensure the module exists in the CLI’s runtime).
