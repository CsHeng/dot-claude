#!/usr/bin/env python3
"""
Backup retention settings loader for config-sync.

Usage:
    python3 -m config_sync.backup_retention <settings_path>

Prints three newline-separated values:
    max_runs
    enabled (true|false)
    dry_run (true|false)
"""

from __future__ import annotations

import json
import sys
from pathlib import Path
from typing import Tuple


DEFAULT_MAX_RUNS = 5
DEFAULT_ENABLED = True
DEFAULT_DRY_RUN = False


def load_retention(path: Path) -> Tuple[int, bool, bool]:
    if not path.exists():
        return DEFAULT_MAX_RUNS, DEFAULT_ENABLED, DEFAULT_DRY_RUN

    try:
        config = json.loads(path.read_text(encoding="utf-8"))
        retention = (config.get("backup") or {}).get("retention") or {}
        max_runs = int(retention.get("maxRuns", DEFAULT_MAX_RUNS))
        enabled = bool(retention.get("enabled", DEFAULT_ENABLED))
        dry_run = bool(retention.get("dryRun", DEFAULT_DRY_RUN))
        return max_runs, enabled, dry_run
    except Exception:
        return DEFAULT_MAX_RUNS, DEFAULT_ENABLED, DEFAULT_DRY_RUN


def main(argv: list[str] | None = None) -> int:
    args = sys.argv[1:] if argv is None else argv
    if len(args) != 1:
        print(
            "Usage: python -m config_sync.backup_retention <settings_path>",
            file=sys.stderr,
        )
        return 1

    settings = Path(args[0]).expanduser()
    max_runs, enabled, dry_run = load_retention(settings)

    print(str(max_runs))
    print(str(enabled).lower())
    print(str(dry_run).lower())
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

