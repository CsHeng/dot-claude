# sync-project-rules Guide

Project-level helpers that sync the shared rule library into IDE assistants (Cursor, VS Code Copilot) for a specific repository.

## Slash Command (preferred)
```bash
# From inside the project (or pass --project-root / use CLAUDE_PROJECT_DIR)
/config-sync/sync-project-rules --all

# Limit to a single target
/config-sync/sync-project-rules --target=cursor

# Run from another directory
CLAUDE_PROJECT_DIR=/path/to/project /config-sync/sync-project-rules --verify-only
```

## Behavior
- Copies `~/.claude/rules/*.md` into the project’s AI rule directories (Cursor, VS Code Copilot) using the same numbering and filenames.
- Slash command auto-detects the project root (or honors `--project-root`/`CLAUDE_PROJECT_DIR`) and creates `.cursor/rules` plus `.github/instructions` on demand.
- Script workflow mirrors the slash command UX and can be committed alongside project-specific settings for teams that prefer repo-local tooling.

## Recommendations
- Re-run whenever project rule overrides change or when onboarding new teammates.
- Use the slash command exclusively; no project-local script is required anymore.
- Combine with project-specific documentation to describe any custom rule subsets or overrides.
