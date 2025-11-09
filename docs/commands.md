# Command Layout Overview (`~/.claude/commands/`)

The commands directory now centers on `/config-sync/sync-cli`, the single orchestrator that lives under `commands/config-sync/`. This CLI drives every sync/analyze/verify/adapt workflow across Qwen, Factory/Droid, Codex, and OpenCode.

## Directory Structure
```
~/.claude/commands/
├── config-sync/        # Config-sync command suite
│   ├── cli/            # Unified CLI manifest + shell entrypoint
│   ├── adapters/       # Tool-specific adapters and helpers
│   ├── lib/            # Shared guidance for helper routines
│   └── scripts/        # Bash helpers referenced by command snippets
├── draft-commit-message.md
└── review-shell-syntax.md
```

> Note: Tool adapters intentionally exclude the internal `config-sync/` module when synchronizing commands to external CLIs so that orchestration logic stays Claude-local.

## Minimal Command Guidelines
- Each command file must include YAML frontmatter with at least `name`, `description`, and (optionally) `argument-hint`.
- Use the new slash-style names for top-level handlers (e.g., `/config-sync/sync-cli`, `/config-sync/sync-project-rules`) and keep adapter references aligned with their registered aliases such as `/config-sync:adapt-permissions`.
- Reference other commands via their published slash form (`/config-sync/sync-cli`, `/config-sync:adapt-permissions`) rather than direct file paths.
- Additional personal commands (like `draft-commit-message.md`) can continue to live at the top level.

For a detailed rundown of `/config-sync/sync-cli` actions and the remaining adapter commands see [`docs/config-sync-commands.md`](./config-sync-commands.md).
