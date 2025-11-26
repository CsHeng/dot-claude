---
name: lint-markdown
description: Execute markdown linting with taxonomy-based classification and custom rules.
  Use when validating markdown compliance with LLM-facing writing standards or when
  generating structured linting reports with automatic fix capabilities.
layer: execution
mode: validation-and-reporting
capability-level: 1
style: minimal-chat
allowed-tools:
  - Bash(remark)
  - Bash(npm)
  - Read
  - Glob
  - Grep
related-skills:
  - skill:workflow-discipline
  - skill:environment-validation
---

## Purpose

Execute remark-based markdown linting with three-tier classification based on taxonomy-rfc.md:
STRICT files require full compliance with LLM-facing standards, MODERATE files apply
governance rules, and LIGHT files receive basic validation.

## IO Semantics

Input: File paths, directories, or global workspace scope with optional parameters.

Output: Structured linting reports with issue categorization, severity levels, and
auto-fix suggestions when applicable.

Side Effects: Updates target files when using --fix parameter, generates
structured reports in JSON or human-readable format.

## Deterministic Steps

### 1. Environment Validation

- Verify remark CLI availability through npm scripts.
- Confirm .remarkrc.mjs configuration exists and loads properly.
- Validate .remarkignore patterns exclude appropriate file types.

### 2. File Classification

- Apply STRICT classification to LLM-facing files:
  commands/**/*.md, skills/**/SKILL.md, agents/**/AGENT.md, rules/**/*.md,
  AGENTS.md, CLAUDE.md
- Apply MODERATE classification to governance files:
  governance/**/*.md, config-sync/**/*.md, agent-ops/**/*.md
- Apply LIGHT classification to remaining markdown files.
- Exclude human-facing docs per .remarkignore: docs/, examples/, tests/, ide/

### 3. Linting Execution

- Run appropriate npm script based on requested mode:
  npm run lint:md for standard validation
  npm run lint:md:report for JSON output
  npm run lint:md:fix for automatic fixes
- Parse remark output and categorize issues by severity and type.

### 4. Report Generation

- Aggregate results by file classification and issue type.
- Generate structured summary with:
  - Total issue count and severity breakdown
  - Classification-specific compliance metrics
  - Auto-fix success rate where applicable
- Provide actionable recommendations organized by priority.

### 5. Validation Compliance

- Ensure all processing respects rules/99-llm-prompt-writing-rules.md constraints.
- Apply imperative communication patterns in all output.
- Maintain 100-character line limits in generated reports.

## Safety Constraints

- Never modify files without explicit --fix parameter.
- Preserve original file content through backup mechanisms when fixing.
- Respect .remarkignore exclusions and never scan excluded directories.
- Validate tool chain compatibility before executing remark commands.