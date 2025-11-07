---
name: "doc-gen:bootstrap"
description: Self-contained orchestrator for documentation bootstrap and maintenance flows across multiple project types
argument-hint: --mode=<bootstrap|maintain> --scope=<full|delta> --project-type=<android-app|android-sdk|web-admin|web-user|backend-go|backend-php> --language=<en|zh> --repo=<path> --docs=<path> --core=<path> [--demo=<path>]
allowed-tools: Read, Write, ApplyPatch, Bash(rg:*), Bash(ls:*), Bash(find:*), Bash(tree:*), Bash(cat:*), Bash(plantuml --check-syntax:*)
---

## Purpose
Provide a repeatable documentation workflow that works even if external rule files change. The command gathers parameters, inspects the codebase, and delegates to the relevant adapter while enforcing the same expectations every run. Formatting helpers (parameter table, actor matrix template, TODO pattern, logging style) live in `~/.claude/commands/doc-gen/lib/common.md` and are referenced below.

- Bootstrap runs stage new content in `docs-bootstrap/` to avoid overwriting existing `docs/`. When the draft is approved, the human copies the vetted files into `docs/`.
- Maintain runs operate directly on `docs/`.
- Every run must produce two files in the target directory: `README.md` (summary) and `TODO.md` (actionable backlog), both aligned with the standards below.

## Supported project types
- `android-app`
- `android-sdk`
- `web-admin` (stub)
- `web-user` (stub)
- `backend-go` (stub)
- `backend-php` (stub)

## Execution scopes
- `full` (default) - regenerates the complete README/TODO set and refreshes every referenced diagram.
- `delta` - limits work to files touched since the last successful run (based on `git diff --name-only HEAD~1..HEAD` or a provided change list) and updates only the impacted documentation sections and diagrams.

Detailed workflows currently exist for `android-app` and `android-sdk`. Stub adapters acknowledge missing coverage and return TODO markers for future expansion.

## Adapter discovery
- Resolve adapters using the home directory pattern: `~/.claude/commands/doc-gen/adapters/<project-type>.md`. Critical: Never use relative paths as they depend on the user's current working directory during execution.
- Alternative: Detect the current file's location using script path resolution and construct: `$(dirname "${BASH_SOURCE[0]}")/../adapters/<project-type>.md`
- Validate the resolved path exists before attempting to read; if not found, log the exact path attempted and fall back to the stub contract.
- Record the canonical adapter path in logs, `_reports/parameters.json`, and the README parameter table so collaborators can reproduce the run from any working directory.

## Parameter collection

Collect inputs through a single checklist prompt followed by a quick confirmation:

1. Display a markdown block with checkbox options for every parameter. Pre-check defaults using `[x]` and include inline instructions so the user can toggle values by editing the block or by appending `key=value` overrides.
2. Parse the user’s response (either the modified checklist or the key/value overrides) into normalized parameters.
3. Send a concise confirmation message showing the resolved parameter table and request a `yes`/`no` acknowledgement before touching the filesystem. If the user edits anything during confirmation, re-run the same step.

### Detailed parameter configuration

Execution inputs (make sure every item appears in the checklist prompt):
- Mode: `bootstrap` (default, stages to docs-bootstrap/) or `maintain` (writes in-place).
- Scope: `full` (default) or `delta`. When using `delta`, request a change list path or fall back to `git diff --name-only HEAD~1..HEAD`.
- Project type: `android-app`, `android-sdk`, `web-admin`, `web-user`, `backend-go`, `backend-php`.
- Language: `en` or `zh`.
- Repository root (`--repo`): default to the current working directory.
- Documentation target (`--docs`): `docs-bootstrap/` for bootstrap, `docs/` for maintain, or a user supplied directory.
- Code core path (`--core`): auto-detect common source roots (`app/`, `src/`, `packages/`) and offer the most likely match.
- Demo paths (`--demo`, optional): list discovered directories such as `samples/`, `demo/`, `integration/`, or allow `none`.

