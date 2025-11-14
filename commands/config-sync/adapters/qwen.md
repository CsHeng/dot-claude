---
command: /config-sync:qwen
description: Qwen CLI specific operations with TOML conversion and JSON permission manifests
argument-hint: "--action=<sync|analyze|verify> --component=<rules,commands,settings,memory|all>"
allowed-tools:
  - Read
  - Write
  - Bash
  - Bash(python3:*)
  - Bash(jq:*)
  - Bash(ls:*)
  - Bash(fd:*)
  - Bash(cat:*)
disable-model-invocation: true
related-commands:
  - /config-sync/sync-cli
related-agents:
  - agent:config-sync
related-skills:
  - skill:automation-language-selection
  - skill:workflow-discipline
---

## usage

Execute Qwen CLI synchronization operations with TOML format conversion from Markdown commands and JSON permission manifest generation.

## arguments

- `--action`: Operation mode
  - `sync`: Complete synchronization of components
  - `analyze`: Analyze current configuration state
  - `verify`: Validate synchronization completeness
- `--component`: Components to process (comma-separated or `all`)
  - `rules`: Rule file synchronization
  - `commands`: TOML format conversion from Markdown
  - `settings`: Qwen-specific configuration generation
  - `memory`: Memory file integration and reference management
  - `all`: All components (default)

## workflow

1. Parameter Parsing: Extract action and component specifications
2. Tool Validation: Verify python3 and jq availability
3. Qwen Analysis: Examine existing Qwen CLI configuration
4. Content Conversion: Convert Claude formats to Qwen-compatible formats
5. TOML Processing: Convert command files to TOML format
6. Permission Setup: Generate JSON permission manifests
7. Verification: Validate synchronization completeness

### qwen-cli-features

Format Requirements:
- Command Format: TOML conversion from Markdown required
- Permissions: JSON permission manifests with allow/ask/deny arrays
- Dependencies: python3 for TOML processing, jq for JSON manipulation
- Conversion Required: Automatic format transformation from Claude structures

Component Processing:
- Rules: Direct sync to Qwen rules directory
- Commands: Convert from Markdown to TOML format
- Settings: Generate Qwen-specific configuration files
- Memory: Configure AGENTS.md and QWEN.md references
- Permissions: Convert to JSON permission manifests

### implementation-requirements

Tool Dependencies:
- python3: Required for content conversion and TOML processing
- jq: Required for settings updates and JSON processing

Directory Structure:
- Source: `$HOME/.claude/` (Claude configuration)
- Target: `$HOME/.qwen/` (Qwen CLI configuration)

### conversion-process

Command Conversion:
- Extract command metadata from YAML frontmatter
- Convert to TOML format with proper syntax
- Preserve functionality and argument handling
- Validate TOML structure before writing

Rule Processing:
- Remove YAML frontmatter from rule files
- Preserve content structure and organization
- Update memory references for Qwen compatibility
- Maintain rule cross-references

## output

Generated Files:
- TOML format command files
- Synchronized rules and settings in Qwen directories
- JSON permission configurations
- Updated memory references

Processing Reports:
- Conversion summary with success/failure counts
- TOML validation results
- Permission mapping analysis
- Dependency verification status

Quality Metrics:
- Format conversion accuracy verification
- Feature preservation assessment
- Integration capability validation

## safety-constraints

1. Dependency Validation: Verify python3 and jq availability before processing
2. Format Validation: Ensure generated TOML files are syntactically correct
3. Backup Creation: Create backups before overwriting existing configurations
4. Atomic Operations: Use temporary files and atomic moves to prevent corruption

## examples

```bash
# Complete Qwen CLI synchronization
/config-sync:qwen --action=sync --component=all

# Convert commands to TOML format
/config-sync:qwen --action=sync --component=commands

# Generate permission manifests
/config-sync:qwen --action=sync --component=permissions

# Verify synchronization completeness
/config-sync:qwen --action=verify
```

## error-handling

Dependency Errors:
- Missing python3: Exit with installation guidance
- Missing jq: Exit with installation instructions
- Tool version incompatibility: Document requirements

Conversion Errors:
- TOML syntax failures: Log specific errors, skip problematic files
- Frontmatter parsing problems: Document issues, continue with available content
- Permission mapping conflicts: Apply conservative defaults

File System Errors:
- Directory creation failures: Exit with permission details
- File write permission errors: Document access issues
- Backup creation problems: Abort before making changes
