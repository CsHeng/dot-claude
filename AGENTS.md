---
name: "AGENTS.md"
description: "System specification for agent architecture, loading sequence, and DEPTH optimization framework"
version: "2.0"
type: "specification"
required-skills:
  - skill:workflow-discipline
  - skill:architecture-patterns
optional-skills:
  - skill:security-logging
  - skill:toolchain-baseline
---

# Agent System Specification

## Loading Sequence and Architecture

### System Loading Sequence
1. Memory Layer (`CLAUDE.md`): Agent routing table and skill mappings with DEPTH optimization
2. Agent Layer (`agents/<name>/AGENT.md`): Execution contracts with standardized workflow phases
3. Skill Layer (`skills/<name>/SKILL.md`): Single-capability modules with deterministic rule references
4. Rule Layer (`rules/*.md`): Canonical standards referenced by skills with validation criteria

Reference Authority: `docs/agentization/taxonomy-rfc.md`

### DEPTH Optimization Framework
All agents implement standardized DEPTH optimization with:
- D: Deterministic workflow phases with clear decision policies
- E: Error handling patterns with severity classification and recovery procedures
- P: Permission gating with comprehensive security validation
- T: Tooling selection with context-aware optimization
- H: Hierarchical escalation with clear fallback procedures

## Rule Application Conditions

### Personal Preferences (ABSOLUTE Mode)
- Location: `rules/00-memory-rules.md`
- Trigger: All operations unless explicitly overridden by user directive
- Validation: 95% coverage on critical execution paths
- Priority: Highest precedence in conflict resolution

### Language-Specific Rules
- Location: `rules/10-23`
- Trigger: File extension detection or declared language context
- Access: Via validated skill modules only
- Validation: Language-specific linting and standards compliance

### LLM Prompt Standards
- Location: `rules/99-llm-prompt-writing-rules.md`
- Trigger: All LLM-facing content modifications and command/skill/agent edits
- Authority: Primary governance standard for content generation
- Enforcement: Strict ABSOLUTE mode application with zero tolerance for violations

### Security Permissions
- Location: `.claude/settings.json`
- Trigger: Operations requiring allow/ask/deny gating with risk assessment
- Override: Never bypass without explicit user approval and audit trail
- Validation: Comprehensive security boundary enforcement

## Agent Capabilities with DEPTH Optimization

### `agent:config-sync` (Orchestration)
Commands: `/config-sync/*`
Mission: Orchestrate configuration synchronization workflows with deterministic permission handling
Inputs: Target directories, configuration files, rule sets, environment specifications
Outputs: Synchronized configurations, comprehensive audit logs, rollback capabilities
Fail-Fast Triggers: Permission denied, invalid target paths, security violations
Escalation: `agent:llm-governance` for governance violations, maintainer for critical failures

DEPTH Implementation:
- Deterministic: Repository analysis → Skill loading → Adapter orchestration → Verification
- Error Handling: Classification matrix with severity-based response and recovery
- Permission: Multi-level gating with user justification and approval workflows
- Tooling: Environment-specific selection with compatibility validation
- Hierarchical: Skill dependencies → Adapter execution → System integration

### `agent:llm-governance` (Governance)
Commands: `/optimize-prompts*`
Mission: Execute LLM governance audits with deterministic rule validation and compliance reporting
Inputs: LLM-facing files, target lists, audit scope specifications
Outputs: Audit reports, compliance assessments, remediation plans with severity classification
Fail-Fast Triggers: Critical governance violations, ABSOLUTE mode breaches, permission bypass attempts
Escalation: Immediate maintainer notification for critical violations

DEPTH Implementation:
- Deterministic: Target analysis → Rule loading → Audit execution → Structured reporting
- Error Handling: Rule validation failures → Default rules → Limited validation → Continuation
- Permission: Strict read-only enforcement with no write operations under any circumstances
- Tooling: Audit complexity-based loading with cross-file consistency validation
- Hierarchical: File analysis → Rule application → Violation classification → Remediation planning

### `agent:doc-gen` (Generation)
Commands: `/doc-gen:*`
Mission: Manage documentation generation with project-specific architecture adaptation
Inputs: Project structure, documentation templates, customization parameters
Outputs: Generated documentation, PlantUML diagrams, maintenance procedures
Fail-Fast Triggers: Invalid project types, missing templates, permission denials
Escalation: `agent:config-sync` for integration issues, maintainer for critical failures

DEPTH Implementation:
- Deterministic: Project analysis → Skill loading → Orchestration → Controlled output generation
- Error Handling: Project type ambiguity → Selection menu → Default application → Generation
- Permission: User confirmation before overwriting with specific justification and alternatives
- Tooling: Project-type specific loading with architecture complexity assessment
- Hierarchical: Project detection → Template selection → Generation → Validation → Maintenance

### `agent:workflow-helper` (Collaboration)
Commands: `/draft-commit-message`, `/review-shell-syntax`
Mission: Execute day-to-day workflows with deterministic tooling selection and permission gating
Inputs: Git state, shell scripts, workflow context, task specifications
Outputs: Commit messages, syntax validation, actionable recommendations with next-step guidance
Fail-Fast Triggers: Security violations, critical errors, repository integrity issues
Escalation: Language-specific agents for specialized issues, `agent:llm-governance` for security violations