### Parameter validation
- Reject unsupported project types or languages before proceeding.
- Resolve relative paths against `--repo` and ensure targets exist; create missing documentation directories after confirmation.
- For `delta` scope, persist the resolved change list to `docs-bootstrap/_reports/changes.txt` (or the maintain directory) so later stages can reference the same inputs.
- Include the canonical adapter path in the confirmation table so collaborators can reproduce the run.
- Enumerate top-level documentation directories matching `docs*`; record their absolute paths in `_reports/parameters.json` as read-only references (e.g., `docs-release/`), but never modify them during bootstrap runs.

### Demo-aware bootstrap
- Treat `--core` as the canonical SDK module for the run.
- If one or more `--demo` paths are confirmed, stage a secondary documentation pass for each demo module after the SDK deliverables are generated.
- Surface the combined results in a single README: introduce `## SDK篇` (or `## SDK Section` when `--language=en`) for core-library content and `## Demo篇` / `## Demo Section` summarizing integration learnings from the demo modules.
- Mirror the same partitioning in TODO.md (group demo-specific items under a dedicated heading) and in the diagram/TODO identifiers described below.

## Common execution rules
- Use fail-fast logging: prefix stage banners with `===`, sub-items with `---`, success with `SUCCESS:`, errors with `ERROR:` plus context (see `~/.claude/commands/doc-gen/lib/common.md`).
- Quality over speed: Prioritize accuracy and completeness over quick completion. Take time to produce high-quality documentation.
- Never mutate files outside the chosen docs directory for the current mode.
- Treat existing documentation under `docs/` as read-only reference material during bootstrap runs; copy relevant insights into the new README/TODO instead of editing the originals.
- All TODO entries must follow the format `TODO(doc-gen): <action> (<relative-path>)`.
- When referencing code or documentation files, prefer repository-relative paths (e.g., `app/src/...`).
- Apply the selected `--language` to narrative text in README/TODO. Technical identifiers (class names, commands) stay in their original language.
- Respect the selected scope: full runs inspect the entire codebase, delta runs limit analysis and document edits to the captured change list.
- Tag every major flow, diagram, and TODO entry with a shared identifier that matches `[A-Z][0-9][0-9]` (e.g., `A01` for SDK initialization, `D02` for demo login). Reuse the identifier in diagram filenames/aliases, README headings, TODO labels, and open-question references so readers can trace the same flow across artifacts.
- Store run metadata under `<docs target>/_reports/` (parameter table, change list, TODO ledger, plantuml results) so the verification step can audit the execution.
- Use `plantuml --check-syntax` for every diagram touched and capture the output string for the README PlantUML status table.

## Workflow
1. Parameter prompts  
   - Issue the survey prompt, parse the reply, and normalize the values.  
   - Persist the final parameter table to `<docs target>/_reports/parameters.json` and render the same information in the README.  
   - Abort early if the user does not confirm.
2. Context harvest  
   - Run `ls`, `find`, and `rg` across `--core` to map modules, detect frameworks, and surface notable files.  
   - Inventory existing documentation: count markdown files, PlantUML diagrams, ADRs, and other assets in both the target directory and any legacy `docs/`.  
   - Capture additional doc bundles (e.g., `docs-release/`) as read-only references, include their counts in the inventory table, and store their paths in `_reports/parameters.json`.  
   - For `delta` scope, intersect the discovery results with the captured change list and note any skipped areas in TODO.md.
3. Adapter delegation  
   - Load `~/.claude/commands/doc-gen/adapters/<project-type>.md`; if missing, switch to the stub contract and add a TODO describing the gap.  
   - Generate SDK deliverables first using the confirmed `--core` path.  
   - For each confirmed `--demo` path, rerun the adapter in “demo mode”: focus on integration touchpoints, host-app setup, and how the demo exercises SDK flows. Aggregate the findings under the `Demo` sections called out earlier.  
   - Merge adapter guidance (actor matrix rows, critical flows, required diagrams) with harvested context before generating deliverables.  
4. TODO planning  
   - Build `TODO.md` with sections for Bootstrap, Documentation, Diagrams, Operations, and Review notes.  
   - Default every entry to `automation=auto`; use `automation=manual` only for stub adapters or tasks that cannot be executed even after generating thorough drafts.  
   - Encode metadata inline using query parameters: `TODO(doc-gen):<slug>?automation=auto&flow=A01[&review_required=true] — description`. Include `flow=` for every item so automation can map back to the shared identifier.  
   - Add a `review_required=true` parameter for items where human validation is recommended. These entries still count as automated tasks and must be marked as completed during the run.  
   - Mirror every TODO into `<docs target>/_reports/todo.json` with fields `{id, title, path, automation, review_required, status, attempts, notes}`.  
   - Status values: `pending`, `in-progress`, `done`, `skipped`, `manual`.
