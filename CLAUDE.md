---
name: "CLAUDE.md"
description: "Memory configuration and routing rules"
required-skills:
  - skill:workflow-discipline
  - skill:environment-validation
related-skills:
  - skill:architecture-patterns
---

# Memory Configuration

## Rule-Loading Conditions

### Default Conditions
Execute ABSOLUTE MODE always unless explicitly overridden
Execute language-specific rules based on file extensions or declared language context
Execute security rules for all operations involving credentials, permissions, or network access
Execute testing rules when operations involve test files or test execution
Execute directory classification from `commands/optimize-prompts/classification-rules.yaml` before routing `/optimize-prompts`
Execute governance exceptions from `rules/99-llm-prompt-writing-rules.md` immediately after classification rules load

### Baseline Skill Initialization
Execute `skill:environment-validation` before dispatching any agent to enforce the canonical toolchain, prefer fd/rg/ast-grep automatically, and surface tool availability constraints for downstream skills.

### Agent Selection Conditions
Execute routing lazily: agents remain unloaded until their command pattern matches the active request, preventing unnecessary policy loading for unrelated tasks.
Execute routing by command patterns:
1. Config-sync routing: `/config-sync/*` → `agent:config-sync`
2. Workflow routing: `/draft-commit-message`, `/review-shell-syntax` → `agent:workflow-helper`
3. Documentation routing: `/doc-gen:*` → `agent:doc-gen`
4. LLM governance routing: `/optimize-prompts` → `agent:llm-governance`
   Note: Official spec-based optimization (skills→SIMPLE, commands→DEPTH, agents→COMPLEX, rules→SIMPLE)
5. Code architecture routing: `/review-code-architecture` → `agent:code-architecture-reviewer`
6. Refactoring routing: `/refactor-*`, `/review-refactor` → `agent:code-refactor-master`
7. Planning routing: `/review-plan`, `/plan-*` → `agent:plan-reviewer`
8. Error resolution routing: `/fix-*`, `/resolve-errors` → `agent:ts-code-error-resolver`
9. Research routing: `/research-*`, `/web-search` → `agent:web-research-specialist`
10. Content-based routing: Files with specific extensions → trigger corresponding language skills
11. Metadata routing: LLM-prompt editing → `agent:llm-governance`

## Active Agents

Execute agent mappings on demand; each row describes what loads once the matching command fires. `skill:environment-validation` is provisioned first so tool-choice hints are available before the agent-specific stack initializes.

| Agent ID | Command Patterns | Default Skills | Optional Skills |
| --- | --- | --- | --- |
| `agent:config-sync` | `/config-sync/*` | `skill:environment-validation`, `skill:workflow-discipline`, `skill:security-logging`, `skill:automation-language-selection`, `skill:search-and-refactor-strategy` | Language skills based on target project |
| `agent:llm-governance` | `/optimize-prompts` | `skill:llm-governance`, `skill:workflow-discipline`, `skill:environment-validation` | None |
| `agent:doc-gen` | `/doc-gen:*` | `skill:workflow-discipline`, `skill:security-logging`, `skill:search-and-refactor-strategy` | Architecture/language skills per project type |
| `agent:workflow-helper` | `/draft-commit-message`, `/review-shell-syntax` | `skill:workflow-discipline`, `skill:automation-language-selection` | `skill:language-shell`, `skill:language-python`, `skill:environment-validation` |
| `agent:code-architecture-reviewer` | `/review-code-architecture` | `skill:architecture-patterns`, `skill:development-standards`, `skill:security-standards` | Language-specific skills based on codebase |
| `agent:code-refactor-master` | `/refactor-*`, `/review-refactor` | `skill:architecture-patterns`, `skill:development-standards`, `skill:testing-strategy`, `skill:search-and-refactor-strategy` | `skill:language-*` based on target code |
| `agent:plan-reviewer` | `/review-plan`, `/plan-*` | `skill:workflow-discipline`, `skill:architecture-patterns`, `skill:testing-strategy`, `skill:search-and-refactor-strategy` | Domain-specific skills based on plan content |
| `agent:ts-code-error-resolver` | `/fix-*`, `/resolve-errors` | `skill:error-patterns`, `skill:development-standards`, `skill:testing-strategy` | `skill:language-*` based on error context |
| `agent:web-research-specialist` | `/research-*`, `/web-search` | `skill:search-and-refactor-strategy`, `skill:workflow-discipline` | Content-specific research skills |
| `agent:refactor-planner` | Refactoring tasks, complex restructuring | `skill:architecture-patterns`, `skill:development-standards`, `skill:workflow-discipline`, `skill:search-and-refactor-strategy` | `skill:language-*`, `skill:testing-strategy` |

