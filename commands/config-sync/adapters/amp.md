---
file-type: command
command: /config-sync:amp
description: Amp CLI operations with AGENTS.md integration and amp.permissions configuration
implementation: commands/config-sync/adapters/amp.md
argument-hint: "--action=<sync|analyze|verify> --component=<rules,permissions,commands,settings,memory|all>"
scope: Included
allowed-tools:
  - Read
  - Write
  - Bash
  - Bash(ls:*)
  - Bash(find:*)
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

Execute Amp CLI synchronization operations with AGENTS.md integration and amp.permissions configuration management.

## arguments

- `--action`: Operation mode
  - `sync`: Complete synchronization of components
  - `analyze`: Analyze current configuration state
  - `verify`: Validate synchronization completeness
- `--component`: Components to process (comma-separated or `all`)
  - `rules`: Rule file synchronization
  - `permissions`: amp.permissions array configuration
  - `commands`: Command file adaptation and placement
  - `settings`: Baseline settings.json generation
  - `memory`: AGENTS.md integration and memory management
  - `all`: All components (default)

## workflow

1. Parameter Validation: Parse action and component arguments
2. Amp Environment Analysis: Examine existing Amp CLI configuration
3. Component Processing: Apply specified operation to components
4. AGENTS.md Integration: Configure agent loading and memory management
5. Permission Setup: Configure amp.permissions array in settings.json
6. Command Adaptation: Update references for Amp CLI environment
7. Verification: Validate synchronization completeness and correctness

### amp-cli-features

Memory Management:
- Automatic AGENTS.md loading from workspace and config directories
- Global memory support via `$HOME/.config/AGENTS.md`
- Subtree-specific AGENTS.md file handling

Command Storage:
- Workspace commands: `.agents/commands/`
- Global commands: `~/.config/amp/commands/`
- Executable permission preservation

Configuration Namespace:
- All settings use `amp.` prefix in settings.json
- Integrated permission system with amp.permissions array
- MCP server and tool timeout configuration

### component-processing

Rules Component:
- Mirror `~/.claude/rules` to `~/.config/amp/rules`
- Update memory references to AGENTS.md
- Maintain rule structure and organization

Commands Component:
- Copy commands excluding config-sync modules
- Update `.claude/commands` references to `.agents/commands`
- Replace `@CLAUDE.md` with `@AGENTS.md` references
- Preserve executable permissions

Permissions Component:
- Convert Claude allow/ask/deny to ordered amp.permissions entries
- Apply conservative mapping (ask → reject, allow → allow with conditions)
- Append fallback `{"tool":"*", "action":"ask"}` rule
- Maintain deterministic rule ordering

Memory Component:
- Configure AGENTS.md references throughout synchronized files
- Create `$HOME/.config/AGENTS.md` global copy
- Update memory file links and cross-references

## output

Generated Files:
- Synchronized rules, commands, settings in Amp directories
- AGENTS.md integration with proper references
- amp.permissions array with ordered security rules
- Backup files of existing configurations

Verification Reports:
- Component-by-component synchronization status
- Permission mapping summary with security analysis
- Reference validation results
- Integration completeness assessment

Action Summary:
- Detailed log of all changes made during operation
- File modification tracking with timestamps
- Security impact assessment for permission changes
- Recommendations for ongoing maintenance

## integration-guidelines

Reference Updates:
- Prefer `@AGENTS.md` over `@CLAUDE.md` in synchronized files
- Update command references from `.claude/commands` to appropriate Amp paths
- Maintain backward compatibility with symlink support where needed

Permission Mapping:
- Apply conservative security approach
- Maintain rule ordering for proper evaluation
- Include fallback rules for unmatched operations
- Document all permission transformations

Memory Management:
- Leverage Amp's automatic AGENTS.md loading capabilities
- Configure both workspace and global memory locations
- Maintain consistency across all memory references

## safety-constraints

1. Backup Creation: Generate backups before modifying existing configurations
2. Permission Conservation: Apply conservative mapping to maintain security
3. Reference Validation: Verify all memory references remain valid
4. Rule Ordering: Maintain deterministic order for permission evaluation
5. Integration Testing: Validate AGENTS.md loading and command functionality

## examples

```bash
# Complete Amp CLI synchronization
/config-sync:amp --action=sync --component=all

# Analyze current Amp configuration
/config-sync:amp --action=analyze

# Update permissions only
/config-sync:amp --action=sync --component=permissions

# Verify synchronization completeness
/config-sync:amp --action=verify --component=commands,rules
```

## error-handling

Configuration Errors:
- Missing Amp directories: Create with proper permissions
- Invalid settings.json format: Backup and regenerate with valid structure
- Permission modification failures: Log detailed error, attempt rollback

Integration Issues:
- AGENTS.md loading failures: Verify file permissions and paths
- Command reference updates: Track failed updates, provide manual correction list
- Memory reference validation: Document broken links, suggest fixes

Security Concerns:
- Permission escalation risks: Abort with detailed security analysis
- Inadequate fallback rules: Require explicit confirmation before continuing
- Rule ordering problems: Generate security impact assessment