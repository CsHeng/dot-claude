# Entry Point: /refactor-*

## Layer
- Layer 1 – UI Entry

## Slash Commands
- Name pattern: `/refactor-*`
- Examples:
  - `/refactor-module`
  - `/refactor-feature`
  - `/refactor-cleanup`

## Intent
Execute concrete, scoped refactors on the current project (file moves, module extraction, pattern
replacement) while preserving behavior and keeping changes reviewable and reversible.

## Routing
- Primary router: `router:code-refactor` (Layer 2).
- Default execution agent: `agent:code-refactor-master` (Layer 3).

## Output Style
- Default: `governance/styles/default.md` (fall back to `output-styles/default.md` if needed).
- Caller may override via `/output-style <name>`.

## Notes
- This entrypoint describes the general protocol for `/refactor-*` commands; specific IDE/CLI
  integrations may provide subcommands or flags that map into the same router payload.

