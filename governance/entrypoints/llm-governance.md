# Entry Point: /llm-governance

## Layer
- Layer 1 – UI Entry

## Slash Command
- Name: `/llm-governance`
- Source spec: `commands/llm-governance.md`

## Intent
Run LLM-governance design-time audits and optional deterministic fixes for LLM-facing files, using
rule-driven schemas and dedicated analysis tools.

## Routing
- Primary router: `router:llm-governance` (Layer 2)
- Default execution agent: `agent:llm-governance` (Layer 3).

## Output Style
- Default: `output-styles/minimal-chat` (as described in command spec)
- Governance may override style based on target environment (CLI, IDE, CI).

## Notes
- This entrypoint ties the slash command to the governance router; all tool invocations and
  low-level validations happen in the execution layer.
