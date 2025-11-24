---
name: "agent-ops:agent-matrix"
description: "Print a capability matrix for all agents including capability level, loop style, and style labels"
argument-hint: "[root-dir]"
allowed-tools:
  - Read
  - Bash(commands/agent-ops/scripts/agent-matrix.sh *)
is_background: false
style: minimal-chat
---

## Usage

```bash
/agent-ops:agent-matrix [root-dir]
```

When no root directory is provided, default to the current working directory.

## Arguments

- `root-dir`: Optional path to the `.claude` directory to inspect (default: current directory).

## Workflow

1. Resolve the root directory argument or default to the current directory.
2. Invoke `commands/agent-ops/scripts/agent-matrix.sh <root-dir>` to collect agent manifests.
3. Print a tabular summary of each agent including:
   - Agent identifier
   - Capability level
   - Loop style
   - Style label
   - Default skills
   - Optional skills

## Output

- A tabular matrix written to standard output listing all agents and their capability and style metadata.
- Suitable for quick human inspection or capture into logs and health reports.

