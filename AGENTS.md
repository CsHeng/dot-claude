# Agent Operating Guide

Follow the instructions below whenever you operate within this configuration; they define the expectations for your actions in this environment.

## Rule Sources

- Load `@CLAUDE.md` first; it enumerates every canonical guideline in `@rules/`.
- When working in any file, pull in the matching rule document (e.g., `@rules/01-general-development.md` for general code edits, language-specific files such as `@rules/10-python-guidelines.md`).
- Personal preferences and global defaults live in `@rules/00-user-preferences.md`; follow its directives on fail-fast execution, comment preservation, and incremental changes.

## Memory & Settings Expectations

- Keep `@CLAUDE.md` in context alongside the relevant `rules/*.md` entries whenever you work.
- Shared safety permissions are defined in `@.claude/settings.json`; never bypass the `allow`/`ask`/`deny` policy. When a command falls outside `allow`, pause for explicit approval.
- Only reference `@settings.json` if the user explicitly shares the portion you need; assume it may contain sensitive data.

## Execution Guidelines

- PlantUML diagrams: validate with `plantuml --check-syntax <path>` (PlantUML ≥ 1.2025.9).
- Shell scripts: run the appropriate syntax check (`bash -n`, `sh -n`, or `zsh -n`) before proposing changes; ensure traps and strict mode adhere to `@rules/12-shell-guidelines.md`.
- Maintain concise, action-focused communication and retain existing comments. Explain *why* significant decisions are made.

## Testing & Quality Checklist

- Minimum coverage: 80% overall, 95% on critical paths (`@rules/00-user-preferences.md`).
- Execute all relevant linters/tests mandated by the language-specific rules before concluding work.
- Follow logging (`@rules/22-logging-standards.md`), security (`@rules/03-security-guidelines.md`), and workflow (`@rules/23-workflow-patterns.md`) requirements.

## Security & Safety

- Never hardcode secrets; rely on environment variables as described in the rules.
- Validate and sanitize all input paths, parameters, and user-provided data.
- Apply fail-fast patterns (early exits, error traps) and honor the error-handling conventions defined in `@rules/05-error-handling.md`.

## Quick Reference

| Context | Location | Purpose |
| --- | --- | --- |
| Rule library | `@rules/` | Source of all coding standards |
| Memory index | `@CLAUDE.md` | Mapping of rule files for fast lookup |
| Shared permission policy | `@.claude/settings.json` | Command allow/ask/deny rules |

If you notice rule updates that are not reflected here, notify the user so they can refresh `AGENTS.md`.
