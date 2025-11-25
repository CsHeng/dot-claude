# Entry Point: /check-secrets

## Layer
- Layer 1 – UI Entry

## Slash Command
- Name: `/check-secrets`
- Source spec: `commands/check-secrets.md`

## Intent
Scan the current project for potential secrets (API keys, credentials, private keys, connection
strings, and similar sensitive values) before commits or reviews.

## Routing
- Primary router: `router:workflow-helper` (Layer 2)
- Default execution agent: `agent:check-secrets` (Layer 3).

## Output Style
- Default: `output-styles/default.md`
- Recommended overrides: `output-styles/professional.md` for CI-facing security reports.

## Notes
- This entrypoint defines high-level semantics only; concrete scanning patterns and tool usage are
  implemented by governance rule-blocks and execution agents.
