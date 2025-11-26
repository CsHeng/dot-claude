# Memory Configuration

> Taxonomy note: for the three-layer model (UI entry, orchestration/governance, execution agents/skills/commands), see `docs/taxonomy-rfc.md`.

## Rule-Loading Conditions

### Default Conditions
Execute communication protocol from `rules/98-communication-protocol.md` in TERSE MODE for all responses unless explanation triggers are present or the active output style prefers explanatory behavior
Execute EXPLANATORY MODE communication patterns from `rules/98-communication-protocol.md` only when user input contains explicit explanation triggers or the active output style prefers explanatory behavior
Execute preferred output style behavior from `rules/98-output-styles.md` and the active output-style manifest when the user selects a named output style
Execute language-specific rules based on file extensions or declared language context
Execute security rules for all operations involving credentials, permissions, or network access
Execute testing rules when operations involve test files or test execution
Execute directory classification from `commands/llm-governance/optimize-prompts/classification-rules.yaml` before routing `/llm-governance/optimize-prompts`
Execute governance exceptions from `rules/99-llm-prompt-writing-rules.md` immediately after classification rules load

### Explanation Trigger Conditions
Treat the following as explanation triggers that switch communication to EXPLANATORY MODE for the current response (even when the default output style prefers terse behavior):
- "explain more", "be more verbose", "help me understand"
- "详细说明", "详细解释", "更详细", "帮我理解"
Treat similar explicit user requests for more detail as explanation triggers

### Output Style Selection
Initialize conversation output behavior using TERSE MODE semantics from `rules/98-communication-protocol.md` and the `default` output style from `governance/styles/default.md` (falling back to `output-styles/default.md` for compatibility) unless overridden by settings
Treat explicit `/output-style <name>` commands as preferred output style selections following `rules/98-output-styles.md`
Allow equivalent natural-language requests that unambiguously map to style identifiers (for example, "use learning mode", "讲解多一点") as output style selections. Style manifests are resolved first from `governance/styles/<name>.md` and then from `output-styles/<name>.md` for compatibility.
Persist the selected output style for all subsequent responses until the user issues a new `/output-style <name>` command or an explicit reset such as `/output-style reset` or a project-defined default

### Baseline Skill Initialization
Execute `skill:environment-validation` before dispatching any agent to enforce the canonical toolchain, prefer fd/rg/ast-grep automatically, and surface tool availability constraints for downstream skills.

### Directory Reference Mapping
Directory references in this document assume the canonical `~/.claude` layout. When a target CLI (for example OpenCode) consumes these instructions, translate the directories using `.claude/commands/config-sync/directory-manifest.json` before execution. As of the 2025-11-19 manifest, OpenCode maps the `commands` component to the `command/` directory and the `agents` component to `agent/`, while other components retain their canonical names. Always check the manifest for the latest per-target mapping when new CLI targets are introduced.

### Agent Selection Conditions
Execute routing lazily: agents remain unloaded until their command pattern matches the active request, preventing unnecessary policy loading for unrelated tasks.
Execute routing by command patterns (governance routers described in `governance/routers/**`, execution agents in `agents/**`):
1. Workflow routing:
   - `/draft-commit-message` → `router:workflow-helper` → `agent:draft-commit-message`
   - `/review-shell-syntax` → `router:workflow-helper` → `agent:review-shell-syntax`
   - `/check-secrets` → `router:workflow-helper` → `agent:check-secrets`
   - `/lint-markdown` → `router:workflow-helper` → `agent:lint-markdown`
2. LLM governance routing: `/llm-governance/optimize-prompts` → `router:llm-governance` → `agent:llm-governance`
   Note: Official spec-based optimization (skills→SIMPLE, commands→DEPTH, agents→COMPLEX, rules→SIMPLE)
3. Code architecture routing: `/review-code-architecture` → `router:code-architecture` → `agent:code-architecture-reviewer`
4. Refactoring routing:
   - `/refactor-*`, `/review-refactor` → `router:code-refactor` → `agent:code-refactor-master` / `agent:refactor-planner`
