---
skill: llm-governance
version: 2.0.0
description: LLM content governance and compliance standards
confidence: high
impact: high
status: active
allowed-tools:
  - Bash(rg --pcre2 '\\*\\*')
  - Bash(rg --pcre2 '\\p{Extended_Pictographic}')
  - Bash(rg --pcre2 '(?<![\\`\\\\])\\*\\*(?![\\`/\\\\\\s])')
  - Bash(rg --pcre2 '\\b(should|could|would|might|may)\\b')
  - Read
  - Write
  - Edit
---

# LLM Content Governance Standards

## ABSOLUTE Mode Enforcement

### Communication Style Requirements

Apply ABSOLUTE mode principles:
- Use terse, directive communication
- Maintain high content density
- Eliminate conversational filler and hedging
- Focus on actionable instructions without explanation

Content density optimization:
- Remove introductory phrases and background context
- Use imperative verbs for all procedural content
- Structure content for direct execution
- Maintain precision in language without ambiguity

### Modal Verb Elimination

Replace modal verbs with imperative equivalents:

Conversion patterns:
- "should use" → "use"
- "could implement" → "implement"
- "would recommend" → "apply"
- "might want to" → "apply"
- "may need to" → "ensure"

Imperative tone enforcement:
- Audit content for modal verb usage
- Convert all conditional language to direct commands
- Maintain meaning while improving directness
- Validate conversions preserve technical requirements

## Content Formatting Standards

### Bold Marker Elimination

Remove all non-code bold formatting:
- Search pattern: `(?<![\\`\\\\])\\*\\*(?![\\`/\\\\\\s])`
- Preserve bold markers within code blocks only
- Replace with plain text equivalents
- Ensure structural clarity without formatting emphasis

Code block exception handling:
- Allow bold markers within triple backticks
- Preserve formatting in shell commands
- Maintain markdown syntax integrity
- Validate code block boundaries accurately

### Unicode Character Removal:

Eliminate all emoji characters:
- Search pattern: `\\p{Extended_Pictographic}`
- Replace emojis with text descriptions when required
- Maintain only standard ASCII characters
- Preserve technical Unicode symbols when appropriate

Character validation standards:
- Use only printable ASCII characters (32-126)
- Allow technical symbols and punctuation
- Remove decorative Unicode elements
- Ensure text-only presentation

## File Scope Compliance

### Target File Identification

Apply governance to specific file types:
- `commands/**/*.md`
- `skills/**/*.md`
- `rules/**/*.md`
- `CLAUDE.md`
- `AGENTS.md`
- `.claude/settings.json`
- Files containing "prompt" in filename

Content categorization:
- LLM-facing documentation files
- Configuration files with LLM interaction
- Template and prompt files
- System instruction files

### Comprehensive Coverage Validation

Ensure complete governance application:
- Scan filesystem for all target files
- Validate each file meets governance standards
- Document any exceptions with justification
- Apply consistent rules across all target content

## Content Structure Standardization

### Hierarchical Organization

Implement consistent content structure:
- Use logical heading hierarchy (H1, H2, H3)
- Apply numbered sections for procedural content
- Use bullet lists for options and requirements
- Structure content for scannability and navigation

Template enforcement:
- Apply consistent section ordering
- Use standardized frontmatter when applicable
- Implement uniform formatting conventions
- Validate structure enhances readability

### Section Ordering Canonicalization

Apply standard section sequence:
1. Core Standards (highest priority)
2. Implementation Patterns (execution guidance)
3. Validation Criteria (compliance checking)
4. Tool Safety (operational constraints)

Content validation:
- Ensure logical flow from principles to implementation
- Validate section completeness
- Check for redundant or misplaced content
- Optimize information architecture

## Quality Assurance Procedures

### Automated Validation

Implement regex-based content checking:
```bash
# Bold marker detection
rg --pcre2 '(?<![\\`\\\\])\\*\\*(?![\\`/\\\\\\s])' --line-number

# Emoji detection
rg --pcre2 '\\p{Extended_Pictographic}' --line-number

# Modal verb detection
rg --pcre2 '\\b(should|could|would|might|may)\\b' --line-number

# Conversational pattern detection
rg --pcre2 '\\b(hello|hi|hey|thanks|please|sorry)\\b' --line-number
```

Automated correction scripts:
```bash
#!/bin/bash
# govern-content.sh

set -euo pipefail

# Remove bold markers outside code blocks
remove_bold_markers() {
    local file="$1"
    rg --pcre2 '(?<![\\`\\\\])\\*\\*(?![\\`/\\\\\\s])' --replace '' "$file" --passthru > "$file.tmp"
    mv "$file.tmp" "$file"
}

# Replace modal verbs
replace_modal_verbs() {
    local file="$1"
    sed -i.tmp \
        -e 's/should/use/g' \
        -e 's/could/implement/g' \
        -e 's/would/apply/g' \
        -e 's/might want to/apply/g' \
        -e 's/may need to/ensure/g' \
        "$file"
    rm "$file.tmp"
}
```

### Manual Review Standards

Content validation criteria:
- Verify technical accuracy maintained after corrections
- Check for unintended meaning changes
- Validate procedural completeness
- Ensure formatting doesn't interfere with functionality

Review process:
- Stage corrections in separate branches
- Validate corrections with test execution
- Document any intentional exceptions
- Maintain audit trail of governance changes

## Compliance Monitoring

### Continuous Compliance Tracking

Implement ongoing governance validation:
- Schedule regular content audits
- Monitor new file additions for compliance
- Track compliance metrics over time
- Address violations systematically

Deviation documentation:
- Document any necessary exceptions
- Provide justification for non-compliance
- Track exception approval processes
- Review exceptions regularly for necessity

### Integration with Development Workflow

Incorporate governance in CI/CD:
- Add governance checks to pull request validation
- Block non-compliant content from merging
- Provide automated correction suggestions
- Maintain governance as part of quality gates

Developer guidance:
- Provide clear governance requirements
- Offer templates and examples
- Include governance in onboarding materials
- Maintain governance documentation updates