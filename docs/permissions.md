# Claude Command Permissions Configuration

Comprehensive command permissions configuration for Claude Code settings. This document is the authoritative source for all permission-related configuration. For general settings information, see [Settings Configuration](settings.md).

## 📋 Command Categories

### ✅ Automatically Allowed Commands (allow)

These commands are considered safe and do not modify system state or cause destructive impact.

#### Basic File Operations
- `ls`, `la`, `ll` - List directory contents
- `cat`, `head`, `tail`, `less`, `more` - Read file contents
- `file`, `stat` - View file information
- `wc`, `du`, `df` - File statistics and disk usage
- `pwd`, `which`, `whereis`, `type` - Path and type queries

#### System Information
- `echo`, `printf` - Output text
- `date`, `cal`, `uptime` - Time and system status
- `whoami`, `id`, `uname` - User and system information
- `env`, `printenv`, `export`, `alias` - Environment variables and aliases

#### Git Read-only Operations
- `git status`, `git log`, `git diff`, `git show`
- `git branch`, `git tag`, `git help`

#### Basic Network Tools
- `ping -c:*`, `ping -w:*` - Limited count ping
- `netstat`, `ss`, `lsof -i:*` - Network connection viewing

#### Process and System Monitoring
- `ps aux:*`, `ps -ef:*` - Process lists
- `top -n:*`, `htop --version` - System monitoring

#### Development Tools
- `terraform validate:*`, `terraform fmt:*` - Terraform validation and formatting
- `terraform show:*`, `terraform state list:*`, `terraform graph:*` - Terraform state viewing
- `docker ps:*`, `docker network ls:*`, `docker volume ls:*` - Docker information viewing
- `docker system df:*`, `docker info:*`, `docker version:*` - Docker system information
- `kubectl config view:*`, `kubectl version:*`, `kubectl cluster-info:*` - Kubernetes configuration
- `pip list`, `pip show`, `pip check`, `pip --:*` - Python package tools
- `npm list`, `npm view`, `npm --:*` - Node.js package tools
- `yarn list`, `yarn info`, `yarn --:*` - Yarn package tools
- `go version:*`, `go mod verify:*`, `go mod tidy:*`, `go mod why:*` - Go tools
- `rustc --:*`, `cargo --:*`, `cargo check:*`, `cargo tree:*` - Rust tools
- `python --version`, `python3 --version`, `node --version` - Version checks
- `plantuml:*` - Diagram generation tool
- `parallel --help:*` - GNU parallel help

#### Data Processing
- `sort`, `uniq`, `cut`, `awk`, `sed -n:*`, `tr` - Text processing
- `base64`, `xxd`, `hexdump`, `od` - Encoding and hex viewing
- `diff:*`, `cmp`, `comm`, `gdiff:*` - File comparison
- `sha1sum`, `sha256sum`, `md5sum`, `cksum` - Checksum calculation
- `xargs:*` - Execute commands from standard input

#### Safe Creation Operations
- `mkdir:*`, `mktemp:*` - Create directories and temporary files
- `ln -s:*` - Create symbolic links
- `tree:*` - Directory tree viewing

#### Compression and Archives
- `tar:*` - Archive operations
- `unzip -l:*`, `unzip --:*`, `zip --:*` - Zip operations

#### Testing and Conditions
- `test:*`, `[*`, `[[*` - Conditional testing
- `history:*`, `fc -l:*` - History viewing
- `shellcheck:*` - Shell script static analysis
- `bash -n:*` - Bash syntax checking (no execution)

#### Search and Refactoring Tools
- `rg:*`, `fd:*`, `ast-grep:*` - Repository-aware search and refactors

#### File Reading and Writing
- `Read(/tmp/**)`, `Write(/tmp/**)` - Read/write temporary files

### ❌ Explicitly Forbidden Commands (deny)

These commands are destructive or potentially dangerous, completely forbidden from execution.

