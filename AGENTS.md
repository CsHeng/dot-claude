---
name: "AGENTS.md"
description: "Agent system specification with DEPTH optimization framework"
version: "2.0.0"
type: "specification"
required-skills:
  - skill:workflow-discipline
  - skill:architecture-patterns
optional-skills:
  - skill:security-logging
  - skill:environment-validation
---

# Agent System Specification

## System Architecture

### Loading Sequence
1. Memory Layer: Agent routing table and skill mappings
2. Agent Layer: Execution contracts with DEPTH optimization
3. Skill Layer: Single-capability modules with rule references
4. Rule Layer: Canonical standards with validation criteria

Reference: `docs/agentization/taxonomy-rfc.md`

### DEPTH Framework Requirements
All agents implement standardized DEPTH optimization:
- **D**: Deterministic workflow phases with clear decision policies
- **E**: Error handling patterns with severity classification
- **P**: Permission gating with comprehensive security validation
- **T**: Tooling selection with context-aware optimization
- **H**: Hierarchical escalation with clear fallback procedures

## Rule Application Matrix

| Rule Type | Location | Trigger Condition | Priority |
|-----------|----------|-------------------|----------|
| Personal Preferences | `rules/00-memory-rules.md` | All operations unless overridden | Highest |
| Language-Specific | `rules/10-23` | File extension or declared context | High |
| LLM Prompt Standards | `rules/99-llm-prompt-writing-rules.md` | LLM-facing content modifications | Critical |
| Security Permissions | `.claude/settings.json` | Operations requiring risk assessment | Critical |

## Agent Specifications

### `agent:config-sync`
**Commands**: `/config-sync/*`
**Mission**: Orchestrate configuration synchronization workflows
**Inputs**: Target directories, configuration files, rule sets
**Outputs**: Synchronized configurations, audit logs, rollback capabilities
**Fail-Fast Triggers**: Permission denied, invalid targets, security violations
**Escalation**: `agent:llm-governance` for governance violations

**DEPTH Implementation**:
- Deterministic: Repository analysis → Skill loading → Orchestration → Verification
- Error Handling: Classification matrix with severity-based response
- Permission: Multi-level gating with user justification workflows
- Tooling: Environment-specific selection with compatibility validation
- Hierarchical: Dependencies → Adapter execution → System integration

### `agent:llm-governance`
**Commands**: `/optimize-prompts`
**Mission**: Execute LLM governance audits with deterministic validation
**Inputs**: LLM-facing files, target lists, audit scope specifications
**Outputs**: Audit reports, compliance assessments, remediation plans
**Fail-Fast Triggers**: Critical governance violations, ABSOLUTE mode breaches
**Escalation**: Immediate maintainer notification for critical violations

**DEPTH Implementation**:
- Deterministic: Target analysis → Rule loading → Audit execution → Reporting
- Error Handling: Rule validation failures → Default rules → Limited validation
- Permission: Strict read-only enforcement, no write operations
- Tooling: Complexity-based loading with cross-file consistency validation
- Hierarchical: File analysis → Rule application → Violation classification → Remediation

### `agent:doc-gen`
**Commands**: `/doc-gen:*`
**Mission**: Manage documentation generation with architecture adaptation
**Inputs**: Project structure, documentation templates, customization parameters
**Outputs**: Generated documentation, PlantUML diagrams, maintenance procedures
**Fail-Fast Triggers**: Invalid project types, missing templates, permission denials
**Escalation**: `agent:config-sync` for integration issues

**DEPTH Implementation**:
- Deterministic: Project analysis → Skill loading → Orchestration → Output generation
- Error Handling: Project type ambiguity → Selection menu → Default application
- Permission: User confirmation before overwriting with justification
- Tooling: Project-type specific loading with complexity assessment
- Hierarchical: Detection → Template selection → Generation → Validation → Maintenance

### `agent:workflow-helper`
**Commands**: `/draft-commit-message`, `/review-shell-syntax`
**Mission**: Execute day-to-day workflows with deterministic tooling selection
**Inputs**: Git state, shell scripts, workflow context, task specifications
**Outputs**: Commit messages, syntax validation, actionable recommendations
**Fail-Fast Triggers**: Security violations, critical errors, repository integrity issues
**Escalation**: Language-specific agents for specialized issues

**DEPTH Implementation**:
- Deterministic: Task analysis → Skill loading → Permission-gated execution → Verification
- Error Handling: Tool selection failures → Manual alternatives → Documented limitations
- Permission: Comprehensive gating with risk assessment and approval workflows
- Tooling: Task-context specific loading with security validation
- Hierarchical: Request validation → Tool selection → Execution → Reporting → Planning

## Skill Loading Requirements

### Mandatory Skills by Category
- **Workflow Discipline**: All agents - maintain incremental delivery and deterministic execution
- **Security Logging**: Sensitive operations - apply structured controls and audit trails
- **Toolchain Baseline**: Development operations - ensure consistency and compatibility

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
  action: "Load environment-validation skill"
  validation: "Tool availability and compatibility"
```

### Validation Requirements
- **Manifest Completeness**: Required fields present with valid values
- **Source References**: Valid rule file mappings with version compatibility
- **Permission Compatibility**: Tool access authorization against security policies
- **Dependency Resolution**: No circular references with conflict detection

## Quality Standards

### Validation Metrics
- **Coverage Requirements**: 80% overall code coverage, 95% on critical paths
- **Linting Standards**: Language-mandated validators before completion
- **Logging Requirements**: Structured logs with comprehensive audit trails
- **Security Validation**: Input validation with vulnerability scanning

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
1. **Input Validation**: Comprehensive validation of all inputs and file paths
2. **Secret Management**: Environment variables only with audit trail
3. **Exception Logging**: Detailed diagnostic information with context preservation
4. **Fallback Strategies**: Documented degradation procedures

## System Dependencies

| Component | Location | Purpose | Validation |
|-----------|----------|---------|------------|
| Taxonomy | `docs/agentization/taxonomy-rfc.md` | System architecture rules | Version compatibility |
| Memory | `CLAUDE.md` | Agent routing and skill mappings | Routing completeness |
| Skills | `skills/` | Capability manifests | Manifest validation |
| Agents | `agents/` | Command execution contracts | DEPTH optimization |
| Rules | `rules/` | Canonical standards | Rule integrity |
| Settings | `.claude/settings.json` | Permission and security policy | Security validation |

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
- **Config-Sync → LLM-Governance**: Permission violations and governance breaches
- **Doc-Gen → Config-Sync**: Integration issues and configuration conflicts
- **Workflow-Helper → Language Agents**: Specialized language-specific tasks
- **All Agents → Maintainer**: Critical failures and security incidents

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