
## Usage

Reference documentation for the doc-gen plugin system. View architecture documentation workflows, component organization, and integration guidelines.

## Arguments

None - This is a documentation file. Use `/doc-gen:bootstrap` for operations.

## Workflow

1. Read plugin architecture and component organization
2. Identify project-type specific adapter requirements
3. Reference shared conventions and standards
4. Follow integration guidelines for new project types

## Output

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
├── lib/                        # Shared automation helpers (shell libraries, etc.)
└── settings.json               # Default runtime configuration
```

### component-responsibilities

Core Orchestrator:
- Input gathering and validation
- Output format enforcement
- Adapter delegation and coordination
- Deliverable verification and validation

Project-Type Adapters:
- Domain-specific documentation guidance
- Industry standard conventions
- Technology-specific patterns
- Asset generation templates

Shared Library:
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

Bootstrap Mode:
- Generate complete documentation structure
- Create initial asset templates
- Output to `docs-bootstrap/` directory
- Preserve existing `docs/` content

Maintain Mode:
- Update existing documentation
- Synchronize with current project state
- Operate on `docs/` directory directly
- Incremental updates and validations

### workflow-features

Consolidated Checklists:
- Mode selection guidance
- Project-type validation
- Language configuration
- Path auto-suggestion and validation

Deliverable Enforcement:
- Parameter summary tables
- Asset count verification
- Actor matrix generation
- PlantUML validation results
- TODO backlog management

## shared-conventions

### Logging Standards

- Headings: `=== Stage` for major phases, `--- Detail` for supporting notes.
- Status prefixes: `SUCCESS:`, `ERROR:`, `WARNING:`, `INFO:` to keep adapter logs machine-friendly.
- Message example:

```
=== Stage Name
--- Context for the stage
SUCCESS: Action completed successfully
```

### Template Structures

Parameter summary table:

```markdown
| Parameter      | Value |
| -------------- | ----- |
| Mode           | [bootstrap|maintain] |
| Project Type   | [project-type] |
| Language       | [language] |
| Repository     | [repo-path] |
| Core Path      | [core-path] |
| Docs Target    | [docs-path] |
| Demo Path      | [demo-path or n/a] |
```

TODO format:
- Prefix every actionable item with `TODO(doc-gen):`.
- Include repository-relative path in parentheses.

Example: `TODO(doc-gen): document authentication flow (docs/architecture/auth.md)`

Actor matrix template:

```markdown
| Actor | Role | Code references | Notes |
| --- | --- | --- | --- |
| End User | Primary system user | app/src/.../MainActivity.kt | Main persona |
| Admin User | System administration | admin/src/.../AdminController.java | Privileged access |
| API Client | External integration | api/src/.../ClientService.php | Third-party access |
| System Service | Background processing | services/src/.../Worker.go | Automated tasks |
```

### Diagram Validation

PlantUML checklist:
1. Store diagrams under `docs/diagrams/` with consistent naming/alias registry.
2. Run `plantuml --check-syntax <diagram-file>` and capture the output.
3. Record validation status in project docs; describe unresolved warnings.

Standards:
- Every diagram must pass syntax validation and include legends for complex notation.
- Maintain consistent styling and descriptive aliases.

### Asset Management

Inventory helpers:

```bash
find <docs> -name "*.md" -type f | wc -l     # Markdown count
find <docs> -name "*.puml" -type f | wc -l    # PlantUML count
```

Checklist:
- Track significant docs assets with relative paths.
- Distinguish generated vs manual content.
- Verify all references exist and counts match expectations.

### Quality Assurance

Consistency checks:
1. Format compliance with templates above.
2. Naming conventions aligned across adapters.
3. Cross-reference validation for internal links.
4. Content completeness for required sections.

Validation procedures:
- Document pass/fail criteria for each adapter deliverable (tables, actor matrix, TODO backlog, diagram validation summary).
- Capture QA notes in the generated README output so `/doc-gen:bootstrap` runs leave an audit trail.

## integration-guidelines

### adding-project-types

1. Create adapter file in `adapters/` directory
2. Follow established template structure
3. Implement project-type specific guidance
4. Register adapter in orchestrator
5. Test integration with core workflow

### adapter-development

Required Sections:
- Project-type specific conventions
- Industry standard patterns
- Technology-specific requirements
- Asset generation guidelines
- Validation criteria

Integration Points:
- Core orchestrator delegation
- Shared library utilization
- Parameter handling standards
- Output format compliance

## agent-integration

| Agent | Commands | Default Skills | Optional Skills |
| --- | --- | --- | --- |
| `agent:doc-gen` | `/doc-gen:bootstrap`, `/doc-gen:maintain` | `skill:workflow-discipline`, `skill:security-logging` | `skill:language-python`, `skill:language-go`, `skill:architecture-patterns` |

## quality-standards

Documentation Quality:
- Comprehensive coverage of project components
- Consistent formatting and structure
- Clear navigation and cross-references
- Regular maintenance and updates

Process Validation:
- Input parameter validation
- Output format verification
- Asset completeness checks
- Integration testing results

Conformance Assurance:
- Industry standard compliance
- Technology-specific best practices
- Organizational guideline adherence
- User experience optimization
