---
name: "doc-gen:android-app"
description: "Adapter for Android application documentation bootstrap/maintenance"
argument-hint: "--mode=<bootstrap|maintain> --repo=<path> --docs=<path> --core=<path> [--demo=<path>]"
allowed-tools:
  - Read
  - Write
  - ApplyPatch
  - Bash
  - Bash(rg:*)
  - Bash(ls:*)
  - Bash(fd:*)
  - Bash(tree:*)
  - Bash(cat:*)
  - Bash(plantuml --check-syntax:*)
is_background: false
---

## Scope
Capture the architecture and business flows of Android apps built with Kotlin or Java. The staged deliverables live in whichever docs directory the orchestrator selected. Use the chosen language for narrative sections; keep code identifiers in their native form.

## Mandatory outputs
- Actor matrix: table with these minimum actors—End User, Android App UI, ViewModel layer, Repository/Data layer, Backend Services, Background Workers, Third-party SDKs (analytics, push, etc.). Add project-specific actors as needed. Populate the table in README with code references (for example `app/src/main/java/.../UserCenterViewModel.kt`).
- Validated PlantUML: at least one sequence or activity diagram covering a high-value flow (onboarding, authentication, download, or push notification). Run `plantuml --check-syntax <file>`, append the raw output to `<docs target>/_reports/plantuml.log`, and quote the result in README.
- Critical flows summary: describe the entry points, core modules, and side effects for the prioritized flows listed below.
- TODO backlog & ledger: break down into architecture, feature modules, operations, and PlantUML tasks. Every entry uses `TODO(doc-gen):` plus a path in parentheses and sets `automation=auto`. If human validation is recommended, add `review_required=true` and explain why in the notes. Mirror the same structure in `<docs target>/_reports/todo.json` so the orchestrator can track status.
- Reports bundle: ensure `<docs target>/_reports/parameters.json`, `_reports/todo.json`, `_reports/plantuml.log`, and (for delta scope) `_reports/changes.txt` receive adapter-specific details—e.g., add adapter name, default diagram inventory, recommended directories.

## Preparation checklist
1. Map Gradle modules with `fd --type f --max-depth 2 'build\\.gradle.*' <core>`.
2. Identify architecture patterns: MVVM, MVI, Clean Architecture, single-Activity + navigation, etc.
3. Locate dependency injection setup (Hilt, Dagger, Koin) and note root components and feature modules.
4. Detect background execution frameworks (WorkManager, Coroutines, AlarmManager, JobScheduler).
5. List key third-party SDKs (analytics, push, payments) from Gradle files.

## Automation defaults
- Treat all deliverables this adapter covers as `automation=auto`; generate full drafts (architecture, feature narratives, operations, diagrams) and mark each TODO item as completed (`[x]`) during the run.
- If further review is recommended, set `review_required=true` and summarize the outstanding questions in both TODO notes and README open questions—do not leave the item unchecked.
- Reserve `automation=manual` only for exceptional gaps (e.g., missing source, external approval) and accompany the entry with detailed rationale. These cases must be rare for Android app projects.
- When running in `delta` scope, only emit new TODO entries for modules touched in the change list and still mark each processed item as `[x]` once the fresh draft is generated.

## Architecture overview guidance
- Draw a module map showing `app/` plus each library under `library/`. Include responsibilities and cross-module dependencies.
- Document navigation graphs (XML or Compose navigation) and principal Activities/Fragments.
- Capture lifecycle hooks: custom `Application`, startup initializers, WorkManager configuration, BroadcastReceivers.
- Note build variants/flavors and how they affect configuration.

## Business module drill-down
For each major feature area (Login/Authentication, Download Management, Game Detail, User Center, Network Games, Rebate/Benefits):
- Identify ViewModels, UseCases, Repositories, and associated data sources.
- Outline UI state management (StateFlow, LiveData, RxJava).
- Record local persistence (Room entities, DataStore tables) and remote APIs touched.
- Highlight analytics/telemetry events and feature flags.
- Add TODO entries referencing concrete source files.

## Critical flows to cover
1. User onboarding/authentication  
   - Entry: `SplashActivity`, `LoginActivity`, or equivalent.  
   - Track ViewModel interactions, repository calls, token storage, analytics events.  
   - Generate PlantUML (suggest `docs-bootstrap/diagrams/A01_user_onboarding.puml` or similar).
2. Download management  
   - Entry: `DownloadActivity`, services in `library/ndownload/`.  
   - Trace queueing, persistence, notification updates, and background workers.
3. Push notification / background event handling  
   - Entry: FirebaseMessagingService or custom receivers.  
   - Cover background-to-UI handoff, deep links, user acknowledgement.
4. Offline sync / caching (if present)  
   - Document WorkManager jobs, conflict resolution, data merge strategies.

Summaries for each flow go in README; corresponding TODOs must name source files needing documentation.

## PlantUML expectations
- Maintain an alias registry at the top of every diagram. Use consistent aliases throughout.
- Prefix section headers with IDs (`== A. Onboarding ==`), and reference those IDs in README/TODO.
- After running `plantuml --check-syntax`, append the output message (e.g., `SUCCESS: plantuml --check-syntax ...`) to `<docs target>/_reports/plantuml.log` and quote the same line in README under the PlantUML section.

## Documentation structure (staging)
When bootstrapping, recommend this layout inside `docs-bootstrap/` (adjust names if the human prefers a different scheme):
```
docs-bootstrap/
├── README.md                # Generated summary (required)
├── TODO.md                  # Generated backlog (required)
├── architecture/
│   ├── module-map.md
│   ├── dependency-injection.md
│   └── lifecycle.md
├── features/
│   ├── onboarding.md
│   ├── download-management.md
│   ├── game-detail.md
│   └── user-center.md
├── operations/
│   ├── build-and-release.md
│   ├── testing-strategy.md
│   └── monitoring.md
└── diagrams/
    ├── A01_user_onboarding.puml
    ├── B01_download_flow.puml
    └── C01_push_notifications.puml
```
Call out any existing files under `docs/` that is merged after review (for example, `docs/VIEWS.md`). Include those merge recommendations in README → Recommended structure.

## Exit criteria
- README contains parameter table, module snapshot, documentation inventory, actor matrix, PlantUML validation results, flow summaries, recommended structure, and open questions.
- TODO backlog includes `TODO(doc-gen)` items with explicit paths for each priority area.
- At least one PlantUML diagram validated; failures are documented with error output and remediation TODO.
- Risks and next steps clearly articulated so maintain runs can pick up work without re-reading the adapter.
