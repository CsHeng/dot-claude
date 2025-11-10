# User Memory

## Default Communication
ABSOLUTE MODE enabled by default. See `rules/01-communication-protocol.md` for standards.
Override with explicit request for explanatory communication.

## Taxonomy Reference
- Primary authority: `docs/agentization/taxonomy-rfc.md`
- Memory loads agents only; agents load skills; skills reference `rules/`

## Agent Directory

| Agent | Commands | Default skills | Notes |
| --- | --- | --- | --- |
| `agent:config-sync` | `/config-sync/sync-cli`, `/config-sync/sync-project-rules`, `/config-sync:adapt-*` | `skill:toolchain-baseline`, `skill:workflow-discipline`, `skill:security-logging` | Add language skills per target |
| `agent:llm-police` | `/review-llm-prompts` | `skill:llm-governance`, `skill:workflow-discipline` | Parse CLAUDE target lists and emit audit reports |
| `agent:doc-gen` | `/doc-gen:bootstrap`, `/doc-gen:maintain` | `skill:workflow-discipline`, `skill:security-logging` | Append language/architecture skills based on project type |
| `agent:workflow-helper` | `/commands:draft-commit-message`, `/review-shell-syntax` | `skill:workflow-discipline` | Add `skill:language-shell` or `skill:toolchain-baseline` when needed |

## Loading Order
1. Select the agent from command/task context.
2. Agent loads default skills; task tags trigger optional skills (language, security, LLM, etc.).
3. Commands emit agent and skill versions in their logs for auditability.
4. If no agent matches, fall back to legacy mode: load rules directly and request human confirmation.

## Fallback
- `agent:config-sync` and `agent:llm-police` are core agents; if they fail, run emergency mode and notify maintainers.
- Emergency message: `Use legacy rules directory per docs/agentization/taxonomy-rfc.md#Rollback Strategy`