- `dd :*` - Low-level disk operations
- `mkfs :*`, `format :*` - File system formatting
- `fdisk :*`, `sfdisk :*`, `parted :*` - Disk partitioning
- `shred :*`, `wipe :*` - Secure deletion tools
- `Read(**/.cursor/**)`, `Read(**/.kiro/**)`, `Read(**/.github/instructions/**)` - Restricted directory access
- `Glob(**/.cursor/**)`, `Glob(**/.kiro/**)`, `Glob(**/.github/instructions/**)` - Restricted directory globbing

### ❓ Commands Requiring Confirmation (ask)

These commands may modify system state, take a long time to execute, or require user confirmation.

#### Infrastructure as Code (Long-running operations)
- `terraform plan:*` - Can take minutes to complete

#### Container Management (Potentially long operations)
- `docker images:*` - May hang on daemon issues or large registries

#### Kubernetes (Cluster-dependent operations)
- `kubectl get:*` - Depends on cluster connectivity, can be slow
- `kubectl describe:*` - Can be very verbose and slow

#### Network Operations (May hang indefinitely)
- `curl --:*` - Network requests, may timeout or hang
- `wget --:*` - Network downloads, may timeout or hang
- `ssh --:*`, `scp --:*` - Remote operations, may hang

#### Module Management (Network-dependent)
- `go mod download:*` - Network-dependent module downloads

## 🔧 Permission System Details

### Wildcard Syntax Rules

⚠️ **Important**: Always use `:*` for prefix matching, not `*`

- ✅ **Correct**: `Bash(rm:*)`, `Bash(git status:*)`, `Bash(npm run:*)`
- ❌ **Incorrect**: `Bash(rm *)`, `Bash(git status *)`, `Bash(npm run *)`

The `:*` syntax matches any arguments after the specified command prefix, while `*` is not supported and will cause validation errors.

### Permission Priority Mechanism

#### Permission Type Priority (High to Low)
```
Deny (Highest Priority) > Ask > Allow (Lowest Priority)
```

#### Execution Logic
1. **Check deny list** - If matched, directly reject
2. **Check ask list** - If matched, require user confirmation
3. **Check allow list** - If matched, allow execution
4. **Other cases** - Default to deny

### Permission Merging Rules

#### Permission List Integration
- **Allow lists**: Merged together, with higher precedence taking priority in conflicts
- **Deny rules**: Absolute priority within each settings layer
- **Ask rules**: Medium priority, requires user confirmation
- **Final effective permissions**: Respect the complete settings hierarchy

#### Permission Configuration Examples

##### Example 1: Basic Permission Structure
```jsonc
// User settings (~/.claude/settings.json) - Base permissions
{
  "permissions": {
    "allow": [
      "Bash(ls:*)",
      "Bash(cat:*)",
      "Bash(git status:*)"
    ],
    "ask": ["Bash(npm install:*)"]
  }
}

// Project settings (.claude/settings.json) - Additional permissions
{
  "permissions": {
    "allow": [
      "Bash(rg:*)",
      "Bash(fd:*)",
      "Bash(project-tool:*)"
    ],
    "ask": [
      "Bash(terraform apply:*)"
    ]
  }
}
```

**Result**: All allow permissions merged, both ask permissions respected

##### Example 2: Security-First Configuration
```jsonc
// High-security project settings
{
  "permissions": {
    "allow": [
      "Bash(git status:*)",
      "Bash(git log:*)",
      "Bash(cat:*)",
      "Bash(rg:*)"
    ],
    "deny": [
      "Bash(rm:*)",
      "Bash(curl:*-X POST:*)",
      "Bash(kubectl apply:*)"
    ],
    "ask": [
      "Bash(terraform apply:*)"
    ]
  }
}
```

**Result**: Deny rules override allow rules, providing security by default

## 🔗 Related Documentation

- [Settings Configuration](settings.md) - General settings hierarchy and file locations
- [Development Guidelines](../rules/01-development-standards.md) - Development standards
- [Security Guidelines](../rules/03-security-standards.md) - Security best practices
