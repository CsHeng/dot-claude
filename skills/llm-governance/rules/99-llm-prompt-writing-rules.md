# LLM Prompt Writing Rules

## Scope

REQUIRED on all LLM-facing files in the Claude Code configuration system:
- commands/**/*.md
- skills/**/SKILL.md
- agents/**/AGENT.md
- rules/**/*.md
- AGENTS.md
- CLAUDE.md
- .claude/settings.json

Excluded from governance: docs/**, README*, commands/**/README*.md, src/**, examples/**, tests/**, ide/**

## Absolute Prohibitions

PROHIBITED markdown bold markers in body content
PROHIBITED emojis
PROHIBITED conversational tone
PROHIBITED narrative explanation
PROHIBITED modal verbs in body content: may, might, could
PROHIBITED ambiguous phrasing
PROHIBITED rephrasing of user input
PROHIBITED emotional alignment

PERMITTED bold markers inside frontmatter only

## Communication Protocol

REQUIRED imperative or declarative syntax
REQUIRED terse, directive, high-density content
REQUIRED termination immediately after core content
REQUIRED meta explanations only when essential

## Structural Rules

### Canonical Ordering

REQUIRED canonical ordering for all rule files:
1. Scope
2. Absolute Prohibitions
3. Communication Protocol
4. Structural Rules
5. Language Rules
6. Formatting Rules
7. Naming Rules
8. Validation Rules
9. Narrative Detection
10. Depth Compatibility

### Command Files

REQUIRED align frontmatter with official Claude Code command schema
- name derived from filename (not required in frontmatter)
- description defaults to first body line when omitted
- allowed-tools is optional (list or comma-separated string)
- argument-hint is optional string describing positional parameters
- model is optional model override
- disable-model-invocation is optional boolean (default false)

RECOMMENDED core body sections: Usage, Arguments, Workflow, Output
REQUIRED deterministic instruction sequences

### Skill Files

REQUIRED manifest schema compliance with skills/llm-governance/rules/97-skills-manifest-standards.md
REQUIRED frontmatter fields name and description
REQUIRED explicit IO semantics in body content
REQUIRED deterministic, tool-safe steps in body content

allowed-tools field is optional (list or comma-separated string)

### Agent Files

REQUIRED manifest schema compliance with skills/llm-governance/rules/97-agents-manifest-standards.md
REQUIRED frontmatter fields name and description
REQUIRED explicit agent role definition in body content
REQUIRED body sections describing required skills, workflow phases, decision policies, and error handling patterns

tools/allowed-tools field is optional (list or comma-separated string)

### Rule Files

REQUIRED canonical ordering
REQUIRED imperative directives
PROHIBITED narrative text
REQUIRED terminology normalization

### Memory Files

Frontmatter is optional
REQUIRED deterministic ordering
REQUIRED explicit rule-loading conditions
PROHIBITED conversational content

### Directory Exceptions

Different directory classifications have specific preservation requirements.

#### Commands File Exceptions

PRESERVE in commands/**/*.md:
- Default parameter values: (default: value)
- Usage examples in code blocks
- Exit codes and error handling
- Safety constraints and security information
- Tool permissions and allowed-tools lists
- Argument definitions with complete specifications
- ## Examples sections with practical usage
- Error scenarios with exit codes
- Safety and backup procedures

DO NOT REMOVE:
- "Use when" trigger clauses in descriptions
- Official frontmatter fields per Claude Code spec

#### Skills File Exceptions

PRESERVE in skills/**/SKILL.md:
- Official trigger conditions: description contains "... Use when ..."
- Claude Code compliance requirements
- Essential capability descriptions
- Required YAML frontmatter fields: name, description
- RFC manifest fields: tags, source, capability, usage, validation

DO NOT REMOVE:
- "Use when" trigger clauses in descriptions
- Official frontmatter fields per Claude Code spec

#### Agents File Exceptions

PRESERVE in agents/**/AGENT.md:
- Routing logic and command patterns
- Agent-skill dependency mappings
- Escalation rules and decision policies
- Workflow phases and dependencies
- Error handling and failure scenarios
- RFC manifest fields: default-skills, optional-skills, supported-commands, inputs, outputs, fail-fast, escalation, permissions

DO NOT REMOVE:
- Official frontmatter fields: name, description, tools, model
- RFC-compliant manifest structure
- Agent routing and delegation logic

#### Core Config Exceptions

PRESERVE in CLAUDE.md, AGENTS.md:
- System routing mappings
- Agent selection conditions
- Permission and type definitions
- Critical dependency relationships
- Directory and scope declarations

