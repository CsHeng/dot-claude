name: "config-sync/sync-project-rules"
command: "~/.claude/commands/config-sync/sync-project-rules.sh"
description: Sync shared Claude rules into project IDE directories (Cursor, VS Code Copilot)
argument-hint: --target=<cursor|copilot|all> [--all] [--dry-run] [--verify-only] [--project-root=<path>]
disable-model-invocation: true
---

# Project Rule Sync Command

## Purpose
Distribute the shared `~/.claude/rules` library plus any project-specific overrides into IDE-facing directories such as `.cursor/rules` and `.github/instructions`. The command mirrors the behavior of `sync-project-rules.sh` but runs directly from `/config-sync/sync-project-rules` with automatic project detection.

## Usage
```bash
/config-sync/sync-project-rules [options]
```

## Options
- `--all` sync every supported IDE target without prompting.
- `--target=<cursor|copilot>` limit syncing to one or more specific targets; flag is repeatable.
- `--dry-run` list destination directories without copying files.
- `--verify-only` display markdown counts for each selected target and exit.
- `--project-root=<path>` explicitly run against a specific project directory.
- `CLAUDE_PROJECT_DIR` environment variable (if set) acts as an implicit project-root override, enabling invocation from any directory.

## Behavior
- Provides built-in logging, copy, and verification helpers so the command stays self-contained (no dependency on legacy `lib/rule-sync-common.sh`).
- Resolves the project root in this order: `--project-root` argument, `CLAUDE_PROJECT_DIR`, then the current working directory (rejecting `~/.claude` itself).
- Honors `CLAUDE_PROJECT_DIR` when present so the command can run from tooling workspaces while still targeting the intended repository.
- Merges sources from `~/.claude/rules` and `<project>/.claude/rules`, allowing checked-in overrides to layer on top of the shared rule set.
- Provides interactive target selection when neither `--all` nor `--target` is supplied.
- Emits verification counts after syncing so users can confirm IDE directories contain the expected files.

## Context Detection
If the command runs from `~/.claude` without an override, it stops immediately to avoid self-sync and instructs the user to supply `--project-root` or `CLAUDE_PROJECT_DIR`. No `.claude/` directory is required inside the target repository; `.cursor/rules` and `.github/instructions` are created on demand.

## Examples
```bash
# Sync both Cursor and Copilot for the current project
/config-sync/sync-project-rules --all

# Sync only Cursor rules for a specific repository
/config-sync/sync-project-rules --target=cursor --project-root=/path/to/project

# Preview destinations without copying
/config-sync/sync-project-rules --dry-run --all
```
