---
file-type: command
command: /config-sync:adapt-commands
description: Adapt Claude commands for universal tool compatibility across AI platforms
implementation: commands/config-sync/adapters/adapt-commands.md
argument-hint: "--target=<droid|qwen|codex|opencode|amp>"
scope: Included
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
  - skill:environment-validation
---

## usage

Execute conversion of Claude command specifications to target-specific formats for universal AI tool compatibility.

## arguments

- `--target`: Target AI tool platform
  - `droid`: Factory/Droid CLI adaptation
  - `qwen`: Qwen CLI adaptation
  - `codex`: OpenAI Codex CLI adaptation
  - `opencode`: OpenCode CLI adaptation
  - `amp`: Amp CLI adaptation

## workflow

1. Command Inventory: Scan `commands/` directory and categorize by functionality
2. Target Validation: Verify target tool compatibility and requirements
3. Structure Analysis: Review frontmatter and argument handling patterns
4. Compatibility Assessment: Identify Claude-specific features requiring adaptation
5. Universal Adaptation: Apply target-specific transformations
6. Output Generation: Create adapted command files with validation
7. Quality Assurance: Verify syntax, structure, and functionality preservation

### adaptation-rules

Frontmatter Processing:
- Keep: `description`, `argument-hint`, `related-commands`
- Remove: `allowed-tools`, Claude-specific keys
- Preserve: Core metadata required by target platform

Argument Handling:
- Universal: Use `$ARGUMENTS` for argument passing
- Exception: OpenCode supports `$1`, `$2` positional arguments
- Maintain: Command-line interface compatibility

Reference Updates:
- Replace: `@CLAUDE.md` with target tool memory files
- Update: Internal command references to target format
- Preserve: Cross-command dependencies and workflows

Functionality Preservation:
- Maintain: Core task logic and instruction sequences
- Preserve: Validation steps and error handling patterns
- Ensure: Tool-agnostic execution capabilities

### target-specific-adaptations

Amp CLI Special Handling:
- Global commands: `~/.config/amp/commands/`
- Workspace commands: `.agents/commands/`
- Reference updates: `@CLAUDE.md` → `@AGENTS.md`
- Permission preservation: Maintain executable permissions

OpenCode Format Support:
- Dual format: JSON and markdown compatibility
- Template variables: Adapt to OpenCode variable system
- Operation mapping: Map Claude tools to OpenCode operations

## output

Generated Files:
- Target-compatible command specifications
- Preserved functionality with platform-specific adaptations
- Backup files of existing commands when applicable

Documentation:
- Compatibility report with detailed change mappings
- Adaptation limitations and workarounds
- Testing instructions for each target tool

Quality Reports:
- Syntax validation results
- Structure verification outcomes
- Functionality preservation verification

## quality-assurance

1. Syntax Validation:
   - Ensure modified frontmatter is valid YAML/JSON
   - Validate command reference accuracy
   - Check argument handling compatibility

2. Functionality Testing:
   - Verify commands maintain original purpose
   - Validate preserved validation steps
   - Test error handling effectiveness

3. Compatibility Verification:
   - Test with target tool command parser
   - Verify frontmatter compliance
   - Check argument processing accuracy

## safety-constraints

1. Backup Creation: Generate backups before overwriting existing commands
2. Permission Preservation: Maintain executable permissions for shell commands
3. Dependency Validation: Ensure target tool requirements are met
4. Rollback Capability: Keep original files for recovery if adaptation fails
5. Security Preservation: Never introduce security vulnerabilities during adaptation

## examples

```bash
# Adapt commands for Droid CLI
/config-sync:adapt-commands --target=droid

# Generate Amp CLI compatible commands
/config-sync:adapt-commands --target=amp

# Create OpenCode dual-format commands
/config-sync:adapt-commands --target=opencode
```

## error-handling

Target Validation Errors:
- Unsupported target: List supported platforms and exit
- Missing dependencies: Specify required tools and exit

Processing Errors:
- Invalid frontmatter: Log file and continue with minimal adaptation
- Command parsing failure: Skip problematic file, log error
- File permission issues: Exit with specific error details

Quality Assurance Failures:
- Syntax validation failure: Generate report, continue with warnings
- Functionality loss detected: Highlight changes, require confirmation
- Compatibility issues: Document limitations, provide workarounds