5. Planning routing: `/review-plan`, `/plan-*` → `router:plan-review` → `agent:plan-reviewer`
6. Error resolution routing: `/fix-*`, `/resolve-errors` → `router:ts-error-resolution` → `agent:ts-code-error-resolver`
7. Research routing: `/research-*`, `/web-search` → `router:web-research` → `agent:web-research-specialist`
8. Content-based routing: Files with specific extensions → trigger corresponding language skills
9. Metadata routing: LLM-prompt editing → `agent:llm-governance`

## Active Agents

Execute agent mappings on demand; each row describes what loads once the matching command fires. `skill:environment-validation` is provisioned first so tool-choice hints are available before the agent-specific stack initializes.

| Agent ID | Command Patterns | Default Skills | Optional Skills |
| --- | --- | --- | --- |
| `agent:llm-governance` | `/llm-governance/optimize-prompts` | `skill:llm-governance`, `skill:workflow-discipline`, `skill:environment-validation` | None |
| `agent:draft-commit-message` | `/draft-commit-message` (via `router:workflow-helper`) | `skill:workflow-discipline`, `skill:environment-validation` | `skill:automation-language-selection` |
| `agent:review-shell-syntax` | `/review-shell-syntax` (via `router:workflow-helper`) | `skill:workflow-discipline` | `skill:language-shell`, `skill:environment-validation` |
| `agent:check-secrets` | `/check-secrets` (via `router:workflow-helper`) | `skill:workflow-discipline` | `skill:security-guardrails`, `skill:environment-validation` |
| `agent:lint-markdown` | `/lint-markdown` (via `router:workflow-helper`) | `skill:lint-markdown`, `skill:workflow-discipline`, `skill:environment-validation` | `skill:search-and-refactor-strategy`, `skill:security-logging` |
| `agent:code-architecture-reviewer` | `/review-code-architecture` (via direct agent execution) | `skill:architecture-patterns`, `skill:development-standards`, `skill:security-standards` | Language-specific skills based on codebase |
| `agent:code-refactor-master` | `/refactor-*`, `/review-refactor` (via direct agent execution) | `skill:architecture-patterns`, `skill:development-standards`, `skill:testing-strategy`, `skill:search-and-refactor-strategy` | `skill:language-*` based on target code |
| `agent:plan-reviewer` | `/review-plan`, `/plan-*` (via direct agent execution) | `skill:workflow-discipline`, `skill:architecture-patterns`, `skill:testing-strategy`, `skill:search-and-refactor-strategy` | Domain-specific skills based on plan content |
| `agent:ts-code-error-resolver` | `/fix-*`, `/resolve-errors` (via direct agent execution) | `skill:error-patterns`, `skill:development-standards`, `skill:testing-strategy` | `skill:language-*` based on error context |
| `agent:web-research-specialist` | `/research-*`, `/web-search` (via direct agent execution) | `skill:search-and-refactor-strategy`, `skill:workflow-discipline` | Content-specific research skills |
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

### `agent:llm-governance`
Execute skill loading:
- Load: `skill:llm-governance`, `skill:workflow-discipline`, `skill:environment-validation`
- Conditional load: None (governance logic handles content-type variations internally)
- Escalation: Notify maintainers on critical violations

Execute skill loading:
- Load: `skill:workflow-discipline`, `skill:security-logging`, `skill:search-and-refactor-strategy`, `skill:architecture-patterns`, `skill:language-python`, `skill:language-go`
- Conditional load: additional `skill:language-*` per project type
- Escalation: Fallback to `agent:config-sync` for integration issues

### `agent:workflow-helper`
Execute skill loading:
- Load: `skill:workflow-discipline`, `skill:automation-language-selection`
- Conditional load: `skill:language-shell` for `/review-shell-syntax` command, `skill:language-python` for Python files/tasks, `skill:language-go` for Go files/tasks, `skill:lint-markdown` for `/lint-markdown` command, Language skills based on task context
- Escalation: Fallback to appropriate specialist agent

### `agent:lint-markdown`
Execute skill loading:
- Load: `skill:lint-markdown`, `skill:workflow-discipline`, `skill:environment-validation`
- Conditional load: `skill:search-and-refactor-strategy` for advanced pattern matching, `skill:security-logging` for audit operations
- Escalation: Fallback to `agent:workflow-helper` for integration issues

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
