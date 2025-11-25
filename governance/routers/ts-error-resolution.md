# Router: ts-error-resolution

## Layer
- Layer 2 – Orchestration & Governance

## Purpose
Route error resolution requests (such as `/fix-*` and `/resolve-errors`) to the appropriate
execution agents, applying error-handling and workflow standards.

## Inputs
- Slash commands / entrypoints:
  - `/fix-*`, `/resolve-errors` → `governance/entrypoints/fix-errors.md`
- Context:
  - Error type (TypeScript, build, etc.)
  - Available error logs and caches

## Policy
- Load governance rule-blocks for:
  - `rule-block:workflow-discipline`
  - `rule-block:error-patterns`
  - `rule-block:development-standards`
- Apply error-handling guidance from:
  - `rules/05-error-patterns.md`
  - `rules/01-development-standards.md`

## Execution Handoff (Layer 3)
- Default execution agent: `agent:ts-code-error-resolver` (execution layer).

## Notes
- This router currently targets TypeScript error resolution via `agent:ts-code-error-resolver` but
  can be extended to other error domains in the future.
