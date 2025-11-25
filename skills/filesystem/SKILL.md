---
name: filesystem
description: "Execution-layer skill for filesystem operations"
layer: execution
kind: skill
commands:
  - fs.readFile
  - fs.writeFile
  - fs.applyPatch
  - fs.glob
notes:
  - "This skill should not embed governance rules; it only exposes filesystem capabilities."
constraints:
  - "Never access paths outside the active project workspace unless explicitly granted."
  - "Do not embed governance or routing logic in this skill; it only exposes filesystem capabilities."
---
