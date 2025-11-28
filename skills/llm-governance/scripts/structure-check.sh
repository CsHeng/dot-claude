#!/usr/bin/env bash
set -euo pipefail

# Error handling
trap 'echo "Error on line $LINENO: $BASH_COMMAND" >&2; exit 1' ERR

# Tool availability checks
command -v rg >/dev/null 2>&1 || { echo "Error: rg (ripgrep) is required but not installed." >&2; exit 1; }

# Structure Check (taxonomy-rfc current)
# Validate that a given Claude configuration root follows the current taxonomy-rfc layering conventions.
# Usage:
#   skills/llm-governance/scripts/structure-check.sh [root-dir]
# Defaults to current directory as Claude root.

readonly ROOT_DIR="${1:-.}"
[ -d "${ROOT_DIR}" ] || { echo "Error: Directory '${ROOT_DIR}' does not exist." >&2; exit 1; }
declare -i FAIL=0

echo "== structure check for ${ROOT_DIR} (taxonomy-rfc)"

# 1. Agents: require layer: execution
if [ -d "${ROOT_DIR}/agents" ]; then
  for f in "${ROOT_DIR}"/agents/*/AGENT.md; do
    [ -f "$f" ] || continue
    if ! { rg -q '^layer:[[:space:]]*execution' "$f" 2>/dev/null || true; }; then
      echo "AGENT:MISSING_LAYER execution: ${f}"
      FAIL=1
    fi
  done
fi

# 2. Skills: require layer: execution
if [ -d "${ROOT_DIR}/skills" ]; then
  for f in "${ROOT_DIR}"/skills/*/SKILL.md; do
    [ -f "$f" ] || continue
    if ! { rg -q '^layer:[[:space:]]*execution' "$f" 2>/dev/null || true; }; then
      echo "SKILL:MISSING_LAYER execution: ${f}"
      FAIL=1
    fi
  done
fi

# 3. Optional sanity: warn if COMMAND.md exists under commands/ (should be slash entrypoints only)
if [ -d "${ROOT_DIR}/commands" ]; then
  for f in "${ROOT_DIR}"/commands/*/COMMAND.md; do
    [ -f "$f" ] || continue
    echo "WARN: COMMAND.md found (expected slash entrypoint style only): ${f}"
  done
fi

if [ "${FAIL}" -eq 0 ]; then
  echo "structure-check: OK"
else
  echo "structure-check: FAILED"
fi
