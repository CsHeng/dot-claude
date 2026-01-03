# Memory (AGENTS.md)

This file is intended to be synced as a "memory" entrypoint for coding agents.
Do not duplicate taxonomy payloads (agents/skills/commands) here; those are synchronized via their own directories and discovered by each tool.

## Rules (Single Source of Truth)

- Load and follow numbered rule files under `rules/` in the current configuration root.
- Treat `rules/` as the canonical policy surface; this memory file should only reference it, not re-encode it.

## Practical Defaults

- Communication protocol: `rules/98-communication-protocol.md`
- Output styles: `rules/98-output-styles.md` and `output-styles/`
