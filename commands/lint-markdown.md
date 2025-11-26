---
name: lint-markdown
description: Validate markdown formatting with taxonomy-based rules and auto-fix capabilities
argument-hint: "[path] [--strict] [--fix] [--report] [--quick]"
allowed-tools:
  - Bash
  - Read
  - Bash(npm run lint:md)
  - Bash(npm run lint:md:fix)
  - Bash(npm run lint:md:report)
is_background: false
style: minimal-chat
---

# Markdown Lint Command

## Purpose

Validate markdown files using remark with taxonomy-based classification rules. Perform
STRICT checking for LLM-facing files, MODERATE for governance files, and LIGHT for
other markdown content. Generate structured reports with auto-fix suggestions.

## Usage

```bash
/lint-markdown [path] [--strict] [--fix] [--report] [--quick]
```

## Arguments

- path: File or directory to lint (default: current directory)
- --strict: Apply only STRICT-level rules (LLM-facing files)
- --fix: Automatically fix format issues where possible
- --report: Generate JSON report instead of terminal output
- --quick: Skip files matching .remarkignore, faster scanning

## Workflow

1. Route to router:workflow-helper → agent:lint-markdown
2. Load default skills:
   - skill:lint-markdown (primary)
   - skill:workflow-discipline (required)
   - skill:environment-validation (required)
3. Execute linting with taxonomy-based file classification
4. Generate structured report with issue categorization
5. Apply auto-fixes when --fix parameter is specified

## What it checks

- LLM-facing file compliance (commands/, skills/, agents/, rules/)
- Governance file standards (governance/, config-sync/)
- Basic markdown validation (all other .md files)
- Frontmatter formatting
- Heading order and structure
- Narrative style (imperative vs subjective)
- Prohibited elements (emojis, strong emphasis, modal verbs)
- Line length limits

## Output

- Issue count by severity (error, warning)
- Classification breakdown (STRICT/MODERATE/LIGHT)
- File-by-file results with line numbers
- Auto-fix summary when applicable
- Remediation recommendations organized by priority