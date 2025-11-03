---
name: "doc-gen:bootstrap"
description: Self-contained orchestrator for documentation bootstrap and maintenance flows across multiple project types
argument-hint: --mode=<bootstrap|maintain> --project-type=<android-app|android-sdk|web-admin|web-user|backend-go|backend-php> --language=<en|zh> --repo=<path> --docs=<path> --core=<path> [--demo=<path>]
allowed-tools: Read, Bash(rg:*), Bash(ls:*), Bash(find:*), Bash(tree:*), Bash(cat:*)
---

## Purpose
Provide a repeatable documentation workflow that works even if external rule files change. The command gathers parameters, inspects the codebase, and delegates to the relevant adapter while enforcing the same expectations every run. Formatting helpers (parameter table, actor matrix template, TODO pattern, logging style) live in `../lib/common.md` relative to this core file and are referenced below.

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

Detailed workflows currently exist for `android-app` and `android-sdk`. Stub adapters acknowledge missing coverage and return TODO markers for future expansion.

## Parameter collection

Use a single unified checkbox interface to collect all parameters at once. Auto-detect available directories and suggest as defaults.

### Detailed parameter configuration

**Execution mode**
- [ ] `bootstrap` - Initialize new documentation structure (creates docs-bootstrap/ staging area)
- [ ] `maintain` - Maintain existing documentation (modifies docs/ directly)

**Project type**
- [ ] `android-app` - Android application (full support)
- [ ] `android-sdk` - Android SDK library (full support)
- [ ] `web-admin` - Web admin interface (stub)
- [ ] `web-user` - Web user-facing frontend (stub)
- [ ] `backend-go` - Go backend service (stub)
- [ ] `backend-php` - PHP backend service (stub)

**Output language**
- [ ] `English` - English documentation
- [ ] `中文` - Chinese documentation (technical terms remain in original language)

**Path configuration**

**Bootstrap mode:**
- **Reference source**: Read existing `docs/` as reference (if present)
- **Output target**: Always `docs-bootstrap/` (safe, preserves existing docs)

**Maintain mode:**
- **Reference and output**: Same directory for both reading and writing
- **Default target**: `docs/` with custom path option
- User selects which docs directory to maintain

Custom input format for all paths: `repo_path, docs_path, core_path, demo_path(optional)`
Example: `./my-project, docs/, src/, samples/`

**Demo directories** (optional)
Auto-detect `samples/`, `demo/`, `integration/` directories with multi-select, or accept `skip`/custom input.

### Parameter validation
- Reject invalid combinations immediately (e.g., unsupported project types)
- Validate paths exist or can be created before proceeding
- Present a single summary table listing all resolved parameters (paths must be absolute or clearly relative to `--repo`)
- Request final confirmation before continuing execution

## Common execution rules
- Use fail-fast logging: prefix stage banners with `===`, sub-items with `---`, success with `SUCCESS:`, errors with `ERROR:` plus context (see `../lib/common.md` relative to this core file).
- **Quality over speed**: Prioritize accuracy and completeness over quick completion. Take time to produce high-quality documentation.
- Never mutate files outside the chosen docs directory for the current mode.
- Treat existing documentation under `docs/` as read-only reference material during bootstrap runs; copy relevant insights into the new README/TODO instead of editing the originals.
- All TODO entries must follow the format `TODO(doc-gen): <action> (<relative-path>)`.
- When referencing code or documentation files, prefer repository-relative paths (e.g., `app/src/...`).
- Apply the selected `--language` to narrative text in README/TODO. Technical identifiers (class names, commands) stay in their original language.

## Workflow
1. **Unified parameter collection**
   - Present quick-start templates and detailed checkbox interface in a single interaction
   - Auto-detect available directories and populate sensible defaults
   - Validate all selections and show confirmed parameter table before proceeding
   - Echo the confirmed parameter table in README, including `--repo`, `--core`, `--docs`, `--demo`, `--mode`, `--project-type`, and `--language`.
2. **Context harvest**  
   - Use `ls`, `find`, and `rg` to map module boundaries under `--core`.  
   - Inventory existing docs: count markdown files, PlantUML diagrams (`*.puml`), ADRs, and any other assets under both the staging directory and the legacy `docs/`. Record exact counts (no estimates).  
   - Highlight mismatches between code structure and documentation coverage.
3. **Adapter delegation**  
   - Load `~/.claude/commands/doc-gen/adapters/<project-type>.md` and carry out the listed tasks.  
   - Incorporate adapter outputs (actor matrices, flow requirements, module notes) into the README/TODO deliverables.
