---
name: search-and-refactor-strategy
description: Guide agents on tool selection between find/fd, grep/rg/ast-grep for search and refactor operations. Use when search-and-refactor-strategy guidance is required.
layer: execution
mode: decision-support
capability-level: 1
style: reasoning-first
allowed-tools:
  - Bash(fd *)
  - Bash(find *)
  - Bash(rg *)
  - Bash(grep *)
  - Bash(ast-grep *)
  - Read
  - Write
  - Edit
related-skills:
  - skill:environment-validation
---

## Purpose
Provide deterministic tool selection guidance for search and refactoring operations, prioritizing safety, accuracy, and modern Unix toolchain efficiency while maintaining robust fallbacks for compatibility.

## IO Semantics
Input: Search requirements, refactoring tasks, codebase modification needs
Output: Tool selection decisions, search commands, refactoring workflows
Side Effects: Optimized search execution, accurate code modifications, .gitignore-aware file discovery

## Deterministic Steps

### 1. Tool Availability Assessment
Execute environment validation to determine available tools:
- Check if `fd`, `rg`, `ast-grep` are available (preferred modern tools)
- Fallback to `find`, `grep` if modern tools unavailable
- Document tool versions for performance optimization

### 2. Task Classification
Classify operation type:
- **File Discovery**: Need to find files by name/pattern → Use fd or find
- **Text Search**: Need to search file contents → Use rg or grep
- **Structural Analysis**: Need AST-aware matching/modification → Use ast-grep
- **Refactoring**: Need code transformations → Use ast-grep with dry-run

### 3. File Discovery Protocol
When discovering files:
1. Use `fd` by default (respects .gitignore, faster, safer)
2. Fallback to `find` when:
   - Need to discover hidden/ignored files
   - System lacks `fd` installation
3. Always include `--type f` to filter directories
4. Document reasons for .gitignore overrides

### 4. Text Search Protocol
When searching file contents:
1. Use `rg` by default (faster, better defaults, PCRE support)
2. Fallback to `grep` when:
   - Minimal system environments
   - Need strict POSIX compatibility
3. Use `rg --type <lang>` for language-specific searches
4. Include line numbers with `-n` for debugging

### 5. Structural Analysis Protocol
When performing AST-aware operations:
1. Use `ast-grep` for:
   - Language-aware pattern matching
   - Safe code refactoring
   - Structural code transformations
2. Always use `--dry-run` before applying changes
3. Use `ast-grep --json` for programmatic output
4. Review structural match accuracy before modifications

### 6. Hybrid Workflow Implementation
For complex operations, chain tools:
1. **Discovery Phase**: `fd` to enumerate candidate files
2. **Shortlist Phase**: `rg` to confirm text matches
3. **Analysis Phase**: `ast-grep` for structural verification
4. **Modification Phase**: `ast-grep` with `--dry-run` then execute

### 7. Safety Protocol
For all refactoring operations:
- Execute dry-run modes first
- Create backups before automated changes
- Test patterns on small subsets
- Verify post-refactor state
- Document changes made

### 8. Performance Optimization
- Prefer `rg` over `grep` for large codebases (5-10x faster)
- Use `fd` with `--hidden` only when necessary
- Leverage `ast-grep` language-specific rules
- Cache search results for repeated operations

## Validation Criteria
- Tool selection matches task requirements (discovery/search/structural)
- Fallback chains properly documented
- Safety measures (dry-runs, backups) consistently applied
- Gitignore behavior honored by default
- Performance considerations documented
- Post-refactor verification completed
