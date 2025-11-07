---
name: "commands:review-llm-prompts"
description: "Review Claude Code prompt files for rule compliance"
argument-hint: "--target=<path> [--mode=<analyze|propose|validate>] [--dry-run]"
allowed-tools: "bash,rg"
is_background: false
---

# Review LLM Prompts

Enforce `rules/99-llm-prompt-writing-rules.md` across Claude Code commands, skills, rules, and memory files.

## Usage

```bash
/review-llm-prompts [--target=<path>] [--mode=<analyze|propose|validate>] [--dry-run]
```

## Parameters

- `--target` - Absolute or repo-relative path. Reject paths outside the LLM-facing set defined by `CLAUDE.md`. Default scans every mapped file and directory.
- `--mode` - Enumerated value. `analyze` reports violations, `propose` emits concrete rewrite suggestions, `validate` fails fast on the first issue and exits non-zero.
- `--dry-run` - Produce analysis output without writing to disk. Combine with any mode for preview-only runs.

## Workflow

- Read `CLAUDE.md` to discover every path tagged as LLM-facing (commands/, rules/, CLAUDE.md, AGENTS.md, `.claude/settings.json`, skills/, future additions).
- Expand directories recursively while ignoring binaries and files not listed in the mapping.
- For each file, verify YAML front matter exists, mandatory metadata fields are filled, and forbidden formatting (bold markers, emojis) is absent.
- Check that instructions use imperative language, describe validation or fail-fast behavior, and preserve the debug output format (`===`, `---`, `SUCCESS:`, `ERROR:`).
- Validate file names: enforce lowercase kebab-case, no spaces, clear scope prefixes (for example `commands/review-llm-prompts.md`). Reject names that overload plural nouns (`patterns`, `guidelines`, `rules`) unless the directory contract requires them.
- Treat sentences that already begin with a base-form verb as compliant imperative language. Flag only statements that rely on modal verbs (`should`, `might`), vague qualifiers (`maybe`), or noun phrases that lack an explicit command.
- When `--mode=validate`, stop at the first violation and emit an `ERROR:` message with rule references; otherwise accumulate issues for summary reporting.

## Frontmatter Requirements

- `commands/**/*.md`: Require YAML front matter containing `name`, `description`, `argument-hint`, `allowed-tools`, and `is_background`. Optional fields like `alwaysApply`, `applyTo`, or `inclusion` are allowed but never mandatory. Do not inject `# Cursor Rules` / `# Copilot Instructions` headers into these files.
- `rules/**/*.md`: Expect the combined metadata block with `# Cursor Rules`, `# Copilot Instructions`, and `# Kiro Steering` as currently present in the rules directory. Flag missing sections only for rule files.
- Memory/config files (`CLAUDE.md`, `AGENTS.md`, `.claude/settings.json`) may omit YAML front matter entirely; skip this check for them.
- Whenever a violation is reported, specify which field is missing instead of proposing a generic header replacement.

## Naming and Terminology Requirements

- Treat `rule` and `standard` as mandatory directives. If a file labels a section as `guideline`, `pattern`, or `principle`, require an explicit statement clarifying that compliance is optional and note any bounded scope.
- Flag mixed terminology that can confuse LLMs (for instance, calling the same section both a rule and a guideline). The tool must either enforce a single noun or rewrite with clear qualifiers like `Optional Guideline`.
- Ensure headings and filenames align: a document under `rules/` must use `Rule`-centric language, while optional-only documents belong in `guidelines/` or explicitly prefix headings with `Optional`.
- Recommend replacing ambiguous verbs (e.g., “consider”, “maybe”) with imperative commands when the file resides in a mandatory directory.

## Target Files

- Default target list is dynamic and sourced from `CLAUDE.md`. Include `commands/`, `rules/`, `CLAUDE.md`, `AGENTS.md`, `.claude/settings.json`, `skills/`, and any future directories marked as LLM-facing.
- User supplied `--target` values must be subsets of that mapping; reject anything else with an immediate `ERROR:` and exit status 1.
- Deduplicate file paths while preserving order so reports remain stable.

## Output Format

- Begin runs with `=== review-llm-prompts` and use `--- <stage>` for subtasks.
- `analyze` prints violations as `--- issue <file>:<line> rule=<id>` followed by one-line reasoning.
- `propose` adds fenced snippets showing the corrected text plus an explanation prefixed with `--- fix`.
- `validate` emits only the first `ERROR:` line and halts.
- Every successful run ends with `SUCCESS: review complete`.
- Report only meaningful diffs: confirm the replacement text differs from the original before emitting a `--- fix` block.

## Examples

```bash
# Analyze all LLM-facing files
/review-llm-prompts

# Analyze specific file
/review-llm-prompts --target=CLAUDE.md

# Generate improvement proposals
/review-llm-prompts --mode=propose

# Validate changes
/review-llm-prompts --mode=validate --target=rules/99-llm-prompt-writing-rules.md
```
