---
description: "Generate a read-only health report for agents, skills, backups, and governance runs based on .claude metadata"
name: agent-ops-health-report
argument-hint: "[--backup-root=<path>] [--runs=<N>] [--since=<ISO8601>]"
allowed-tools:
  - Read
  - Bash
  - Bash(python3 skills/llm-governance/scripts/validator.py *)
  - Bash(skills/llm-governance/scripts/agent-matrix.sh *)
  - Bash(skills/llm-governance/scripts/skill-matrix.sh *)
  - Bash(skills/llm-governance/scripts/structure-check.sh *)
metadata:
  is_background: false
  style: minimal-chat
---

## Usage

```bash
/agent-ops:health-report [--backup-root=<path>] [--runs=<N>] [--since=<ISO8601>]
```

## Arguments

- `--backup-root`: Optional path to the backup root directory (default: `.claude/backup`).
- `--runs`: Optional maximum number of recent runs to include in the report.
- `--since`: Optional ISO8601 timestamp; when provided, only runs after this time are considered.

## Workflow

1. Discover backup and run metadata under the configured backup root.
2. Collect recent llm-governance and config-sync executions with timestamps and status.
3. Run `skills/llm-governance/scripts/validator.py` in read-only mode over the `.claude` directory to aggregate critical errors and warnings.
4. Invoke `skills/llm-governance/scripts/agent-matrix.sh` and `skills/llm-governance/scripts/skill-matrix.sh` to snapshot capability-level and style coverage.
5. Run `skills/llm-governance/scripts/structure-check.sh` against the target Claude root (for example `~/.claude` or a project's `.claude/`) to validate:
   - All agents and skills are marked `layer: execution`.
   - Warn (only) if legacy `commands/*/COMMAND.md` files are present (execution-layer command families are no longer expected).
6. Correlate validator findings, matrices, structure-check results, and run metadata into a structured health summary:
   - Counts of runs, rollbacks, and backups by domain.
   - Capability and style coverage across agents and skills.
   - Outstanding critical governance violations or structural inconsistencies.
7. Identify rollback candidates by scanning rollback directories and associating them with source runs.
8. Emit a minimal-chat report with clearly delimited sections and no conversational padding.

## Output

- Health Summary:
  - Recent runs by domain (config-sync, llm-governance, others) with counts and basic status.
  - Capability-level and style coverage extracted from agent and skill matrices.
  - High-level governance status derived from `skills/llm-governance/scripts/validator.py` results.
- Risk Summary:
  - Critical and high-severity issues grouped by file, rule, or domain.
  - Explicit references to manifests or rules that require human attention.
- Rollback Candidates:
  - List of rollback directories with timestamps and associated run identifiers.
  - Qualitative scope (for example, config-only, rules-only) when derivable from metadata.
- Sync Drift Summary:
  - Optional description of detectable drift between environments when config-sync metadata is available.
