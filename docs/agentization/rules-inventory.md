# Legacy Rules Inventory

Track which sections of `rules/` are represented in skills. Update this table whenever you migrate a rule into a skill.

| Rule File | Key Sections | Covered by Skill | Notes |
| --- | --- | --- | --- |
| rules/00-memory-rules.md | Tool Version Preferences | skill:toolchain-baseline | ✅ |
|  | Development Workflow Preferences | skill:workflow-discipline | ✅ |
|  | Debug Output Format | skill:workflow-discipline | ✅ |
|  | Logging Format | skill:security-logging | ✅ |
| rules/01-development-standards.md | General coding standards | skill:development-standards | ✅ |
| rules/02-architecture-patterns.md | Architecture patterns | skill:architecture-patterns | ✅ |
| rules/03-security-standards.md | Security practices | skill:security-guardrails | ✅ |
| rules/04-testing-strategy.md | Testing strategy | skill:testing-strategy | ✅ |
| rules/05-error-patterns.md | Error handling | skill:error-patterns | ✅ |
| rules/10-python-guidelines.md | Python architecture, typing, testing | skill:language-python | ✅ |
| rules/11-go-guidelines.md | Go architecture, error handling | skill:language-go | ✅ |
| rules/12-shell-guidelines.md | Strict mode, traps, portability | skill:language-shell | ✅ |
| rules/13-docker-guidelines.md | Docker/Container rules | skill:deployment-docker | ✅ |
| rules/14-networking-guidelines.md | Network patterns | skill:networking-controls | ✅ |
| rules/20-tool-standards.md | Tool configurations | skill:toolchain-baseline | ✅ (partial) |
| rules/21-quality-standards.md | Quality metrics/coverage | skill:quality-standards | ✅ |
| rules/22-logging-standards.md | Logging format/implementation | skill:security-logging | ✅ |
| rules/23-workflow-patterns.md | Workflow coordination | skill:workflow-patterns | ✅ |
| rules/98-communication-protocol.md | Communication rules | skill:workflow-discipline | ✅ |
| rules/99-llm-prompt-writing-rules.md | LLM-facing rules | skill:llm-governance | ✅ |

Legend:
- ✅ = skill exists and references the sections via `source`.
- (planned) = skill needs to be created or updated.
