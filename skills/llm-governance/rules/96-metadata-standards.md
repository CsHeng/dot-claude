---
file-type: rule
---

## scope
REQUIRED: Apply these metadata standards to all agents, skills, commands, and governance files that declare custom metadata fields in their manifests.

## absolute-prohibitions
PROHIBITED: Place custom metadata fields in top-level frontmatter (must be in metadata section)
PROHIBITED: Place official Claude Code fields in metadata section (must be in top-level)
PROHIBITED: Use metadata field names that conflict with Claude Code official fields
PROHIBITED: Use capability levels outside the range 0–4
PROHIBITED: Assign capability-level values that conflict with the declared role (agent vs skill)
PROHIBITED: Encode metadata semantics only in narrative text without clear labels

## communication-protocol
REQUIRED: Describe metadata field expectations using terse, declarative statements
REQUIRED: Reference metadata fields explicitly when documenting behaviors and acceptance criteria
PROHIBITED: Implicit or ambiguous descriptions of metadata field usage

## structural-rules

### metadata-field-placement
REQUIRED: Place all custom metadata fields in the `metadata` section of frontmatter
REQUIRED: Place all official Claude Code fields in top-level frontmatter
REQUIRED: Official fields include: name, description, allowed-tools, tools, model, permissionMode, skills, argument-hint, disable-model-invocation
REQUIRED: Custom metadata fields include: capability-level, loop-style, layer, sources, style, mode, related-skills, keep-coding-instructions, source, default-skills, optional-skills, supported-commands, inputs, outputs, fail-fast, permissions, escalation, tags, usage, validation, is_background

### capability-levels-agents
REQUIRED: Interpret agent capability-levels as:
- 0: Single-step helper agents with no tool usage and no persistent state
- 1: Tool-using helpers with stateless, short workflows
- 2: Multi-step workflows with local task memory and deterministic phases
- 3: Planning agents coordinating multiple phases, skills, or subagents
- 4: Long-running system agents with monitoring, metrics, and self-healing behaviors

REQUIRED: For level 3 agents:
- Provide a `Capability Profile` section describing planning behavior and orchestration scope
- Document the execution loop (`loop-style`) and how it maps to phases or DEPTH-style steps
- Place `capability-level` and `loop-style` in metadata section

REQUIRED: For level 4 agents (when introduced):
- Document monitoring responsibilities, rollback strategy, and health-check integration

### capability-levels-skills
REQUIRED: Interpret skill capability-levels as:
- 0: Single-use helpers or thin wrappers around rules or tools
- 1: Guidance or decision-support skills (language guidelines, search strategies)
- 2: Stateful or multi-step skills applying rules with deterministic behavior
- 3: Planning or orchestration skills coordinating other skills or tools
- 4: System-level management skills with persistent coordination responsibilities

REQUIRED: For level 2 and above:
- Provide IO semantics and deterministic steps in the body of the SKILL.md
- Place `capability-level` and `mode` in metadata section

### layer-field
REQUIRED: Use `layer` metadata field to distinguish taxonomy layers:
- `governance`: Layer 2 (Orchestration & Governance) - for governance/rules, governance/routers, governance/entrypoints
- `execution`: Layer 3 (Execution) - for agents, skills, commands

REQUIRED: Place `layer` field in metadata section
REQUIRED: Validate layer value matches file location (governance files should have layer: governance)

### sources-field
REQUIRED: Use `sources` metadata field for rule-blocks to reference canonical policy files
REQUIRED: `sources` must be a list of file paths
REQUIRED: Place `sources` field in metadata section
REQUIRED: Paths should reference files under `rules/` directory

### style-field
REQUIRED: Use `style` metadata field to specify prompt or execution style
REQUIRED: Allowed values: reasoning-first, tool-first, minimal-chat
REQUIRED: Place `style` field in metadata section
REQUIRED: Validate style value against controlled vocabulary

### other-metadata-fields
REQUIRED: Place all custom fields in metadata section:
- `mode`: Capability axis label for skills (metadata section)
- `related-skills`: List of skill identifiers for skills (metadata section)
- `keep-coding-instructions`: Boolean for output-styles (metadata section)
- `source`: Source file path for output-styles (metadata section)
- `default-skills`, `optional-skills`, `supported-commands`, `inputs`, `outputs`, `fail-fast`, `permissions`, `escalation`: Agent metadata fields (metadata section)
- `is_background`: Boolean for commands (metadata section)

## language-rules
REQUIRED: Use consistent terminology for metadata fields in documentation and manifests
REQUIRED: Refer to metadata field values explicitly with their types and constraints
REQUIRED: Document metadata field placement requirements clearly

## formatting-rules
REQUIRED: Plain markdown with section headings as defined above
REQUIRED: Use bullet lists to define expectations per field
PROHIBITED: Bold markers in body content

## naming-rules
REQUIRED: Use kebab-case for all metadata field names
REQUIRED: Use `capability-level` as the field name in manifests for level values
REQUIRED: Use `mode` and `loop-style` for descriptive capability labels, not for numeric levels
REQUIRED: Avoid field names that conflict with Claude Code official fields

## validation-rules

### field-placement-validation
REQUIRED: Validate that custom metadata fields are placed in metadata section
REQUIRED: Validate that official fields are placed in top-level frontmatter
REQUIRED: Flag custom fields in top-level as critical errors
REQUIRED: Flag official fields in metadata section as critical errors

### level-range
REQUIRED: Validate that all declared capability-level values are integers between 0 and 4

### agent-level-expectations
REQUIRED: For level 3 agents, ensure:
- `Capability Profile` section exists in AGENT.md
- `loop-style` is present in metadata section

OPTIONAL: For level 4 agents, enforce additional monitoring and rollback documentation in separate rules

### skill-level-expectations
REQUIRED: For level 2 and above skills, ensure:
- `IO Semantics` section describes inputs, outputs, and side effects
- `Deterministic Steps` section describes ordered behavior

### layer-validation
REQUIRED: Validate layer field matches file location:
- Files in `governance/` should have `layer: governance`
- Files in `agents/`, `skills/`, `commands/` should have `layer: execution` (if present)

### style-validation
REQUIRED: Validate style field values against controlled vocabulary
REQUIRED: Flag unknown style values as warnings

## narrative-detection
REQUIRED: Treat narrative paragraphs in this file as violations of rule style
PROHIBITED: Multi-sentence explanatory paragraphs that do not read as directives

## depth-compatibility
REQUIRED: Keep metadata field schema stable enough for deterministic parsing and rewrite tools
PROHIBITED: Depend on any specific execution framework name such as DEPTH for schema validity
REQUIRED: Express metadata-related information only through frontmatter fields so tools can derive values

