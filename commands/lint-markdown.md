---
description: Validate markdown formatting with taxonomy-based rules using Python validator
name: lint-markdown
argument-hint: "[path] [--strict] [--fix] [--report] [--quick]"
allowed-tools:
  - Bash
  - Read
  - Bash(python3 skills/llm-governance/scripts/validator.py *)
metadata:
  is_background: False
  style: minimal-chat
---

# Markdown Lint Command

## Purpose

Validate markdown files using Python validator with taxonomy-based classification rules. Perform
STRICT checking for LLM-facing files, MODERATE for governance files, and LIGHT for other markdown content. Generate structured reports with validation findings.

## Usage

```bash
/lint-markdown [path] [--strict] [--fix] [--report] [--quick]
```

## Arguments

- path: File or directory to lint (default: current directory)
- --strict: Limit scope to LLM-facing files (commands/, skills/**/SKILL.md, agents/**/AGENT.md, rules/**, AGENTS.md, CLAUDE.md)
- --fix: Automatically fix format issues where possible (uses remark --output)
- --report: Emit JSON statistics to stdout (temporary file under /tmp, repo stays clean)
- --quick: Fast pass on LLM-facing + governance files only (commands/, skills/**/SKILL.md, agents/**/AGENT.md, rules/**, governance/, config-sync/, agent-ops/)

## Workflow

1. Route to router:workflow-helper → agent:lint-markdown
2. Load default skills:
   - skill:lint-markdown (primary)
   - skill:workflow-discipline (required)
   - skill:environment-validation (required)
3. Execute Python validator with taxonomy-based file classification and flag-specific scopes
4. Generate structured report with issue categorization
5. Note: Auto-fix capabilities are planned for future implementation

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
