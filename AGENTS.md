# Agent System Specification

## System Architecture

### Loading Sequence
1. Memory Layer: Agent routing table and skill mappings
2. Agent Layer: Execution contracts with DEPTH optimization
3. Skill Layer: Single-capability modules with rule references
4. Rule Layer: Canonical standards with validation criteria

All agents instantiate lazily—no agent initializes until its slash-command pattern is invoked. Before handing control to any agent, Memory automatically loads `skill:environment-validation` so tooling decisions (fd vs find, rg vs grep, ast-grep detection, PATH hygiene) are resolved once and propagated to subsequent skills.

Reference: `docs/agentization/taxonomy-rfc.md`

### DEPTH Framework Requirements
All agents implement standardized DEPTH optimization:
- D: Deterministic workflow phases with clear decision policies
- E: Error handling patterns with severity classification
- P: Permission gating with comprehensive security validation
- T: Tooling selection with context-aware optimization
- H: Hierarchical escalation with clear fallback procedures

## Rule Application Matrix

| Rule Type | Location | Trigger Condition | Priority |
|-----------|----------|-------------------|----------|
| Personal Preferences | `rules/00-memory-rules.md` | All operations unless overridden | Highest |
| Language-Specific | `rules/10-23` | File extension or declared context | High |
| LLM Prompt Standards | `rules/99-llm-prompt-writing-rules.md` | LLM-facing content modifications | Critical |
| Security Permissions | `.claude/settings.json` | Operations requiring risk assessment | Critical |

## Agent Specifications

### `agent:config-sync`
Commands: `/config-sync/*`
Mission: Orchestrate configuration synchronization workflows
Inputs: Target directories, configuration files, rule sets
Outputs: Synchronized configurations, audit logs, rollback capabilities
Fail-Fast Triggers: Permission denied, invalid targets, security violations
Escalation: `agent:llm-governance` for governance violations

DEPTH Implementation:
- Deterministic: Repository analysis → Skill loading → Orchestration → Verification
- Error Handling: Classification matrix with severity-based response
- Permission: Multi-level gating with user justification workflows
- Tooling: Environment-specific selection with compatibility validation
- Hierarchical: Dependencies → Adapter execution → System integration

### `agent:llm-governance`
Commands: `/optimize-prompts`
Mission: Execute LLM governance audits with official spec-based optimization
Inputs: LLM-facing files, target lists, audit scope specifications
Outputs: Audit reports, compliance assessments, remediation plans
Fail-Fast Triggers: Critical governance violations, essential information loss
Escalation: Immediate maintainer notification for critical violations

Official Specification-Based Optimization:
- Skills: SIMPLE framework (model-invoked, minimal frontmatter: name + description)
- Commands: DEPTH framework (user-invoked, complex parameters, user guidance)
- Agents: COMPLEX framework (subagents, delegation, specialized tools)
- Rules: SIMPLE framework (imperative rules only, no narrative)

DEPTH Implementation:
- Deterministic: Official spec classification → Targeted optimization → Validation
- Error Handling: Spec-compliance preservation → Rollback capability
- Permission: Strict validation of official frontmatter requirements
- Tooling: Official Claude Code spec alignment + critical pattern matching
- Hierarchical: Type detection → Framework application → Spec compliance reporting

### `agent:doc-gen`
Commands: `/doc-gen:*`
Mission: Manage documentation generation with architecture adaptation
Inputs: Project structure, documentation templates, customization parameters
Outputs: Generated documentation, PlantUML diagrams, maintenance procedures
Fail-Fast Triggers: Invalid project types, missing templates, permission denials
Escalation: `agent:config-sync` for integration issues

DEPTH Implementation:
- Deterministic: Project analysis → Skill loading → Orchestration → Output generation
- Error Handling: Project type ambiguity → Selection menu → Default application
- Permission: User confirmation before overwriting with justification
- Tooling: Project-type specific loading with complexity assessment
- Hierarchical: Detection → Template selection → Generation → Validation → Maintenance

### `agent:workflow-helper`
Commands: `/draft-commit-message`, `/review-shell-syntax`
Mission: Execute day-to-day workflows with deterministic tooling selection
Inputs: Git state, shell scripts, workflow context, task specifications
Outputs: Commit messages, syntax validation, actionable recommendations
Fail-Fast Triggers: Security violations, critical errors, repository integrity issues
Escalation: Language-specific agents for specialized issues

DEPTH Implementation:
- Deterministic: Task analysis → Skill loading → Permission-gated execution → Verification
- Error Handling: Tool selection failures → Manual alternatives → Documented limitations
- Permission: Comprehensive gating with risk assessment and approval workflows
- Tooling: Task-context specific loading with security validation
- Hierarchical: Request validation → Tool selection → Execution → Reporting → Planning

