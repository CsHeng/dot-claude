---
name: "doc-gen:web-user"
description: Stub adapter for web user-facing frontend documentation workflow
argument-hint: --mode=<bootstrap|maintain> --repo=<path> --docs=<path> --core=<path>
---

## Usage

Use this adapter via `/doc-gen:core:bootstrap` with `--project-type=web-user`. The core command reads this file to capture stub documentation requirements for user-facing frontends.

## Arguments

No additional CLI arguments beyond those accepted by `/doc-gen:core:bootstrap`. Mode, repository, docs, and core paths are inherited from the core command.

## Workflow

1. Treat this adapter as a stub; detailed guidance for `web-user` projects is not yet available.
2. Record TODO items covering landing pages, marketing funnels, checkout flows, and content delivery pipelines.
3. Tag each entry with `automation=manual`, mark it as `[x] (manual follow-up required)`, and ensure `_reports/todo.json` captures outstanding work.
4. Add a stub reminder to `<docs target>/_reports/parameters.json`.
5. Reference the core workflow for asset sweeps, module mapping, and PlantUML validation, and emit interim notes using the selected `--language`.

## Output

When used by the core orchestrator, this adapter contributes:
- TODO entries describing web user-facing documentation gaps.
- Stub metadata recorded in `_reports/parameters.json`.
- Clear signals in README and TODO files about missing dedicated guidance.
