#!/usr/bin/env bash
set -euo pipefail

# Structure Check (taxonomy-rfc current)
# Validate that a given Claude configuration root follows the current taxonomy-rfc layering conventions.
# Usage:
#   commands/agent-ops/scripts/structure-check.sh [root-dir]
# Defaults to current directory as Claude root.

ROOT_DIR="${1:-.}"
FAIL=0

echo "== structure check for ${ROOT_DIR} (taxonomy-rfc)"

# 1. Agents: require layer: execution
if [ -d "${ROOT_DIR}/agents" ]; then
  for f in "${ROOT_DIR}"/agents/*/AGENT.md; do
    [ -f "$f" ] || continue
    if ! rg -q '^layer:[[:space:]]*execution' "$f" 2>/dev/null; then
      echo "AGENT:MISSING_LAYER execution: ${f}"
      FAIL=1
    fi
  done
done

# 2. Skills: require layer: execution
if [ -d "${ROOT_DIR}/skills" ]; then
  for f in "${ROOT_DIR}"/skills/*/SKILL.md; do
    [ -f "$f" ] || continue
    if ! rg -q '^layer:[[:space:]]*execution' "$f" 2>/dev/null; then
      echo "SKILL:MISSING_LAYER execution: ${f}"
      FAIL=1
    fi
  done
done

# 3. Optional sanity: warn if COMMAND.md exists under commands/ (should be slash entrypoints only)
if [ -d "${ROOT_DIR}/commands" ]; then
  for f in "${ROOT_DIR}"/commands/*/COMMAND.md; do
    [ -f "$f" ] || continue
    echo "WARN: COMMAND.md found (expected slash entrypoint style only): ${f}"
  done
done

if [ "${FAIL}" -eq 0 ]; then
  echo "structure-check: OK"
else
  echo "structure-check: FAILED"
fi
