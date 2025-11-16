---
name: "agent-ops:health-report"
description: "Generate a read-only health report for agents, skills, backups, and governance runs based on .claude metadata"
argument-hint: "[--backup-root=<path>] [--runs=<N>] [--since=<ISO8601>]"
allowed-tools:
  - Read
  - Bash
  - Bash(python3 commands/llm-governance/optimize-prompts/llm_spec_validator.py *)
  - Bash(commands/agent-ops/scripts/agent-matrix.sh *)
  - Bash(commands/agent-ops/scripts/skill-matrix.sh *)
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
2. Collect recent optimize-prompts and config-sync executions with timestamps and status.
3. Run `llm_spec_validator.py` in read-only mode over the `.claude` directory to aggregate critical errors and warnings.
4. Invoke `agent-matrix.sh` and `skill-matrix.sh` to snapshot capability-level and style coverage.
5. Correlate validator findings, matrices, and run metadata into a structured health summary:
   - Counts of runs, rollbacks, and backups by domain.
   - Capability and style coverage across agents and skills.
   - Outstanding critical governance violations or structural inconsistencies.
6. Identify rollback candidates by scanning rollback directories and associating them with source runs.
7. Emit a minimal-chat report with clearly delimited sections and no conversational padding.

## Output

- Health Summary:
  - Recent runs by domain (config-sync, optimize-prompts, others) with counts and basic status.
  - Capability-level and style coverage extracted from agent and skill matrices.
  - High-level governance status derived from `llm_spec_validator.py` results.
- Risk Summary:
  - Critical and high-severity issues grouped by file, rule, or domain.
  - Explicit references to manifests or rules that require human attention.
- Rollback Candidates:
  - List of rollback directories with timestamps and associated run identifiers.
  - Qualitative scope (for example, config-only, rules-only) when derivable from metadata.
- Sync Drift Summary:
  - Optional description of detectable drift between environments when config-sync metadata is available.
