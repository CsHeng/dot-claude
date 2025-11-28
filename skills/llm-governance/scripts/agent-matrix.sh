#!/usr/bin/env bash
set -euo pipefail

# Error handling
trap 'echo "Error on line $LINENO: $BASH_COMMAND" >&2; exit 1' ERR

# Tool availability checks
command -v rg >/dev/null 2>&1 || { echo "Error: rg (ripgrep) is required but not installed." >&2; exit 1; }
command -v awk >/dev/null 2>&1 || { echo "Error: awk is required but not installed." >&2; exit 1; }
command -v sed >/dev/null 2>&1 || { echo "Error: sed is required but not installed." >&2; exit 1; }

# Agent Capability Matrix
# Summarize agents, their capability levels, loop styles, styles, and skill dependencies.
# Usage:
#   skills/llm-governance/scripts/agent-matrix.sh [root-dir]
#
# Defaults to current directory as repo root.

readonly ROOT_DIR="${1:-.}"
[ -d "${ROOT_DIR}" ] || { echo "Error: Directory '${ROOT_DIR}' does not exist." >&2; exit 1; }

printf "%-32s %-5s %-18s %-16s %-40s %-40s\n" "Agent" "Lvl" "Loop" "Style" "Default Skills" "Optional Skills"
printf "%-32s %-5s %-18s %-16s %-40s %-40s\n" "$(printf '%.0s-' {1..32})" "$(printf '%.0s-' {1..5})" "$(printf '%.0s-' {1..18})" "$(printf '%.0s-' {1..16})" "$(printf '%.0s-' {1..40})" "$(printf '%.0s-' {1..40})"

for f in "${ROOT_DIR}"/agents/*/AGENT.md; do
  [ -f "$f" ] || continue

  name=$(rg -n '^name:' -m 1 "$f" 2>/dev/null | sed 's/^.*name:[[:space:]]*//; s/"//g' || true)
  level=$(rg -n '^capability-level:' -m 1 "$f" 2>/dev/null | awk '{print $2}' || true)
  loop=$(rg -n '^loop-style:' -m 1 "$f" 2>/dev/null | awk '{print $2}' || true)
  style=$(rg -n '^style:' -m 1 "$f" 2>/dev/null | sed 's/^.*style:[[:space:]]*//' || true)

  default_skills=$(
    awk '
      /^default-skills:/ {flag=1; next}
      /^optional-skills:/ {flag=0}
      /^supported-commands:/ {flag=0}
      flag && /^[[:space:]]+-/ {
        gsub(/^[[:space:]]+-[[:space:]]*/, "", $0);
        if (out == "") { out = $0 } else { out = out "," $0 }
      }
      END { print out }
    ' "$f"
  )

  optional_skills=$(
    awk '
      /^optional-skills:/ {flag=1; next}
      /^supported-commands:/ {flag=0}
      flag && /^[[:space:]]+-/ {
        gsub(/^[[:space:]]+-[[:space:]]*/, "", $0);
        if (out == "") { out = $0 } else { out = out "," $0 }
      }
      END { print out }
    ' "$f"
  )

  printf "%-32s %-5s %-18s %-16s %-40s %-40s\n" \
    "${name:-}" "${level:-}" "${loop:-}" "${style:-}" "${default_skills:-}" "${optional_skills:-}"
done

