# AI Agent Instructions

For project overview and setup instructions, see [README.md](./README.md).

## Project Context

This is the user-level Claude Code configuration harness (`~/.claude/`). It manages agents, rules, output styles, and project-level tooling. Skills are provided via the plugin system rather than local `skills/` directories.

## Repository Layout

User-level (`~/.claude/`) — synchronized across environments:

```text
~/.claude/
├── CLAUDE.md                 # Symlink to AGENTS.md
├── AGENTS.md                 # This file
├── agents/                   # User-level agent definitions (AGENT.md per subdirectory)
├── rules/                    # Development standards (auto-loaded by CLAUDE.md)
├── output-styles/            # Named output style manifests
├── plugins/                  # Plugin cache, marketplace data, installed plugin registry
├── docs/                     # Architecture and philosophy documentation
└── settings.json             # Global Claude Code configuration
```

Project-level (`.claude/`) — tooling only, not synchronized:

```text
.claude/
├── agents/                   # Project-scoped tool agents (llm-governance, lint-markdown)
├── commands/                 # Project-level slash commands
└── skills/                   # Project-scoped tool implementations
```

## Memory Configuration

### On-Demand (via Skills)
- Language selection: invoke `language-decision-tree` skill when creating new code
- Tool selection: invoke `tool-decision-tree` skill when performing searches/refactors
- Language-specific guidance: invoke `go-guidelines`, `python-guidelines`, `shell-guidelines`, `powershell-guidelines`, `lua-guidelines` as needed

## Rule-Loading Conditions

### Default Conditions
Match response language to user input language (Chinese input -> Chinese response, English input -> English response), while file content follows existing file conventions and comment styles per rules.
Execute language-specific skills based on file extensions or declared language context.

## Compact Instructions

When compressing, preserve in priority order:

1. Architecture decisions (NEVER summarize)
2. Modified files and their key changes
3. Current verification status (pass/fail)
4. Open TODOs and rollback notes
5. Tool outputs (can delete, keep pass/fail only)

@RTK.md

## Workflow Preferences

### Adding New Agents
User-level agents (global availability — `~/.claude/agents/`):
1. Create subdirectory under `agents/`
2. Define `AGENT.md` with frontmatter (`name`, `description`, `metadata`)
3. Specify required and optional skills in the agent documentation
4. Agent is auto-discovered via frontmatter — no registration needed

Project-level agents (project-specific — `.claude/agents/`):
1. Create subdirectory under `.claude/agents/`
2. Define `AGENT.md` with frontmatter
3. Scope to project tooling only; do not include in user-level sync payload

### Creating New Skills
- Prefer plugin-provided skills over local `~/.claude/skills/` so they are reusable and hot-swappable
- Install via plugin system (`plugins/`); manage with `bin/agents skills link` from the agents CLI
- For project-level tools: create under `.claude/skills/` with `SKILL.md` specification

### Rule Files
- User-level rules live in `rules/` and are auto-loaded
- Use `default.rules` for cross-cutting constraints
- Named rule files (`NN-topic.md`) load conditionally per `CLAUDE.md` instructions

### Output Styles
- Output style manifests live in `output-styles/`
- Reference by name in prompts or settings
- Do not add conversational or emotional content to manifests
