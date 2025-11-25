# Entry Point: /review-refactor

## Layer
- Layer 1 – UI Entry

## Slash Command
- Name: `/review-refactor`

## Intent
Analyze an existing or proposed refactor (diff, branch, or plan) and produce a structured review:
risks, architectural impact, testing implications, and a stepwise execution/rollback plan.

## Routing
- Primary router: `router:code-refactor` (Layer 2).
- Default execution agent: `agent:refactor-planner` (Layer 3).

## Output Style
- Default: `governance/styles/default.md` (fall back to `output-styles/default.md` if needed).
- Caller may override via `/output-style <name>`.

## Notes
- This entrypoint pairs with `agents/refactor-planner/AGENT.md` and is meant for **planning and
  review only**, not direct code changes.

