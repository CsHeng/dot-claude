---
description: "Print a capability matrix for all skills including capability level, mode, and style labels"
name: agent-ops-skill-matrix
argument-hint: "[root-dir]"
allowed-tools:
  - Read
  - Bash(skills/llm-governance/scripts/skill-matrix.sh *)
metadata:
  is_background: false
  style: minimal-chat
---

## Usage

```bash
/agent-ops:skill-matrix [root-dir]
```

When no root directory is provided, default to the current working directory.

## Arguments

- `root-dir`: Optional path to the `.claude` directory to inspect (default: current directory).

## Workflow

1. Resolve the root directory argument or default to the current directory.
2. Invoke `skills/llm-governance/scripts/skill-matrix.sh <root-dir>` to collect skill manifests.
3. Print a tabular summary of each skill including:
   - Skill identifier
   - Capability level
   - Mode label
   - Style label
   - Tags

## Output

- A tabular matrix written to standard output listing all skills and their capability and style metadata.
- Suitable for quick human inspection or capture into logs and health reports.

