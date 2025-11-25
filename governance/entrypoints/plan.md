# Entry Point: /review-plan and /plan-*

## Layer
- Layer 1 – UI Entry

## Slash Commands
- Names:
  - `/review-plan`
  - `/plan-*`

## Intent
Analyze development or refactor plans for feasibility, risk, coverage, and alternatives, producing
structured reviews and implementation roadmaps.

## Routing
- Primary router: `router:plan-review` (Layer 2)
- Default execution agent: `agent:plan-reviewer` (Layer 3).

## Output Style
- Default: `governance/styles/explanatory.md`
- Recommended: `governance/styles/professional.md` for plans intended for wider stakeholder review.

## Notes
- This entrypoint covers a family of planning-related commands; governance chooses specific
  behaviors based on command name and context.
