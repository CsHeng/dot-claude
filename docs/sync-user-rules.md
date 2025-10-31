# sync-user-rules.sh Guide

Synchronizes the master rule library (`~/.claude/rules/`) into user-level AI tooling directories.

## Targets
- **Qwen CLI** → `~/.qwen/rules/`
- **Factory/Droid CLI** → `~/.factory/rules/`
- **Codex CLI** → `~/.codex/AGENTS.md`

## Usage
```bash
# Interactive selection
./sync-user-rules.sh

# All targets without prompts
./sync-user-rules.sh --all

# Dry run (no copies)
./sync-user-rules.sh --dry-run

# Verification without syncing
./sync-user-rules.sh --verify-only

# Specific targets (repeatable)
./sync-user-rules.sh --target qwen --target codex
```

## Behavior
- Copies Markdown rules into each selected tool’s directory, replacing existing copies.
- Regenerates `~/.qwen/QWEN.md` with the rule index.
- Renders `~/.codex/AGENTS.md` with the latest rule content for Codex.
- Logs verification output after every sync.
- Custom command synchronization is handled separately via `sync-user-commands.sh`.

## Best Practices
- Run after editing any files in `~/.claude/rules/`.
- Pair with `sync-user-commands.sh --verify-only` to confirm custom commands remain in sync.
- Use `--dry-run` during testing to confirm destination paths.