## Language Rules

PROHIBITED soft priority labels: PREFERRED, OPTIONAL, RECOMMENDED
PROHIBITED directives starting with weak or ambiguous modals
REQUIRED directives starting with action verbs
REQUIRED explicit REQUIRED and PROHIBITED labels for hard constraints only
REQUIRED plain imperative syntax for best practices and guidelines
REQUIRED consistent terminology across all files
REQUIRED respect language and tool selection rules from rules/10-python-guidelines.md, rules/12-shell-guidelines.md, rules/15-cross-language-architecture.md, rules/20-tool-standards.md, and rules/21-language-tool-selection.md when describing or generating automation patterns

## Formatting Rules

PROHIBITED markdown bold in body content
PROHIBITED inconsistent heading structures
REQUIRED plain markdown
REQUIRED language markers for all code blocks
REQUIRED lowercase kebab-case filenames
REQUIRED directory semantics aligned with purpose
PERMITTED bold markers in frontmatter only

## Naming Rules

PROHIBITED inconsistent naming patterns across file categories
PROHIBITED style label values outside controlled vocabulary
REQUIRED lowercase kebab-case filenames
REQUIRED semantic directory placement
REQUIRED directive naming for rule files
REQUIRED consistent naming patterns across file categories
REQUIRED style labels, when present in manifests, to match documented style guide names

## Validation Rules

REQUIRED apply validation rules using skills/llm-governance/scripts/config.yaml as Single Source of Truth (SSOT) for schema and validation constraints. When rules and schema diverge, update the rules to mirror the schema rather than broadening constraints.

### Content Standards

PROHIBITED harmful content
PROHIBITED low information density
REQUIRED high information density
REQUIRED deterministic, unambiguous content
REQUIRED tool safety

### Structure Standards

PROHIBITED missing required sections
PROHIBITED inconsistent heading structures
REQUIRED canonical ordering for all directory classifications
REQUIRED frontmatter compliance for command and skill files

### Compliance Standards

PROHIBITED broken references
PROHIBITED misalignment with repository directory semantics
REQUIRED consistency with skill and agent dependencies
REQUIRED cross-file consistency
REQUIRED alignment with repository directory semantics

### Style Compatibility

PROHIBITED schema requirements that depend on style labels for validity
PROHIBITED style label values outside controlled vocabulary
REQUIRED style values, when present, to use a controlled vocabulary documented in this file
REQUIRED treat style mismatches between directory type and declared style as warnings, not blocking errors

Style fields in manifests may describe prompt or execution style using plain imperatives

## Narrative Detection

A paragraph is narrative when any condition holds:
- does not begin with an action verb
- contains subjective adverbs: usually, typically, generally, often
- contains modal verbs: may, might, could
- contains multiple sentences without explicit directives

Narrative paragraphs MUST be removed or rewritten into imperative form.

## Depth Compatibility

REQUIRED compatibility with structured execution frameworks used by rewrite commands

Files must satisfy:

decomposition: ensure purpose, sections, and dependencies are extractable as distinct phases

explicit reasoning: ensure constraints, assumptions, and invariants are derivable from the content

parameters: ensure frontmatter and structure fully specify behavior, ensure required fields are present and normalized

tests: ensure normal, edge, and failure cases are inferable

heuristics: ensure rules remain compatible with deterministic normalization and tool-safety

frameworks:
- PROHIBITED schema requirements that depend on a specific named framework
- Use of named frameworks such as SIMPLE, DEPTH, COMPLEX, and community loop styles is permitted
- REQUIRED alignment between chosen frameworks and rule content only when it improves clarity, determinism, or tool-safety

### Style Guides

REQUIRED define style labels in terms of directive patterns and structure instead of schema fields

#### reasoning-first

PROHIBITED conversational storytelling or open-ended exploration in governed content
REQUIRED present short, structured reasoning before tools or final answers
REQUIRED surface assumptions, plan, and checks explicitly when this style is declared

#### tool-first

PROHIBITED delaying tool selection behind long reasoning sections in command manifests
REQUIRED list tools, parameters, and error handling decisions before narrative guidance
REQUIRED keep command specifications and agent workflows focused on concrete actions and safeguards

#### minimal-chat

PROHIBITED conversational fillers, acknowledgements, or small talk in minimal-chat content
REQUIRED keep outputs limited to structured fields, tables, or bullet lists with no filler prose
REQUIRED use this style for IDE, CI, and governance agents that must produce machine-consumable output