DEPTH Implementation:
- Deterministic: Task analysis → Skill loading → Permission-gated execution → Comprehensive verification
- Error Handling: Tool selection failures → Manual alternatives → Documented limitations → Continuation
- Permission: Comprehensive gating for script execution with risk assessment and approval workflows
- Tooling: Task-context specific loading with security and performance validation
- Hierarchical: Request validation → Tool selection → Execution → Reporting → Next-step planning

## Skill Loading Rules and Dependencies

### Mandatory Skill Categories
- Workflow Discipline: All agents - Maintain incremental delivery and deterministic execution
- Security Logging: Operations with sensitive data - Apply structured controls and audit trails
- Toolchain Baseline: Development toolchain operations - Ensure consistency and compatibility

### Conditional Skill Loading Logic
```yaml
Language Detection:
  pattern: "file extension or declared context"
  action: "Load corresponding language skill"
  validation: "Compatibility and dependency check"

Project Type Analysis:
  pattern: "architecture complexity indicators"
  action: "Load architecture patterns skill"
  validation: "Project type compatibility assessment"

Security Context:
  pattern: "sensitive operations or data access"
  action: "Load security-guardrails skill"
  validation: "Security boundary validation"

Audit Complexity:
  pattern: "multi-file or system-wide analysis"
  action: "Load toolchain-baseline skill"
  validation: "Tool availability and compatibility"
```

### Skill Validation Requirements
- Manifest Completeness: All required fields present with valid values
- Source References: Valid rule file mappings with version compatibility
- Permission Compatibility: Tool access authorization validated against security policies
- Dependency Resolution: No circular references with conflict detection and resolution

## Execution Standards and Quality Requirements

### Quality Metrics and Validation
- Coverage Requirements: 80% overall code coverage, 95% on critical execution paths
- Linting Standards: Language-mandated validators required before completion
- Logging Requirements: Structured logs per `rules/22` with comprehensive audit trails
- Security Validation: Input validation and sanitization with vulnerability scanning

### Tool Validation and Compatibility
```yaml
PlantUML Validation:
  minimum_version: "1.2025.9"
  command: "plantuml --check-syntax <path>"
  integration: "Documentation generation workflows"

DBML Processing:
  command: "dbml2sql <path>"
  validation: "Schema integrity and syntax checking"

Shell Script Validation:
  commands: ["bash -n", "sh -n", "zsh -n"]
  reference: "rules/12-shell-guidelines.md"
  security: "Security-guardrails skill integration"
```

### Error Handling and Recovery Patterns
- Fail-Fast Behavior: Immediate halt on critical security errors or permission violations
- Input Validation: Comprehensive validation of all user inputs and file paths
- Secret Management: Environment variables only with audit trail generation
- Exception Logging: Detailed diagnostic information with context preservation
- Recovery Procedures: Documented fallback strategies with capability degradation

## System Reference Matrix and Dependencies

| Component | Location | Purpose | Validation |
|-----------|----------|---------|------------|
| Taxonomy | `docs/agentization/taxonomy-rfc.md` | System architecture and loading rules | Version compatibility |
| Memory | `CLAUDE.md` | Agent routing and skill mappings | Routing completeness |
| Skills | `skills/` | Capability manifests with rule references | Manifest validation |
| Agents | `agents/` | Command execution contracts | DEPTH optimization |
| Rules | `rules/` | Canonical standards library | Rule integrity |
| Settings | `.claude/settings.json` | Permission and security policy | Security validation |

## Critical Failure Modes and Recovery

### System-Level Escalation Procedures
```yaml
Memory File Corruption:
  detection: "Checksum validation failure"
  response: "Immediate maintainer intervention"
  recovery: "Backup restoration with integrity verification"

Taxonomy Conflicts:
  detection: "Version incompatibility or rule conflicts"
  response: "System halt with comprehensive diagnostics"
  recovery: "Conflict resolution with version synchronization"

Permission Bypass:
  detection: "Unauthorized access attempts"
  response: "Security incident response with immediate containment"
  recovery: "Security audit with policy reinforcement"

Agent Loading Cascade Failure:
  detection: "Multiple agent initialization failures"
  response: "System restart with diagnostic mode"
  recovery: "Progressive agent loading with fallback activation"
```

### Recovery Validation Sequence
1. Memory File Integrity: Validate checksum and structure completeness
2. Taxonomy Compatibility: Check version compatibility and rule consistency
3. Agent Manifest Validation: Verify DEPTH optimization and skill mappings
4. Skill Loading Sequence: Test progressive skill loading with dependency resolution
5. Rule Accessibility: Confirm all referenced rules are available and valid

## Agent Interaction and Escalation Patterns

### Inter-Agent Communication
- Config-Sync → LLM-Governance: Permission violations and governance breaches
- Doc-Gen → Config-Sync: Integration issues and configuration conflicts
- Workflow-Helper → Language Agents: Specialized language-specific tasks
- All Agents → Maintainer: Critical failures and security incidents

### Escalation Decision Logic
```
IF critical security violation detected:
    → Immediate agent:llm-governance escalation
    → Security incident response procedures
    → Maintainer notification with full context

IF agent capability exceeded:
    → Escalate to specialized agent with context transfer
    → Maintain audit trail across agent boundaries
    → Preserve execution state for continuation

IF system-level failure:
    → System halt with comprehensive diagnostics
    → Maintainer intervention with recovery procedures
    → Full system validation before restart
```

### Context Preservation Across Boundaries
- State Transfer: Complete execution context with audit trails
- Skill Dependencies: Active skill manifests with compatibility information
- Permission State: Current approval levels and security boundaries
- Error History: Full error context with resolution attempts and outcomes