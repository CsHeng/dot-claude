---
name: "agent:main"
description: "Primary execution agent that orchestrates filesystem, git, and subagent skills based on governance routing."
layer: execution
capability-level: 2
loop-style: DEPTH
style: reasoning-first
required-skills:
  - filesystem
  - git
  - subagents
notes:
  - "This agent should be invoked via governance routers, not directly from UI." 
  - "Routing and policy decisions belong to governance; this agent focuses on execution."
---
