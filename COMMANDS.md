# Claude Global Command Permissions Configuration

Command permissions configuration documentation in `~/.claude/settings.json`.

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
- `git branch`, `git tag`, `git remote`, `git config`
- `git help`, `git --version`

#### Basic Network Tools
- `ping -c:*`, `ping -w:*` - Limited count ping
- `netstat`, `ss`, `lsof -i:*` - Network connection viewing
- `curl --version`, `curl --help` - curl information queries
- `wget --version`, `wget --help` - wget information queries

#### Process and System Monitoring
- `ps aux:*`, `ps -ef:*` - Process lists
- `top -n:*`, `htop --version` - System monitoring

#### Development Tools
- `terraform plan/validate/fmt/show` - Terraform read-only operations
- `docker images/ps/network ls/volume ls` - Docker information viewing
- `kubectl get/describe/config view/version` - Kubernetes read-only operations
- `pip list/show/check`, `python --version` - Python tools
- `npm list/view`, `node --version` - Node.js tools
- `yarn list/info`, `yarn --version` - Yarn tools
- `go version`, `go mod download/verify/tidy/why` - Go tools
- `rustc --version`, `cargo --version/check/tree` - Rust tools
- `mise list/where/which`, `mise --version` - Mise tools

#### Data Processing
- `sort`, `uniq`, `cut`, `awk`, `sed -n:*`, `tr` - Text processing
- `base64`, `xxd`, `hexdump`, `od` - Encoding and hex viewing
- `diff:*`, `cmp`, `comm` - File comparison
- `sha1sum`, `sha256sum`, `md5sum`, `cksum` - Checksum calculation
- `xargs:*` - Execute commands from standard input

#### Safe Creation Operations
- `mkdir:*` - Create directories
- `ln -s:*` - Create symbolic links
- `tree:*` - Directory tree viewing

#### Compression and Archives
- `tar:*` - Archive operations
- `unzip -l:*` - View zip contents

#### Testing and Conditions
- `test:*`, `[*`, `[[*` - Conditional testing
- `history:*`, `fc -l:*` - History viewing

#### Specific Tools
- `Bash(plantuml:*)` - PlantUML diagram generation
- `Bash(grep:*)`, `Bash(find:*)` - Search and find
- `Bash(gdiff:*)` - GNU diff
- `Bash(mkdir:*)`, `Bash(chmod:*)` - Directory creation and permission setting

### ❌ Explicitly Forbidden Commands (deny)

These commands are destructive or potentially dangerous, completely forbidden from execution.

- `dd :*` - Low-level disk operations
- `mkfs :*`, `format :*` - File system formatting
- `fdisk :*`, `sfdisk :*`, `parted :*` - Disk partitioning
- `shred :*`, `wipe :*` - Secure deletion tools

### ❓ Commands Requiring Confirmation (ask)

These commands may modify system state and require user confirmation.

#### Java and Basic File Operations
- `Bash(java:*)` - Java program execution
- `Bash(rm :*)`, `Bash(rmdir :*)` - Delete files and directories
- `Bash(mv :*)`, `Bash(cp :*)` - Move and copy files
- `Bash(chown :*)`, `Bash(chmod -R :*)` - Modify file permissions (recursive)

#### Git Write Operations
- `git add:*`, `git commit:*`, `git push:*`, `git pull:*`
- `git merge:*`, `git rebase:*`, `git reset:*`
- `git checkout:*`, `git switch:*`, `git restore:*`
- `git stash:*`, `git clean:*`

#### Containers and Orchestration
- `docker run:*`, `docker rmi:*`, `docker rm:*`
- `docker stop:*`, `docker kill:*`, `docker build:*`
- `docker compose up:*`, `docker compose down:*`, `docker compose restart:*`
- `kubectl apply:*`, `kubectl delete:*`, `kubectl create:*`
- `kubectl edit:*`, `kubectl exec:*`, `kubectl logs:*`

#### Infrastructure as Code
- `terraform apply:*`, `terraform destroy:*`, `terraform import:*`
- `terraform taint:*`, `terraform state rm:*`

#### Package Managers
- `pip install:*`, `pip uninstall:*`, `python -m pip install:*`
- `npm install:*`, `npm uninstall:*`, `npm run:*`
- `yarn add:*`, `yarn remove:*`, `yarn install:*`, `yarn run:*`
- `go get:*`, `cargo install:*`, `cargo uninstall:*`, `cargo build:*`
- `mise install:*`, `mise uninstall:*`, `mise use:*`

#### Network Requests
- `curl -X POST:*`, `curl -X PUT:*`, `curl -X DELETE:*`
- `curl -d:*`, `curl --data:*`
- `wget --post-data:*`, `wget --method:*`

#### Remote Operations
- `ssh :* :*`, `scp :* :*`, `rsync :*`

#### Permission Modifications
- `chmod +x :*`, `chmod 755 :*`, `chmod 644 :*`

## 🔧 Permission System Details

### Wildcard Syntax Rules

⚠️ **Important**: Always use `:*` for prefix matching, not `*`

- ✅ **Correct**: `Bash(rm :*)`, `Bash(git status:*)`, `Bash(npm run:*)`
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

### Configuration File Merging Logic

#### Layered Permission System
1. **Global settings** (`~/.claude/settings.json`) - Base permission layer
2. **Project settings** (`./.claude/settings.local.json`) - Project-specific permission layer
3. **Deny rules** - Highest priority, overrides all allow rules
4. **Ask rules** - Medium priority, requires user confirmation

#### Permission Merging Method
- **Project allow list** is **appended** to Global allow list, not replaced
- **deny rules** have absolute priority, even if project settings have allow
- Final effective permissions are the **union** of both, but limited by deny rules

### Practical Examples

#### Example 1: Project Allow vs Global Deny
```json
// Global settings
{
  "permissions": {
    "deny": ["Bash(rm :*)"],
    "allow": ["Bash(ls :*)"]
  }
}

// Project settings
{
  "permissions": {
    "allow": ["Bash(rm -rf :*)"]
  }
}
```
**Result**: `Bash(rm -rf :*)` will be rejected because global deny has higher priority

#### Example 2: Multiple Permission Sources
```json
// Global allow: ["Bash(ls :*)", "Bash(cat :*)"]
// Project allow: ["Bash(grep :*)", "Bash(find :*)"]
// Global deny: ["Bash(dd :*)"]
```
**Final allow**: `["Bash(ls :*)", "Bash(cat :*)", "Bash(grep :*)", "Bash(find :*)"]`
**Final deny**: `["Bash(dd :*)"]` (overrides all allow)

### Project Override
Projects can override or extend these settings in `.claude/settings.local.json`, project settings will be merged with global settings.

### Adjusting Permissions
To modify command permissions, edit `~/.claude/settings.json` and choose appropriate category:
- `allow` - Completely safe, automatically allowed
- `deny` - Dangerous operations, completely forbidden
- `ask` - May modify state, requires confirmation

### Configuration File Locations
- **Global**: `~/.claude/settings.json`
- **Project**: `{project_root}/.claude/settings.local.json`