---
file-type: command
command: /doc-gen/README
description: Documentation generation plugin overview and usage reference
implementation: commands/doc-gen/README.md
scope: Included
related-commands:
  - /doc-gen:bootstrap
related-agents:
  - agent:doc-gen
related-skills:
  - skill:workflow-discipline
  - skill:security-logging
disable-model-invocation: true
---

## usage

Reference documentation for the doc-gen plugin system. View architecture documentation workflows, component organization, and integration guidelines.

## arguments

None - This is a documentation file. Use `/doc-gen:bootstrap` for operations.

## workflow

1. Read plugin architecture and component organization
2. Identify project-type specific adapter requirements
3. Reference shared conventions and standards
4. Follow integration guidelines for new project types

## output

Complete reference documentation including:
- Plugin architecture and component responsibilities
- Usage patterns and command invocation examples
- Project-type adapter specifications
- Shared conventions and formatting standards
- Agent integration mappings and skill requirements

## plugin-architecture

### directory-structure

```
commands/doc-gen/
├── README.md                    # This reference documentation
├── core/                        # Orchestration logic and workflows
│   └── bootstrap.md            # Self-contained orchestrator prompt
├── adapters/                    # Project-type specific adapters
│   ├── android-app.md          # Android application guidance
│   ├── android-sdk.md          # Android SDK guidance
│   ├── backend-go.md           # Go backend service guidance
│   ├── backend-php.md          # PHP backend service guidance
│   ├── web-admin.md            # Web admin interface guidance
│   └── web-user.md             # Web user interface guidance
├── lib/                        # Shared utilities and conventions
│   └── common.md               # Common formatting and logging standards
└── settings.json               # Default runtime configuration
```

### component-responsibilities

**Core Orchestrator:**
- Input gathering and validation
- Output format enforcement
- Adapter delegation and coordination
- Deliverable verification and validation

**Project-Type Adapters:**
- Domain-specific documentation guidance
- Industry standard conventions
- Technology-specific patterns
- Asset generation templates

**Shared Library:**
- Consistent formatting conventions
- Logging standards and patterns
- Template structures and utilities
- Validation criteria and checklists

## usage-patterns

### command-invocation

```bash
# Bootstrap new Android app documentation
/doc-gen:bootstrap --project-type=android-app --mode=bootstrap --language=en --repo=<path> --docs=<path> --core=<path>

# Maintain existing Android SDK documentation
/doc-gen:bootstrap --project-type=android-sdk --mode=maintain --language=zh --repo=<path> --docs=<path> --core=<path> --demo=<path>

# Generate Go backend service documentation
/doc-gen:bootstrap --project-type=backend-go --mode=bootstrap --language=en --repo=<path> --docs=<path> --core=<path>
```

### execution-modes

**Bootstrap Mode:**
- Generate complete documentation structure
- Create initial asset templates
- Output to `docs-bootstrap/` directory
- Preserve existing `docs/` content

**Maintain Mode:**
- Update existing documentation
- Synchronize with current project state
- Operate on `docs/` directory directly
- Incremental updates and validations

### workflow-features

**Consolidated Checklists:**
- Mode selection guidance
- Project-type validation
- Language configuration
- Path auto-suggestion and validation

**Deliverable Enforcement:**
- Parameter summary tables
- Asset count verification
- Actor matrix generation
- PlantUML validation results
- TODO backlog management

## integration-guidelines

### adding-project-types

1. Create adapter file in `adapters/` directory
2. Follow established template structure
3. Implement project-type specific guidance
4. Register adapter in orchestrator
5. Test integration with core workflow

### adapter-development

**Required Sections:**
- Project-type specific conventions
- Industry standard patterns
- Technology-specific requirements
- Asset generation guidelines
- Validation criteria

**Integration Points:**
- Core orchestrator delegation
- Shared library utilization
- Parameter handling standards
- Output format compliance

## agent-integration

| Agent | Commands | Default Skills | Optional Skills |
| --- | --- | --- | --- |
| `agent:doc-gen` | `/doc-gen:bootstrap`, `/doc-gen:maintain` | `skill:workflow-discipline`, `skill:security-logging` | `skill:language-python`, `skill:language-go`, `skill:architecture-patterns` |

## quality-standards

**Documentation Quality:**
- Comprehensive coverage of project components
- Consistent formatting and structure
- Clear navigation and cross-references
- Regular maintenance and updates

**Process Validation:**
- Input parameter validation
- Output format verification
- Asset completeness checks
- Integration testing results

**Conformance Assurance:**
- Industry standard compliance
- Technology-specific best practices
- Organizational guideline adherence
- User experience optimization