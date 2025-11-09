# sync-project-rules Guide

Project-level helpers that sync the shared rule library into IDE assistants (Cursor, VS Code Copilot) for a specific repository.

## Slash Command (preferred)
```bash
# From inside the project (or pass --project-root / use CLAUDE_PROJECT_DIR)
/config-sync:sync-project-rules --all

# Limit to a single target
/config-sync:sync-project-rules --target=cursor

# Run from another directory
CLAUDE_PROJECT_DIR=/path/to/project /config-sync:sync-project-rules --verify-only
```

## Legacy Script (optional)
```bash
# Copy script into the project once
cp ~/.claude/sync-project-rules.sh /path/to/project/.claude/

# From inside the project
cd /path/to/project
.claude/sync-project-rules.sh

# Verification only
.claude/sync-project-rules.sh --verify-only

# Preview affected files
.claude/sync-project-rules.sh --dry-run
```

## Behavior
- Copies `~/.claude/rules/*.md` into the project’s AI rule directories (Cursor, VS Code Copilot) using the same numbering and filenames.
- Slash command auto-detects the project root (or honors `--project-root`/`CLAUDE_PROJECT_DIR`) and creates `.cursor/rules` plus `.github/instructions` on demand.
- Script workflow mirrors the slash command UX and can be committed alongside project-specific settings for teams that prefer repo-local tooling.

## Recommendations
- Re-run whenever project rule overrides change or when onboarding new teammates.
- Keep the legacy script executable (`chmod +x .claude/sync-project-rules.sh`) if you choose to store it in the repository.
- Combine with project-specific documentation to describe any custom rule subsets or overrides.
