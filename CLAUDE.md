---
version: 2.0.0
description: Agent and skill selection configuration
confidence: high
impact: high
status: active
---

# Memory Configuration

## Rule-Loading Conditions

### Default Conditions
- **ABSOLUTE MODE**: Always enabled unless explicitly overridden
- **Language-specific rules**: Trigger based on file extensions or declared language context
- **Security rules**: Apply to all operations involving credentials, permissions, or network access
- **Testing rules**: Apply when operations involve test files or test execution

### Agent Selection Conditions
1. Config-sync routing: `/config-sync/*` → `agent:config-sync`
2. Workflow routing: `/draft-commit-message`, `/review-shell-syntax` → `agent:workflow-helper`
3. Documentation routing: `/doc-gen:*` → `agent:doc-gen`
4. LLM governance routing: `/optimize-prompts` → `agent:llm-governance`
5. Code architecture routing: `/review-code-architecture` → `agent:code-architecture-reviewer`
6. Refactoring routing: `/refactor-*`, `/review-refactor` → `agent:code-refactor-master`
7. Planning routing: `/review-plan`, `/plan-*` → `agent:plan-reviewer`
8. Error resolution routing: `/fix-*`, `/resolve-errors` → `agent:ts-code-error-resolver`
9. Research routing: `/research-*`, `/web-search` → `agent:web-research-specialist`
10. Content-based routing: Files with specific extensions → trigger corresponding language skills
11. Metadata routing: LLM-prompt editing → `agent:llm-governance`

## Active Agents

| Agent ID | Command Patterns | Default Skills | Optional Skills |
| --- | --- | --- | --- |
| `agent:config-sync` | `/config-sync/*` | `skill:toolchain-baseline`, `skill:workflow-discipline`, `skill:security-logging`, `skill:tooling-code-tool-selection` | Language skills based on target project |
| `agent:llm-governance` | `/optimize-prompts` | `skill:llm-governance`, `skill:workflow-discipline` | Content-type specific skills |
| `agent:doc-gen` | `/doc-gen:*` | `skill:workflow-discipline`, `skill:security-logging` | Architecture/language skills per project type |
| `agent:workflow-helper` | `/draft-commit-message`, `/review-shell-syntax` | `skill:workflow-discipline`, `skill:tooling-code-tool-selection` | `skill:language-shell`, `skill:language-python`, `skill:toolchain-baseline` |
| `agent:code-architecture-reviewer` | `/review-code-architecture` | `skill:architecture-patterns`, `skill:development-standards`, `skill:security-standards` | Language-specific skills based on codebase |
| `agent:code-refactor-master` | `/refactor-*`, `/review-refactor` | `skill:architecture-patterns`, `skill:development-standards`, `skill:testing-strategy` | `skill:language-*` based on target code |
| `agent:plan-reviewer` | `/review-plan`, `/plan-*` | `skill:workflow-discipline`, `skill:architecture-patterns`, `skill:testing-strategy` | Domain-specific skills based on plan content |
| `agent:ts-code-error-resolver` | `/fix-*`, `/resolve-errors` | `skill:error-patterns`, `skill:development-standards`, `skill:testing-strategy` | `skill:language-*` based on error context |
| `agent:web-research-specialist` | `/research-*`, `/web-search` | `skill:tooling-search-refactors`, `skill:workflow-discipline` | Content-specific research skills |
| `agent:refactor-planner` | Refactoring tasks, complex restructuring | `skill:architecture-patterns`, `skill:development-standards`, `skill:workflow-discipline` | `skill:language-*`, `skill:testing-strategy` |

## Skill Dependencies

### Core Required Skills
- `skill:workflow-discipline`: Required for all agents
- `skill:security-logging`: Required for agents handling sensitive operations

### Conditional Required Skills
- `skill:toolchain-baseline`: Required for development toolchain operations
- `skill:llm-governance`: Required for LLM-prompt modifications
- `skill:language-*`: Required when operating on specific language files

### Optional Skills
- `skill:tooling-code-tool-selection`: Optional for tool selection guidance
- `skill:testing-strategy`: Optional for test-related operations
- `skill:architecture-patterns`: Optional for architectural guidance

## Agent-Skill Mappings

### `agent:config-sync`
- Load: `skill:toolchain-baseline`, `skill:workflow-discipline`, `skill:security-logging`, `skill:tooling-code-tool-selection`
- Conditional load: `skill:language-*` based on target project
- Escalation: Fallback to `agent:llm-governance` for permission violations

### `agent:llm-governance`
- Load: `skill:llm-governance`, `skill:workflow-discipline`
- Conditional load: Content-specific skills for specialized review
- Escalation: Notify maintainers on critical violations

### `agent:doc-gen`
- Load: `skill:workflow-discipline`, `skill:security-logging`
- Conditional load: `skill:language-*`, `skill:architecture-patterns` per project type
- Escalation: Fallback to `agent:config-sync` for integration issues

### `agent:workflow-helper`
- Load: `skill:workflow-discipline`, `skill:tooling-code-tool-selection`
- Conditional load: Language skills based on task context
- Escalation: Fallback to appropriate specialist agent

### `agent:code-architecture-reviewer`
- Load: `skill:architecture-patterns`, `skill:development-standards`, `skill:security-standards`
- Conditional load: `skill:language-*` based on codebase analysis
- Escalation: Fallback to `agent:code-refactor-master` for architectural issues

### `agent:code-refactor-master`
- Load: `skill:architecture-patterns`, `skill:development-standards`, `skill:testing-strategy`
- Conditional load: `skill:language-*` based on target code
- Escalation: Fallback to `agent:refactor-planner` for complex restructuring

### `agent:plan-reviewer`
- Load: `skill:workflow-discipline`, `skill:architecture-patterns`, `skill:testing-strategy`
- Conditional load: Domain-specific skills based on plan content
- Escalation: Fallback to `agent:refactor-planner` for implementation planning

### `agent:ts-code-error-resolver`
- Load: `skill:error-patterns`, `skill:development-standards`, `skill:testing-strategy`
- Conditional load: `skill:language-*` based on error context
- Escalation: Fallback to language-specific agents for complex issues

### `agent:web-research-specialist`
- Load: `skill:tooling-search-refactors`, `skill:workflow-discipline`
- Conditional load: Content-specific research skills
- Escalation: Fallback to `agent:llm-governance` for source validation

### `agent:refactor-planner`
- Load: `skill:architecture-patterns`, `skill:development-standards`, `skill:workflow-discipline`
- Conditional load: `skill:language-*`, `skill:testing-strategy` based on project scope
- Escalation: Fallback to `agent:code-refactor-master` for implementation

## Fallback Rules

### Agent Selection Failure
1. No command match → Error with maintainer notification
2. Multiple agent matches → Use most specific match
3. Agent loading failure → Attempt fallback agent
4. All agents failed → Escalate to maintainers

### Skill Loading Failure
1. Default skill missing → Agent fails fast
2. Optional skill missing → Continue with warning
3. Skill validation failure → Agent fails fast
4. Dependency cycle → Abort with diagnostic

### Critical Escalation Triggers
- Security rule violations
- Permission bypass attempts
- Unrecoverable skill loading errors
- Taxonomy conflicts
- Agent execution timeouts