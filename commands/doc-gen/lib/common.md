---
name: doc-gen:lib-common
description: Shared conventions and formatting standards for doc-gen adapters
argument-hint: ''
allowed-tools: []
is_background: false
related-commands:
- /doc-gen:bootstrap
related-agents:
- agent:doc-gen
related-skills:
- skill:workflow-discipline
disable-model-invocation: true
---

## Usage

Reference documentation for shared conventions used across doc-gen adapters to maintain consistency and standardization without external rule dependencies.

## Arguments

None - This is a conventions reference file.

## Workflow

1. Reference logging standards for consistent output formatting
2. Apply parameter summary table templates for documentation
3. Use TODO format specifications for actionable items
4. Follow actor matrix template for stakeholder documentation
5. Implement PlantUML validation procedures for diagram quality
6. Use inventory checklist for asset management and verification

## Output

Complete convention specifications including:
- Logging format standards and message patterns
- Template structures for tables and matrices
- Validation procedures for diagrams and assets
- Formatting guidelines for consistent documentation
- Quality assurance checklists and verification criteria

## logging-standards

### message-formatting

Heading Hierarchy:
- Use `=== Stage` for high-level section headings
- Use `--- Detail` for sub-items and detailed information

Status Prefixes:
- `SUCCESS:` Prefix for successful action completion
- `ERROR:` Prefix for error conditions and failures
- `WARNING:` Prefix for cautionary information
- `INFO:` Prefix for informational messages

Message Structure:
```
=== Stage Name
--- Detail information about the stage
SUCCESS: Action completed successfully
ERROR: Description of error condition
```

## template-structures

### parameter-summary-table

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

### todo-format-specification

Required Format:
- Every actionable item must start with `TODO(doc-gen):`
- Append repository-relative path in parentheses
- Include specific component or file reference

Examples:
```markdown
TODO(doc-gen): document authentication flow (docs/architecture/auth.md)
TODO(doc-gen): create API endpoint documentation (docs/api/endpoints.md)
TODO(doc-gen): review dependency injection patterns (src/main/java/com/example/di/)
```

### actor-matrix-template

```markdown
| Actor | Role | Code references | Notes |
| --- | --- | --- | --- |
| End User | Primary system user | app/src/.../MainActivity.kt | Main persona |
| Admin User | System administration | admin/src/.../AdminController.java | Privileged access |
| API Client | External integration | api/src/.../ClientService.php | Third-party access |
| System Service | Background processing | services/src/.../Worker.go | Automated tasks |
```

## diagram-validation

### plantuml-procedures

File Organization:
- Store diagrams under selected docs directory (`docs/diagrams/`)
- Maintain alias registry at top of each diagram
- Use consistent naming conventions

Validation Process:
1. Run syntax validation: `plantuml --check-syntax <diagram-file>`
2. Capture validation output string
3. Place validation results in README under PlantUML section
4. Document any syntax issues or warnings

Quality Standards:
- All diagrams must pass syntax validation
- Include descriptive aliases and comments
- Maintain consistent styling across diagrams
- Provide legend for complex notations

## asset-management

### inventory-checklist

File Counting:
```bash
# Count markdown files
find <docs> -name "*.md" -type f | wc -l

# Count PlantUML files
find <docs> -name "*.puml" -type f | wc -l
```

Asset Documentation:
- List significant documentation assets with relative paths
- Include README files, ADRs, flow charts
- Document generated vs. manual assets
- Track asset dependencies and relationships

Verification Criteria:
- All referenced files exist and are accessible
- Asset counts match expected totals
- Cross-references are valid and current
- Generated content follows template standards

## quality-assurance

### consistency-checks

1. Format Compliance: Verify all templates follow specified structures
2. Naming Conventions: Ensure consistent file and component naming
3. Cross-Reference Validation: Check all internal links and references
4. Content Completeness: Validate all required sections are present

### validation-procedures

1. Template Usage: Confirm proper application of all template formats
2. Syntax Verification: Validate PlantUML and structured data formats
3. Accessibility Check: Ensure documentation is navigable and understandable
4. Integration Testing: Verify adapter compatibility with shared standards

## error-handling

### validation-failures

Template Format Issues:
- Document specific formatting violations
- Provide correction examples
- Flag for manual review and correction

Asset Validation Problems:
- List missing or inaccessible files
- Document broken references
- Suggest correction strategies

PlantUML Syntax Errors:
- Capture specific syntax error messages
- Provide corrected diagram examples
- Document common syntax issues and solutions