### `agent:code-architecture-reviewer`
Commands: `/review-code-architecture`
Mission: Evaluate architectural fitness of recent code changes with systemic analysis
Inputs: Code files, architecture diagrams, change descriptions
Outputs: Architecture assessment, risk classification, integration notes
Fail-Fast Triggers: Missing architectural context, unreadable sources, policy violations
Escalation: `agent:code-refactor-master` for remediation planning

DEPTH Implementation:
- Deterministic: Context analysis → Pattern alignment → Findings generation
- Error Handling: Missing data → Document assumptions; invalid artifacts → Request resubmission
- Permission: Read-only evaluation of code + docs
- Tooling: Language skill auto-selection enforced after `skill:environment-validation`
- Hierarchical: Architecture issues escalate to refactor or plan reviewers based on scope

### `agent:code-refactor-master`
Commands: `/refactor-*`, `/review-refactor`
Mission: Orchestrate refactor plans with deterministic sequencing and validation
Inputs: Target files, refactor goals, dependency graphs
Outputs: Refactor blueprints, risk logs, validation plans
Fail-Fast Triggers: Undefined targets, unsafe dependency rewrite requests
Escalation: `agent:refactor-planner` for large-scale restructure roadmaps

DEPTH Implementation:
- Deterministic: Scope capture → Impact analysis → Refactor plan → Validation gating
- Error Handling: Conflicts or blockers → Document severity → escalate/back off
- Permission: Enforce approval before write operations, maintain rollback plans
- Tooling: Ast-grep, rg, fd pipelines aligned with environment validation
- Hierarchical: Delegates tests to testing strategy skills, coordinates with workflow helper for commits

### `agent:plan-reviewer`
Commands: `/review-plan`, `/plan-*`
Mission: Validate user-submitted plans for completeness, feasibility, and risk
Inputs: Written plans, supporting specs, acceptance criteria
Outputs: Gap analysis, risk register, actionable adjustments
Fail-Fast Triggers: Missing objectives, conflicting requirements, permissions issues
Escalation: `agent:workflow-helper` for day-to-day adjustments or `agent:refactor-planner` for execution plans

DEPTH Implementation:
- Deterministic: Context mapping → Constraint validation → Recommendation synthesis
- Error Handling: Ambiguous scope → request clarification; conflicting constraints → highlight blocking issues
- Permission: Read-only on plan artifacts
- Tooling: Structured template enforcement and diff-aware review
- Hierarchical: Plans requiring code changes route to refactor/architecture agents automatically

### `agent:ts-code-error-resolver`
Commands: `/fix-*`, `/resolve-errors`
Mission: Resolve TypeScript and general runtime errors with deterministic debugging
Inputs: Stack traces, failing tests, code snippets
Outputs: Root cause analysis, fix patches, regression tests
Fail-Fast Triggers: Missing repro steps, inadequate permissions to run diagnostics
Escalation: Language-specific agents or `agent:code-architecture-reviewer` when architectural fixes required

DEPTH Implementation:
- Deterministic: Repro capture → Trace analysis → Fix proposal → Validation plan
- Error Handling: Non-reproducible issues → Document steps tried; environment mismatch → escalate to environment validation
- Permission: Controlled execution of tests + linters per settings
- Tooling: Shell, node, and test runners verified through environment skill
- Hierarchical: Hard blockers trigger maintainer notification with run logs

### `agent:web-research-specialist`
Commands: `/research-*`, `/web-search`
Mission: Conduct structured research with citation-ready deliverables
Inputs: Research prompts, scope boundaries, source constraints
Outputs: Curated findings, citation lists, risk notes
Fail-Fast Triggers: Network restrictions, source trust violations, compliance issues
Escalation: `agent:llm-governance` for source compliance disputes

DEPTH Implementation:
- Deterministic: Scope definition → Query planning → Source vetting → Report compilation
- Error Handling: Blocked domains → document + retry alternative queries
- Permission: Enforce security policies from `.claude/settings.json`
- Tooling: Browserless fetch + verification tooling validated up front
- Hierarchical: Escalates policy or security incidents to governance agent

### `agent:refactor-planner`
Commands: invoked automatically by refactor/plan workflows
Mission: Produce end-to-end refactor plans with dependency charts, milestones, and rollback steps
Inputs: Architecture maps, code owners, dependency matrices
Outputs: Execution plans, phased milestones, risk mitigations
Fail-Fast Triggers: Missing ownership data, conflicting dependency constraints
Escalation: `agent:code-refactor-master` for implementation, `agent:plan-reviewer` for stakeholder validation

DEPTH Implementation:
- Deterministic: Inventory gathering → Impact scoring → Milestone synthesis → Validation gating
- Error Handling: Unknown dependencies → flag and require user input
- Permission: Planning-only, no write operations to production files
- Tooling: Graph generation + doc templates defined under doc-gen rules
- Hierarchical: Coordinates between architecture reviewer and refactor executor

