# config-sync CLI Playbook

`/config-sync/sync-cli` is now the **only** orchestrator entrypoint. Every workflow (sync, analyze, verify, adapt, plan, report) is exposed via the `--action` flag, while adapters remain available for direct tool interactions.

## CLI Actions

| Action | Purpose | Common Flags |
| --- | --- | --- |
| `sync` | Collect → analyze → plan → prepare → adapt → execute → (optional) verify → report | `--target=<list|all>`, `--components=<list|all>`, `--profile=<full|fast|custom>`, `--dry-run`, `--force`, `--fix`, `--no-verify` |
| `analyze` | Inspect target capabilities and emit reports (markdown/table/json) | `--format=<markdown|table|json>`, `--detailed` |
| `verify` | Run verification routines (and optional fixes) across components | `--components=<list|all>`, `--fix`, `--detailed` |
| `adapt` | Execute a single adapter via the CLI pipeline | `--adapter=<commands|permissions|rules|memory|settings>` |
| `plan` | Build and persist a plan without executing later phases | `--plan-file=<path>` |
| `report` | Re-render the latest run metadata (requires prior phases) | `--plan-file=<path>` |

Global helpers: `--target`, `--components`, `--profile`, `--plan-file`, `--from-phase`, `--until-phase`, `--dry-run`, `--force`, `--fix`, `--no-verify`, `--adapter`, `--format`, `--verbose`.

## Quick Recipes

```bash
# Full sync with defaults
/config-sync/sync-cli --action=sync

# Dry-run sync for rules + commands on Droid + Qwen
/config-sync/sync-cli --action=sync --target=droid,qwen --components=rules,commands --dry-run

# Analyze OpenCode in table format
/config-sync/sync-cli --action=analyze --target=opencode --format=table --detailed

# Verify permissions + commands for Codex and auto-fix
/config-sync/sync-cli --action=verify --target=codex --components=permissions,commands --fix

# Run only the permissions adapter for Qwen
/config-sync/sync-cli --action=adapt --adapter=permissions --target=qwen --dry-run

# Resume a run from prepare to verify using a stored plan
/config-sync/sync-cli --action=sync --plan-file=~/.claude/backup/plan-20250205-120210.json --from-phase=prepare
```

## Adapter Catalog

| Slash Command | Purpose |
| --- | --- |
| `/config-sync:adapt-permissions` | Map Claude’s `allow/ask/deny` sets to a target tool |
| `/config-sync:adapt-commands` | Convert Claude markdown commands for specific targets |
| `/config-sync:droid` `/config-sync:qwen` `/config-sync:codex` `/config-sync:opencode` | Tool-specific adapters (sync/analyze/verify sub-flags) |
| `/config-sync:adapt-rules-content` | Normalize rules for non-Claude platforms |
| `/config-sync:adapt-permissions` | Permissions-only adaptation helper |

Adapters can be run directly or via `/config-sync/sync-cli --action=adapt --adapter=<name>`.

## Target Snapshot

| Tool | Config Directory | Key Files | Command Format |
| --- | --- | --- | --- |
| Factory/Droid CLI | `~/.factory` | `settings.json`, `config.json`, `DROID.md`, `AGENTS.md`, `rules/` | Markdown |
| Qwen CLI | `~/.qwen` | `settings.json`, `QWEN.md`, `AGENTS.md`, `rules/` | TOML |
| OpenAI Codex CLI | `~/.codex` | `config.toml`, `CODEX.md`, `AGENTS.md`, `rules/` | Markdown |
| OpenCode | `~/.config/opencode` | `opencode.json`, optional `user-settings.json`, `AGENTS.md`, `rules/` | JSON |

## End-to-End Workflow

1. **Analyze** – `/config-sync/sync-cli --action=analyze --target=<tool>` (understand capabilities + gaps)
2. **Sync** – `/config-sync/sync-cli --action=sync --target=<tool>` (apply changes)
3. **Verify** – `/config-sync/sync-cli --action=verify --target=<tool>` (ensure correctness)
4. **Report / resume** – rerun `--action=report` or `--action=sync` with `--plan-file` as needed

## Component Coverage

- **Rules** – Markdown guidelines synchronized across tools
- **Commands** – Slash command definitions, adapted per platform
- **Settings** – Tool config files, respecting force flags
- **Permissions** – Allow/ask/deny lists mapped to native formats
- **Memory** – CLAUDE.md and AGENTS.md derivatives tailored per tool

## Safety Checklist

1. Back up target directories (the CLI’s `prepare` phase handles this when not in `fast` profile).
2. Confirm tool installations and write permissions (`collect` phase fails fast if missing).
3. Review CLI output for warnings (especially around permissions and settings).
4. Always run `--action=verify` (or enable verification during sync) before considering the run complete.
5. When syncing Qwen commands, ensure the Python `toml` module is available (`python3 -m pip install --user toml`) so verification can parse the generated `.toml` manifests.

## Troubleshooting

- **Permission denied** – Ensure the CLI process can write to the target directory (or rerun with elevated privileges if policies permit).
- **Missing adapter** – Verify the relevant script exists under `commands/config-sync/adapters/`.
- **Plan mismatch** – When resuming with `--plan-file`, make sure targets/components match the original plan file.
- **Skipped verification** – Use `--no-verify` sparingly; re-run `--action=verify` to close the loop.
- **Qwen command warnings** – Install the `toml` Python module so the verify phase can parse `.toml` commands instead of skipping them.
