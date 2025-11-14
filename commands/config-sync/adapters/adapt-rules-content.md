---
file-type: command
command: /config-sync:adapt-rules-content
description: Adapt Claude rule content for universal AI agent compatibility across target tools
implementation: commands/config-sync/adapters/adapt-rules-content.md
argument-hint: "--target=<droid|qwen|codex|opencode|amp|all>"
scope: Included
allowed-tools:
  - Read
  - Write
  - Bash
  - Bash(fd:*)
  - Bash(rg:*)
  - Bash(cat:*)
disable-model-invocation: true
related-commands:
  - /config-sync/sync-cli
related-agents:
  - agent:config-sync
related-skills:
  - skill:workflow-discipline
---

## usage

Execute conversion of Claude-specific rule content to target tool terminology while preserving technical guidelines and maintaining functionality across AI platforms.

## arguments

- `--target`: Target AI tool platform
  - `droid`: Factory/Droid CLI memory references
  - `qwen`: Qwen CLI terminology adaptation
  - `codex`: OpenAI Codex CLI content conversion
  - `opencode`: OpenCode CLI reference updates
  - `amp`: Amp CLI AGENTS.md integration
  - `all`: Create universal tool-agnostic versions

## workflow

1. Content Analysis: Scan rule files for Claude-specific terminology and references
2. Target Mapping: Determine appropriate substitutions per tool requirements
3. Content Adaptation: Apply terminology replacements while preserving technical content
4. Reference Updates: Update memory file references and tool-specific mentions
5. Quality Validation: Ensure accuracy preservation and natural language flow
6. File Generation: Create target-compatible rule files
7. Integration Testing: Verify cross-rule references and structure integrity

### substitution-mappings

Universal Replacements:
- "Claude Memory" → "AI Memory"
- "Claude Code" → "AI Development Tool"
- "Store in Claude Memory" → "Store in AI Memory"
- "Integrated into Claude memory" → "Available to AI agents"

Target-Specific Adaptations:
- Factory/Droid: Claude Memory → Droid Memory
- Qwen CLI: Claude Memory → Qwen Memory, Claude Code → Qwen CLI
- Codex CLI: Claude Memory → Codex Memory, Claude Code → Codex CLI
- OpenCode: Align with OPENCODE.md references
- Amp CLI: Claude Memory → AGENTS.md guidance, `@CLAUDE.md` → `@AGENTS.md`

### content-preservation-rules

Technical Integrity:
- Preserve all code examples, best practices, and technical guidelines
- Maintain rule structure and organizational hierarchy
- Keep cross-references between rules functional
- Ensure technical terminology accuracy

Language Consistency:
- Apply natural, contextually appropriate substitutions
- Maintain professional tone and grammatical correctness
- Avoid awkward phrasing or forced terminology changes
- Preserve readability and comprehension

Tool Appropriateness:
- Align references with target tool's memory system
- Ensure context relevance for each specific platform
- Avoid conflicting terminology within adapted content
- Maintain coherence with target tool's documentation style

## output

Generated Files:
- Target-adapted rule files with updated terminology
- Preserved technical content and structure
- Updated file headers and descriptions

Documentation:
- Comprehensive substitution report with all changes made
- Before/after comparisons for significant modifications
- Guidelines for future rule content maintenance
- Quality assurance validation results

Quality Reports:
- Content integrity verification results
- Language consistency assessment
- Tool appropriateness validation
- Cross-reference functionality testing

## quality-assurance

1. Content Verification:
   - Technical guidelines unchanged from original
   - Code examples and practices preserved completely
   - Rule structure and organization maintained
   - Cross-rule references remain functional

2. Language Validation:
   - Substitutions appear natural and appropriate
   - No grammatical issues or awkward phrasing
   - Technical terminology remains accurate
   - Professional tone consistently maintained

3. Tool Compatibility:
   - References align with target tool memory files
   - Context makes sense for each specific platform
   - No conflicting terminology introduced
   - Integration with tool documentation verified

## safety-constraints

1. Backup Creation: Generate backups of original rule files before modification
2. Content Integrity: Verify no loss of important technical information
3. Rollback Capability: Maintain ability to restore original content if needed
4. Validation Testing: Test that adaptations maintain rule effectiveness
5. Reference Consistency: Ensure all internal references remain valid

## examples

```bash
# Adapt rules for all target tools
/config-sync:adapt-rules-content --target=all

# Create universal tool-agnostic version
/config-sync:adapt-rules-content --target=amp

# Adapt for specific tool platform
/config-sync:adapt-rules-content --target=droid
```

## error-handling

Processing Errors:
- Invalid target specification: List supported platforms and exit
- File access permissions: Log specific file errors, continue with available files
- Content parsing failures: Skip problematic files, document issues

Quality Issues:
- Awkward substitutions detected: Flag for manual review
- Technical accuracy concerns: Require validation before completion
- Reference validation failures: Generate detailed error reports

Integration Problems:
- Cross-rule reference failures: Document broken links, provide fixes
- Tool compatibility issues: Flag for manual adaptation
- Structure preservation failures: Require manual intervention
