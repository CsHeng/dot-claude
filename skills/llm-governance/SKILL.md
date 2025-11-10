---
name: "skill:llm-governance"
description: "Enforce ABSOLUTE mode and LLM prompt-writing rules"
tags: [llm, governance]
source:
  - rules/99-llm-prompt-writing-rules.md
allowed-tools:
  - Bash(rg --pcre2 '\\*\\*')
  - Bash(rg --pcre2 '\\p{Extended_Pictographic}')
capability:
  - "Disallow bold markers and emojis; output must follow ABSOLUTE mode"
  - "Commands and skills written in imperative tone with no fluff"
  - "Applies to `commands/`, `rules/`, `skills/`, `CLAUDE.md`, and any LLM-facing file"
usage:
  - "Load for review-llm-prompts, config-sync, doc-gen, and any LLM content task"
validation:
  - "rg --pcre2 '(?<![\\`\\\\])\\*\\*(?![\\`/\\\\\\s])' <file>"
  - "rg --pcre2 '\\p{Extended_Pictographic}' <file>"
fallback: ""
---

## Notes
- Keep regex logic aligned with review-llm-prompts.
- Agents must ensure their outputs adhere to ABSOLUTE mode.
