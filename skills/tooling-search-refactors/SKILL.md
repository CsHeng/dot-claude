---
name: "skill:tooling-search-refactors"
description: "Guide agents on when to prefer ast-grep versus ripgrep and how to chain them safely"
allowed-tools:
  - Bash(ast-grep --version)
  - Bash(rg --version)
---

## Purpose
Provide deterministic guidance for selecting between ast-grep and ripgrep tools based on search requirements, accuracy needs, and structural vs textual analysis as defined in the agentization taxonomy and shell guidelines.

## IO Semantics
Input: Search requirements, refactoring tasks, codebases needing modification
Output: Tool selection guidance, search commands, refactoring workflows
Side Effects: Optimized search strategies, accurate code modifications, improved refactoring efficiency

## Deterministic Steps

### 1. Tool Selection Analysis
Identify structural matches or rewrites needed → ast-grep
Identify fast textual reconnaissance required → ripgrep
Assess accuracy concerns outweighing speed → ast-grep

### 2. Hybrid Workflow Implementation
Execute `rg` to shortlist candidate files
Pipe results into `ast-grep` for precise matches
Use `ast-grep` for codemods and structural rewrites

### 3. Language-Specific Guidance
Provide Go-focused structural search patterns
Generate codemod examples for common refactoring
Create hybrid workflow demonstrations

### 4. Safety Protocol Enforcement
Execute `ast-grep --dry-run` before large-scale edits
Use `rg --files` for file discovery before modifications
Warn about import changes requiring `goimports` or similar tools

### 5. Documentation Requirements
Document false positive tradeoffs (node vs line matching)
Highlight accuracy differences when precision required
Provide post-refactor cleanup instructions

## Tool Safety
Validate tool versions before execution
Use dry-run modes for large-scale modifications
Backup code before applying automated refactors
Test search patterns on small subsets first
Monitor tool performance and resource usage

## Validation Criteria
Tool selection matches task requirements (structural vs textual)
Hybrid workflows properly chained and documented
Safety measures (dry runs, backups) consistently applied
Post-refactor cleanup procedures documented and executed
Accuracy vs speed tradeoffs properly evaluated and communicated