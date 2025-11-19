---
name: "doc-gen:backend-php"
description: Stub adapter for PHP backend documentation workflow
argument-hint: --mode=<bootstrap|maintain> --repo=<path> --docs=<path> --core=<path>
is_background: false
---

## Usage

Use this adapter via `/doc-gen:core:bootstrap` with `--project-type=backend-php`. The core command reads this file to decide how to represent missing PHP backend documentation.

## Arguments

No additional CLI arguments beyond those accepted by `/doc-gen:core:bootstrap`. Mode, repository, docs, and core paths are inherited from the core command.

## Workflow

1. Treat this adapter as a stub specification for PHP backend projects.
2. During orchestration runs, concentrate on routing definitions, controllers, service providers, queue workers, and deployment routines.
3. Record `TODO(doc-gen)` markers with `automation=manual`, mark them `[x] (manual follow-up required)`, and include rationale so `_reports/todo.json` captures the outstanding work.
4. Add a stub notice to `<docs target>/_reports/parameters.json` and honor the `--language` selection when emitting notes.

## Output

When used by the core orchestrator, this adapter contributes:
- TODO entries describing PHP backend documentation gaps.
- Parameters and stub metadata recorded in `_reports/parameters.json`.
- Guidance for humans on where to focus manual documentation work.
