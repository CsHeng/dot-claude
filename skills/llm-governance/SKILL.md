---
name: skill:llm-governance
description: LLM content governance and compliance standards. Use when llm governance guidance is required.
allowed-tools:
- Bash(python3 commands/llm-governance/optimize-prompts/tool_checker.py *)
- Bash(python3 commands/llm-governance/optimize-prompts/claude_code_validator.py *)
- Read
- Write
- Edit
---

## Purpose

Enforce LLM content governance for all LLM-facing files using ABSOLUTE mode, rule-driven validation, and deterministic tooling.

Apply rules from `rules/99-llm-prompt-writing-rules.md` and related governance rule files through standardized validators instead of ad-hoc scripts.

## IO semantics

Input: LLM-facing markdown and configuration files.

Output: Governance findings, severity classifications, suggested edits, and updated files when explicitly approved by higher-level commands.

Side effects: Backups created by orchestration commands before modifications; no direct writes required when running validation only.

## Deterministic Steps

### 1. Toolchain Validation

- Use `tool_checker.py` to confirm availability of required tools and select fallbacks.
- Abort governance execution for this skill when critical tools are missing and cannot be replaced safely.

### 2. Target Selection

- Select LLM-facing files using directory classification:
  - `commands/**/*.md`
  - `skills/**/SKILL.md`
  - `agents/**/AGENT.md`
  - `rules/**/*.md`
  - `CLAUDE.md`
  - `AGENTS.md`
  - `.claude/settings.json`
- Exclude non LLM-facing directories such as documentation, examples, tests, IDE metadata, backup directories, and any file containing `dont-optimize: true` in frontmatter.

### 3. Automated Validation

- Run `python3 commands/llm-governance/optimize-prompts/claude_code_validator.py <directory>` across the selected scope.
- For each file, detect:
  - Body bold markers outside code blocks.
  - Emoji and decorative Unicode characters.
  - Narrative paragraphs and conversational patterns.
  - Missing or malformed frontmatter for skills, agents, commands, rules, and memory files.
- Classify violations by severity using rule definitions from `rules/99-llm-prompt-writing-rules.md`.

### 4. Content Normalization Guidelines

- Enforce ABSOLUTE mode:
  - Rewrite narrative paragraphs into imperative directives.
  - Remove conversational fillers and hedging language.
  - Maintain high information density and precise terminology.
- Enforce formatting rules:
  - Remove non code bold markers from body content.
  - Remove emoji and non-essential decorative Unicode characters.
  - Preserve code blocks and required technical symbols.
- Enforce structural rules:
  - Ensure required frontmatter fields and section ordering per directory classification.
  - Normalize heading levels and list formatting for clarity and determinism.

### 5. Integration with Orchestration Commands

- Delegate bulk analysis, candidate generation, backup creation, and writeback decisions to `/llm-governance/optimize-prompts` and `agent:llm-governance`.
- Use this skill to interpret validator results, derive rewrite strategies, and keep governance behavior aligned with rule files.

## Validation Criteria

- No body bold markers outside code blocks in LLM-facing files.
- No emoji or decorative Unicode characters in governed content.
- Communication is terse, directive, and ABSOLUTE-mode compliant.
- Required frontmatter fields and sections are present for each governed directory classification.
- All governance violations are either resolved or documented with justification in governance reports.
