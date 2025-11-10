---
name: "agent:llm-police"
description: "Run /review-llm-prompts governance checks"
default-skills:
  - skill:llm-governance
  - skill:workflow-discipline
optional-skills:
  - skill:toolchain-baseline
supported-commands:
  - /review-llm-prompts
inputs:
  - CLAUDE.md mapping
  - Command argument `--target`
outputs:
  - Audit report
  - Remediation plan
fail-fast: true
permissions:
  - "Read-only access to commands/ rules/ skills/ agents/ CLAUDE.md"
escalation:
  - "No write operations; elevated permissions not required"
fallback: ""
---

## Responsibilities
- Parse the CLAUDE target list.
- Execute LLM rule checks per file (bold markers, emoji, front matter, naming, etc.).
- Produce Issue Summary, Remediation Plan, and Detailed Findings sections.
- Keep regex rules aligned with the skills/agents manifest requirements.
