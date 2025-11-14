---
name: config-sync:codex
description: Execute OpenAI Codex CLI synchronization operations
argument-hint: --action=<sync|analyze|verify> --component=<rules,commands,settings,memory|all>
allowed-tools:
- Read
- Write
- Bash
- Bash(ls:*)
- Bash(fd:*)
- Bash(cat:*)
is_background: false
disable-model-invocation: true
related-commands:
- /config-sync/sync-cli
related-agents:
- agent:config-sync
related-skills:
- skill:workflow-discipline
- skill:automation-language-selection
- skill:security-logging
---

## usage

Execute OpenAI Codex CLI synchronization operations with basic Markdown format conversion and sandbox-based permission configuration.

## arguments

- `--action`: Operation mode
  - `sync`: Complete synchronization of components
  - `analyze`: Analyze current configuration state
  - `verify`: Validate synchronization completeness
- `--component`: Components to process (comma-separated or `all`)
  - `rules`: Rule file synchronization
  - `commands`: Command file conversion to basic format
  - `settings`: Codex-specific configuration generation
  - `memory`: Memory file integration and reference management
  - `all`: All components (default)

## workflow

1. Parameter Validation: Parse action and component specifications
2. Codex Analysis: Examine existing Codex CLI configuration state
3. Component Processing: Apply operations to specified components
4. Format Simplification: Convert Claude features to basic Markdown
5. Permission Setup: Configure sandbox-based access controls
6. Verification: Validate synchronization completeness and integrity

### codex-cli-constraints

Format Limitations:
- Basic Markdown only, no YAML frontmatter
- Reduced feature set compared to Claude
- Simplified command structure
- Minimal configuration capabilities

Permission Model:
- Three-tier sandbox structure
- Basic access level controls
- No fine-grained permission categories
- API key authentication required

Component Adaptations:
- Strip YAML frontmatter from commands
- Simplify rule content structure
- Generate minimal settings.json
- Update memory references for basic format

### component-processing

Rules Component:
- Convert to basic Markdown format
- Remove Claude-specific features
- Preserve core technical content
- Update memory references

Commands Component:
- Remove YAML frontmatter completely
- Simplify command descriptions
- Maintain basic functionality
- Preserve execution logic

Settings Component:
- Generate minimal version.json
- Configure basic settings only
- Strip complex permission models
- Maintain essential functionality

Memory Component:
- Simplify memory file references
- Remove complex cross-references
- Update for basic format compatibility
- Preserve essential guidance

## output

Generated Files:
- Basic Markdown format command files
- Simplified rule files without frontmatter
- Minimal Codex configuration files
- Updated memory references

Verification Reports:
- Component synchronization status
- Format conversion validation results
- Feature simplification summary
- Compatibility assessment

Quality Metrics:
- Feature reduction impact analysis
- Functionality preservation verification
- Format compliance validation
- Integration capability assessment

## safety-constraints

1. Feature Simplification: Remove only non-essential Claude features
2. Functionality Preservation: Maintain core command capabilities
3. Format Validation: Ensure generated files meet Codex requirements
4. Minimal Configuration: Generate only essential settings

## examples

```bash
# Complete Codex synchronization
/config-sync:codex --action=sync --component=all

# Convert commands to basic format
/config-sync:codex --action=sync --component=commands

# Analyze Codex configuration requirements
/config-sync:codex --action=analyze

# Verify synchronization completeness
/config-sync:codex --action=verify --component=rules,commands
```

## error-handling

Format Conversion Errors:
- Complex frontmatter parsing failures: Skip files, log detailed errors
- Feature simplification conflicts: Document specific issues
- Markdown validation problems: Generate syntax error reports

Configuration Issues:
- Minimal generation failures: Document missing requirements
- API authentication problems: Provide setup guidance
- Directory access permission errors: Suggest manual fixes

Integration Problems:
- Memory reference conflicts: Update for basic format compatibility
- Command functionality loss: Identify critical features removed
- Verification failures: Provide detailed remediation steps