4. **Deliverables generation**  
   - `README.md` must include the following sections (adjust headings to the selected language if needed):  
     1. Project overview (include parameter table).  
     2. Codebase snapshot (module layout, key tech stack).  
     3. Documentation inventory with exact counts.  
     4. Actor matrix table (`Actor | Role | Code references | Notes`).  
     5. PlantUML status: list every diagram touched plus the result of `plantuml --check-syntax`; explicitly state if a diagram has not been validated yet.  
     6. Critical flows summary (per adapter guidance).  
     7. Recommended documentation structure (baseline is to stage in `docs-bootstrap/` during bootstrap; point to `docs/` for maintain).  
     8. Open questions or risks.  
   - `TODO.md` must organize tasks by priority and domain. Each checklist item uses the `TODO(doc-gen)` prefix and references the relevant path. Separate sections for PlantUML actions, architecture tasks, feature docs, and operations. Mark completed bootstrap steps (parameter collection, inventory, etc.) as `[x]`.
5. **TODO execution**
   - Parse generated TODO.md and **systematically execute ALL tasks with focus on quality**
   - Auto-execute ALL PlantUML diagram validation and generation with meaningful content (not just syntax)
   - Auto-create ALL recommended directory structure and documentation files with substantial content
   - Auto-generate ALL architecture diagrams and module documentation from thorough code analysis
   - Execute ALL feature documentation tasks (download, game detail, network games, rebate systems, etc.) with detailed analysis
   - Execute ALL operations documentation tasks (testing, monitoring, deployment, etc.) with comprehensive coverage
   - **No task left behind**: Process every single TODO item except those truly impossible to automate
   - **Quality first approach**: Take time to ensure each generated file has meaningful, accurate content
   - Update TODO.md to mark completed tasks as [x] during execution
   - Continue execution until **100% of TODO tasks are completed** (executed or skipped due to failures)
   - **Safety rule**: If the same command fails 5 times in a row on the same TODO item, skip that item and note the failure

6. **TODO completion verification**
   - **Mandatory verification step**: Read and analyze TODO.md to verify completion status
   - **Completion audit**: Count total TODO items and verify each has definitive status ([x] completed or marked as failed/skipped)
   - **PlantUML content verification**:
     - Verify all PlantUML files are not just syntactically valid
     - Check each .puml file contains actual diagram content (participants, actors, interactions)
     - Reject empty or placeholder PlantUML files
     - Ensure diagrams have meaningful content with proper relationships and flows
   - **Documentation content verification**:
     - Verify all generated .md files contain substantial content (>500 characters minimum)
     - Check documentation files are not empty templates
     - Ensure content matches the described purpose and scope
   - **Self-check**: If any TODO items remain unprocessed OR any generated files are inadequate, automatically return to step 5
   - **Verification loop**: Repeat execution → verification cycle until 100% completion and content quality is achieved
   - **Quality gate**: Cannot proceed to final handoff without passing verification
   - **Evidence collection**: Document verification results, completion statistics, and content quality metrics

7. **Final handoff**
   - Only conclude when **all TODO tasks are processed** (100% completion rate, zero unprocessed items)
   - Report detailed execution statistics: Total tasks X, Completed Y, Skipped Z, Failed W (X=Y+Z+W)
   - **Mandatory requirement**: Must demonstrate that every single TODO item has been addressed
   - List tasks skipped due to 5-strike failures (if any) with specific error reasons
   - List remaining truly manual tasks that require human judgment (if any)
   - **Early completion rejection**: Bootstrap is incomplete if any TODO items remain unprocessed

## Output checklist (minimum acceptance criteria)
- Parameter table in README listing all confirmed inputs.
- Accurate counts of markdown files and PlantUML diagrams (no placeholders).
- Actor matrix populated with at least the roles mandated by the adapter.
- **ALL PlantUML diagrams validated with syntax check AND contain meaningful content**.
- **All generated .puml files contain actual diagram elements (actors, participants, flows)**.
- **All generated .md files contain substantial content (>500 characters minimum)**.
- **100% of TODO tasks processed and marked as [x] in TODO.md** (completed or skipped due to 5-strike failures).
- **Zero unprocessed TODO items permitted** - every item must have definitive status.
- **Verification step passed**: TODO completion verification must confirm 100% processing AND content quality.
- **Generated documentation files actually created and populated with meaningful content**.
- Summary of open questions and recommended next actions (for remaining manual tasks only).
- For bootstrap: confirm whether the human should merge changes into `docs/` after review.
- For maintain: state the diff impact on `docs/`.
- **TODO execution results**: Detailed summary of completed vs skipped vs failed tasks with 100% processing rate.
- **Generated artifacts**: All recommended directory structure and documentation files created with quality content.
- **Evidence of completion**: Must show concrete proof that every TODO was addressed, files contain meaningful content, and verification passed.

Failure to meet any of these items means the bootstrap run is incomplete and must be repeated or amended before handoff.
- When building tables or TODO entries, follow the templates in `../lib/common.md` relative to this core file.
