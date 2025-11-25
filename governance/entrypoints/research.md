# Entry Point: /research-* and /web-search

## Layer
- Layer 1 – UI Entry

## Slash Commands
- Names:
  - `/research-*`
  - `/web-search`

## Intent
Perform structured web research to support debugging, design decisions, or learning tasks, producing
summarized findings and references.

## Routing
- Primary router: `router:web-research` (Layer 2)
- Default execution agent: `agent:web-research-specialist` (Layer 3).

## Output Style
- Default: `governance/styles/explanatory.md`

## Notes
- This entrypoint focuses on research workflows; governance ensures safe browsing and sourcing
  standards are applied.
