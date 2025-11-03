# Command Layout Overview (`~/.claude/commands/`)

The commands directory now centers on the `/config-sync:*` slash-command suite that lives under `config-sync/`. These commands orchestrate all rule, permission, settings, and command synchronization across Qwen, Factory/Droid, Codex, and OpenCode.

## Directory Structure
```
~/.claude/commands/
├── config-sync/        # Slash commands implemented as Markdown specs
│   ├── core/           # High-level orchestrators (sync, analyze, verify)
│   ├── adapters/       # Tool-specific adapters and helpers
│   ├── lib/            # Shared guidance for helper routines
│   └── scripts/        # Bash helpers referenced by command snippets
├── draft-commit-message.md
└── review-shell-syntax.md
```

> Note: Tool adapters intentionally exclude the internal `config-sync/` module when synchronizing commands to external CLIs so that orchestration logic stays Claude-local.

## Minimal Command Guidelines
- Each command file must include YAML frontmatter with at least `name`, `description`, and (optionally) `argument-hint`.
- Use slash names (`config-sync:sync`, etc.) to avoid collisions and clarify intent.
- Reference other commands via their slash name (`/config-sync:adapt-permissions`) rather than direct file paths.
- Additional personal commands (like `draft-commit-message.md`) can continue to live at the top level.

For a detailed rundown of every `/config-sync:*` command see [`docs/config-sync-commands.md`](./config-sync-commands.md).
