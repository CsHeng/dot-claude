# Config-Sync System Guide

Config-Sync is a unified system for synchronizing Claude configuration across multiple AI tools and platforms.

## Architecture Overview

The system operates on an 8-phase pipeline:
`collect → analyze → plan → prepare → adapt → execute → verify → report`

### Phase Pipeline Details

1. **Collect** - Gather current configuration from Claude and target tools
2. **Analyze** - Inspect target capabilities and identify gaps/conflicts
3. **Plan** - Create execution plan with specific actions and dependencies
4. **Prepare** - Create backups and validate prerequisites
5. **Adapt** - Transform configurations for target tool formats
6. **Execute** - Apply configurations to target tools
7. **Verify** - Validate successful application and functionality
8. **Report** - Generate comprehensive execution report

### Backup System

The backup system uses a **unified centralized approach** during the **prepare** phase:

- **Location**: `~/.claude/backup/run-TIMESTAMP/backups/`
- **Scope**: Complete target configuration directories
- **Strategy**: Single comprehensive backup operation per tool
- **Structure**: Organized by tool with timestamped subdirectories

#### Unified Backup Structure
```
~/.claude/backup/run-TIMESTAMP/
├── backups/
│   ├── droid/              # Complete ~/.factory/ backup
│   ├── qwen/               # Complete ~/.qwen/ backup
│   ├── codex/              # Complete ~/.codex/ backup
│   └── opencode/           # Complete ~/.config/opencode/ backup
├── logs/
└── metadata/
```

#### Backup Features
- **Automatic cleanup** of legacy backup directories in target tool directories
- **Detailed logging** with file counts and backup sizes
- **Backup manifests** (JSON) for verification and restoration
- **Complete directory backup** using rsync with delete flag for accuracy
- **Profile awareness** - Fast profile skips backup but records placeholder

### Resumption Capability

Execution can be resumed from any phase:
```bash
# Resume from prepare phase using stored plan
claude /config-sync:sync-cli --action=sync --plan-file=~/.claude/backup/plan-20250205-120210.json --from-phase=prepare
```

- **Primary orchestrator**: `claude /config-sync:sync-cli` - Full workflow management
- **Adapter commands**: Tool-specific operations for targeted tasks
- **Project integration**: `claude /config-sync:sync-project-rules` - IDE synchronization

### PlantUML Integration

The system includes PlantUML sequence diagrams for workflow visualization:

- **CLI Workflow**: `docs/config-sync-cli-sequence-diagram.puml`
- **Project Rules Workflow**: `docs/config-sync-project-sequence-diagram.puml`

These diagrams can be rendered to SVG for documentation:
```bash
# Render CLI workflow diagram
plantuml -tsvg docs/config-sync-cli-sequence-diagram.puml

# Render project rules workflow diagram
plantuml -tsvg docs/config-sync-project-sequence-diagram.puml
```

## Target Tools

| Tool | Config Directory | Key Files | Command Format |
|------|------------------|-----------|----------------|
| Droid CLI | `~/.factory` | `settings.json`, `config.json`, `DROID.md`, `AGENTS.md`, `rules/` | Markdown |
| Qwen CLI | `~/.qwen` | `settings.json`, `permissions.json`, `QWEN.md`, `AGENTS.md`, `rules/` | TOML |
| OpenAI Codex CLI | `~/.codex` | `config.toml`, `CODEX.md`, `AGENTS.md`, `rules/` | Markdown |
| OpenCode | `~/.config/opencode` | `opencode.json`, optional `user-settings.json`, `AGENTS.md`, `rules/` | JSON |
| Amp CLI | `~/.config/amp` | `settings.json`, `AGENTS.md`, global `~/.config/AGENTS.md`, `commands/`, `rules/` | Markdown + executables |

## CLI Reference

### Primary Orchestrator: `claude /config-sync:sync-cli`

All operations use: `claude /config-sync:sync-cli --action=<ACTION> [FLAGS]`

#### Actions

