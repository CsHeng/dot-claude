# Entry Point: /review-shell-syntax

## Layer
- Layer 1 – UI Entry

## Slash Command
- Name: `/review-shell-syntax`
- Source spec: `commands/review-shell-syntax.md`

## Intent
Perform a structured audit of a shell script for syntax errors and guideline violations, and propose
minimal, rule-driven fixes (typically via diff-style patches).

## Routing
- Primary router: `router:workflow-helper` (Layer 2)
- Default execution agent: `agent:review-shell-syntax` (Layer 3).

## Output Style
- Default: `output-styles/default.md`
- Recommended overrides: `output-styles/professional.md` for CI-facing reports.

## Notes
- This entrypoint defines semantics for the slash command; implementation details live in router and
  execution-layer agents/skills.
