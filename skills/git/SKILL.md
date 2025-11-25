---
name: git
description: "Execution-layer skill for git inspection and safe patching"
layer: execution
kind: skill
commands:
  - git.status
  - git.diff
  - git.applyPatch
notes:
  - "This skill must never perform commits, pushes, or history rewrites."
constraints:
  - "Never run git commit, push, or destructive history operations."
  - "Primary focus is read-only inspection plus safe patch application."
---
