# Governance Manifest Standards

**DEPRECATED**: The governance/ directory (Layer 2) has been orphaned. These standards are preserved for historical reference only.

## scope
DEPRECATED: Governance manifests under `.claude/governance/**/*.md` are no longer actively maintained:
- `governance/rules/**/*.md` (rule-block files)
- `governance/routers/**/*.md` (router files)
- `governance/entrypoints/**/*.md` (entrypoint files)
- `governance/styles/**/*.md` (output-style files)

Current standards apply only to:
- `agents/**/*.md` (AGENT.md files)
- `skills/**/SKILL.md` (SKILL.md files)
- `commands/**/*.md` (command files)
- `rules/**/*.md` (rule files)

## absolute-prohibitions
PROHIBITED: Place custom metadata fields in top-level frontmatter (must be in metadata section)
PROHIBITED: Place official Claude Code fields in metadata section (must be in top-level)
PROHIBITED: Omit required frontmatter fields for governance manifests
PROHIBITED: Use inconsistent field names for core manifest properties
PROHIBITED: Encode capability information only in body text without frontmatter fields

## communication-protocol
REQUIRED: Use terse, declarative statements for template definitions
REQUIRED: Describe required and optional fields explicitly
REQUIRED: Avoid narrative examples; prefer canonical templates

## structural-rules

### rule-block-manifest-frontmatter
REQUIRED: Use YAML frontmatter starting and ending with `---` markers
REQUIRED: Include fields:
- name: string (rule-block identifier, for example `rule-block:llm-governance`)
- description: string
REQUIRED: Place in metadata section:
- layer: string (must be "governance")
- sources: list of strings (canonical policy file paths under `rules/`)

REQUIRED: Keep name and description in top-level frontmatter
REQUIRED: Place layer and sources in metadata section
REQUIRED: Name must follow pattern `rule-block:[a-z0-9-]+`

### router-manifest-frontmatter
REQUIRED: Use YAML frontmatter starting and ending with `---` markers (optional)
OPTIONAL: Include description in top-level frontmatter
OPTIONAL: Place in metadata section:
- layer: string (should be "governance" if present)

REQUIRED: Body sections must include:
- ## Layer (Layer 2 – Orchestration & Governance)
- ## Purpose
- ## Policy
- ## Execution Handoff

### entrypoint-manifest-frontmatter
REQUIRED: Use YAML frontmatter starting and ending with `---` markers (optional)
OPTIONAL: Include description in top-level frontmatter
OPTIONAL: Place in metadata section:
- layer: string (should be "governance" if present)

REQUIRED: Body sections must include:
- ## Layer (Layer 1 – UI Entry)
- ## Slash Command
- ## Intent
- ## Routing

### output-style-manifest-frontmatter
REQUIRED: Use YAML frontmatter starting and ending with `---` markers
REQUIRED: Include fields:
- name: string (style identifier, lowercase letters, numbers, hyphens only)
- description: string
REQUIRED: Place in metadata section:
- keep-coding-instructions: boolean (optional)
- source: string (source file path, optional)

REQUIRED: Keep name and description in top-level frontmatter
REQUIRED: Place keep-coding-instructions and source in metadata section

### body-structure-governance
REQUIRED: Use sections appropriate to file type as defined above
REQUIRED: Keep section headings stable and aligned with defined names
OPTIONAL: Omit sections when not applicable, but preserve ordering for present sections
PROHIBITED: Encode frontmatter-only fields in body headings

## language-rules
REQUIRED: Use imperative or declarative sentences for all field definitions
REQUIRED: Use explicit labels (REQUIRED, OPTIONAL, PROHIBITED) when describing template rules
PROHIBITED: Narrative descriptions of usage scenarios in this file

## formatting-rules
REQUIRED: Plain markdown with code fences only for literal examples
PROHIBITED: Markdown bold markers in body content
REQUIRED: Lowercase kebab-case filename `97-governance-manifest-standards.md`
REQUIRED: Headings as defined above without additional nesting beyond required sections

## naming-rules
REQUIRED: Use `name` as the canonical identifier key for rule-blocks and output-styles
REQUIRED: Use `layer` only for taxonomy layer metadata (governance or execution)
REQUIRED: Use `sources` only for rule-block policy file references
REQUIRED: Use `style` only as a label referencing documented style guides when present

## validation-rules

### manifest-completeness
REQUIRED: Validate presence of required fields for all governance files
REQUIRED: Flag missing name or description (for rule-blocks and output-styles) as critical errors
REQUIRED: Flag custom metadata fields placed in top-level as critical errors
REQUIRED: Flag official fields placed in metadata section as critical errors

### field-placement-validation
REQUIRED: Validate that custom metadata fields (layer, sources, keep-coding-instructions, source) are placed in metadata section
REQUIRED: Validate that official fields (name, description) are placed in top-level frontmatter
REQUIRED: Flag violations as critical errors

### layer-validation
REQUIRED: Validate layer field value is "governance" for governance directory files
REQUIRED: Validate layer field matches file location

### cross-file-consistency
REQUIRED: Keep governance file names synchronized with all references in routers, entrypoints, and memory files
REQUIRED: Reject manifest templates that introduce conflicting field names for the same concept

## narrative-detection
REQUIRED: Treat narrative paragraphs in this file as violations of rule style
PROHIBITED: Multi-sentence explanatory paragraphs that do not read as directives

## depth-compatibility
REQUIRED: Keep governance manifest schema stable enough for deterministic parsing and rewrite tools
PROHIBITED: Depend on any specific execution framework name such as DEPTH for schema validity
REQUIRED: Express metadata-related information only through frontmatter fields so tools can derive values

