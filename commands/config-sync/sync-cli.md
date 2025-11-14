---
name: "config-sync:sync-cli"
description: "Unified orchestrator for config-sync workflows across IDE targets"
argument-hint: "--action=<sync|analyze|verify|adapt|plan|report> --target=<list|all> --components=<list|all>"
allowed-tools:
  - Read
  - Write
  - ApplyPatch
  - Bash
  - Bash(rg:*)
  - Bash(ls:*)
  - Bash(find:*)
  - Bash(cat:*)
is_background: false
---

## Usage

Execute unified configuration synchronization workflows across multiple IDE targets and components.

## Arguments

- `--action`: Workflow execution mode
  - `sync`: Execute complete synchronization pipeline
  - `analyze`: Analyze current configuration state
  - `verify`: Validate configuration integrity
  - `adapt`: Apply configuration adaptations
  - `plan`: Generate execution plan only
  - `report`: Generate summary report
- `--target`: Target systems (comma-separated or `all`)
  - Supported: `droid`, `qwen`, `codex`, `opencode`, `amp`
  - Default: `all`
- `--components`: Component types (comma-separated or `all`)
  - Supported: `rules`, `permissions`, `commands`, `settings`, `memory`
  - Default: `all`
- `--adapter`: Specific adapter for adapt phase (optional)
- `--profile`: Execution profile
  - `fast`: Minimal operations
  - `full`: Complete synchronization (default)
  - `custom`: User-defined profile
- `--plan-file`: Path to existing plan file for resume operations
- `--from-phase`: Start execution from specific phase
- `--until-phase`: Stop execution at specific phase
- `--dry-run`: Preview changes without execution
- `--force`: Force execution despite warnings
- `--no-verify`: Skip verification phase
- `--verbose`: Enable detailed logging

## Workflow

1. Parameter Validation: Parse and validate all command-line arguments
2. Environment Detection: Identify IDE targets and validate accessibility
3. Settings Integration: Merge runtime parameters with persistent settings
4. Plan Generation: Create execution plan with phases and dependencies
5. Phase Execution: Run determined phases in sequence with validation
6. Result Persistence: Save execution metadata and artifacts
7. Cleanup Operations: Manage temporary files and backup retention

### Phase Mapping

| Action | Phases Executed |
| --- | --- |
| `sync` | collect → analyze → plan → prepare → adapt → execute → verify → cleanup → report |
| `analyze` | collect → analyze |
| `verify` | execute → verify |
| `adapt` | adapt → execute |
| `plan` | collect → analyze → plan → prepare |
| `report` | report |

## Output

Generated Artifacts:
- Plan file: `~/.claude/backup/plan-<timestamp>.json`
- Run logs: `~/.claude/backup/run-<timestamp>/logs/*.log`
- Execution report: `~/.claude/backup/run-<timestamp>/metadata/report.json`
- Console output: Structured progress and error messages

Exit Codes:
- 0: Successful completion
- 1: Parameter validation failure
- 2: Environment detection failure
- 3: Phase execution failure
- 4: File system permission error
- 5: Configuration validation failure

## Safety Constraints

1. Parameter Validation: Validate all parameters before file operations
2. Target Accessibility: Verify target system directories are accessible
3. Backup Creation: Create automatic backups before modifications
4. Rollback Capability: Maintain rollback information for failed operations
5. Permission Checks: Validate write permissions before execution
6. Dependency Verification: Ensure required tools and dependencies are available

## Examples

```bash
# Complete synchronization for all targets
/config-sync/sync-cli --action=sync

# Analyze configuration state for opencode target
/config-sync/sync-cli --action=analyze --target=opencode

# Verify integrity of rules and permissions
/config-sync/sync-cli --action=verify --components=rules,permissions

# Preview changes without execution
/config-sync/sync-cli --action=sync --dry-run --target=droid,qwen

# Resume execution from specific phase
/config-sync/sync-cli --action=sync --plan-file=~/.claude/backup/plan-20250205-120210.json --from-phase=prepare

# Fast profile execution for specific components
/config-sync/sync-cli --action=sync --profile=fast --components=commands,settings
```

## Error Handling

Parameter Errors:
- Invalid action: Display supported actions and exit with code 1
- Invalid target: List supported targets and exit with code 1
- Invalid component: Show valid component types and exit with code 1

Environment Errors:
- Target inaccessible: Log error and continue with available targets
- Permission denied: Exit with code 4 after logging affected paths
- Missing dependencies: Exit with code 2 after listing requirements

Execution Errors:
- Phase failure: Log detailed error information and exit with code 3
- Configuration validation: Exit with code 5 after reporting violations
- File system errors: Log specific error and attempt rollback