| Action | Purpose | Key Flags |
|--------|---------|-----------|
| `sync` | Full workflow: collect → analyze → plan → prepare → adapt → execute → verify → report | `--target=<list|all>`, `--components=<list|all>`, `--profile=<full|fast|custom>`, `--dry-run`, `--force`, `--no-verify` |
| `analyze` | Inspect target capabilities and emit reports | `--format=<markdown|table|json>`, `--detailed` |
| `verify` | Run verification routines | `--components=<list|all>`, `--detailed` |
| `adapt` | Execute a single adapter via the CLI pipeline | `--adapter=<commands|permissions|rules|memory|settings>` |
| `plan` | Build and persist a plan without executing later phases | `--plan-file=<path>` |
| `report` | Re-render the latest run metadata (requires prior phases) | `--plan-file=<path>` |

#### Global Flags

`--target`, `--components`, `--profile`, `--plan-file`, `--from-phase`, `--until-phase`, `--dry-run`, `--force`, `--no-verify`, `--adapter`, `--format`, `--verbose`

#### Component Types

- **rules** - Markdown guidelines synchronized across tools
- **commands** - Slash command definitions, adapted per platform
- **settings** - Tool config files, respecting force flags
- **permissions** - Allow/ask/deny lists mapped to native formats
- **memory** - CLAUDE.md and AGENTS.md derivatives tailored per tool

### Usage Examples

```bash
# Full sync with defaults
claude /config-sync:sync-cli --action=sync

# Dry-run sync for rules + commands on Droid + Qwen
claude /config-sync:sync-cli --action=sync --target=droid,qwen --components=rules,commands --dry-run

# Analyze OpenCode in table format
claude /config-sync:sync-cli --action=analyze --target=opencode --format=table --detailed

# Verify permissions + commands for Codex
claude /config-sync:sync-cli --action=verify --target=codex --components=permissions,commands

# Run only the permissions adapter for Qwen
claude /config-sync:sync-cli --action=adapt --adapter=permissions --target=qwen --dry-run

# Resume a run from prepare to verify using a stored plan
claude /config-sync:sync-cli --action=sync --plan-file=~/.claude/backup/plan-20250205-120210.json --from-phase=prepare
```

## Adapter Commands

### Tool-Specific Adapters

| Command | Purpose |
|---------|---------|
| `/config-sync/droid` | Droid CLI synchronization (sync/analyze/verify sub-flags) |
| `/config-sync/qwen` | Qwen CLI synchronization (sync/analyze/verify sub-flags) |
| `/config-sync/codex` | OpenAI Codex CLI synchronization (sync/analyze/verify sub-flags) |
| `/config-sync/opencode` | OpenCode synchronization (sync/analyze/verify sub-flags) |
| `/config-sync/amp` | Amp CLI synchronization (sync/analyze/verify sub-flags) |

### Utility Adapters

| Command | Purpose |
|---------|---------|
| `/config-sync/analyze-target-tool` | Deep analysis of a specific tool's capabilities and configuration |
| `/config-sync/adapt-permissions` | Map Claude's allow/ask/deny sets to a target tool |
| `/config-sync/adapt-commands` | Convert Claude markdown commands for specific targets |
| `/config-sync/adapt-rules-content` | Normalize rules for non-Claude platforms |

### When to Use Adapters vs Main CLI

- **Main CLI**: Multi-tool operations, full workflow, phase gating
- **Tool adapters**: Single-tool operations, quick syncs, tool-specific issues
- **Utility adapters**: Targeted tasks (permission mapping, command conversion, etc.)

## Project Rules Integration

### `claude /config-sync:sync-project-rules`

Project-level helper that syncs the shared rule library into IDE assistants (Cursor, VS Code Copilot) for a specific repository.

```bash
# From inside the project (or pass --project-root / use CLAUDE_PROJECT_DIR)
claude /config-sync:sync-project-rules --all

# Limit to a single target
claude /config-sync:sync-project-rules --target=cursor

# Run from another directory
CLAUDE_PROJECT_DIR=/path/to/project claude /config-sync:sync-project-rules --verify-only
```

#### Behavior

- Copies `~/.claude/rules/*.md` into the project's AI rule directories (Cursor, VS Code Copilot) using the same numbering and filenames
- Auto-detects the project root (or honors `--project-root`/`CLAUDE_PROJECT_DIR`) and creates `.cursor/rules` plus `.github/instructions` on demand
- Script workflow mirrors the slash command UX and can be committed alongside project-specific settings for teams that prefer repo-local tooling