## Skill Dependencies

### Core Required Skills
Execute mandatory skill loading:
- `skill:environment-validation`: Required for every agent to drive tool decisions (fd vs find, rg vs grep, ast-grep availability) before other skills execute
- `skill:workflow-discipline`: Required for all agents
- `skill:security-logging`: Required for agents handling sensitive operations

### Conditional Required Skills
Execute conditional skill loading:
- `skill:llm-governance`: Required for LLM-prompt modifications
- `skill:language-*`: Required when operating on specific language files

### Optional Skills
Execute optional skill loading:
- `skill:automation-language-selection`: Optional for automation language selection guidance
- `skill:testing-strategy`: Optional for test-related operations
- `skill:architecture-patterns`: Optional for architectural guidance

## Agent-Skill Mappings

### `agent:config-sync`
Execute skill loading:
- Load: `skill:environment-validation`, `skill:workflow-discipline`, `skill:security-logging`, `skill:automation-language-selection`, `skill:search-and-refactor-strategy`
- Dependency: `skill:environment-validation` must be loaded before `skill:search-and-refactor-strategy`
- Conditional load: `skill:language-*` based on target project
- Escalation: Fallback to `agent:llm-governance` for permission violations

### `agent:llm-governance`
Execute skill loading:
- Load: `skill:llm-governance`, `skill:workflow-discipline`, `skill:environment-validation`
- Conditional load: None (governance logic handles content-type variations internally)
- Escalation: Notify maintainers on critical violations

### `agent:doc-gen`
Execute skill loading:
- Load: `skill:workflow-discipline`, `skill:security-logging`, `skill:search-and-refactor-strategy`
- Conditional load: `skill:language-*`, `skill:architecture-patterns` per project type
- Escalation: Fallback to `agent:config-sync` for integration issues

### `agent:workflow-helper`
Execute skill loading:
- Load: `skill:workflow-discipline`, `skill:automation-language-selection`
- Conditional load: Language skills based on task context
- Escalation: Fallback to appropriate specialist agent

### `agent:code-architecture-reviewer`
Execute skill loading:
- Load: `skill:architecture-patterns`, `skill:development-standards`, `skill:security-standards`
- Conditional load: `skill:language-*` based on codebase analysis
- Escalation: Fallback to `agent:code-refactor-master` for architectural issues

### `agent:code-refactor-master`
Execute skill loading:
- Load: `skill:architecture-patterns`, `skill:development-standards`, `skill:testing-strategy`, `skill:search-and-refactor-strategy`
- Conditional load: `skill:language-*` based on target code
- Escalation: Fallback to `agent:refactor-planner` for complex restructuring

### `agent:plan-reviewer`
Execute skill loading:
- Load: `skill:workflow-discipline`, `skill:architecture-patterns`, `skill:testing-strategy`, `skill:search-and-refactor-strategy`
- Conditional load: Domain-specific skills based on plan content
- Escalation: Fallback to `agent:refactor-planner` for implementation planning

### `agent:ts-code-error-resolver`
Execute skill loading:
- Load: `skill:error-patterns`, `skill:development-standards`, `skill:testing-strategy`
- Conditional load: `skill:language-*` based on error context
- Escalation: Fallback to language-specific agents for complex issues

### `agent:web-research-specialist`
Execute skill loading:
- Load: `skill:search-and-refactor-strategy`, `skill:workflow-discipline`
- Conditional load: Content-specific research skills
- Escalation: Fallback to `agent:llm-governance` for source validation

### `agent:refactor-planner`
Execute skill loading:
- Load: `skill:architecture-patterns`, `skill:development-standards`, `skill:workflow-discipline`, `skill:search-and-refactor-strategy`
- Conditional load: `skill:language-*`, `skill:testing-strategy` based on project scope
- Escalation: Fallback to `agent:code-refactor-master` for implementation

## Fallback Rules

### Agent Selection Failure
Execute failure handling:
1. No command match → Error with maintainer notification
2. Multiple agent matches → Use most specific match
3. Agent loading failure → Attempt fallback agent
4. All agents failed → Escalate to maintainers

### Skill Loading Failure
Execute failure handling:
1. Default skill missing → Agent fails fast
2. Optional skill missing → Continue with warning
3. Skill validation failure → Agent fails fast
4. Dependency cycle → Abort with diagnostic

### Critical Escalation Triggers
Execute immediate escalation for:
- Security rule violations
- Permission bypass attempts
- Unrecoverable skill loading errors
- Taxonomy conflicts
- Agent execution timeouts
