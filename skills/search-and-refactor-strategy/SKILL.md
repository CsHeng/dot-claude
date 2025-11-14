---
name: "skill:search-and-refactor-strategy"
description: "Guide agents on when to prefer ast-grep versus ripgrep and how to chain them safely (project, gitignored)"
allowed-tools:
  - Bash(ast-grep --version)
---

## Purpose
Provide deterministic guidance for selecting between ast-grep and ripgrep tools based on search requirements, accuracy needs, and structural vs textual analysis as defined in the agentization taxonomy and shell guidelines.

Dependencies: This skill assumes that `skill:environment-validation` has been loaded to validate tool availability.

## IO Semantics
Input: Search requirements, refactoring tasks, codebases needing modification
Output: Tool selection guidance, search commands, refactoring workflows
Side Effects: Optimized search strategies, accurate code modifications, improved refactoring efficiency

## Deterministic Steps

### 1. Tool Selection Analysis
Identify .gitignore-aware file discovery or directory inventories → fd
Identify structural matches or rewrites needed → ast-grep
Identify fast textual reconnaissance required → ripgrep
Assess accuracy concerns outweighing speed → ast-grep

### 2. Hybrid Workflow Implementation
Use `fd` to enumerate candidate files while respecting `.gitignore`
Execute `rg` to shortlist files and confirm textual matches
Pipe results into `ast-grep` for precise matches
Use `ast-grep` for codemods and structural rewrites

### 3. Language-Specific Guidance
Provide Go-focused structural search patterns
Generate codemod examples for common refactoring
Create hybrid workflow demonstrations

### 4. Safety Protocol Enforcement
Execute `ast-grep --dry-run` before large-scale edits
Use `fd --type f` (default) for file discovery before modifications
Escalate to `fd --no-ignore` or `--ignore-vcs` consciously when hidden files are required
Warn about import changes requiring `goimports` or similar tools

### 5. Documentation Requirements
Document false positive tradeoffs (node vs line matching)
Highlight accuracy differences when precision required
Clarify `.gitignore`-aware discovery defaults (`fd`) versus manual `find` fallbacks
Provide post-refactor cleanup instructions

## Tool Safety
Use dry-run modes for large-scale modifications
Backup code before applying automated refactors
Test search patterns on small subsets first
Monitor tool performance and resource usage

## Validation Criteria
Tool selection matches task requirements (discovery vs textual vs structural)
Hybrid workflows properly chained and documented
Safety measures (dry runs, backups) consistently applied
Post-refactor cleanup procedures documented and executed
Accuracy vs speed tradeoffs properly evaluated and communicated
File discovery honors `.gitignore` behavior by default via fd, with overrides justified
