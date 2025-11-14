---
name: "command:config-sync:codex"
description: "Execute OpenAI Codex CLI synchronization operations"
argument-hint: "--action=<sync|analyze|verify> --component=<rules,commands,settings,memory|all>"
allowed-tools:
  - Read
  - Write
  - Bash
  - Bash(ls:*)
  - Bash(find:*)
  - Bash(cat:*)
is_background: false
required-skills:
  - skill:workflow-discipline
  - skill:tooling-code-tool-selection
  - skill:security-logging
---

## Usage
```bash
/config-sync:codex --action=<sync|analyze|verify> --component=<rules,commands,settings,memory|all>
```

## Arguments
- `--action`: Operation mode (sync, analyze, verify)
- `--component`: Target components (rules, commands, settings, memory, all)

## DEPTH Workflow

### D - Decomposition
- Objective: Execute Codex CLI synchronization operations
- Scope: Configuration, rules, commands, memory components
- Output: Synchronized files and verification reports
- Reference: rules/20-tool-standards.md

### E - Explicit Reasoning
- Command Execution: Execute specified action on target components
- Format Conversion: Convert Claude features to basic formats
- Permission Setup: Configure sandbox-based access levels
- Verification: Validate synchronization completeness

### P - Parameters
- Action Types: sync (complete), analyze (examine), verify (validate)
- Component Sets: Individual or all components
- Format Target: Basic Markdown without YAML frontmatter
- Permission Model: Three-tier sandbox structure

### T - Test Cases
- Failure Case: Invalid action → Error with valid options
- Failure Case: Invalid component → Error with component list
- Success Case: Valid parameters → Execute synchronization
- Edge Case: Mixed components → Process each appropriately

### H - Heuristics
- Fail Fast: Validate parameters before execution
- Minimal Surface: Convert only essential features
- Deterministic Output: Consistent results for same inputs
- Safe Operations: Maintain system integrity during sync

## Workflow
1. Parameter Validation: Parse and validate action and component arguments
2. Codex Analysis: Examine existing Codex CLI configuration state
3. Component Processing: Apply specified operations to target components
4. Format Simplification: Convert Claude-specific features to basic formats
5. Permission Configuration: Setup sandbox-based access levels
6. Verification: Validate synchronization completeness and integrity

## Output
- Synchronization Status: PASS/FAIL with component details
- Generated Files: Basic Markdown format files
- Configuration Updates: Minimal Codex settings
- Verification Reports: Component synchronization validation
- Error Logs: Issues encountered during processing

## Configuration Constraints
- Format Limits: Basic Markdown only, no YAML frontmatter
- Permission Model: Sandbox-based three-tier structure
- Feature Set: Reduced functionality compared to Claude
- Authentication: API key required

## Safety Constraints
1. Feature Simplification: Remove complex Claude features
2. Permission Documentation: Document sandbox limitations
3. Minimal Configuration: Generate essential settings only
4. Integrity Preservation: Maintain core functionality