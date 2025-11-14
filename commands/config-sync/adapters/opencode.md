---
command: /config-sync:opencode
description: OpenCode CLI operations with JSON command conversion and operation-based permissions
argument-hint: "--action=<sync|analyze|verify> --component=<rules,permissions,commands,settings,memory|all>"
allowed-tools:
  - Read
  - Write
  - Bash
  - Bash(ls:*)
  - Bash(fd:*)
  - Bash(cat:*)
disable-model-invocation: true
related-commands:
  - /config-sync/sync-cli
related-agents:
  - agent:config-sync
related-skills:
  - skill:workflow-discipline
  - skill:security-logging
---

## usage

Execute OpenCode CLI synchronization with JSON command conversion, operation-based permissions, and external reference management.

## arguments

- `--action`: Operation mode
  - `sync`: Complete synchronization of components
  - `analyze`: Analyze current configuration state
  - `verify`: Validate synchronization completeness
- `--component`: Components to process (comma-separated or `all`)
  - `rules`: Rule file synchronization
  - `permissions`: Operation-based permission configuration
  - `commands`: JSON command conversion from Markdown
  - `settings`: OpenCode-specific configuration generation
  - `memory`: AGENTS.md integration and reference management
  - `all`: All components (default)

## workflow

1. Parameter Validation: Parse action and component specifications
2. OpenCode Analysis: Examine existing OpenCode configuration
3. Component Processing: Apply operations to specified components
4. JSON Conversion: Transform Markdown commands to structured JSON format
5. Permission Mapping: Convert to operation-based permission controls
6. External References: Configure file linking and lazy loading
7. Verification: Validate synchronization completeness

### opencode-cli-features

Command Format:
- Structured JSON command definitions
- Template variables ($1, $2, @filename, !command)
- External reference support with lazy loading

Permission System:
- Operation-based permissions (edit, bash, webfetch, read)
- Less granular but configurable JSON permission settings
- Category-based access control

Integration Features:
- AGENTS.md as primary memory reference
- External file linking for organization
- Enhanced instruction arrays support

### component-processing

Rules Component:
- Direct sync with OpenCode-compatible formatting
- Update memory references to AGENTS.md
- Maintain rule structure and organization

Commands Component:
- Convert Markdown to JSON structured format
- Preserve functionality while adapting structure
- Configure template variables and external references

Settings Component:
- Generate opencode.json with OpenCode configuration
- Configure operation-based permissions
- Set up external reference parameters

Memory Component:
- Configure AGENTS.md as primary reference
- Update all memory file links and cross-references
- Enhance external linking capabilities

### operation-permissions

Permission Categories:
- edit: File modification operations
- bash: Command execution operations
- webfetch: Web content retrieval operations
- read: Read-only operations

Mapping Strategy:
- File editing commands → edit permission
- Shell execution commands → bash permission
- Network operations → webfetch permission
- Analysis commands → read permission

### special-features

External References:
- Lazy loading for performance optimization
- File linking for reference organization
- Instruction arrays for complex operations

Template Variables:
- Positional arguments ($1, $2)
- File references (@filename)
- Command execution (!command)

## output

Generated Files:
- JSON command definitions with structured format
- Synchronized rules and settings in OpenCode directories
- Operation-based permission configurations
- External reference link configurations

Verification Reports:
- Component-by-component synchronization status
- JSON conversion validation results
- Permission mapping analysis
- External reference integrity check

Integration Documentation:
- AGENTS.md enhancement summary
- External reference organization guide
- Template variable usage documentation

## safety-constraints

1. Format Conversion: Validate JSON structure and syntax
2. Permission Conservation: Apply conservative mapping for uncertain operations
3. Reference Integrity: Ensure all external links remain valid
4. Template Validation: Verify template variable compatibility

## examples

```bash
# Complete OpenCode synchronization
/config-sync:opencode --action=sync --component=all

# Convert commands to JSON format
/config-sync:opencode --action=sync --component=commands

# Configure operation-based permissions
/config-sync:opencode --action=sync --component=permissions

# Set up external references
/config-sync:opencode --action=sync --component=memory
```

## error-handling

Conversion Errors:
- Invalid JSON generation: Log syntax errors, skip problematic files
- Template variable conflicts: Document incompatible patterns
- External reference failures: Generate broken link reports

Permission Issues:
- Mapping ambiguities: Apply conservative defaults, document choices
- Operation categorization conflicts: Flag for manual review
- Configuration validation failures: Provide detailed error reports

Integration Problems:
- AGENTS.md loading issues: Verify file permissions and paths
- External link validation: Document broken references
- Template processing errors: Suggest manual corrections
