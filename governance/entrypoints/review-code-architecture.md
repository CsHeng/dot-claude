# Entry Point: /review-code-architecture

## Layer
- Layer 1 – UI Entry

## Slash Command
- Name: `/review-code-architecture`
- Source spec: Documentation under `docs/commands.md` and the architecture review agent manifest.

## Intent
Review code for architectural consistency, layering, and integration with existing systems, producing
structured feedback and recommendations without modifying code directly.

## Routing
- Primary router: `router:code-architecture` (Layer 2)
- Default execution agent: `agent:code-architecture-reviewer` (Layer 3).

## Output Style
- Default: `governance/styles/explanatory.md`

## Notes
- This entrypoint defines UI semantics only; routing and rule selection are handled by governance,
  and implementation details live in execution-layer agents and skills.
