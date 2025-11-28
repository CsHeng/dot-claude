# Skill Manifest Standards

## scope
REQUIRED: Apply these standards to all skill manifests under `.claude/skills/**/SKILL.md`.

## absolute-prohibitions
PROHIBITED: Omit required frontmatter fields for skill manifests
PROHIBITED: Use inconsistent field names for core manifest properties
PROHIBITED: Encode capability information only in body text without frontmatter fields

## communication-protocol
REQUIRED: Use terse, declarative statements for template definitions  
REQUIRED: Describe required and optional fields explicitly  
REQUIRED: Avoid narrative examples; prefer canonical templates  

## structural-rules

### skill-manifest-frontmatter
REQUIRED: Use YAML frontmatter starting and ending with `---` markers  
REQUIRED: Include fields:
- name: string (skill identifier, lowercase letters, numbers, hyphens only)
- description: string
OPTIONAL fields:
- tags: list of strings
- source: list of documentation or rule file paths
- capability: string describing high-level behavior
- usage: list of usage strings
- validation: list of validation rules
- allowed-tools: list of tool invocation patterns
- mode: string (capability axis label; descriptive, implementation-defined)
- capability-level: integer 0–4 (capability axis level; see taxonomy RFC)
- style: string or list of strings describing prompt or execution style (for example reasoning-first, tool-first, minimal-chat)

REQUIRED: Keep required fields present even when optional fields are omitted  
REQUIRED: Place capability-level and mode only in frontmatter, not duplicated in body  

### body-structure-skills
REQUIRED: Use sections in this order when present:
1. Purpose
2. IO Semantics
3. Deterministic Steps
4. Tool Safety
5. Validation Criteria

REQUIRED: Keep section headings stable and aligned with the above names  
OPTIONAL: Omit sections when not applicable, but preserve ordering for present sections  
PROHIBITED: Encode frontmatter-only fields (name, tags, capability-level, mode) in body headings  

## language-rules
REQUIRED: Use imperative or declarative sentences for all field definitions  
REQUIRED: Use explicit labels (REQUIRED, OPTIONAL, PROHIBITED) when describing template rules  
PROHIBITED: Narrative descriptions of usage scenarios in this file  

## formatting-rules
REQUIRED: Plain markdown with code fences only for literal examples  
PROHIBITED: Markdown bold markers in body content  
REQUIRED: Lowercase kebab-case filename `97-skills-manifest-standards.md`  
REQUIRED: Headings as defined above without additional nesting beyond required sections  

## naming-rules
REQUIRED: Use `name` as the canonical identifier key for skills  
REQUIRED: Use `capability-level` and `mode` only for capability axis metadata  
REQUIRED: Use `style` only as a label referencing documented style guides when present  

## validation-rules

### manifest-completeness
REQUIRED: Validate presence of required fields for all SKILL.md files  
REQUIRED: Flag missing name or description as critical errors  
REQUIRED: Flag capability-level or mode placed outside metadata section as violations
REQUIRED: Flag capability-level or mode placed in top-level frontmatter as violations (must be in metadata section)  

### capability-axis-alignment
REQUIRED: Ensure capability-level values fall within 0–4 when present  
REQUIRED: Ensure mode fields are simple string labels when present  
OPTIONAL: Enforce domain-specific expectations for certain capability-level values in separate rule files  

### cross-file-consistency
REQUIRED: Keep skill names synchronized with all references in commands, agents, and memory files  
REQUIRED: Reject manifest templates that introduce conflicting field names for the same concept  

## narrative-detection
REQUIRED: Treat narrative paragraphs in this file as violations of rule style  
PROHIBITED: Multi-sentence explanatory paragraphs that do not read as directives  

## depth-compatibility
REQUIRED: Keep skill manifest schema stable enough for deterministic parsing and rewrite tools  
PROHIBITED: Depend on any specific execution framework name such as DEPTH for schema validity  
REQUIRED: Express capability-related metadata only through metadata section fields so tools can derive levels and modes
REQUIRED: Refer to `skills/llm-governance/rules/96-metadata-standards.md` for complete metadata field placement and validation rules
