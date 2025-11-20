#!/usr/bin/env python3
"""
Settings loader for sync-cli defaults.

Usage:
    python3 -m config_sync.settings_loader <settings_path>

Prints four newline-separated values:
    target_default
    component_default
    verify_default (true|false)
    dry_run_default (true|false)
"""

from __future__ import annotations

import json
import sys
from pathlib import Path
from typing import Tuple


def load_defaults(path: Path) -> Tuple[str, str, bool, bool]:
    if not path.exists():
        return "all", "all", True, False

    try:
        config = json.loads(path.read_text(encoding="utf-8"))
        defaults = config.get("defaults") or {}
    except Exception:
        defaults = {}

    target = defaults.get("target") or "all"

    components = defaults.get("components") or []
    if isinstance(components, list):
        component_value = ",".join(components) if components else "all"
    else:
        component_value = str(components)

    verify = bool(defaults.get("verify", True))
    dry_run = bool(defaults.get("dryRun", False))

    return target, component_value, verify, dry_run


def main(argv: list[str] | None = None) -> int:
    args = sys.argv[1:] if argv is None else argv
    if len(args) != 1:
        print(
            "Usage: python -m config_sync.settings_loader <settings_path>",
            file=sys.stderr,
        )
        return 1

    settings = Path(args[0]).expanduser()
    target, components, verify, dry_run = load_defaults(settings)

    print(target)
    print(components)
    print("true" if verify else "false")
    print("true" if dry_run else "false")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

