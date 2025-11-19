# Optimize-Prompts Optimization Implementation

This directory contains the optimized implementation of the `/llm-governance/optimize-prompts` command with enhanced tool availability, validation, and dependency analysis capabilities.

## What Was Optimized

### Phase 1: Tool Chain Standardization (Completed)

1. Enhanced Environment Validation Skill
   - Added support for required tools: `rg`, `fd`, `ast-grep`, `find`
   - Implemented tool availability validation and fallback mechanisms
   - Added version checking and compatibility validation

2. Tool Fallback Strategy Implementation
   - File discovery: `fd` → `find` → Python pathlib
   - Text search: `rg` → `grep` → Python string methods
   - Structural analysis: `ast-grep` → pattern-based `rg` → manual parsing

3. Tool Availability Pre-Check Mechanism
   - `tool_checker.py` for automatic tool detection
   - Deterministic tool selection logic
   - Transparent fallback reporting

### Phase 2: Validation Enhancement (Completed)

4. Claude Code Style Specification Validator
   - `llm_spec_validator.py` for manifest and content compliance
   - Validates frontmatter fields, naming conventions, and content rules
   - Detects narrative content, emojis, and formatting violations

5. Dependency Graph Analysis
   - `dependency_analyzer.py` for cross-file consistency
   - Maps `skill:` and `agent:` references to actual files
   - Detects circular dependencies and invalid dependency directions
   - Validates RFC hierarchy compliance (`rules → skill → agent → command`)

6. Comprehensive System Testing
   - `system_test.py` for end-to-end validation
   - Tests tool availability, file structure, and compliance
   - Provides reporting with severity classification

## Files in This Directory

- `tool_checker.py` - Tool availability and fallback management
- `llm_spec_validator.py` - Specification-style compliance validator
- `dependency_analyzer.py` - Cross-file dependency relationship analyzer
- `system_test.py` - Comprehensive system testing framework
- `optimize-prompts.py` - Main optimized `/llm-governance/optimize-prompts` implementation
- `optimize-prompts-simple.py` - Simplified implementation without external dependencies
- `classification-rules.yaml` - Directory-based classification and preservation rules for LLM-facing files

## Usage

### Tool Availability Check

```bash
python3 commands/llm-governance/optimize-prompts/tool_checker.py
```

### Governance Validation

```bash
python3 commands/llm-governance/optimize-prompts/llm_spec_validator.py /path/to/.claude
```

### Dependency Analysis

```bash
python3 commands/llm-governance/optimize-prompts/dependency_analyzer.py /path/to/.claude
```

### Comprehensive System Test

```bash
python3 commands/llm-governance/optimize-prompts/system_test.py /path/to/.claude
```

### End-to-End Optimize-Prompts Execution

```bash
python3 commands/llm-governance/optimize-prompts/optimize-prompts.py --all --root /path/to/.claude
```

## Integration with Taxonomy and Rules

- Taxonomy source of truth: `docs/taxonomy-rfc.md`
- Directory classification and preservation behavior: `classification-rules.yaml`
- LLM prompt-writing rules and governance standards: `rules/99-llm-prompt-writing-rules.md`

`optimize-prompts.py` reads `classification-rules.yaml` to discover LLM-facing files, applies governance rules via `llm_spec_validator.py`, validates dependencies via `dependency_analyzer.py`, and orchestrates backups and optional writeback for approved changes.