## Skill Loading Requirements

### Mandatory Skills by Category
- Workflow Discipline: All agents - maintain incremental delivery and deterministic execution
- Toolchain Baseline (`skill:environment-validation`): All agents - enforce consistent tool chains, prefer fd/rg/ast-grep, and validate PATH/tool availability before other skills execute
- Security Logging: Sensitive operations - apply structured controls and audit trails

### Conditional Loading Logic
```yaml
Language Detection:
  trigger: "file extension or declared context"
  action: "Load corresponding language skill"
  validation: "Compatibility and dependency check"

Project Analysis:
  trigger: "architecture complexity indicators"
  action: "Load architecture patterns skill"
  validation: "Project type compatibility assessment"

Security Context:
  trigger: "sensitive operations or data access"
  action: "Load security-guardrails skill"
  validation: "Security boundary validation"

Audit Complexity:
  trigger: "multi-file or system-wide analysis"
  action: "Intensify environment-validation checks (fd vs find, rg vs grep, ast-grep availability)"
  validation: "Tool availability and compatibility"
```

### Validation Requirements
- Manifest Completeness: Required fields present with valid values
- Source References: Valid rule file mappings with version compatibility
- Permission Compatibility: Tool access authorization against security policies
- Dependency Resolution: No circular references with conflict detection

## Quality Standards

### Validation Metrics
- Coverage Requirements: 80% overall code coverage, 95% on critical paths
- Linting Standards: Language-mandated validators before completion
- Logging Requirements: Structured logs with comprehensive audit trails
- Security Validation: Input validation with vulnerability scanning

### Tool Compatibility Matrix
```yaml
PlantUML:
  minimum_version: "1.2025.9"
  validation_command: "plantuml --check-syntax <path>"
  integration: "Documentation generation workflows"

DBML:
  processing_command: "dbml2sql <path>"
  validation: "Schema integrity and syntax checking"

Shell Scripts:
  validation_commands: ["bash -n", "sh -n", "zsh -n"]
  reference: "rules/12-shell-guidelines.md"
  security: "Security-guardrails skill integration"
```

## Error Handling and Recovery

### Fail-Fast Triggers
- Critical security errors or permission violations
- Unauthorized access attempts
- System corruption or integrity failures
- Critical dependency resolution failures

### Recovery Procedures
1. Input Validation: Comprehensive validation of all inputs and file paths
2. Secret Management: Environment variables only with audit trail
3. Exception Logging: Detailed diagnostic information with context preservation
4. Fallback Strategies: Documented degradation procedures

## System Dependencies

| Component | Location | Purpose | Validation |
|-----------|----------|---------|------------|
| Taxonomy | `docs/agentization/taxonomy-rfc.md` | System architecture rules | Version compatibility |
| Memory | `CLAUDE.md` | Agent routing and skill mappings | Routing completeness |
| Skills | `skills/` | Capability manifests | Manifest validation |
| Agents | `agents/` | Command execution contracts | DEPTH optimization |
| Rules | `rules/` | Canonical standards | Rule integrity |
| Settings | `.claude/settings.json` | Permission and security policy | Security validation |
| Directory Classification | `commands/optimize-prompts/classification-rules.yaml` | Directory-to-framework routing | Version-matched with `rules/99-llm-prompt-writing-rules.md` |

## Critical Failure Modes

### System-Level Escalation
```yaml
Memory Corruption:
  detection: "Checksum validation failure"
  response: "Immediate maintainer intervention"
  recovery: "Backup restoration with integrity verification"

Taxonomy Conflicts:
  detection: "Version incompatibility or rule conflicts"
  response: "System halt with comprehensive diagnostics"
  recovery: "Conflict resolution with version synchronization"

Permission Bypass:
  detection: "Unauthorized access attempts"
  response: "Security incident response with containment"
  recovery: "Security audit with policy reinforcement"

Agent Cascade Failure:
  detection: "Multiple agent initialization failures"
  response: "System restart with diagnostic mode"
  recovery: "Progressive loading with fallback activation"
```

## Inter-Agent Communication

### Communication Patterns
- Config-Sync → LLM-Governance: Permission violations and governance breaches
- Doc-Gen → Config-Sync: Integration issues and configuration conflicts
- Workflow-Helper → Language Agents: Specialized language-specific tasks
- All Agents → Maintainer: Critical failures and security incidents

### Escalation Decision Logic
```
IF critical security violation:
    → Immediate agent:llm-governance escalation
    → Security incident response procedures
    → Maintainer notification with full context

IF agent capability exceeded:
    → Escalate to specialized agent with context transfer
    → Maintain audit trail across boundaries
    → Preserve execution state for continuation

IF system-level failure:
    → System halt with comprehensive diagnostics
    → Maintainer intervention with recovery procedures
    → Full system validation before restart
```
