# Router: code-refactor

## Layer
- Layer 2 – Orchestration & Governance

## Purpose
Route refactoring-related workflows (batch refactors and refactor plan review) to appropriate
execution agents while enforcing architecture, quality, and workflow-discipline standards.

## Inputs
- Slash commands / entrypoints:
  - `/refactor-*` → `governance/entrypoints/refactor.md`
  - `/review-refactor` → `governance/entrypoints/review-refactor.md`
- Context:
  - Current project type and language mix
  - Detected technology stack (languages, frameworks)
  - Active output-style (from `/output-style` or settings)

## Policy
- Always load governance rule-blocks for:
  - `rule-block:workflow-discipline`
  - `rule-block:development-standards`
  - `rule-block:architecture-patterns`
  - `rule-block:testing-strategy`
  - `rule-block:unified-search-discover`
- Prefer **incremental, reversible refactors** over large bang-bang changes.
- Require explicit confirmation before destructive file operations.

## Execution Handoff (Layer 3)
- For `/refactor-*` flows:
  - Primary execution agent: `agent:code-refactor-master`.
  - Expected skills: `filesystem`, `git`, `subagents`.
  - Additional rule-blocks:
    - `rule-block:quality-standards`
    - `rule-block:workflow-patterns`.
- For `/review-refactor`:
  - Primary execution agent: `agent:refactor-planner`.
  - Expected skills: `filesystem`, `git` (for context), documentation-writing.
  - Additional rule-blocks:
    - `rule-block:quality-standards`
    - `rule-block:testing-strategy`.

## Notes
- This router is the governance-layer counterpart to the existing
  `agents/code-refactor-master/AGENT.md` and `agents/refactor-planner/AGENT.md` manifests.
- Over time, high-level refactoring policies should be moved entirely into `governance/rules/**`,
  with execution agents focusing purely on tool usage and concrete transformations.

