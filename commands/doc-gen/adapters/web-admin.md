---
name: "doc-gen:web-admin"
description: Stub adapter for web admin documentation workflow
argument-hint: --mode=<bootstrap|maintain> --repo=<path> --docs=<path> --core=<path>
is_background: false
---

## Usage

Use this adapter via `/doc-gen:core:bootstrap` with `--project-type=web-admin`. The core command reads this file to capture stub documentation requirements for admin frontends.

## Arguments

No additional CLI arguments beyond those accepted by `/doc-gen:core:bootstrap`. Mode, repository, docs, and core paths are inherited from the core command.

## Workflow

1. Treat this adapter as a stub; detailed guidance for `web-admin` requires authoring.
2. Use the core orchestrator to gather context and produce a TODO backlog that notes the missing guidance.
3. Mark TODO items with `automation=manual`, check them off as `[x] (manual follow-up required)`, and ensure `_reports/todo.json` and README clearly signal the gap.
4. Focus on route definitions, RBAC modules, dashboard data sources, and analytics integrations when drafting documentation manually.
5. Capture a stub reminder inside `<docs target>/_reports/parameters.json`, and ensure interim notes adopt the selected `--language`.

## Output

When used by the core orchestrator, this adapter contributes:
- TODO entries describing web admin documentation gaps.
- Parameters and stub metadata recorded in `_reports/parameters.json`.
- Clear signals in README and TODO files that a dedicated adapter implementation is pending.
