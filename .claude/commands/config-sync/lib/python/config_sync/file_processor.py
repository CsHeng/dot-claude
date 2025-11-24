#!/usr/bin/env python3
"""
File Processor - File processing utilities for configuration sync

Usage:
    python3 -m config_sync.file_processor sync-files <source> <target>
    python3 -m config_sync.file_processor validate-file <file>
"""

import argparse
import os
import shutil
import sys
from pathlib import Path
from typing import Dict, List, Optional, Any
import hashlib


class FileProcessor:
    """File processing utilities"""

    def __init__(self):
        pass

    def sync_file(self, source: str, target: str, backup: bool = True) -> bool:
        """Sync a single file from source to target"""
        try:
            source_path = Path(source).expanduser()
            target_path = Path(target).expanduser()

            if not source_path.exists():
                print(f"Error: Source file not found: {source_path}", file=sys.stderr)
                return False

            # Create target directory if needed
            target_path.parent.mkdir(parents=True, exist_ok=True)

            # Create backup if target exists
            if target_path.exists() and backup:
                backup_path = target_path.with_suffix(target_path.suffix + ".backup")
                shutil.copy2(target_path, backup_path)

            # Copy file
            shutil.copy2(source_path, target_path)
            return True

        except Exception as e:
            print(f"Error syncing file: {e}", file=sys.stderr)
            return False

    def compare_files(self, file1: str, file2: str) -> bool:
        """Compare two files for equality"""
        try:
            path1 = Path(file1).expanduser()
            path2 = Path(file2).expanduser()

            if not path1.exists() or not path2.exists():
                return False

            return path1.stat().st_size == path2.stat().st_size and \
                   path1.read_bytes() == path2.read_bytes()

        except Exception:
            return False

    def get_file_hash(self, file_path: str) -> str:
        """Get SHA256 hash of file"""
        try:
            path = Path(file_path).expanduser()
            if not path.exists():
                return ""

            content = path.read_bytes()
            return hashlib.sha256(content).hexdigest()

        except Exception:
            return ""

    def find_files(self, directory: str, pattern: str = "*") -> List[str]:
        """Find files matching pattern in directory"""
        try:
            dir_path = Path(directory).expanduser()
            if not dir_path.exists():
                return []

            return [str(p) for p in dir_path.rglob(pattern) if p.is_file()]

        except Exception as e:
            print(f"Error finding files: {e}", file=sys.stderr)
            return []

    def validate_file_structure(self, file_path: str, expected_structure: Dict) -> bool:
        """Validate file against expected structure"""
        try:
            path = Path(file_path).expanduser()
            if not path.exists():
                return False

            if path.suffix == '.json':
                import json
                data = json.loads(path.read_text(encoding='utf-8'))
                return self._validate_structure(data, expected_structure)

            elif path.suffix in ['.yml', '.yaml']:
                import yaml
                data = yaml.safe_load(path.read_text(encoding='utf-8'))
                return self._validate_structure(data, expected_structure)

            return True  # Non-structured files are considered valid

        except Exception as e:
            print(f"Error validating file structure: {e}", file=sys.stderr)
            return False

    def _validate_structure(self, data: Any, expected: Dict) -> bool:
        """Recursively validate data structure"""
        if not isinstance(data, dict) or not isinstance(expected, dict):
            return True

        for key, expected_type in expected.items():
            if key not in data:
                return False

            if expected_type == dict and isinstance(data[key], dict):
                if not self._validate_structure(data[key], expected_type):
                    return False
            elif expected_type == list and not isinstance(data[key], list):
                return False
            elif expected_type == str and not isinstance(data[key], str):
                return False

        return True


def main():
    """CLI interface for FileProcessor"""
    parser = argparse.ArgumentParser(
        description="File processing utilities",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  %(prog)s sync-file source.md target.md
  %(prog)s compare-files file1.md file2.md
  %(prog)s find-files --dir ~/.factory/commands --pattern "*.md"
        """
    )

    subparsers = parser.add_subparsers(dest='command', help='Available commands')

    # sync-file command
    sync_parser = subparsers.add_parser('sync-file', help='Sync single file')
    sync_parser.add_argument('source', help='Source file path')
    sync_parser.add_argument('target', help='Target file path')
    sync_parser.add_argument('--no-backup', action='store_true', help='Skip backup creation')

    # compare-files command
    compare_parser = subparsers.add_parser('compare-files', help='Compare two files')
    compare_parser.add_argument('file1', help='First file path')
    compare_parser.add_argument('file2', help='Second file path')

    # find-files command
    find_parser = subparsers.add_parser('find-files', help='Find files matching pattern')
    find_parser.add_argument('--dir', required=True, help='Directory to search')
    find_parser.add_argument('--pattern', default="*", help='File pattern (default: *)')

    args = parser.parse_args()

    processor = FileProcessor()

    if args.command == 'sync-file':
        backup = not args.no_backup
        if processor.sync_file(args.source, args.target, backup):
            print(f"✓ Synced: {args.source} -> {args.target}")
            sys.exit(0)
        else:
            sys.exit(1)

    elif args.command == 'compare-files':
        if processor.compare_files(args.file1, args.file2):
            print(f"✓ Files are identical: {args.file1} == {args.file2}")
        else:
            print(f"✗ Files differ: {args.file1} != {args.file2}")
            sys.exit(1)

    elif args.command == 'find-files':
        files = processor.find_files(args.dir, args.pattern)
        for file_path in files:
            print(file_path)
        print(f"\nFound {len(files)} files")
        sys.exit(0)

    else:
        parser.print_help()
        sys.exit(1)


if __name__ == '__main__':
    main()