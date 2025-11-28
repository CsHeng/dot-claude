# LLM Prompt Writing Rules

## scope
MANDATORY on:
- commands/**/*.md
- skills/**/SKILL.md
- agents/**/AGENT.md
- rules/**/*.md
- governance/**/*.md
- AGENTS.md
- CLAUDE.md
- .claude/settings.json

EXCLUDED:
docs/**, README*, commands/**/README*.md, src/**, examples/**, tests/**, ide/**

## absolute-prohibitions
PROHIBITED markdown bold markers in body content
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
REQUIRED align frontmatter with official Claude Code command schema:  
- allowed-tools: OPTIONAL list or comma-separated string; inherits defaults when omitted  
- argument-hint: OPTIONAL string describing positional parameters  
- description: OPTIONAL string; defaults to first body line when omitted  
- model: OPTIONAL model override  
- disable-model-invocation: OPTIONAL boolean (default false)  
NOTE name is derived from filename; do not require name in frontmatter  
RECOMMENDED core body sections Usage, Arguments, Workflow, Output for clarity  
REQUIRED deterministic instruction sequences  

### skill-files
REQUIRED manifest schema compliance with `skills/llm-governance/rules/97-skills-manifest-standards.md`  
REQUIRED frontmatter fields name and description; allowed-tools OPTIONAL (list or comma-separated string)  
REQUIRED explicit IO semantics in body content  
REQUIRED deterministic, tool-safe steps in body content  

### agent-files
REQUIRED manifest schema compliance with `skills/llm-governance/rules/97-agents-manifest-standards.md`  
REQUIRED frontmatter fields name and description; tools/allowed-tools OPTIONAL (list or comma-separated string)  
REQUIRED explicit agent role definition in body content  
REQUIRED body sections describing required skills, workflow phases, decision policies, and error handling patterns  

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
REQUIRED respect language and tool selection rules from rules/10-python-guidelines.md, rules/12-shell-guidelines.md, rules/15-cross-language-architecture.md, rules/20-tool-standards.md, and rules/21-language-tool-selection.md when describing or generating automation patterns  

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
REQUIRED style labels, when present in manifests, to match documented style guide names  

## validation-rules

REQUIRED apply validation rules from `governance/rules/llm-governance.md` which declares the schema Single Source of Truth (SSOT) location at `skills/llm-governance/scripts/config.yaml`; when these rules and the schema diverge, update the rules to mirror the schema rather than broadening constraints  

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

### style-compatibility
OPTIONAL style fields in manifests to describe prompt or execution style  
REQUIRED style values, when present, to use a controlled vocabulary documented in this file  
REQUIRED treat style mismatches between directory type and declared style as warnings, not blocking errors  
PROHIBITED schema requirements that depend on style labels for validity  

## narrative-detection
A paragraph is narrative when any condition holds:
- does not begin with an action verb  
- contains subjective adverbs: usually, typically, generally, often  
- contains modal verbs: may, might, could  
- contains multiple sentences without explicit directives  

Narrative paragraphs MUST be removed or rewritten into imperative form.

## depth-compatibility
REQUIRED compatibility with structured execution frameworks used by rewrite commands  
Files must satisfy:

decomposition:
- ensure purpose, sections, and dependencies are extractable as distinct phases

explicit reasoning:
- ensure constraints, assumptions, and invariants are derivable from the content

parameters:
- ensure frontmatter and structure fully specify behavior  
- ensure required fields are present and normalized

tests:
- ensure normal, edge, and failure cases are inferable

heuristics:
- ensure rules remain compatible with deterministic normalization and tool-safety

frameworks:
- PERMITTED use of named frameworks such as SIMPLE, DEPTH, COMPLEX, and community loop styles
- PROHIBITED schema requirements that depend on a specific named framework
- REQUIRED alignment between chosen frameworks and rule content only when it improves clarity, determinism, or tool-safety

### style-guides
REQUIRED define style labels in terms of directive patterns and structure instead of schema fields  

#### reasoning-first
REQUIRED present short, structured reasoning before tools or final answers  
REQUIRED surface assumptions, plan, and checks explicitly when this style is declared  
PROHIBITED conversational storytelling or open-ended exploration in governed content  

#### tool-first
REQUIRED list tools, parameters, and error handling decisions before narrative guidance  
REQUIRED keep command specifications and agent workflows focused on concrete actions and safeguards  
PROHIBITED delaying tool selection behind long reasoning sections in command manifests  

#### minimal-chat
REQUIRED keep outputs limited to structured fields, tables, or bullet lists with no filler prose  
REQUIRED use this style for IDE, CI, and governance agents that must produce machine-consumable output  
PROHIBITED conversational fillers, acknowledgements, or small talk in minimal-chat content  
