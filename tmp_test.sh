#!/bin/bash
set -euo pipefail
matches="$(
  python3 - "$1" <<'PY'
if True:
    marker = "```" if "a".startswith("a") else "~~~"
PY
)"
echo "DONE"
