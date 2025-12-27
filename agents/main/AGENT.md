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
---

# Main Agent

## Notes

- Invoke via governance routers; do not call directly from UI.
- Governance handles routing/policy; this agent focuses on execution.
