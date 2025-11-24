# Project-Level Memory Configuration

## Agent Selection Conditions

Execute routing lazily: agents remain unloaded until their command pattern matches the active request, preventing unnecessary policy loading for unrelated tasks.
Execute routing by command patterns:
1. Config-sync routing: `/config-sync/*` → `agent:config-sync`
2. AgentOps routing: `/agent-ops:health-report` → `agent:agent-ops`

## Active Agents

Execute agent mappings on demand; each row describes what loads once the matching command fires. `skill:environment-validation` is provisioned first so tool-choice hints are available before the agent-specific stack initializes.

| Agent ID | Command Patterns | Default Skills | Optional Skills |
| --- | --- | --- | --- |
| `agent:config-sync` | `/config-sync/*` | `skill:environment-validation`, `skill:workflow-discipline`, `skill:security-logging`, `skill:automation-language-selection`, `skill:config-sync-cli-workflow`, `skill:config-sync-project-rules-sync`, `skill:config-sync-target-adaptation` | `skill:search-and-refactor-strategy`, `skill:project-config-sync-overview`, language skills based on target project |
| `agent:agent-ops` | `/agent-ops:health-report` | `skill:workflow-discipline`, `skill:environment-validation` | `skill:project-config-sync-overview`, `skill:project-doc-gen-overview` |

## Agent-Skill Mappings

### `agent:config-sync`
Execute skill loading:
- Load: `skill:environment-validation`, `skill:workflow-discipline`, `skill:security-logging`, `skill:automation-language-selection`, `skill:config-sync-cli-workflow`, `skill:config-sync-project-rules-sync`, `skill:config-sync-target-adaptation`
- Optional load: `skill:search-and-refactor-strategy`, `skill:project-config-sync-overview`
- Dependency: `skill:environment-validation` must be loaded before `skill:search-and-refactor-strategy`
- Conditional load: `skill:language-*` based on target project
- Escalation: Fallback to `agent:llm-governance` for permission violations

### `agent:agent-ops`
Execute skill loading:
- Load: `skill:workflow-discipline`, `skill:environment-validation`
- Conditional load: `skill:project-config-sync-overview`, `skill:project-doc-gen-overview`
- Escalation: Fallback to `agent:config-sync` for integration issues