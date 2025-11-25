# Router: web-research

## Layer
- Layer 2 – Orchestration & Governance

## Purpose
Route web research requests (such as `/research-*` and `/web-search`) to the appropriate execution
agents, applying workflow discipline and security guardrails.

## Inputs
- Slash commands / entrypoints:
  - `/research-*`, `/web-search` → `governance/entrypoints/research.md`
- Context:
  - Research topic and constraints
  - Sensitivity of information (e.g., security-related topics)

## Policy
- Load governance rule-blocks for:
  - `rule-block:workflow-discipline`
  - `rule-block:security-standards`
  - `rule-block:llm-governance`
- Apply security and governance guidance from:
  - `rules/03-security-standards.md`
  - `rules/99-llm-prompt-writing-rules.md`

## Execution Handoff (Layer 3)
- Default execution agent: `agent:web-research-specialist` (execution layer).

## Notes
- This router ensures research workflows respect security guardrails and structured research
  patterns; execution agents perform the actual web queries and summarization.
