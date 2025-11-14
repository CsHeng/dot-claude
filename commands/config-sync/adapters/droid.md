---
name: config-sync:droid
description: Droid CLI operations with full YAML frontmatter compatibility and JSON
  permissions
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
- skill:security-logging
---

## usage

Execute Droid CLI synchronization with full YAML frontmatter compatibility and commandAllowlist/commandDenylist permission system.

## arguments

- `--action`: Operation mode
  - `sync`: Complete synchronization of components
  - `analyze`: Analyze current configuration state
  - `verify`: Validate synchronization completeness
- `--component`: Components to process (comma-separated or `all`)
  - `rules`: Rule file synchronization
  - `commands`: Command file preservation with frontmatter
  - `settings`: Droid-specific configuration generation
  - `memory`: DROID.md and AGENTS.md integration
  - `all`: All components (default)

## workflow

1. Parameter Validation: Parse action and component specifications
2. Droid Analysis: Examine existing Droid CLI configuration
3. Component Processing: Apply operations to specified components
4. Format Compatibility: Handle Markdown with YAML frontmatter preservation
5. Permission Mapping: Convert Claude permissions to allowlist/denylist format
6. Verification: Validate synchronization completeness

### droid-cli-features

Command Format:
- Full YAML frontmatter compatibility
- Direct Claude command compatibility
- No conversion required for existing commands

Permission System:
- commandAllowlist/commandDenylist in settings.json
- JSON-based permission configuration
- Conservative security approach (ask → deny)

Configuration Structure:
- settings.json and config.json files
- commands/ and rules/ directories
- DROID.md and AGENTS.md memory files

### component-processing

Rules Component:
- Direct sync to Droid rules directory
- Preserve rule structure and organization
- Update memory references as needed

Commands Component:
- Copy commands with frontmatter preservation
- Maintain Claude command compatibility
- Update tool references for Droid environment

Settings Component:
- Generate Droid-specific settings.json
- Configure commandAllowlist/commandDenylist
- Preserve existing non-permission settings

Memory Component:
- Configure DROID.md as primary memory reference
- Set up AGENTS.md for agent documentation
- Update cross-references and links

### permission-mapping

Direct Translations:
- Claude allow → Droid commandAllowlist
- Claude deny → Droid commandDenylist
- Claude ask → Droid commandDenylist (conservative approach)

Security Considerations:
- Apply conservative mapping for uncertain permissions
- Manual review recommended for permission changes
- Document all permission transformations

## output

Generated Files:
- Synchronized rules, commands, settings in Droid directories
- Droid-specific settings.json with permission mappings
- Memory files with proper Droid references

Verification Reports:
- Component-by-component synchronization status
- Permission mapping summary
- Reference validation results

Security Documentation:
- Permission transformation analysis
- Security impact assessment
- Conservative mapping rationale

## integration-guidelines

Command Compatibility:
- Most Claude commands work directly with Droid
- Verify Droid-specific features after sync
- Test command functionality post-synchronization

Permission Management:
- No wildcard support in Droid permission system
- Convert complex patterns to explicit entries
- Manual review recommended for critical permissions

## safety-constraints

1. Backup Creation: Generate backups before modifying existing configurations
2. Permission Conservation: Apply conservative permission mapping
3. Format Preservation: Maintain YAML frontmatter structure
4. Reference Validation: Ensure all memory references remain valid

## examples

```bash
# Complete Droid CLI synchronization
/config-sync:droid --action=sync --component=all

# Analyze current Droid configuration
/config-sync:droid --action=analyze

# Sync commands with frontmatter preservation
/config-sync:droid --action=sync --component=commands

# Update permission mappings only
/config-sync:droid --action=sync --component=settings
```

## error-handling

Configuration Errors:
- Invalid settings.json format: Backup and regenerate
- Permission modification failures: Log detailed errors
- Directory creation problems: Document permission issues

Integration Issues:
- Command compatibility problems: List affected commands
- Permission mapping conflicts: Document conservative choices
- Memory reference failures: Provide manual correction guidance

Security Concerns:
- Permission escalation risks: Abort with security analysis
- Inadequate denylist coverage: Document security gaps
