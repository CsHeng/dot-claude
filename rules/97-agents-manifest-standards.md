# Agent Manifest Standards

## scope
REQUIRED: Apply these standards to all agent manifests under `.claude/agents/**/AGENT.md`.

## absolute-prohibitions
PROHIBITED: Omit required frontmatter fields for agent manifests
PROHIBITED: Use inconsistent field names for core manifest properties
PROHIBITED: Encode capability information only in body text without frontmatter fields

## communication-protocol
REQUIRED: Use terse, declarative statements for template definitions  
REQUIRED: Describe required and optional fields explicitly  
REQUIRED: Avoid narrative examples; prefer canonical templates  

## structural-rules

### agent-manifest-frontmatter
REQUIRED: Use YAML frontmatter starting and ending with `---` markers  
REQUIRED: Include fields:
- name: string (agent identifier, for example `agent:config-sync`)
- description: string
OPTIONAL fields:
- tools: list of allowed tool invocations
- default-skills: list of skill identifiers
- optional-skills: list of skill identifiers
- supported-commands: list of command patterns
- inputs: list of logical input parameters
- outputs: list of logical outputs
- fail-fast: list of critical failure conditions
- permissions: list of permission descriptors
- capability-level: integer 0–4 (capability axis level)
- loop-style: string (execution loop label, for example `DEPTH`, `structured-phases`)
 - style: string or list of strings describing agent interaction or reasoning style (for example reasoning-first, tool-first, minimal-chat)

REQUIRED: Keep name and description present and consistent with routing tables  
REQUIRED: Place capability-level and loop-style only in frontmatter, not duplicated in body headings  

### body-structure-agents
REQUIRED: Use sections in this order when present:
1. Mission
2. Capability Profile
3. Core Responsibilities
4. Required Skills
5. Workflow Phases (DEPTH or structured equivalent)
6. Error Handling Patterns
7. Decision Policies
8. Critical Constraints
9. Output Requirements

REQUIRED: Keep section headings stable and aligned with the above names when used  
OPTIONAL: Omit sections that are not relevant for a given agent, but preserve ordering for present sections  
PROHIBITED: Duplicate frontmatter fields inside headings, for example restate capability-level  

## language-rules
REQUIRED: Use imperative or declarative sentences for all field definitions  
REQUIRED: Use explicit labels (REQUIRED, OPTIONAL, PROHIBITED) when describing template rules  
PROHIBITED: Narrative descriptions of usage scenarios in this file  

## formatting-rules
REQUIRED: Plain markdown with code fences only for literal examples  
PROHIBITED: Markdown bold markers in body content  
REQUIRED: Lowercase kebab-case filename `97-agents-manifest-standards.md`  
REQUIRED: Headings as defined above without additional nesting beyond required sections  

## naming-rules
REQUIRED: Use `name` as the canonical identifier key for agents  
REQUIRED: Use `capability-level` only for capability axis metadata  
REQUIRED: Use `loop-style` only for agent execution loop labels  
REQUIRED: Use `style` only as a label referencing documented style guides when present  

## validation-rules

### manifest-completeness
REQUIRED: Validate presence of required fields for all AGENT.md files  
REQUIRED: Flag missing name or description as critical errors  
REQUIRED: Flag capability-level or loop-style placed outside frontmatter as violations  

### capability-axis-alignment
REQUIRED: Ensure capability-level values fall within 0–4 when present  
REQUIRED: Ensure loop-style fields are simple string labels when present  
OPTIONAL: Enforce domain-specific expectations for certain capability-level values in separate rule files  

### cross-file-consistency
REQUIRED: Keep agent default-skills and optional-skills aligned with CLAUDE.md and AGENTS.md tables  
REQUIRED: Reject manifest templates that introduce conflicting field names for the same concept  

## narrative-detection
REQUIRED: Treat narrative paragraphs in this file as violations of rule style  
PROHIBITED: Multi-sentence explanatory paragraphs that do not read as directives  

## depth-compatibility
REQUIRED: Keep agent manifest schema stable enough for deterministic parsing and rewrite tools  
PROHIBITED: Depend on any specific execution framework name such as DEPTH for schema validity  
REQUIRED: Express capability-related metadata only through frontmatter fields so tools can derive levels and loop-style
