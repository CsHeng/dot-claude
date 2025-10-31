# sync-project-rules.sh Guide

Project-level helper that syncs the shared rule library into IDE assistants (Cursor, VS Code Copilot) for a specific repository.

## Typical Workflow
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
- Supports interactive or flag-driven selection of targets, mirroring the UX of the user-level sync script.
- Intended to be committed alongside project-specific settings (`.claude/settings.json`) for team-wide consistency.

## Recommendations
- Re-run whenever project rule overrides change or when onboarding new teammates.
- Keep the script executable (`chmod +x .claude/sync-project-rules.sh`) inside the project repository.
- Combine with project-specific documentation to describe any custom rule subsets or overrides.
