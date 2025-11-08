---
name: "config-sync:adapt-rules-content"
description: Adapt rule content for universal AI agent compatibility
argument-hint: --target=<droid|qwen|codex|opencode|all>
---

## Task
Analyze and adapt Claude-specific references in rule files to make them universally compatible across all AI development tools.

## Analysis Requirements
1. Identify Claude-specific references:
   - Scan all rule files for Claude-specific terminology
   - Find references to "Claude Memory", "Claude Code", etc.
   - Document all instances that need adaptation

2. Determine appropriate substitutions:
   - "Claude Memory" → "AI Memory" or "Agent Memory"
   - "Claude Code" → "AI Development Tool" or target tool name
   - Tool-specific references made generic

3. Adapt content for target tool:
   - Replace Claude-specific terminology with universal equivalents
   - Maintain technical accuracy and intent
   - Ensure content remains relevant for all AI agents

## Claude-Specific References Found

### Current References:
1. `00-memory-rules.md`:
   - "This file serves as both Claude Memory and is synchronized to other AI tools for consistent behavior."

2. `23-workflow-patterns.md`:
   - "Guidelines for development workflows, tool preferences, and coding practices that is integrated into Claude memory."
   - "### Tool Preferences to Store in Claude Memory"

## Adaptation Strategy

### Universal Substitutions:
- "Claude Memory" → "AI Memory" (most universal)
- "Claude Code" → "AI Development Tool" or target-specific name
- "Integrated into Claude memory" → "Available to AI agents"
- "Store in Claude Memory" → "Store in AI Memory"

### Target-Specific Adaptations:

#### For Factory/Droid CLI:
- "Claude Memory" → "Droid Memory"
- "Claude Code" → "Factory/Droid CLI"
- References align with DROID.md

#### For Qwen CLI:
- "Claude Memory" → "Qwen Memory"
- "Claude Code" → "Qwen CLI"
- References align with QWEN.md

#### For Codex CLI:
- "Claude Memory" → "Codex Memory"
- "Claude Code" → "Codex CLI"
- References align with CODEX.md

#### For Universal (all tools):
- "Claude Memory" → "AI Memory"
- "Claude Code" → "AI Development Tool"
- Make completely tool-agnostic

## Execution Process

### For each target tool:
1. Create adapted rule files:
   - Read original rule files from `~/.claude/rules/`
   - Apply target-specific substitutions
   - Preserve all technical content and structure
   - Update file headers and descriptions

2. Update synchronized rules:
   - Replace existing rule files in target directories
   - Maintain file structure and naming
   - Ensure proper file permissions

3. Verify adaptations:
   - Check that no Claude-specific references remain
   - Verify technical accuracy is maintained
   - Test that content flows naturally with substitutions

## Quality Assurance

### Content Integrity:
-  Technical guidelines remain unchanged
-  Code examples and practices preserved
-  Rule structure and organization maintained
-  Cross-references between rules still work

### Language Consistency:
-  Substitutions feel natural and appropriate
-  No awkward phrasing or grammatical issues
-  Technical terminology remains accurate
-  Professional tone maintained

### Tool Appropriateness:
-  References align with target tool's memory file
-  Context makes sense for each specific tool
-  No conflicting terminology introduced

## Output Requirements

### Generate:
- Adapted rule files for each target tool
- Summary of changes made
- Verification that all Claude references have been addressed
- Recommendation for ongoing maintenance

### Document:
- List of all substitutions made
- Before/after comparisons for major changes
- Any content that required creative adaptation
- Guidelines for future rule updates

## Safety Considerations
- Back up original rule files before modification
- Test that technical accuracy is preserved
- Ensure no loss of important information
- Maintain ability to rollback changes if needed

## Usage Examples
```bash
# Adapt for all target tools
/config-sync:adapt-rules-content--target=all

# Adapt for specific tool
/config-sync:adapt-rules-content--target=droid

# Create universal version
/config-sync:adapt-rules-content--target=universal
```