#### Recommendations

- Re-run whenever project rule overrides change or when onboarding new teammates
- Use the slash command exclusively; no project-local script is required anymore
- Combine with project-specific documentation to describe any custom rule subsets or overrides

## Configuration & Safety

### Settings and Profiles

- **Profile types**: `full` (complete backup + verification), `fast` (minimal checks), `custom` (user-defined)
- **Force flags**: Override safety checks when necessary (use with caution)
- **Plan files**: JSON-based execution plans that can be resumed and audited

### Backup Strategy

The `prepare` phase automatically creates backups unless using `fast` profile:
- Timestamped backup directories
- Configuration file versioning
- Rollback capability via plan files

### Permission Mapping Logic

- Claude allow/ask/deny → Tool-specific formats
- Security-first approach with risk assessment
- Format conversion: JSON → TOML → Guidelines
- Tool-appropriate sandbox levels and operation-based permissions

### Safety Checklist

1. **Back up target directories** - The CLI's `prepare` phase handles this when not in `fast` profile
2. **Confirm tool installations** - `collect` phase fails fast if tools or write permissions are missing
3. **Review CLI output** - Especially warnings around permissions and settings
4. **Run verification** - Always run `--action=verify` (or enable verification during sync) before considering the run complete
5. **Install Qwen dependencies** - When syncing Qwen commands, ensure Python `toml` module is available (`python3 -m pip install --user toml`)

### Verification Workflows

```bash
# Full verification with detailed output
claude /config-sync:sync-cli --action=verify --target=all --components=all --detailed

# Verification with auto-fix
claude /config-sync:sync-cli --action=verify --target=codex --components=permissions,commands

# Component-specific verification
claude /config-sync:sync-cli --action=verify --target=qwen --components=rules
```

### Rollback Procedures

1. **Use plan files**: `claude /config-sync:sync-cli --action=report --plan-file=<path>` to review changes
2. **Manual restore**: Restore from backup directories created during `prepare` phase
3. **Re-sync**: Run sync again with corrected configuration

## Troubleshooting

### Common Issues

- **Permission denied** - Ensure the CLI process can write to the target directory (or rerun with elevated privileges if policies permit)
- **Missing adapter** - Verify the relevant script exists under `commands/config-sync/adapters/`
- **Plan mismatch** - When resuming with `--plan-file`, make sure targets/components match the original plan file
- **Skipped verification** - Use `--no-verify` sparingly; re-run `--action=verify` to close the loop
- **Qwen command warnings** - Install the `toml` Python module so the verify phase can parse `.toml` commands instead of skipping them

### Debug Options

- **Verbose output**: Add `--verbose` flag for detailed execution information
- **Dry-run**: Use `--dry-run` to preview changes without execution
- **Phase control**: Use `--from-phase` and `--until-phase` to isolate problematic phases

### Getting Help

- Use `--help` flag with any command for detailed usage information
- Check plan files for execution history and error details
- Review backup directories for original configurations if needed

## End-to-End Workflows

### Initial Setup

1. **Analyze** - `claude /config-sync:sync-cli --action=analyze --target=<tool>` (understand capabilities + gaps)
2. **Sync** - `claude /config-sync:sync-cli --action=sync --target=<tool>` (apply changes)
3. **Verify** - `claude /config-sync:sync-cli --action=verify --target=<tool>` (ensure correctness)
4. **Report** - Re-run `--action=report` or `--action=sync` with `--plan-file` as needed

### Ongoing Maintenance

- **Targeted updates**: Use `--target` and `--components` flags for specific changes
- **Regular verification**: Schedule periodic verification runs
- **Project sync**: Use `claude /config-sync:sync-project-rules` when project rules change
- **Monitor**: Check CLI output for warnings and recommendations

### Multi-Tool Management

- **Bulk operations**: Use `--target=all` for system-wide changes
- **Parallel processing**: All tool adapters run in parallel to reduce total sync time
- **Phase gating**: Control execution phases for complex operations
- **Plan resumption**: Store and resume execution plans for long-running operations