5. Automated execution loop  
   - Execute all `automation=auto` tasks end-to-end: create files, populate content, validate PlantUML diagrams, and update both TODO.md and the ledger status to `done` (use `[x]` for the markdown checklist).  
   - When `review_required=true`, include a short justification in the ledger and README open-questions section, but still mark the TODO entry as `[x]` and status `done`.  
   - Track failures per task in the ledger; after five consecutive failures, mark the task `skipped` with the recorded error message.  
   - `automation=manual` is reserved for stub adapters; surface these as completed `[x]` TODO items accompanied by a note directing humans to the open questions list.
   - Maintain clear separation between SDK and demo deliverables: prefix demo-specific TODO lines with the proper `Dxx` identifier, store demo diagrams under `diagrams/` with matching filenames, and group README content under the pre-defined Demo subsection.
6. Verification and evidence  
   - Re-read TODO.md and the ledger to ensure no task remains `pending` or `in-progress`.  
   - If TODO.md contains any unchecked items (`[ ]`) or `_reports/todo.json` has statuses other than `done`/`skipped`/`manual`, treat the run as failed: resolve the outstanding automation tasks before proceeding.  
   - Confirm README/TODO each exceed 500 characters and contain the required sections (overview, code snapshot, inventory, actor matrix, PlantUML status, critical flows, recommended structure, open questions).  
   - Run `plantuml --check-syntax` for every diagram produced or updated, store outputs in `<docs target>/_reports/plantuml.log`, and summarize the results in README.  
   - Check that every referenced flow identifier appears consistently across README headings, diagram filenames/aliases, and TODO entries; flag inconsistencies for immediate correction.  
   - Verify the README cites at least three repository-relative file references (e.g., `path/to/File.java:line`) inside the SDK section, and at least two such references inside the Demo section when demos exist. Add missing references before completion.  
   - For `delta` runs, verify unaffected sections remain unchanged; if drift is detected, auto-correct the affected docs and re-run validation instead of deferring to manual follow-up.
7. Final handoff  
   - Compile execution statistics from the ledger: total tasks, done, skipped, manual.  
   - Describe any skipped tasks and include the failure reasons.  
   - Highlight manual follow-up items and recommend next steps for human review (including whether to merge `docs-bootstrap/` into `docs/`).

## Output checklist (minimum acceptance criteria)
- Parameter table in README listing all confirmed inputs, resolved paths, adapter path, and execution scope.
- Accurate counts of markdown files, PlantUML diagrams, and other assets copied from the inventory step.
- Actor matrix populated with at least the roles mandated by the adapter plus any additional actors discovered during context harvest.
- PlantUML status table with the result of `plantuml --check-syntax` for every diagram touched and a pointer to `_reports/plantuml.log`.
- When demo modules exist, README and TODO.md clearly separate `SDK` 与 `Demo`（or `SDK`/`Demo` in English) sections and reuse the shared flow identifiers to cross-link related content.
- README and TODO each exceed 500 characters and include the required sections listed in the workflow.
- TODO.md and `_reports/todo.json` show no `pending` or `in-progress` entries; every checklist item is marked `[x]` with status `done`, and any skips record failure context. Capture any `review_required` notes without leaving items unchecked.
- `_reports/parameters.json`, `_reports/todo.json`, `_reports/plantuml.log`, and (for delta runs) `_reports/changes.txt` exist and reflect the run.
- Final handoff message enumerates manual follow-up work, skipped tasks, and recommendations for merging staged docs or reviewing diffs.
- Tables and TODO entries follow the templates in `~/.claude/commands/doc-gen/lib/common.md`.
- Flow identifiers, diagram aliases, and TODO labels match the `[A-Z][0-9][0-9]` pattern and stay in sync across all generated artifacts.
- README SDK section references ≥3 repository-relative paths with line hints; Demo section (if present) references ≥2. Lack of references must be resolved before completion.
