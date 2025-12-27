# Agent Discovery

Agents are discovered via their `AGENT.md` frontmatter, not through manual registration.

## Discovery Mechanism

Claude Code automatically discovers agents from:
- `~/.claude/agents/*/AGENT.md` (user-level)
- `<project>/.claude/agents/*/AGENT.md` (project-level)

## Available Agents

| Agent | Purpose | Location |
|-------|---------|----------|
| `lint-markdown` | Markdown validation with taxonomy rules | `agents/lint-markdown/` |
| `llm-governance` | LLM-facing file governance | `agents/llm-governance/` |
| `draft-commit-message` | Generate commit messages | `agents/draft-commit-message/` |
| `review-shell-syntax` | Shell script syntax review | `agents/review-shell-syntax/` |
| `check-secrets` | Scan for secrets in code | `agents/check-secrets/` |
| `code-architecture-reviewer` | Review code architecture | `agents/code-architecture-reviewer/` |
| `code-refactor-master` | Execute code refactoring | `agents/code-refactor-master/` |
| `plan-reviewer` | Review implementation plans | `agents/plan-reviewer/` |
| `ts-code-error-resolver` | Resolve TypeScript errors | `agents/ts-code-error-resolver/` |
| `web-research-specialist` | Web research tasks | `agents/web-research-specialist/` |
| `refactor-planner` | Plan refactoring strategies | `agents/refactor-planner/` |

## Agent Frontmatter

Each agent defines its own metadata in `AGENT.md`:
```yaml
---
name: agent:lint-markdown
description: Execute markdown linting with taxonomy-based classification
metadata:
  capability-level: 2
  layer: execution
  loop-style: DEPTH
---
```

## Routing

Commands route to agents via their frontmatter or direct invocation. No routing tables are maintained manually.
