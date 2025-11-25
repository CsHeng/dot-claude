# Entry Point: /fix-* and /resolve-errors

## Layer
- Layer 1 – UI Entry

## Slash Commands
- Names:
  - `/fix-*`
  - `/resolve-errors`

## Intent
Assist with automated or semi-automated error resolution workflows (for example, TypeScript
compilation errors), while preserving safety and code standards.

## Routing
- Primary router: `router:ts-error-resolution` (Layer 2)
- Default execution agent: `agent:ts-code-error-resolver` (Layer 3).

## Output Style
- Default: `governance/styles/default.md`

## Notes
- This entrypoint defines semantics for error-resolution workflows; concrete tool use and fix
  strategies are defined in governance rule-blocks and execution agents.
