---
name: agent:main
description: Primary execution agent that orchestrates filesystem, git, and subagent skills based on governance routing.
allowed-tools:
  - Read
  - Write
  - Edit
  - Bash
  - Grep
  - Glob
  - Task
  - TodoWrite
  - AskUserQuestion
  - ExitPlanMode
  - EnterPlanMode
  - Skill
  - SlashCommand
  - WebSearch
  - WebFetch
  - KillShell
  - BashOutput
metadata:
  capability-level: 2
  default-skills:
    - filesystem
    - git
    - subagents
  layer: execution
  loop-style: DEPTH
  style: reasoning-first
---

# Main Agent

## Notes

- Invoke via governance routers; do not call directly from UI.
- Governance handles routing/policy; this agent focuses on execution.
