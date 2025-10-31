# sync-user-commands.sh Guide

Mirrors personal Claude custom commands (`~/.claude/commands/`) into the Factory/Droid CLI command directory (`~/.factory/commands/`) with Droid-compatible formatting.

## Usage
```bash
# Synchronize commands
./sync-user-commands.sh

# Preview mappings and warnings only
./sync-user-commands.sh --dry-run

# Display current synced command stats
./sync-user-commands.sh --verify-only
```

## Behavior
- Cleans previously mirrored files with the `claude__` prefix before copying.
- Flattens nested paths and sanitizes Markdown frontmatter to keys supported by Droid (`description`, `argument-hint`).
- Warns when positional placeholders (`$1`, `$2`, …) or unsupported frontmatter keys (e.g., `allowed-tools`) are detected.
- Leaves executable commands (with shebangs) untouched aside from path normalization.

## Tips
- Review warnings after each run; adjust the source command to remove unsupported constructs where possible.
- Use `--dry-run` when adding new commands to check for naming collisions.
- Pair with `sync-user-rules.sh` to ensure rules and commands remain aligned across tools.
