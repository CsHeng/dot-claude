# Global Development Constraints

## Scope
Cross-cutting constraints that apply to ALL development work. Language-specific guidance lives in skills.

## Absolute Prohibitions
- NEVER hardcode API keys, passwords, secrets, or sensitive credentials
- NEVER use bold markers in any documentation or comments
- NEVER commit configuration files containing secrets to version control
- NEVER bypass environment variable override mechanisms
- NEVER remove existing comments when modifying code
- NEVER implement changes without explicit user requests

## Tool Version Pins
- Python: 3.13+ with union syntax `X | None`
- Go: 1.23+
- Shell: `#!/bin/zsh` for interactive dev, `#!/usr/bin/env bash` for CI
- Lua: 5.4+ with `luac -p` validation
- PlantUML: >=1.2025.9 with `plantuml --check-syntax` validation

## Environment Management
- Python: single `.venv` at project root; `uv` as package manager
- Environment variables: MANDATORY override support on all configurations
- Docker Compose: PROHIBITED `version` field
- Tool versions: `mise` for management

## Development Philosophy
- Incremental: changes file by file for review
- Explicit: only implement explicitly requested changes
- Preservation: preserve existing code structures and comments
- Complete: provide complete edits in single chunks per file
- Testing: RGR when requirements clear; implement-first when exploratory
- Behavior-first: test behavior, not implementation

## CLI Parameter Requirements
- REQUIRED: `--parameter` format for all custom CLI scripts
- PROHIBITED: short parameter aliases (`-x`, `-y`, `-h`) in custom scripts
- PROHIBITED: bare parameters (`help`, `version`) in custom scripts
- REQUIRED: third-party tools retain their native parameter styles
- REQUIRED: write/modify/delete operations default to dry-run; require `--apply` or `--execute`

## Debug and Logging
- Sections: `===` major, `---` sub-sections
- Status: `SUCCESS:` / `ERROR:` prefixes with context
- Log format: `+0800 2025-08-06 15:22:30 INFO main.go(180) | message`
- Fail-fast: exit immediately on errors with relevant state

## Documentation
- PlantUML for architecture diagrams; validate before committing
- Explain rationale, not functionality
- Minimal formatting without bold markers

## Project Structure
- Single app: `cmd/`, `internal/`, `pkg/`, `configs/`, `tests/`
- Multiple apps: independent `cmd/` per app with `shared/` components
- MANDATORY: environment variable support; `.env` for local dev only

## Dbml
- Validate with `dbml2sql <path>`
- Use original table names in Ref statements
- PROHIBITED: table aliases in references
