# Entry Point: /draft-commit-message

## Layer
- Layer 1 – UI Entry

## Slash Command
- Name: `/draft-commit-message`
- Source spec: `commands/draft-commit-message.md`

## Intent
Generate one or more high-quality commit message proposals **without** running `git commit`, based on
current repository status and an optional scoped path filter.

## Routing
- Primary router: `router:workflow-helper` (Layer 2)
- Default execution agent: `agent:draft-commit-message` (Layer 3).

## Output Style
- Default: `output-styles/default.md`
- Caller may override via `/output-style <name>`.

## Notes
- This entrypoint only describes how the slash command is interpreted and which router handles it.
- Tool usage (`git`, filesystem) is the responsibility of execution-layer commands/agents, not this file.
