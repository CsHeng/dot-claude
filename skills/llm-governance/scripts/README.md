# LLM Governance Scripts

This directory contains the complete implementation of the `/llm-governance` command, including validation scripts, tool management, dependency analysis, and system testing for LLM-facing files (skills, agents, commands, rules, and governance files).

## Architecture

All validation and optimization logic is encapsulated in this skill directory, following the Taxonomy v3 architecture:

- **Configuration Source**: `config.yaml` - Single Source of Truth (SSOT) for all validation rules, classification, and metadata standards
- **Schema Loader**: `schema_loader.py` - Loads and provides access to config.yaml definitions
- **Validator**: `validator.py` - Main validation engine using config.yaml definitions
- **Optimizer**: `optimize-prompts.py` - Main command implementation with tool fallbacks and dependency analysis

## Files

### Core Validation
- `config.yaml` - Unified configuration (SSOT) containing:
  - Classification rules for all LLM-facing file types (including governance directory)
  - Frontmatter schemas for all manifest types (skill, agent, command, rule-block, router, entrypoint, output-style)
  - Metadata validation rules (distinguishing official fields vs custom metadata fields)
  - Content validation rules
  - Severity level definitions
- `schema_loader.py` - Config loading and access utilities
- `validator.py` - Main validation engine (validates only, does not fix files)

### Optimization & Analysis
- `optimize-prompts.py` - Main optimized `/llm-governance` implementation
- `tool_checker.py` - Tool availability and fallback management
- `dependency_analyzer.py` - Cross-file dependency relationship analyzer
- `system_test.py` - Comprehensive system testing framework

### Configuration
- `config.yaml` - Unified SSOT configuration (replaces `schema.yaml` and `classification-rules.yaml`)

### AgentOps Utilities
- `agent-matrix.sh` - Generate agent capability matrix for health reporting
- `skill-matrix.sh` - Generate skill capability matrix for health reporting
- `structure-check.sh` - Validate taxonomy-rfc compliance and structural integrity

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
   - `validator.py` for manifest and content compliance
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

## Usage

### Tool Availability Check

```bash
python3 skills/llm-governance/scripts/tool_checker.py
```

### Governance Validation

```bash
python3 skills/llm-governance/scripts/validator.py /path/to/.claude
```

### Dependency Analysis

```bash
python3 skills/llm-governance/scripts/dependency_analyzer.py /path/to/.claude
```

### Comprehensive System Test

```bash
python3 skills/llm-governance/scripts/system_test.py /path/to/.claude
```

### End-to-End LLM Governance Execution

```bash
python3 skills/llm-governance/scripts/optimize-prompts.py --all --root /path/to/.claude
```

### From Agent/Skill

The validator is called by `agent:llm-governance` through `skill:llm-governance`:

```bash
Bash(python3 skills/llm-governance/scripts/validator.py *)
Bash(python3 skills/llm-governance/scripts/optimize-prompts.py *)
```

## Validation Rules

The validator checks:

1. **Frontmatter Key Order**: Required fields → Optional fields → metadata (in schema order)
2. **Metadata Key Order**: Metadata keys must be alphabetically sorted
3. **Field Placement**: 
   - Custom metadata fields must be in metadata section (critical error if in top-level)
   - Official fields must be in top-level (critical error if in metadata section)
4. **Indentation**: All keys and list items must have correct indentation
5. **YAML Syntax**: Frontmatter must be valid YAML
6. **Field Validation**: Required fields present, field types correct, value constraints
7. **Metadata Field Validation**: Custom metadata fields validated against metadata_rules (capability-level, loop-style, layer, sources, style, etc.)
8. **Content Rules**: Prohibited elements (emojis, bold markers, narrative content)
9. **Governance File Types**: Validates rule-block, router, entrypoint, and output-style files

The validator **only validates** - it does not automatically fix files. Files must be manually corrected to pass validation.

## Configuration Structure

The `config.yaml` file (SSOT) defines:

1. **Classification Rules**: Directory-based classification for all LLM-facing file types including governance directory (Layer 2)
2. **Frontmatter Schemas**: Required/optional official fields and custom metadata fields for all manifest types:
   - Execution layer: skill, command, agent
   - Governance layer: rule-block, router, entrypoint, output-style
3. **Metadata Rules**: Complete metadata validation system distinguishing:
   - Official fields (top-level): name, description, allowed-tools, etc.
   - Custom metadata fields (metadata section): capability-level, loop-style, layer, sources, style, etc.
4. **Content Rules**: Prohibited elements, style requirements
5. **Validation Rules**: Field validation patterns, length limits, type constraints
6. **Structural Requirements**: Required sections based on capability levels

**Key Principle**: All custom metadata fields must be placed in the `metadata` section to avoid conflicts with Claude Code official fields. Official fields must remain in top-level frontmatter.

## Adding New Validation Rules

To add new validation rules:

1. Update `config.yaml` with the new rule definition
2. Update `validator.py` if new validation logic is needed
3. Test with: `python3 validator.py <directory>`

## Integration with Taxonomy and Rules

- Taxonomy source of truth: `docs/taxonomy-rfc.md`
- Directory classification and preservation behavior: `config.yaml` (classification section)
- LLM prompt-writing rules and governance standards: `skills/llm-governance/rules/99-llm-prompt-writing-rules.md`
- Metadata standards: `skills/llm-governance/rules/96-metadata-standards.md`

`optimize-prompts.py` reads `config.yaml` to discover LLM-facing files (including governance directory), applies governance rules via `validator.py`, validates dependencies via `dependency_analyzer.py`, and orchestrates backups and optional writeback for approved changes.

## Governance Directory Support

llm-governance manages all LLM-facing files including:
- **Layer 2 (Governance)**: `governance/rules/`, `governance/routers/`, `governance/entrypoints/`, `governance/styles/`
- **Layer 3 (Execution)**: `agents/`, `skills/`, `commands/`
- **Core Config**: `AGENTS.md`, `CLAUDE.md`, `.claude/settings.json`

All governance files are validated against their respective schemas defined in `config.yaml`, with proper distinction between official fields and custom metadata fields.

## Migration Notes

This directory was created as part of the governance validation unification:

- Previously: Validation scripts were in `commands/llm-governance/optimize-prompts/`
- Now: All validation and optimization logic is encapsulated in `skills/llm-governance/scripts/`
- Schema: Single source of truth replaces hardcoded definitions

