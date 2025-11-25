---
name: language-python
description: Python language patterns and best practices. Use when language python
  guidance is required or when selecting a primary language for non-trivial automation.
layer: execution
mode: language-guidelines
capability-level: 1
allowed-tools:
  - Bash(uv)
  - Bash(ruff)
  - Bash(pytest)
---
## Key Execution Capabilities

### Code Validation
- Run syntax and type checking: `ruff check`, `mypy`
- Execute linting and formatting with ruff
- Run tests with pytest
- Validate project structure and dependencies

### Tool Integration
- Use `ruff` for linting, formatting, and code analysis
- Leverage `uv` for package management and virtual environments
- Apply pytest for testing frameworks
- Execute mypy for type checking

### Execution Context
- Process Python files from filesystem layer
- Generate structured reports with findings
- Create minimal, rule-compliant patches for violations
- Maintain separation between governance rules and execution tools

## Error Handling

This skill provides execution-layer error handling for Python code analysis:
- Invalid Python syntax or imports
- Missing dependencies or tools
- Type checking failures
- Test execution errors

## Usage Notes

- Always delegate to governance rules for policy decisions
- Focus on concrete tool execution and result processing
- Provide deterministic, tool-first analysis results
- Maintain separation between rule definition and rule application
