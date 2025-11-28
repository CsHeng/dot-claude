#!/usr/bin/env bash
set -euo pipefail

# Error handling
trap 'echo "Error on line $LINENO: $BASH_COMMAND" >&2; exit 1' ERR

# Tool availability checks
command -v rg >/dev/null 2>&1 || { echo "Error: rg (ripgrep) is required but not installed." >&2; exit 1; }
command -v awk >/dev/null 2>&1 || { echo "Error: awk is required but not installed." >&2; exit 1; }

# Skill Capability Matrix
# Summarize skills, their capability levels, modes, styles, and tags.
# Usage:
#   skills/llm-governance/scripts/skill-matrix.sh [root-dir]
#
# Defaults to current directory as repo root.

readonly ROOT_DIR="${1:-.}"
[ -d "${ROOT_DIR}" ] || { echo "Error: Directory '${ROOT_DIR}' does not exist." >&2; exit 1; }

printf "%-32s %-5s %-16s %-16s %-40s\n" "Skill" "Lvl" "Mode" "Style" "Tags"
printf "%-32s %-5s %-16s %-16s %-40s\n" "$(printf '%.0s-' {1..32})" "$(printf '%.0s-' {1..5})" "$(printf '%.0s-' {1..16})" "$(printf '%.0s-' {1..16})" "$(printf '%.0s-' {1..40})"

for f in "${ROOT_DIR}"/skills/*/SKILL.md; do
  [ -f "$f" ] || continue

  name=$(rg -n '^name:' -m 1 "$f" 2>/dev/null | sed 's/^.*name:[[:space:]]*//' || true)
  level=$(rg -n '^capability-level:' -m 1 "$f" 2>/dev/null | awk '{print $2}' || true)
  mode=$(rg -n '^mode:' -m 1 "$f" 2>/dev/null | sed 's/^.*mode:[[:space:]]*//' || true)
  style=$(rg -n '^style:' -m 1 "$f" 2>/dev/null | sed 's/^.*style:[[:space:]]*//' || true)

  # If not found at top level, check in metadata subfield
  if [[ -z "$level" ]]; then
    level=$(rg -A 10 '^metadata:' "$f" 2>/dev/null | rg 'capability-level:' -m 1 | awk '{print $2}' || true)
  fi
  if [[ -z "$mode" ]]; then
    mode=$(rg -A 10 '^metadata:' "$f" 2>/dev/null | rg 'mode:' -m 1 | sed 's/^.*mode:[[:space:]]*//' || true)
  fi
  if [[ -z "$style" ]]; then
    style=$(rg -A 10 '^metadata:' "$f" 2>/dev/null | rg 'style:' -m 1 | sed 's/^.*style:[[:space:]]*//' || true)
  fi

  tags=$(
    awk '
      /^tags:/ {flag=1; next}
      flag && /^[[:space:]]*-/ {
        gsub(/^[[:space:]]*-[[:space:]]*/, "", $0);
        if (out == "") { out = $0 } else { out = out "," $0 }
      }
      flag && !/^[[:space:]]*-/ {flag=0}
      END { print out }
    ' "$f"
  )

  printf "%-32s %-5s %-16s %-16s %-40s\n" \
    "${name:-}" "${level:-}" "${mode:-}" "${style:-}" "${tags:-}"
done

