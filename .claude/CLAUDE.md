# CLI Coding Agent Config Sync System Memory Configuration

This file configures the CLI coding agent config sync system, which synchronizes Claude configuration across multiple AI tools and platforms (Droid, Qwen, Codex, OpenCode, Amp).

## Agent Selection Conditions

Execute routing lazily: agents remain unloaded until their command pattern matches the active request, preventing unnecessary policy loading for unrelated tasks.
Execute routing by command patterns:
1. Config-sync routing: `/config-sync/*` → `config-sync` (CLI coding agent config sync system)
2. AgentOps routing: `/agent-ops:health-report` → `agent-ops`

## Active Agents

Execute agent mappings on demand; each row describes what loads once the matching command fires. `skill:environment-validation` is provisioned first so tool-choice hints are available before the agent-specific stack initializes.

| Agent ID | Command Patterns | Default Skills | Optional Skills |
| --- | --- | --- | --- |
| `config-sync` | `/config-sync/*` | `skill:environment-validation`, `skill:unified-search-discover`, `skill:workflow-discipline`, `skill:security-logging`, `skill:automation-language-selection`, `skill:config-sync-cli-workflow`, `skill:config-sync-target-adaptation` | `skill:config-sync-overview`, language skills based on target project |
| `agent-ops` | `/agent-ops:health-report` | `skill:unified-search-discover`, `skill:workflow-discipline`, `skill:environment-validation` | `skill:config-sync-overview`, `skill:project-doc-gen-overview` |

## Agent-Skill Mappings

### `agent:config-sync`
Execute skill loading:
- Load: `skill:environment-validation`, `skill:unified-search-discover`, `skill:workflow-discipline`, `skill:security-logging`, `skill:automation-language-selection`, `skill:config-sync-cli-workflow`, `skill:config-sync-target-adaptation`
- Optional load: `skill:config-sync-overview`
- Conditional load: `skill:language-*` based on target project
- Escalation: Fallback to `agent:llm-governance` for permission violations

### `agent:agent-ops`
Execute skill loading:
- Load: `skill:unified-search-discover`, `skill:workflow-discipline`, `skill:environment-validation`
- Conditional load: `skill:config-sync-overview`, `skill:project-doc-gen-overview`
- Escalation: Fallback to `agent:config-sync` for integration issues
