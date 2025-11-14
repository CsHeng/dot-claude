---
name: "optimize-prompts"
description: "Perform DEPTH-based analysis and deterministic rewrite of LLM-facing files using rule-driven schemas"
argument-hint: "[path/to/file] [--all]"
allowed-tools:
  - Read
  - Write
  - Bash(ls *)
  - Bash(cat *)
  - Bash(rg *)
  - Bash(fd *)
  - Bash(ast-grep *)
is_background: false
dont-optimize: true
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

Use `fd` for discovery:

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

### 0. Load Configuration
- Load file-type rules from `commands/optimize-prompts/simple-optimization.yaml`
- Load file-type exceptions from `rules/99-llm-prompt-writing-rules.md`
- Determine file type by directory structure based on official Claude Code + RFC requirements:
  - `skills/**/SKILL.md` → SIMPLE framework (model-invoked, official + RFC frontmatter)
  - `commands/**/*.md` → DEPTH framework (user-invoked, complex parameters)
  - `agents/**/*.md` → COMPLEX framework (subagents, official + RFC manifest)
  - `rules/**/*.md` → SIMPLE framework (imperative rules only)

### 1. Resolve Targets
- When path provided: Include if within LLM-facing scope
- When --all provided: Include all LLM-facing files
- When both provided: Use --all
- Enumerate candidates with `fd` so `.gitignore` rules are honored. Do not shell out to `find`; if exotic predicates are required, run them via `fd --exec` or filter the fd output in Python.

### 2. Classify Files by Directory
- For each target, determine file type by directory path:
  - `skills/**/SKILL.md` → skills type
  - `commands/**/*.md` → commands type
  - `agents/**/*.md` → agents type
  - `CLAUDE.md`, `AGENTS.md` → core type
- Apply corresponding framework and preservation rules
- Skip files flagged dont-optimize or with file-type: rule

### 3. Load and Validate
- Load all targets into memory
- Apply file-type specific validation before optimization
- Check required fields and sections per file type
- Validate frontmatter compliance where required

### 4. Per-File Framework-Specific Analysis
For each loaded file:
- Apply assigned framework (SIMPLE, DEPTH, COMPLEX, METADATA)
- Execute framework-specific phases based on file type
- Generate an in-memory rewritten candidate
- Prohibit generation of bold markers
- Apply file-type preservation patterns and special rules
- Preserve the original file unchanged on disk

### 5. Official-Based Normalization

#### Skills (skills/**/SKILL.md) - SIMPLE Framework
- Preserve official format: name, description with "Use when" triggers
- Preserve RFC manifest fields: tags, source, capability, usage, validation
- Model-invoked autonomous agents, minimal complexity
- Remove conversational content while keeping official trigger format

#### Commands (commands/**/*.md) - DEPTH Framework
- User-invoked slash commands with complex frontmatter
- Preserve allowed-tools, argument-hint, parameter defaults, usage examples
- Maintain exit codes and error handling for user guidance

#### Agents (agents/**/*.md) - COMPLEX Framework
- Subagents with separate contexts and specialized tools
- Preserve official fields: name, description, tools, model
- Preserve RFC manifest fields: default-skills, optional-skills, supported-commands, inputs, outputs, fail-fast, escalation, permissions
- Keep routing logic critical for delegation and skill relationships

#### Rules (rules/**/*.md) - SIMPLE Framework
- Imperative rules only, no narrative content allowed
- Preserve REQUIRED/PROHIBITED/OPTIONAL rule formats
- Remove all explanatory text, keep only direct commands

### 6. Dependency and Consistency

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

### 7. Review and Confirmation
For each file:
- Print original summary
- Print rewritten candidate
- Print DEPTH rationale
- Print derived test cases

Then request explicit confirmation for writeback.

### 8. Writeback
- When approved: Write candidate content to disk
  - Confirm all candidates files are written successfully
  - Validate post-write integrity against file-type requirements
- When denied: Leave all files unchanged and retain analysis output

### 9. Validation and Rollback

#### Pre-Write Validation
For each candidate file:
- Validate required frontmatter fields per file type
- Check preservation of critical patterns (defaults, examples, exit codes)
- Verify file-type specific structural requirements
- Ensure no critical information loss has occurred

#### Post-Write Verification
After writing files:
- Read back written files and compare with candidates
- Validate file integrity and structure maintenance
- Check that all critical patterns are preserved
- Run file-type specific validation rules

#### Rollback Capability
Maintain rollback information:
- Create backup timestamp before any modifications
- Store original file content in `~/.claude/backup/rollback-<timestamp>/`
- Provide recovery commands for each file type
- Enable selective or complete rollback if validation fails

#### Validation Reports
Official specification-based validation:
- Skills: Check "Use when" conditions and minimal frontmatter
- Commands: Verify complex frontmatter and user guidance preserved
- Agents: Confirm subagent fields and delegation logic intact
- Rules: Ensure only imperative rule formats remain

Status Messages:
- When validation fails: "Validation failed for <file_type>: <specific_issue>"
- When rollback needed: "Rollback initiated for <affected_files>"
- When successful: "File-type specific optimization completed successfully"

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
