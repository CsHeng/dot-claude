# Command Layout Overview (`~/.claude/commands/`)

The commands directory contains slash commands for various workflows including config-sync, documentation generation, code review, and utility operations.

## Directory Structure
```
~/.claude/commands/
├── config-sync/                    # Config-sync command suite
│   ├── sync-cli.md                # Main orchestrator for CLI tool sync
│   ├── sync-project-rules.md      # Project rules sync for IDEs
│   ├── adapters/                  # Tool-specific adapters
│   │   ├── analyze-target-tool.md # Target tool analysis
│   │   ├── adapt-permissions.md   # Permission mapping
│   │   ├── adapt-commands.md      # Command format conversion
│   │   ├── adapt-rules-content.md # Rules normalization
│   │   ├── droid.md              # Droid CLI adapter
│   │   ├── qwen.md               # Qwen CLI adapter
│   │   ├── codex.md              # (config-sync adapter for Codex targets)
│   │   └── opencode.md           # OpenCode adapter
│   ├── lib/                       # Shared guidance
│   └── scripts/                   # Bash helpers
├── doc-gen/                        # Documentation generation commands
│   ├── core/
│   │   └── bootstrap.md           # Main documentation orchestrator
│   └── adapters/                  # Project-specific adapters
│       ├── backend-go.md
│       ├── android-sdk.md
│       ├── android-app.md
│       ├── web-user.md
│       └── web-admin.md
├── draft-commit-message.md         # Git commit message drafting
├── review-shell-syntax.md          # Shell script validation
└── review-llm-prompts.md           # LLM prompt compliance review
```

## Available Commands

### Config-Sync Commands

| Command | Purpose | Key Features |
|---------|---------|--------------|
| `claude /config-sync:sync-cli` | Main orchestrator for CLI tool synchronization | 8-phase pipeline, multi-target support, verification |
| `claude /config-sync:sync-project-rules` | Sync Claude rules to IDE projects | Cursor/VS Code Copilot integration, auto-detection |
| `/config-sync:analyze-target-tool` | Analyze specific tool capabilities | Installation checks, configuration audit |
| `/config-sync:adapt-permissions` | Map Claude permissions to tool formats | Security-first approach, format conversion |
| `/config-sync:adapt-commands` | Convert command formats between tools | Markdown ↔ TOML ↔ JSON conversion |
| `/config-sync:adapt-rules-content` | Normalize rules for different platforms | Cross-platform compatibility |
| `/config-sync:droid` | Droid CLI specific operations | Tool-specific sync/analyze/verify |
| `/config-sync:qwen` | Qwen CLI specific operations | Tool-specific sync/analyze/verify |
| `/config-sync:codex` | Codex CLI-specific operations (handled via config-sync) | Tool-specific sync/analyze/verify |
| `/config-sync:opencode` | OpenCode specific operations | Tool-specific sync/analyze/verify |

### Documentation Generation Commands

| Command | Purpose | Project Types |
|---------|---------|---------------|
| `/doc-gen:core:bootstrap` | Documentation workflow orchestrator | Android (app/sdk), Web (admin/user), Backend (Go/PHP) |
| `/doc-gen:adapters:backend-go` | Go backend documentation | Go projects |
| `/doc-gen:adapters:android-sdk` | Android SDK documentation | Android SDK projects |
| `/doc-gen:adapters:android-app` | Android app documentation | Android applications |
| `/doc-gen:adapters:web-user` | Web frontend documentation | User-facing web apps |
| `/doc-gen:adapters:web-admin` | Web admin documentation | Admin web interfaces |

### Review and Utility Commands

| Command | Purpose | Scope |
|---------|---------|-------|
| `/draft-commit-message` | Generate commit messages from git status | Current repository |
| `/review-shell-syntax` | Validate shell script compliance | `rules/12-shell-guidelines.md` |
| `/review-llm-prompts` | Review LLM prompt compliance | `rules/99-llm-prompt-writing-rules.md` |

## Command Guidelines

### Frontmatter Requirements
Each command file must include YAML frontmatter with:
- `name`: Command name (used for slash command registration)
- `description`: Brief purpose description
- `argument-hint`: Usage syntax (optional)
- `allowed-tools`: Permitted tool permissions (optional)

### Naming Conventions
- Use slash-style names for top-level handlers
- Adapter references use registered aliases (e.g., `/config-sync:adapt-permissions`)
- Reference other commands via published slash form, not file paths

### Development Best Practices
- Tool adapters exclude internal `config-sync/` module when syncing to external CLIs
- Use `commands/config-sync/lib/common.md` for shared guidance
- Include parameter tables and usage examples
- Follow `rules/99-llm-prompt-writing-rules.md` for LLM-facing content

## Related Documentation

- **[Config-Sync Guide](./config-sync-guide.md)** - Complete sync system documentation
- **[Settings Reference](./settings.md)** - Configuration hierarchy and permissions
- **[Directory Structure](./directory-structure.md)** - Detailed file organization
