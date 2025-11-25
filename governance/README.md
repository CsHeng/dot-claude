# Governance Layer

This directory contains the **orchestration & governance** layer for `~/.claude`.

It complements the three-layer model defined in `docs/taxonomy-rfc.md`:

- Layer 1 – UI entry (slash commands / entrypoints)
- Layer 2 – Orchestration & governance (this directory)
- Layer 3 – Execution (real agents/skills/commands under `~/.claude/{agents,skills,commands}`)

Subdirectories:

- `entrypoints/` – slash-command / UI entrypoint specifications.
- `routers/` – workflow routers that choose which execution agent to call.
- `rules/` – governance rule-blocks that wrap or reference `rules/**`.
- `styles/` – output-style manifests (user-level styles and presets).
