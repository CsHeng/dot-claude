---
name: config-sync:adapt-permissions
description: Adapt Claude permissions to target tool configuration formats
argument-hint: --target=<droid|qwen|codex|opencode|amp>
allowed-tools:
- Read
- Write
- Bash
- Bash(cat:*)
- Bash(ls:*)
is_background: false
disable-model-invocation: true
related-commands:
- /config-sync/sync-cli
related-agents:
- agent:config-sync
related-skills:
- skill:security-logging
---

## usage

Execute conversion of Claude permission configurations to target tool formats while maintaining security boundaries and adapting to platform-specific permission systems.

## arguments

- `--target`: Target AI tool platform for permission adaptation
  - `droid`: Factory/Droid CLI permission configuration
  - `qwen`: Qwen CLI permission manifest
  - `codex`: OpenAI Codex CLI sandbox configuration
  - `opencode`: OpenCode CLI operation permissions
  - `amp`: Amp CLI permission array

## workflow

1. Permission Analysis: Extract Claude allow/ask/deny lists from `settings.json`
2. Target Assessment: Evaluate target tool permission capabilities and format
3. Mapping Strategy: Convert Claude permission categories to target format
4. Configuration Generation: Create target-specific permission files
5. Security Validation: Verify permission mapping completeness and safety
6. File Installation: Apply configurations to target tool directories
7. Verification: Generate mapping reports and security analysis

### target-permission-systems

Factory/Droid CLI:
- Format: JSON configuration with `commandAllowlist`/`commandDenylist`
- Location: `~/.factory/settings.json`
- Mapping: Direct allow/deny list translation

Qwen CLI:
- Format: JSON manifest with permission arrays
- Location: `~/.qwen/permissions.json`
- Mapping: Allow/ask/deny array structure

OpenAI Codex CLI:
- Format: TOML configuration with sandbox block
- Location: `~/.codex/config.toml`
- Mapping: Derive sandbox mode from permission strictness

OpenCode CLI:
- Format: JSON with operation-based permissions
- Location: `~/.config/opencode/opencode.json`
- Mapping: Command categories to operation permissions

Amp CLI:
- Format: JSON permission array with tool matching
- Location: `~/.config/amp/settings.json`
- Mapping: Command patterns to permission rules

### permission-mapping-logic

Direct Mapping:
- `allow` → target allowlist where supported
- `deny` → target denylist where supported
- `ask` → confirmation mechanism or high-risk denylist

Security Classification:
- Safe: Read-only operations, basic file operations
- Risky: Network operations, package management, file modifications
- Dangerous: System-level changes, destructive operations

Category Mapping:
- File editing commands → `permission.edit` (OpenCode)
- Bash/shell commands → `permission.bash` (OpenCode)
- Network/web commands → `permission.webfetch` (OpenCode)

## output

Configuration Files:
- Target-specific permission configurations
- Preserved existing non-permission settings
- Backup files of original configurations

Documentation:
- Permission mapping summary with change details
- Security considerations for unmappable permissions
- Manual permission management guidelines
- Verification checklist for permission effectiveness

Security Reports:
- Risk assessment for adapted permissions
- Permission escalation analysis
- Critical system protection verification

## safety-constraints

1. Backup Requirement: Create backups before modifying target configurations
2. Security Preservation: Never upgrade dangerous commands from deny to allow
3. Conservative Approach: Prefer stricter permissions when mapping is uncertain
4. Rule Ordering: Maintain deterministic rule ordering for proper evaluation
5. Fallback Rules: Include safe default rules for unmatched operations
6. Context Validation: Verify target tool directories exist and are accessible

## file-processing-details

### factory-droid-cli
```json
{
  "commandAllowlist": ["permitted-commands"],
  "commandDenylist": ["blocked-commands"]
}
```

### qwen-cli
```json
{
  "version": 1,
  "permissions": {
    "allow": ["claude-allow-commands"],
    "ask": ["claude-ask-commands"],
    "deny": ["claude-deny-commands"]
  }
}
```

### opencode-cli
```json
{
  "permission": {
    "edit": "allow|ask|deny",
    "bash": "allow|ask|deny",
    "webfetch": "allow|ask|deny"
  }
}
```

### amp-cli
```json
{
  "amp.permissions": [
    { "tool": "Bash", "matches": { "cmd": ["pattern"] }, "action": "ask" },
    { "tool": "*", "action": "ask" }
  ]
}
```

## security-analysis

1. Risk Assessment:
   - Identify commands with data loss potential
   - Flag system-modifying operations
   - Note network dependencies and external calls

2. Permission Classification:
   - Categorize commands by risk level
   - Apply appropriate security restrictions
   - Document classification rationale

3. Adaptation Decisions:
   - Never weaken security boundaries
   - Document permission reductions with justification
   - Maintain audit trail of all permission changes

## examples

```bash
# Adapt permissions for Amp CLI with rule-based filtering
/config-sync:adapt-permissions --target=amp

# Generate Qwen CLI permission manifest
/config-sync:adapt-permissions --target=qwen

# Create OpenCode operation-based permissions
/config-sync:adapt-permissions --target=opencode
```

## error-handling

Configuration Errors:
- Missing source permissions: Exit with error, provide setup instructions
- Invalid permission format: Log error and continue with safe defaults

Target Tool Errors:
- Unsupported target: List supported platforms and exit
- Target directory inaccessible: Exit with permission details

Security Validation:
- Permission escalation detected: Abort with security warning
- Dangerous command reclassification: Require explicit confirmation
- Missing fallback rules: Exit with security concern details

File System Errors:
- Backup creation failure: Exit before making changes
- Configuration write failure: Rollback if possible, exit with error
- Permission modification failure: Log detailed error information