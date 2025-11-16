# Command Manifest Standards

## scope
REQUIRED: Apply these standards to all command specification files under `.claude/commands/**/*.md` except README files.

## absolute-prohibitions
PROHIBITED: Omit required frontmatter fields for command manifests
PROHIBITED: Use inconsistent field names for core command manifest properties
PROHIBITED: Define command semantics only in narrative body text without structured sections

## communication-protocol
REQUIRED: Use terse, directive statements for command usage and workflow definitions  
REQUIRED: Describe arguments, workflow, and output explicitly  
REQUIRED: Avoid narrative walkthroughs; prefer canonical command specs  

## structural-rules

### command-manifest-frontmatter
REQUIRED: Use YAML frontmatter starting and ending with `---` markers  
REQUIRED frontmatter keys:
- name
- description
- argument-hint
- allowed-tools
OPTIONAL frontmatter key:
- is_background (boolean, default: false)
OPTIONAL frontmatter key:
- style (string or list of strings describing prompt style, for example reasoning-first, tool-first, minimal-chat)

REQUIRED frontmatter types:
- name: string  
- description: string  
- argument-hint: string  
- allowed-tools: list  
- is_background: boolean when present  
 - style: string or list when present  

PREFERRED frontmatter key order:
1. name
2. description
3. argument-hint
4. allowed-tools
5. is_background
6. style

### command-body-structure
REQUIRED: Provide body sections describing:
- Usage  
- Arguments  
- Workflow  
- Output  

REQUIRED: Use these section headings with stable spelling and title case  
OPTIONAL: Add extra sections such as Examples, Safety, Error Handling after the core sections  
REQUIRED: Keep instruction sequences deterministic and tool-safe  

## language-rules
REQUIRED: Use imperative sentences for workflow steps and output descriptions  
REQUIRED: Describe arguments and their types precisely  
PROHIBITED: Narrative prose that does not read as command documentation  

## formatting-rules
REQUIRED: Plain markdown with code fences only for literal examples and command snippets  
PROHIBITED: Markdown bold markers in body content  
REQUIRED: Lowercase kebab-case filename `97-commands-manifest-standards.md`  

## naming-rules
REQUIRED: Use `name` as the canonical identifier key for commands  
REQUIRED: Use semantic, lowercase names that match routing or slash-command identifiers  
REQUIRED: Use `style` only as a label referencing documented style guides when present  

## validation-rules

### manifest-completeness
REQUIRED: Validate presence of required frontmatter keys for all governed command files  
REQUIRED: Flag missing or incorrectly typed fields as critical errors  

### structure-alignment
REQUIRED: Ensure core sections Usage, Arguments, Workflow, Output are present  
REQUIRED: Flag missing or renamed core sections as violations  

## narrative-detection
REQUIRED: Treat multi-paragraph narrative in command specs as violations unless explicitly marked as examples  
PROHIBITED: Conversational guidance that does not describe concrete command behavior  

## depth-compatibility
REQUIRED: Keep command manifest schema stable enough for deterministic parsing and rewrite tools  
REQUIRED: Express all parameters and behaviors through frontmatter and structured sections so tools can derive usage and workflows  
