---
name: "config-sync:analyze-target-tool"
description: Analyze target tool's configuration capabilities
argument-hint: --target=<droid|qwen|codex|opencode>
---

## Task
Comprehensively analyze the target tool's configuration system, capabilities, and limitations to inform adaptation strategies.

## Analysis Requirements
1. Parse target specification:
   - Extract target tool from `--target` argument
   - Validate target tool is supported for analysis

2. Configuration discovery:
   - Scan target tool's directory structure
   - Identify configuration file locations and formats
   - Document existing configuration content

3. Capability assessment:
   - Analyze supported configuration features
   - Identify limitations and missing features
   - Document tool-specific syntax requirements

## Analysis Areas

### 1. Configuration File System
- File locations: Where configuration files are stored
- File formats: JSON, YAML, Markdown, etc.
- File naming conventions: Standard naming patterns
- Directory structure: Organization of config files
- Backup mechanisms: Automatic or manual backup support

### 2. Permission System Capabilities
- Permission model: How permissions are structured and enforced
- Permission granularity: File-level, command-level, etc.
- Permission categories: Allow/deny/ask or other models
- Security boundaries: Built-in safety mechanisms
- Permission inheritance: How permissions propagate

### 3. Command Format Support
- Command definition: How commands are specified and stored
- Frontmatter support: YAML/metadata block capabilities
- Argument handling: Parameter passing mechanisms
- Script execution: Supported script types and execution methods
- Command scope: Available commands and restrictions

### 4. Settings and Environment
- Environment variables: Support for env var configuration
- Settings hierarchy: How settings are prioritized and inherited
- Runtime configuration: Dynamic configuration changes
- Profile support: Multiple configuration profiles
- Setting validation: Built-in configuration validation

### 5. File Structure Requirements
- Directory permissions: Required access permissions
- File ownership: User/group ownership requirements
- Naming constraints: Forbidden characters or patterns
- Size limitations: File size or count restrictions
- Encoding requirements: Required text encoding

### 6. Integration Capabilities
- External tool integration: How other tools can be integrated
- API access: Available configuration APIs
- Hook system: Event-driven configuration updates
- Plugin architecture: Extensibility mechanisms
- Import/export: Configuration data exchange capabilities

## Known Tool Analysis

### Factory/Droid CLI
- Configuration files: `settings.json`, `config.json`
- Permission system: `commandAllowlist`/`commandDenylist`
- Command support: Compatible with Claude frontmatter format
- Settings: Model configuration, API settings, autonomy levels
- Limitations: No fine-grained permission categories (no 'ask')

### Qwen CLI
- Configuration files: `settings.json` (basic)
- Permission system: No formal permission system
- Command support: Unknown (needs investigation)
- Settings: Authentication, session management
- Limitations: Minimal configuration capabilities

### Codex CLI
- Configuration files: `version.json` (minimal)
- Permission system: No formal permission system
- Command support: Unknown (needs investigation)
- Settings: Very limited configuration
- Limitations: Minimal configuration support

## Analysis Methods

### File System Analysis
- Scan target tool directories for configuration files
- Analyze existing configuration content and structure
- Document file permissions and ownership patterns
- Identify configuration file formats and syntax

### Documentation Research
- Review tool documentation for configuration options
- Check for configuration guides and examples
- Identify best practices and recommendations
- Document any version-specific differences

### Testing and Validation
- Test configuration file acceptance and parsing
- Validate permission system behavior
- Check command format compatibility
- Verify setting application and persistence

## Output Requirements

### Capability Report
- Complete inventory of configuration capabilities
- Detailed analysis of supported features
- Documentation of limitations and constraints
- Recommendations for adaptation strategies

### Adaptation Guidelines
- Which Claude features can be directly transferred
- What requires modification or adaptation
- What cannot be supported and why
- Suggested workarounds for unsupported features

### Risk Assessment
- Security implications of configuration adaptations
- Potential for functionality loss or degradation
- Risks of overwriting existing configurations
- Mitigation strategies for identified risks

## Documentation Structure

### Executive Summary
- High-level overview of tool capabilities
- Key limitations and constraints
- Recommended adaptation approach
- Risk assessment summary

### Detailed Analysis
- Comprehensive breakdown of each analysis area
- Specific findings and recommendations
- Technical details and implementation notes
- Examples and best practices

### Appendices
- Configuration file examples
- Syntax reference guides
- Troubleshooting common issues
- Additional resources and references

## Quality Assurance
- Verify accuracy of analysis findings
- Test recommendations where possible
- Validate assumptions about tool behavior
- Review for completeness and correctness

## Error Handling
- Handle cases where target tool is not installed
- Deal with inaccessible configuration files
- Manage cases with insufficient permissions
- Provide clear guidance for analysis failures