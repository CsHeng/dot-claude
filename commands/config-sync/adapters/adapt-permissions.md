---
name: "config-sync:adapt-permissions"
description: Adapt Claude permissions to target tool format
argument-hint: --target=<droid|qwen|codex|opencode>
disable-model-invocation: true
---

## Task
Analyze Claude's permission system and generate appropriate permission configuration for the target tool.

## Analysis Requirements
1. Read Claude permissions:
   - Extract `allow/ask/deny` lists from `~/.claude/settings.json`
   - Review permission categories in `docs/permissions.md`
   - Understand security rationale behind each permission level

2. Parse target specification:
   - Extract target tool from `--target` argument
   - Validate target tool is supported

3. Target tool capability assessment:
   - Factory/Droid: Has `commandAllowlist`/`commandDenylist` in settings.json
   - Qwen CLI: No formal permission system
   - Codex CLI: No formal permission system
   - OpenCode CLI: Operation-based permissions (edit/bash/webfetch) in opencode.json

4. Permission mapping strategy:
   - Map Claude `allow` → target allowlist where supported
   - Map Claude `deny` → target denylist where supported
   - Handle Claude `ask` category appropriately
   - For OpenCode: Map command permissions to operation-based permissions
   - Document permissions that cannot be mapped

## Permission Mapping Logic

### Claude Permission Categories
- allow: Safe commands that run automatically
- ask: Commands requiring user confirmation
- deny: Dangerous commands that are completely blocked

### Target Tool Adaptations

#### Factory/Droid CLI
```json
{
  "commandAllowlist": [/* Claude 'allow' commands */],
  "commandDenylist": [/* Claude 'deny' commands + high-risk 'ask' commands */]
}
```

#### Qwen CLI
```json
{
  "version": 1,
  "permissions": {
    "allow": [/* Claude 'allow' commands */],
    "ask": [/* Claude 'ask' commands */],
    "deny": [/* Claude 'deny' commands */]
  }
}
```
- Emit `permissions.json` manifest consumed by Qwen CLI wrappers
- Keep the manifest sorted/deduplicated for stable diffs

#### Codex CLI
- Update the `[sandbox]` block inside `~/.codex/config.toml`
- Derive `mode`, `allow_network`, and `allow_execution` from permission strictness
- Preserve unrelated configuration fields while rewriting the sandbox block

#### OpenCode CLI
```json
{
  "permission": {
    "edit": "allow|ask|deny",
    "bash": "allow|ask|deny",
    "webfetch": "allow|ask|deny"
  }
}
```
Map Claude command permissions to operation-based permissions:
- File editing commands → `permission.edit`
- Bash/shell commands → `permission.bash`
- Network/web commands → `permission.webfetch`

## Security Analysis Requirements
1. Risk assessment:
   - Identify commands that could cause data loss
   - Flag system-modifying commands
   - Note network operations and external dependencies

2. Permission classification:
   - Safe: Read-only operations, basic file operations
   - Risky: Network operations, package management, file modifications
   - Dangerous: System-level changes, destructive operations

3. Adaptation decisions:
   - Never move dangerous commands from deny to allow
   - Prefer stricter permissions when in doubt
   - Document any permission weakening with security rationale

## Output Requirements

### For Factory/Droid CLI
- Generate/overwrite `~/.factory/settings.json` with adapted permissions
- Preserve existing non-permission settings
- Backup original file before modification
- NEVER add sync metadata or tracking information

### For Qwen CLI
- Generate/overwrite `~/.qwen/permissions.json` with allow/ask/deny arrays
- Preserve manifest readability (indentation, stable ordering)
- Ensure `permissions.json` is backed up by the prepare phase before mutation
- Avoid emitting supplemental Markdown files

### For Codex CLI
- Generate/update the `[sandbox]` block inside `~/.codex/config.toml`
- Preserve existing `[core]`, `[sync]`, and other sections
- Keep previously configured `enabled`, `timeout`, and `memory_limit` values when present
- Respect `--force` semantics before overwriting structural changes

### For OpenCode CLI
- Generate/overwrite `~/.config/opencode/opencode.json` with adapted permissions
- Map Claude command permissions to operation-based permissions
- Preserve existing non-permission settings
- Backup original file before modification
- NEVER add sync metadata or tracking information

## Safety Requirements
- Only modify target tool configuration files after confirming prepare-phase backups exist
- Use `rsync -a` (not `cp`) for all backups to preserve metadata
- If temporary files are needed, create them in /tmp using mktemp
- ALWAYS clean up temporary files in /tmp immediately after use
- NEVER leave temporary files in target tool directories
- Preserve target tools' natural configuration structure

### Documentation Requirements
- Permission mapping summary (what went where)
- Security considerations for unmappable permissions
- Manual permission management guidelines
- Verification checklist for permission effectiveness

## Safety Checks
- Validate that no dangerous commands are inappropriately allowed
- Ensure critical system protections remain in place
- Check for permission escalation risks
- Verify backup files are created before modifications

## Error Handling
- Handle missing or malformed permission configurations
- Deal with unsupported target tools gracefully
- Provide clear error messages for invalid inputs
- Roll back changes if adaptation fails
