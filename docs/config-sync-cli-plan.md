# config-sync-cli redesign plan

## objective
Unify every config-sync workflow under a single entrypoint named `config-sync-cli`. The new CLI must collect and validate parameters once, enforce phase ordering automatically, and fan out to adapters or verifiers based on a declarative plan. Legacy slash commands become thin aliases that call the CLI with presets until they can be deleted.

## current-state summary
- Core commands live under `commands/config-sync/core` (`sync`, `sync-user-config`, `verify`, `analyze`).
- Adapter commands live under `commands/config-sync/adapters` (tool-specific sync plus helpers such as `adapt-commands`, `adapt-permissions`, `adapt-rules-content`).
- Each command re-implements argument parsing, validation, environment bootstrapping, and logging; sequencing between commands depends on human memory.
- Settings such as `defaults.target` reside in `commands/config-sync/settings.json`, but the defaults are not enforced uniformly.
- Scripts (`scripts/executor.sh`, `scripts/backup.sh`) and shared helpers (`lib/common.sh`) are callable by any command yet lack a coordinator that understands cross-command dependencies.
- Pain points: duplicate parsing, manual enforcement of pre/post verification, scattered logging, and no single surface to introduce new phases or feature flags.

## target user journeys
1. **Full sync**: `config-sync-cli --action=sync --target=droid,qwen --components=rules,permissions` collects parameters, builds an execution plan, runs required adapters, then verifies automatically.
2. **Analyze only**: `config-sync-cli --action=analyze --target=opencode --format=table` produces a report without touching files.
3. **Verification after external changes**: `config-sync-cli --action=verify --target=all --component=commands --fix` runs validation routines and optional remediation.
4. **Selective adaptation**: `config-sync-cli --action=adapt --adapter=permissions --target=qwen --dry-run` executes only the permissions adapter but still benefits from shared validation, logging, and reporting.
5. **Pipeline replay**: `config-sync-cli --plan-file=.config-sync/plan.json --from-phase=prepare --until-phase=verify` resumes a previously generated plan when a run was interrupted.

## cli contract
### invocation model
```
config-sync-cli [--action=<sync|analyze|verify|adapt|plan|report>] \
                [--target=<list|all>] \
                [--components=<list|all>] \
                [--adapter=<commands|permissions|rules|memory|settings>] \
                [--profile=<fast|full|custom>] \
                [--plan-file=<path>] \
                [--from-phase=<phase>] [--until-phase=<phase>] \
                [--dry-run] [--force] [--fix] [--no-verify]
```
- `--action` selects the high-level intent. Default is `sync`, which implicitly runs analyze→plan→prepare→execute→verify.
- `--target` and `--components` reuse the parsing helpers from `lib/common.sh`; inputs are comma-separated, case-insensitive, and validated up front.
- The parameter collection UI exposes checkbox-style multi-select controls for both targets and components. When arguments are missing, `all/full` is preselected so one submission captures the defaults; CLI flags still override any interactive choices for scripted runs.
- `--profile` loads canned option bundles (for example `fast` skips command adaptation, `full` uses strict verification, `custom` defers to plan file overrides).
- `--plan-file` stores or loads the declarative execution plan (`plan build` writes JSON, later runs consume it for reproducibility); default location is `~/.claude/config-sync/plan-<timestamp>.json`.
- `--from-phase` and `--until-phase` gate which pipeline segments run during this invocation, preventing misuse (for example, cannot run `execute` before `prepare`).
- Flags such as `--dry-run`, `--force`, `--fix`, and `--no-verify` map directly to behaviors in the plan and are enforced consistently instead of per-command.

### validation strategy
1. Parse CLI arguments once, using `getopts` or `yq` to support both short and long forms.
2. Normalize targets/components via `parse_target_list` and `parse_component_list`.
3. Load defaults from `settings.json` and merge with explicit arguments (CLI overrides > profile > defaults).
4. Build a plan object that lists phases, steps, dependencies, and required scripts/commands.
5. Run structural validation on the plan (detect missing adapters, invalid phase ordering, or conflicting flags).
6. Persist the plan so later phases and external tooling can inspect exactly what will run.

## execution phases
- `collect`: Gather environment data (installed CLIs, existing config paths, user overrides) and fail fast if prerequisites are missing.
- `analyze`: Inspect Claude's source of truth plus target tooling state, producing a capability digest stored in the plan.
- `plan`: Determine which adapters and scripts must run, plus backup requirements, concurrency, and verification depth.
- `prepare`: Create backups by snapshotting every file that may change for each target, stage temp work directories, and fetch any remote assets; abort if backup fails when `--force` is not present.
- `adapt`: Invoke component-specific adapters (rules, commands, permissions, memory) with arguments derived from the plan.
- `execute`: Apply file operations via `scripts/executor.sh`, orchestrating rsync/cp/link steps per target and guaranteeing rollback by restoring from the pre-execution snapshots when failures occur.
- `verify`: Call the verification routines and optionally auto-fix issues when `--fix` is set.
- `report`: Emit a summary (markdown/json) that captures run metadata, changes, and follow-up recommendations.
Phase gating logic ensures we cannot jump into `adapt` without a validated plan, aligning with the user's requirement for strict ordering.

## module architecture
```
commands/config-sync/
  cli/
    config-sync-cli.md      # single slash command definition
    config-sync-cli.sh      # entrypoint script
  lib/
    common.sh               # keep shared parsing/logging helpers
    phases/
      collect.sh            # phase controller, reused across flows
      analyze.sh
      plan.sh
      prepare.sh
      adapt.sh
      execute.sh
      verify.sh
      report.sh
    planners/
      sync_plan.sh          # builds plans for sync flows
      adapt_plan.sh
  adapters/
    <existing adapters invoked internally; legacy markdown wrappers become thin aliases during transition>
  scripts/
    executor.sh
    backup.sh
  settings.json             # defaults extended with per-profile presets
```
- `config-sync-cli.sh` loads `lib/common.sh`, dispatches on `--action`, assembles the plan with planner helpers, and streams execution through the phase modules.
- Phase modules expose a uniform interface (`run_phase <phase_name> <plan_json>`) so they can be sequenced dynamically.
- Adapter scripts remain focused on target-specific transformations but are called exclusively via the CLI’s adapt phase once wrappers are deprecated.
- Report generation writes both stdout-friendly summaries and machine-readable artifacts under `~/.claude/config-sync/run-<timestamp>/` for auditing.

## migration approach
1. Implement `config-sync-cli.md` and `.sh` behind a feature flag while keeping legacy commands untouched.
2. Update `/config-sync:sync`, `/config-sync:verify`, etc., to call the CLI with pre-populated arguments (for example `/config-sync:verify` becomes a wrapper script that executes `config-sync-cli --action=verify ...`).
3. Deprecate legacy commands incrementally by emitting warnings and documenting the new usage in `commands/config-sync/readme.md` and `docs/config-sync-commands.md`.
4. After parity is proven, remove redundant command markdown files and scripts, leaving only the CLI plus wrapper shims for external tools that still require old names.
5. Expand automated tests or smoke scripts to cover CLI flows, ensuring coverage thresholds (80% overall, 95% on critical flows) stay intact.

## instrumentation and reporting
- Standardize logging format via helpers in `lib/common.sh` so every phase emits `[+0800 TIMESTAMP LEVEL file(line)] message` per user preference.
- Persist run metadata (targets, components, phases executed, duration, exit codes) in `~/.claude/config-sync/history.jsonl` for traceability.
- Provide `--format` toggles for `report` to produce markdown (human), json (automation), and brief CLI summaries.
