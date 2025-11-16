# Command Layout Overview (`~/.claude/commands/`)

The commands directory contains slash commands for various workflows including config-sync, documentation generation, code review, and utility operations.

## Directory Structure
```
~/.claude/commands/
├── config-sync/                    # Config-sync command suite
│   ├── sync-cli.md                # Main orchestrator for CLI tool sync
│   ├── sync-project-rules.md      # Project rules sync for IDEs
│   ├── adapters/                  # Target-specific shell adapters (*.sh)
│   ├── lib/                       # Shared guidance and phase runners
│   └── scripts/                   # Bash helpers (backup cleanup, diagnostics)
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
├── llm-governance/optimize-prompts.md  # LLM-facing manifest optimization
└── agent-ops/                      # AgentOps utilities
    ├── health-report.md            # Agent and skill health reporting
    ├── agent-matrix.md             # Agent capability matrix view
    └── skill-matrix.md             # Skill capability matrix view
```

## Available Commands

### Config-Sync Commands

| Command | Purpose | Key Features |
|---------|---------|--------------|
| `claude /config-sync:sync-cli` | Main orchestrator for CLI tool synchronization | 9-phase pipeline, multi-target support, verification and cleanup |
| `claude /config-sync:sync-project-rules` | Sync Claude rules to IDE projects | Cursor/VS Code Copilot integration, auto-detection |

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
| `/llm-governance/optimize-prompts` | Governance-driven LLM-facing file optimization | All LLM-facing files |
| `/agent-ops:health-report` | Read-only health report for agents, skills, backups, and governance runs | `.claude/backup`, matrices, and manifests |
| `/agent-ops:agent-matrix` | Show capability and style matrix for all agents | Current `.claude` directory or provided root |
| `/agent-ops:skill-matrix` | Show capability and style matrix for all skills | Current `.claude` directory or provided root |

## Command Guidelines

### Frontmatter Requirements
Each command file must include YAML frontmatter with:
- `name`: Command name (used for slash command registration)
- `description`: Brief purpose description
- `argument-hint`: Usage syntax (optional)
- `allowed-tools`: Permitted tool permissions (optional)

### Naming Conventions
- Use slash-style names for top-level handlers
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
