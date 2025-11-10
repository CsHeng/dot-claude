# Agent Operating Guide

Use this guide whenever you operate in this environment; it outlines how the Memory → Agent → Skill system is meant to work.

## Load Order

1. **CLAUDE.md** – primary routing table. Each entry maps commands to agents and lists default/optional skills.
2. **Agents (`agents/<name>/AGENT.md`)** – describe responsibilities, inputs/outputs, fail-fast policy, permissions, and fallback procedures.
3. **Skills (`skills/<name>/SKILL.md`)** – single-capability modules referencing `rules/` sections. Agents load them automatically; do not import rules directly.
4. **Rules (`rules/*.md`)** – still the canonical reference, but accessed via skills.

Always consult `docs/agentization/taxonomy-rfc.md` for the current taxonomy.

## Rule & Settings Expectations

- Personal preferences and defaults live in `rules/00-memory-rules.md`.
- Language/technology specifics live in `rules/10-23`. Skills already encode them, but you may reference the original rule text when clarifying behavior.
- The LLM-facing contract (`rules/99-llm-prompt-writing-rules.md`) is the primary authority whenever you edit commands, skills, CLAUDE, or other AI-facing prompts.
- Shared safety permissions remain in `settings.json` / `.claude/settings.json`; never bypass allow/ask/deny without explicit approval.

## Execution Guidelines

- PlantUML ≥ 1.2025.9: `plantuml --check-syntax <path>`
- DBML: `dbml2sql <path>`
- Shell scripts: `bash -n`, `sh -n`, or `zsh -n` and follow `rules/12-shell-guidelines.md`.
- Keep communication concise and action-oriented; explain *why* when making significant decisions.

## Testing & Quality

- Coverage targets: 80% overall, 95% on critical paths (`rules/00-memory-rules.md`).
- Run the language-mandated linters/tests before finishing work.
- Follow logging (`rules/22`), security (`rules/03`), and workflow (`rules/23`) standards embedded in skills.

## Security & Safety

- Never hardcode secrets; use environment variables per rules.
- Validate/sanitize user input and file paths.
- Apply fail-fast/error-handling conventions (see `rules/05` and relevant skills).

## Quick Reference

| Context | Location | Purpose |
| --- | --- | --- |
| Taxonomy | `docs/agentization/taxonomy-rfc.md` | Memory → Agent → Skill definitions |
| Memory entry | `CLAUDE.md` | Agent tables and fallback rules |
| Skills directory | `skills/` | Single-capability manifests |
| Agents directory | `agents/` | Execution contracts for slash commands |
| Rule library | `rules/` | Canonical standards referenced by skills |
| Permission policy | `.claude/settings.json` | allow/ask/deny gating |

If you discover new rules or agent changes, update CLAUDE, the taxonomy RFC, and this guide accordingly.
