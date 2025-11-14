---
file-type: command
command: /optimize-prompts
description: Perform DEPTH-based analysis and deterministic rewrite of LLM-facing files using rule-driven schemas
implementation: commands/optimize-prompts.md
argument-hint: "[path/to/file] [--all]"
scope: Included
allowed-tools:
  - Read
  - Write
  - Bash(find *)
  - Bash(ls *)
  - Bash(cat *)
  - Bash(rg *)
dont-optimize: true
is_background: false
---

## Usage

/optimize-prompts [path]
/optimize-prompts --all

## Arguments

- `path`: Optional target file path
- `--all`: Include all LLM-facing files
- When both provided, --all dominates

## Overview

This command performs the following operations:
- Loads all target files into memory
- Performs DEPTH analysis and generates rewritten candidates without modifying disk files
- Enforces schemas and canonical ordering defined in rules
- Evaluates dependencies and cross-file consistency based on the candidate state
- Writes changes only after explicit confirmation

## Target Scope Filter

Included:
- `commands/**/*.md`
- `skills/**/SKILL.md`
- `agents/**/AGENT.md`
- `AGENTS.md`
- `rules/**/*.md`
- `CLAUDE.md`
- `.claude/settings.json`

Excluded:
- `commands/**/README.md`
- `**/README*`
- `docs/**`
- `src/**`
- `examples/**`
- `tests/**`
- `ide/**`
- Files flagged `dont-optimize: true`

## DEPTH Framework

### Decomposition
- Identify file type, purpose, expected structure
- Extract sections, frontmatter, dependencies
- Derive a structural model for rewrite

### Explicit Reasoning
- Infer missing constraints from rule files
- Detect vague or ambiguous directives
- Determine required normalization steps

### Parameters
- Apply frontmatter schemas from rules
- Enforce deterministic key ordering and value types
- Standardize section presence and naming

### Tests
- Derive normal usage scenarios
- Derive edge and failure cases
- Detect insufficient or contradictory behavior

### Heuristics
- Remove narrative and conversational content
- Remove body bold markers
- Prioritize tool safety and deterministic output
- Minimize unnecessary changes while achieving canonical form

## Workflow

### 1. Resolve Targets
- When path provided: Include if within LLM-facing scope
- When --all provided: Include all LLM-facing files
- When both provided: Use --all

### 2. Load and Classify
- Load all targets into memory
- Assign one of: command-file, skill-file, agent-file, rule-file, memory-file
- Skip files flagged dont-optimize
- Skip canonical rule files that govern rewrite behavior

### 3. Per-File DEPTH Analysis
For each loaded file:
- Run Decomposition, Explicit reasoning, Parameters, Tests, Heuristics
- Generate an in-memory rewritten candidate
- Preserve the original file unchanged on disk

### 4. Candidate Normalization
Apply rule-driven constraints:
- Frontmatter schema normalization
- Canonical section ordering
- Removal of narrative paragraphs
- Removal of body bold markers
- Directory and filename consistency
- Enforcement of imperative directives

### 5. Dependency and Consistency

#### Dependency Graph
A single, acyclic hierarchy:
- `rules → skill → agent → command`
- `memory → rules`

#### Validation
Using rewritten candidates, validate:
- Invalid or missing references
- Missing or extra dependencies
- Wrong dependency direction
- Circular dependencies
- Naming mismatches
- Missing or misordered sections
- Inconsistent `allowed-tools`
- Missing rule-loading conditions

#### Auto-Fix
When safe, auto-correct:
- Add missing dependencies
- Remove invalid upward dependencies
- Fix broken reference names
- Normalize frontmatter fields
- Normalize section ordering
- Enforce tool and rule constraints

All fixes apply only to the in-memory candidate, never directly to disk.

### 6. Review and Confirmation
For each file:
- Print original summary
- Print rewritten candidate
- Print DEPTH rationale
- Print derived test cases

Then request explicit confirmation for writeback.

### 7. Writeback
- When approved: Write candidate content to disk
- When denied: Leave all files unchanged and retain analysis output

## Output

### Per File
- Structure summary
- Candidate content
- DEPTH reasoning summary
- Test cases

### Batch
- Dependency graph overview
- Cross-file consistency report

### Status Messages
- When no writebacks approved: Print analysis complete. no files were modified.
- When all writebacks approved: Print changes applied successfully.