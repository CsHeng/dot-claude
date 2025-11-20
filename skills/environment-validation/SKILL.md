---
name: environment-validation
description: Unify toolchain versions and validation rules (project, gitignored).
  Use when environment validation guidance is required.
allowed-tools:
- Bash(rg --version)
- Bash(fd --version)
- Bash(ast-grep --version)
- Bash(python3 --version)
- Bash(go version)
- Bash(lua -v)
- Bash(plantuml --version)
- Bash(dbml2sql --version)
- Bash(which *)
- Bash(command -v *)
mode: stateless-validation
capability-level: 1
---

## Purpose
Establish and validate baseline toolchain requirements including version compatibility, environment management, and dependency resolution across all development tools as defined in rules/00-memory-rules.md. Provide explicit signals about Python+uv and Shell capabilities so language and tool selection can prefer Python-first automation with Shell as a wrapper.

## IO Semantics
Input: Development environment, tool installations, configuration files
Output: Toolchain validation reports, environment compliance status, remediation instructions
Side Effects: Updated tool installations, configured environment, validated dependency chain

## Deterministic Steps

### 1. Version Validation Execution
Execute `python3 --version | rg '3\\.1[3-9]'` for Python 3.13+ validation when Python is present
Execute `go version | rg 'go1\\.2[3-9]'` for Go 1.23+ validation
Execute `plantuml --version` for PlantUML availability check
Execute `dbml2sql --version` for dbml2sql availability check
Execute `rg --version` to confirm ripgrep availability
Execute `fd --version` to confirm `.gitignore` aware file discovery support
Execute `ast-grep --version` to confirm structural search and refactoring tool availability
Execute `which find` and `command -v find` to verify find command availability

### 2. Toolchain Requirements Enforcement
Validate Python >= 3.13 requirement compliance
Confirm Go >= 1.23 requirement compliance
Verify Lua >= 5.4 requirement availability
Ensure PlantUML >= 1.2025.9 requirement compliance
Validate ripgrep availability for high-performance text search
Validate fd availability for gitignore-aware file discovery
Validate ast-grep availability for structural code analysis
Validate find availability as fallback file discovery method

### 3. Environment Management Validation
Confirm single `.venv` managed by UV usage in development environments
Validate mise tool installation management for development tooling
Enforce CGO_ENABLED=0 for Go builds
Verify default interactive shell = zsh configuration

### 4. Dependency Resolution Implementation
Execute `mise install` when missing dependencies detected
Execute `uv tool install <name>` for missing Python tools
Record validation results in execution logs
Provide clear remediation instructions for failures

### 5. Integration Testing Validation
Validate tool integration with common workflows
Ensure PATH configuration includes all required tools
Test tool availability and functionality in isolation
Verify tool version compatibility across ecosystem
Test tool fallback mechanisms (fd -> find, rg -> grep)
Validate performance characteristics of different tool combinations
Ensure tool selection logic provides deterministic behavior
Record whether Python+uv are available so downstream skills can choose Python-first automation with Shell wrappers only when appropriate

## Tool Safety
Validate tool versions in isolated environments
Test tool functionality before requiring them
Backup environment configurations before changes
Monitor resource usage during tool validation
Ensure tool installation doesn't break existing functionality

## Validation Criteria
Python version >= 3.13 confirmed and functional
Go version >= 1.23 confirmed and functional
PlantUML >= 1.2025.9 available and operational
dbml2sql tool available and functional
Ripgrep and fd available and functional (primary tools)
ast-grep available and functional for structural analysis
find command available as fallback for file discovery
grep command available as fallback for text search
All tools in PATH and working correctly
Tool fallback mechanisms tested and validated
Environment management practices properly configured
Tool selection logic provides deterministic results
