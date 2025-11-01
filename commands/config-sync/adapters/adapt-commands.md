---
name: "config-sync:adapt-commands"
description: Adapt Claude commands for universal tool compatibility
argument-hint: --target=<droid|qwen|codex|opencode>
---

## Task
Analyze Claude custom commands and adapt them for universal compatibility across all target tools.

## Analysis Requirements
1. Inventory Claude commands:
   - Scan `commands/*.md` for all custom commands
   - Categorize commands by type and complexity
   - Identify command dependencies and requirements

2. Parse target specification:
   - Extract target tool from `--target` argument
   - Validate target tool compatibility

3. Command structure analysis:
   - Review frontmatter format and supported keys
   - Analyze argument handling patterns
   - Identify Claude-specific features and syntax

4. Universal compatibility assessment:
   - Keep `---` frontmatter blocks (widely supported)
   - Remove `allowed-tools` parameter (Claude-specific)
   - Use `$ARGUMENTS` instead of positional parameters (or `$1`, `$2` for OpenCode)
   - Update tool references (`@CLAUDE.md` → `@TOOL.md` or `@AGENTS.md` for OpenCode)

## Adaptation Rules

### Frontmatter Changes
- Keep: `description`, `argument-hint`
- Remove: `allowed-tools`, Claude-specific parameters
- Format: Maintain YAML frontmatter with `---` delimiters

### Content Adaptations
- Arguments: Replace `$1`, `$2`, etc. with `$ARGUMENTS` (except for OpenCode which supports `$1`, `$2`)
- Tool references: Update `@CLAUDE.md` to target tool's memory file
- Rule references: Keep `@rules/` references (universal)
- Template variables: Support OpenCode variables like `$ARGUMENTS`, `$1`, `$2`, `@filename`, `!command`
- Validation: Preserve syntax checking and quality gates

### Command Categories and Adaptations

#### Shell Script Commands
- Keep bash/zsh syntax validation steps
- Preserve error handling and traps
- Ensure script paths work in target environment

#### Git Commands
- Maintain repository operation safety
- Preserve commit message drafting logic
- Keep branch and status checking

#### Development Tool Commands
- Adapt tool-specific commands to target environment
- Preserve validation and verification steps
- Maintain code quality checks

## Content Processing Logic

### For each command file:
1. Parse frontmatter:
   - Extract supported keys
   - Remove Claude-specific parameters
   - Preserve core metadata

2. Analyze command body:
   - Identify argument usage patterns
   - Find tool-specific references
   - Locate validation steps

3. Apply adaptations:
   - Update argument handling to use `$ARGUMENTS`
   - Replace `@CLAUDE.md` with `@TOOL.md`
   - Remove or adapt Claude-specific features

4. Preserve functionality:
   - Maintain core task logic and instructions
   - Keep validation steps and error handling
   - Ensure tool-agnostic execution patterns

## Quality Assurance Requirements
1. Syntax validation:
   - Ensure modified frontmatter is valid YAML
   - Check that command references are correct
   - Validate that argument handling works

2. Functionality testing:
   - Verify commands maintain original purpose
   - Check that validation steps still work
   - Ensure error handling remains effective

3. Compatibility verification:
   - Test with target tool's command parser
   - Verify frontmatter compatibility
   - Check argument processing works correctly

## Output Requirements

### File Generation
- Create adapted command files in target tool's directory
- Maintain original file structure and naming
- Generate backup of existing commands if present
- For OpenCode: Support dual format (JSON/markdown) and template variable adaptation

### Documentation
- Document all changes made to each command
- Explain any functionality modifications
- Provide compatibility notes for each target tool
- List any commands that couldn't be adapted

### Verification
- Generate command compatibility report
- Provide testing instructions for each command
- Create troubleshooting guide for common issues

## Error Handling
- Handle commands that cannot be adapted gracefully
- Provide clear explanations for adaptation failures
- Generate fallback options where possible
- Document limitations and workarounds

## Special Considerations
- Security: Ensure adaptations don't introduce security vulnerabilities
- Dependencies: Check for tool-specific dependencies and adapt accordingly
- Performance: Maintain or improve command execution efficiency
- Usability: Preserve user-friendly command interfaces