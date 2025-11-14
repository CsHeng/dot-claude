---
file-type: command
command: /config-sync:analyze-target-tool
description: Analyze target tool configuration capabilities and adaptation requirements
implementation: commands/config-sync/adapters/analyze-target-tool.md
argument-hint: "--target=<droid|qwen|codex|opencode|amp>"
scope: Included
allowed-tools:
  - Read
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
  - skill:environment-validation
---

## usage

Analyze target AI tool configuration capabilities, limitations, and adaptation requirements for Claude configuration synchronization.

## arguments

- `--target`: Target AI tool to analyze
  - `droid`: Factory/Droid CLI with JSON configuration
  - `qwen`: Qwen CLI with TOML conversion and JSON manifests
  - `codex`: OpenAI Codex CLI with minimal configuration
  - `opencode`: OpenCode CLI with JSON commands and operation permissions
  - `amp`: Amp CLI with AGENTS.md integration and permission arrays

## workflow

1. Target Validation: Parse and validate target tool specification
2. Configuration Discovery: Scan directory structure and identify configuration formats
3. Capability Assessment: Analyze supported features and technical limitations
4. System Analysis: Evaluate configuration, permissions, and command handling
5. Integration Testing: Test configuration file acceptance and parsing behavior
6. Report Generation: Compile comprehensive analysis with adaptation recommendations
7. Documentation: Create detailed capability matrix and limitation summary

### analysis-areas

Configuration System:
- File locations, formats, naming conventions
- Configuration inheritance and hierarchy
- Runtime configuration capabilities
- Profile support and validation mechanisms

Permission Model:
- Permission structure, granularity, and categories
- Security boundaries and enforcement mechanisms
- Administrative interfaces and management tools
- Audit logging and monitoring capabilities

Command Format Support:
- Definition methods and frontmatter compatibility
- Argument handling and parameter processing
- Script execution and environment integration
- Command composition and workflow support

Integration Capabilities:
- External tool integration mechanisms
- API access and extensibility options
- Hook system and event-driven updates
- Plugin architecture and import/export capabilities

## output

Capability Analysis:
- Complete inventory of configuration capabilities
- Detailed feature-by-feature comparison matrix
- Limitation documentation with impact assessment
- Technical constraint analysis

Adaptation Guidelines:
- Direct transfer recommendations for compatible features
- Modification requirements for partial compatibility
- Workaround suggestions for unsupported capabilities
- Risk assessment for each adaptation approach

Implementation Strategy:
- Priority-based adaptation roadmap
- Resource requirement estimates
- Testing and validation procedures
- Rollback and recovery plans

## tool-capability-summaries

### factory-droid-cli
- Configuration: `settings.json`, `config.json` with JSON format
- Permissions: `commandAllowlist`/`commandDenylist` system
- Commands: Full Claude frontmatter compatibility
- Limitations: No fine-grained permission categories (no 'ask' level)

### qwen-cli
- Configuration: Basic `settings.json` with minimal options
- Permissions: JSON permission manifests with allow/ask/deny arrays
- Commands: TOML format conversion from Markdown required
- Dependencies: python3 for TOML processing, jq for JSON manipulation

### openai-codex-cli
- Configuration: Minimal `version.json` with basic settings
- Permissions: No formal permission system
- Commands: Basic Markdown format without frontmatter
- Limitations: Minimal configuration capabilities

### opencode-cli
- Configuration: `opencode.json` with structured settings
- Permissions: Operation-based system (edit/bash/webfetch)
- Commands: JSON format with template variables and external references
- Features: Advanced linking and lazy loading capabilities

### amp-cli
- Configuration: `~/.config/amp/settings.json` with amp. namespace
- Permissions: `amp.permissions` array with tool matching rules
- Commands: Markdown/executable format from `.agents/commands` or global directory
- Integration: Automatic AGENTS.md loading with hierarchical discovery

## quality-assurance

1. Accuracy Verification: Test configuration file acceptance and parsing
2. Feature Validation: Verify documented capabilities through practical testing
3. Limitation Confirmation: Confirm constraints through attempted operations
4. Integration Testing: Test external tool integration and API functionality

## examples

```bash
# Analyze Amp CLI capabilities
/config-sync:analyze-target-tool --target=amp

# Generate OpenCode adaptation analysis
/config-sync:analyze-target-tool --target=opencode

# Compare all target capabilities
/config-sync:analyze-target-tool --target=droid && \
/config-sync:analyze-target-tool --target=qwen && \
/config-sync:analyze-target-tool --target=codex
```

## error-handling

Target Validation Errors:
- Unsupported target: List supported platforms with descriptions
- Tool not installed: Provide installation guidance

Analysis Failures:
- Inaccessible directories: Document permission issues, suggest fixes
- Configuration parsing errors: Log specific format problems
- Feature testing failures: Document test environment requirements

Reporting Issues:
- Incomplete analysis: Identify missing information areas
- Conflicting findings: Highlight inconsistencies, recommend manual verification
