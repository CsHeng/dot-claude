---
name: "commands:review-llm-prompts"
description: "Review Claude Code prompt files for rule compliance"
argument-hint: "--target=<path> [--dry-run]"
allowed-tools: Bash(find *), Bash(rg *), Bash(cat *), Bash(ls *), Read
is_background: false
---

# Review LLM Prompts

Enforce `rules/99-llm-prompt-writing-rules.md` across Claude Code commands, skills, rules, and memory files.

## Usage

```bash
/review-llm-prompts [--target=<path>] [--dry-run]
```

## Parameters

- `--target` - Absolute or repo-relative path. Reject paths outside the LLM-facing set defined by `CLAUDE.md`. Default scans every mapped file and directory.

## Context Gathering as target list

- Default target list is sourced from `CLAUDE.md`. Include `commands/`, `rules/`, `skills/`, `CLAUDE.md`, `AGENTS.md`, `.claude/settings.json`
- Expand only those directories. Never fall back to repo-wide globbing; if a file lives outside the mapped set (for example `README.md`, `docs/**`, `ide/**`), treat it as human-facing and skip it entirely.
- User supplied `--target` values must be subsets of that mapping; reject anything else with an immediate `ERROR:` and exit status 1.
- Deduplicate file paths while preserving order so reports remain stable.

## Workflow

- For each file in target list, verify YAML front matter exists, mandatory metadata fields are filled, and forbidden formatting (bold markers, emojis) is absent.
  - Treat bold marker violations as true Markdown emphasis pairs only. Use the PCRE2 pattern ``(?<![\`\\])\*\*(?![\`/\\\s])(?:(?!\*\*)[^\r\n])*?(?<![\`/\\\s])\*\*(?![\`\\])`` so only inline `**text**` spans with real word characters on each side are flagged. This avoids glob literals such as `docs/**` or `rules/**/*.md` where the asterisks are part of syntax rather than emphasis.
  - Detect emojis using Unicode-aware matching instead of hardcoded character lists. Prefer `rg --pcre2 '\p{Extended_Pictographic}'` (or equivalent Unicode-aware traversal) so variation selectors (`\uFE0F`) and ZWJ sequences (pictograph + `\u200D` chains) are flagged as a single token.
  - Check that instructions use imperative language and describe validation or fail-fast behavior. Skip debugger-style output enforcement because the format varies across language toolchains.
  - Flag sentences that rely on modal verbs (`should`, `might`), vague qualifiers (`maybe`), or noun phrases that lack explicit commands.
  - Validate file names: enforce lowercase kebab-case, no spaces, clear scope prefixes (for example `commands/review-llm-prompts.md`). Reject names that overload plural nouns (`patterns`, `guidelines`, `rules`) unless the directory contract requires them.
- Aggregate findings by category (bold markers, emoji usage, front matter gaps, rule header reminders) and report them without modifying any files. Use the summary to decide what to fix manually or in a follow-up command.

## Frontmatter Requirements

- `commands/**/*.md`: Follow the custom slash command contract from the official docs (`https://code.claude.com/docs/en/slash-commands#custom-slash-commands`). Require YAML front matter with `name` (the slash path) and `description`, then validate optional keys (`argument-hint`, `allowed-tools`, `model`, `disable-model-invocation`) against the published table. Skip front matter enforcement for documentation files such as `README.md`, `readme.md`, or anything under `docs/**` because they serve humans, not slash commands.
- `skills/**/SKILL.md`: Enforce the Skill manifest format from `https://code.claude.com/docs/en/skills#agent-skills`. The YAML block must declare `name` and `description`, may include `allowed-tools`, and must live alongside the rest of the Skill directory so referenced helpers stay in scope.
- `rules/**/*.md`: Treat the `# Cursor Rules`, `# Copilot Instructions`, and `# Kiro Steering` headers as advisory only. When they are missing or incomplete, emit a reminder instead of a failing violation because these rules are loaded contextually through the CLAUDE.md import graph described in `https://code.claude.com/docs/en/memory#memory-best-practices`. Do not auto-fix or propose edits for these files unless the user explicitly requests it.
- Memory/config files (`CLAUDE.md`, `AGENTS.md`, `.claude/settings.json`) may omit YAML front matter entirely; skip this check for them.
- Whenever a violation is reported, specify which field is missing instead of proposing a generic header replacement. Use reminders for advisory-only rule metadata gaps.

## Naming and Terminology Requirements

- Treat `rule` and `standard` as mandatory directives. If a file labels a section as `guideline`, `pattern`, or `principle`, require an explicit statement clarifying that compliance is optional and note any bounded scope.
- Flag mixed terminology that can confuse LLMs (for instance, calling the same section both a rule and a guideline). The tool must either enforce a single noun or rewrite with clear qualifiers like `Optional Guideline`.
- Ensure headings and filenames align: a document under `rules/` must use `Rule`-centric language, while optional-only documents belong in `guidelines/` or explicitly prefix headings with `Optional`.
- Use imperative commands instead of ambiguous verbs (e.g., "consider", "maybe") when the file resides in a mandatory directory.
- Skip naming checks for documentation files (`README.md`, `docs/**`, `**/readme.md`) since they are outside the LLM-facing contract.

## Output Format

- Begin runs with `=== review-llm-prompts` and use `--- <stage>` for progress updates.
- After scanning, print `=== Issue Summary` with one line per violation category (`Bold markers (**) detected: N occurrence(s)`).
- Follow the summary with `=== Remediation Plan` that groups findings by rule: for each rule name/requirement, list the affected files (comma separated) and state the next action (`fix immediately`, `skip - human-facing docs`, `manual follow-up`, etc.). When no files require action, emit `- No remediation needed`.
- Print reminder counts (for advisory rule headers) in the same summary block.
- Emit `=== Detailed Findings` followed by `--- <category>` sections listing `path:line - reason` entries for each issue. Append the exact offending line (prefixed with `> `) so the user can preview the change without opening the file.
- Emit `=== Reminders Detail` with the same structure when advisory notices exist.
- Always end with `SUCCESS: review complete`.

## Examples

```bash
# Review all LLM-facing files and prompt for auto-fixes
/review-llm-prompts

# Restrict to a specific file (still emits fix proposals)
/review-llm-prompts --target=CLAUDE.md

# Preview fixes without changing disk
/review-llm-prompts --dry-run
```
