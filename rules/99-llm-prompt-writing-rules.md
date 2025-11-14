---
dont-optimize: true
---

# LLM Prompt Writing Rules

## scope
MANDATORY on:
- commands/**/*.md
- skills/**/SKILL.md
- agents/**/AGENT.md
- AGENTS.md
- rules/**/*.md
- CLAUDE.md
- .claude/settings.json

EXCLUDED:
docs/**, README*, src/**, examples/**, tests/**, ide/**

ALWAYS SKIPPED BY OPTIMIZER:
- any file containing dont-optimize: true
- rules/99-llm-prompt-writing-rules.md
- any file with file-type: rule

## absolute-prohibitions
PROHIBITED use of markdown bold syntax of form `**text**` inside body content
PERMITTED bold markers inside frontmatter
PROHIBITED emojis
PROHIBITED conversational tone
PROHIBITED narrative explanation
PROHIBITED modal verbs in body content: may, might, could
EXCEPTION: normative rule definitions may include modal verbs when required
PROHIBITED ambiguous phrasing
PROHIBITED rephrasing of user input
PROHIBITED emotional alignment

## communication-protocol
REQUIRED imperative or declarative syntax  
REQUIRED terse, directive, high-density content  
REQUIRED termination immediately after core content  
REQUIRED meta explanations only when essential  

## structural-rules

### canonical-ordering
REQUIRED canonical ordering for all rule files:
1. scope
2. absolute-prohibitions
3. communication-protocol
4. structural-rules
5. language-rules
6. formatting-rules
7. naming-rules
8. validation-rules
9. narrative-detection
10. depth-compatibility

### command-files
REQUIRED YAML frontmatter  
REQUIRED frontmatter key order:
1. name
2. description
3. argument-hint
4. allowed-tools
5. is_background

REQUIRED types:
- name: string  
- description: string  
- argument-hint: string  
- allowed-tools: list  
- is_background: boolean  

REQUIRED body sections:
- usage  
- arguments  
- workflow  
- output  

REQUIRED deterministic instruction sequences  

### skill-files
REQUIRED frontmatter:
- name: string  
- description: string  
OPTIONAL: allowed-tools: list  
REQUIRED IO semantics  
REQUIRED deterministic, tool-safe steps  

### agent-files
REQUIRED agent role definition  
REQUIRED required-skills list  
REQUIRED workflow phases  
REQUIRED decision policies  
REQUIRED error handling patterns  

### rule-files
REQUIRED canonical ordering  
REQUIRED imperative directives  
PROHIBITED narrative text  
REQUIRED terminology normalization  

### memory-files
OPTIONAL frontmatter  
REQUIRED deterministic ordering  
REQUIRED explicit rule-loading conditions  
PROHIBITED conversational content  

### directory-exceptions
CRITICAL: Different directory classifications have specific preservation requirements:

#### commands-file-exceptions
MUST PRESERVE:
- Default parameter values: `(default: value)`
- Usage examples in code blocks
- Exit codes and error handling
- Safety constraints and security information
- Tool permissions and allowed-tools lists
- Argument definitions with complete specifications

MUST NOT remove:
- `## Examples` sections with practical usage
- Error scenarios with exit codes
- Safety and backup procedures
- Parameter default value declarations

#### skills-file-exceptions
MUST PRESERVE:
- Official trigger conditions: `description: ... Use when ...`
- Claude Code compliance requirements
- Essential capability descriptions
- Required YAML frontmatter fields: name, description
- RFC manifest fields: tags, source, capability, usage, validation
MUST NOT remove:
- "Use when" trigger clauses in descriptions
- Official frontmatter fields per Claude Code spec

#### agents-file-exceptions
MUST PRESERVE:
- Routing logic and command patterns
- Agent-skill dependency mappings
- Escalation rules and decision policies
- Workflow phases and dependencies
- Error handling and failure scenarios
- RFC manifest fields: default-skills, optional-skills, supported-commands, inputs, outputs, fail-fast, escalation, permissions
MUST NOT remove:
- Official frontmatter fields: name, description, tools, model
- RFC-compliant manifest structure
- Agent routing and delegation logic

#### core-config-exceptions
MUST PRESERVE:
- System routing mappings
- Agent selection conditions
- Permission and type definitions
- Critical dependency relationships
- Directory and scope declarations

## language-rules
REQUIRED directives starting with action verbs  
REQUIRED removal of ambiguity and soft modals  
REQUIRED explicit REQUIRED, OPTIONAL, PROHIBITED labels  
REQUIRED consistent terminology across all files  

## formatting-rules
PROHIBITED markdown bold in body content  
PERMITTED bold markers in frontmatter  
REQUIRED plain markdown  
REQUIRED language markers for all code blocks  
REQUIRED lowercase kebab-case filenames  
REQUIRED directory semantics aligned with purpose  

## naming-rules
REQUIRED lowercase kebab-case filenames  
REQUIRED semantic directory placement  
REQUIRED directive naming for rule files  
REQUIRED consistent naming patterns across file categories  

## validation-rules

### content-standards
REQUIRED high information density  
REQUIRED deterministic, unambiguous content  
REQUIRED tool safety  
PROHIBITED harmful content  

### structure-standards
REQUIRED canonical ordering for all directory classifications  
PROHIBITED missing required sections  
REQUIRED frontmatter compliance for command and skill files  
PROHIBITED inconsistent heading structures  

### compliance-standards
REQUIRED consistency with skill and agent dependencies  
REQUIRED cross-file consistency  
PROHIBITED broken references  
REQUIRED alignment with repository directory semantics  

## narrative-detection
A paragraph is narrative when any condition holds:
- does not begin with an action verb  
- contains subjective adverbs: usually, typically, generally, often  
- contains modal verbs: may, might, could  
- contains multiple sentences without explicit directives  

Narrative paragraphs MUST be removed or rewritten into imperative form.

## depth-compatibility
Rewrite commands rely on the DEPTH model. Files must satisfy:

decomposition:
- purpose, sections, and dependencies must be extractable

explicit reasoning:
- constraints, assumptions, and invariants must be derivable from the content

parameters:
- frontmatter and structure must fully specify behavior  
- required fields must be present and normalized

tests:
- normal, edge, and failure cases must be inferable

heuristics:
- rules must be compatible with deterministic normalization and tool-safety
