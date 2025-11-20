#!/usr/bin/env python3
"""
Check whether the 'toml' Python module is available.

Usage:
    python3 -m config_sync.toml_check

Exit codes:
    0: toml module import succeeded
    1: toml module not available
"""

from __future__ import annotations

import sys


def main() -> int:
    try:
        import toml  # noqa: F401
    except ModuleNotFoundError:
        return 1
    except Exception:
        return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

