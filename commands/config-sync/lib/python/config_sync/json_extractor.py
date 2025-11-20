#!/usr/bin/env python3
"""
JSON Field Extractor - Module for extracting fields from JSON files

Usage:
    python3 -m config_sync.json_extractor extract <file> --field <field>
    python3 -m config_sync.json_extractor validate <file>
"""

import argparse
import json
import sys
from pathlib import Path
from typing import Any, Dict, List, Optional


class JsonExtractor:
    """Extract and validate JSON data from files"""

    def __init__(self):
        pass

    def extract_field(self, file_path: str, field_path: str) -> str:
        """
        Extract a field from JSON file using dot notation
        e.g., "targets.droid.configDir"
        """
        try:
            file_path_obj = Path(file_path).expanduser()
            if not file_path_obj.exists():
                print(f"Error: File not found: {file_path_obj}", file=sys.stderr)
                return ""

            data = json.loads(file_path_obj.read_text(encoding='utf-8'))

            # Navigate through dot notation
            keys = field_path.split('.')
            current = data

            for key in keys:
                if isinstance(current, dict) and key in current:
                    current = current[key]
                else:
                    print(f"Error: Field '{field_path}' not found in {file_path}", file=sys.stderr)
                    return ""

            return str(current) if current is not None else ""

        except json.JSONDecodeError as e:
            print(f"Error: Invalid JSON in {file_path}: {e}", file=sys.stderr)
            return ""
        except Exception as e:
            print(f"Error: {e}", file=sys.stderr)
            return ""

    def extract_fields(self, file_path: str, field_paths: List[str]) -> Dict[str, str]:
        """Extract multiple fields from JSON file"""
        results = {}
        for field_path in field_paths:
            results[field_path] = self.extract_field(file_path, field_path)
        return results

    def validate_json(self, file_path: str) -> bool:
        """Validate JSON file syntax"""
        try:
            file_path_obj = Path(file_path).expanduser()
            if not file_path_obj.exists():
                print(f"Error: File not found: {file_path_obj}", file=sys.stderr)
                return False

            json.loads(file_path_obj.read_text(encoding='utf-8'))
            return True

        except json.JSONDecodeError as e:
            print(f"Error: Invalid JSON in {file_path}: {e}", file=sys.stderr)
            return False
        except Exception as e:
            print(f"Error: {e}", file=sys.stderr)
            return False

    def get_keys(self, file_path: str, prefix: str = "") -> List[str]:
        """Get all keys from JSON file as dot notation paths"""
        try:
            file_path_obj = Path(file_path).expanduser()
            if not file_path_obj.exists():
                return []

            data = json.loads(file_path_obj.read_text(encoding='utf-8'))
            return self._extract_keys_recursive(data, prefix)

        except Exception:
            return []

    def _extract_keys_recursive(self, obj: Any, prefix: str = "") -> List[str]:
        """Recursively extract keys from nested structure"""
        keys = []

        if isinstance(obj, dict):
            for key, value in obj.items():
                full_key = f"{prefix}.{key}" if prefix else key
                keys.append(full_key)
                if isinstance(value, (dict, list)):
                    keys.extend(self._extract_keys_recursive(value, full_key))

        return keys


def main():
    """CLI interface for JsonExtractor"""
    parser = argparse.ArgumentParser(
        description="Extract fields from JSON files",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  %(prog)s extract manifest.json --field "targets.droid.configDir"
  %(prog)s extract manifest.json --field "basePaths.userHome"
  %(prog)s validate manifest.json
  %(prog)s list-keys manifest.json
        """
    )

    subparsers = parser.add_subparsers(dest='command', help='Available commands')

    # extract command
    extract_parser = subparsers.add_parser('extract', help='Extract field from JSON')
    extract_parser.add_argument('file', help='JSON file path')
    extract_parser.add_argument('--field', required=True, help='Field path (dot notation)')

    # extract-multiple command
    multi_parser = subparsers.add_parser('extract-multiple', help='Extract multiple fields')
    multi_parser.add_argument('file', help='JSON file path')
    multi_parser.add_argument('--fields', nargs='+', required=True, help='Field paths (dot notation)')

    # validate command
    validate_parser = subparsers.add_parser('validate', help='Validate JSON syntax')
    validate_parser.add_argument('file', help='JSON file path')

    # list-keys command
    keys_parser = subparsers.add_parser('list-keys', help='List all keys in JSON')
    keys_parser.add_argument('file', help='JSON file path')
    keys_parser.add_argument('--prefix', default='', help='Key prefix filter')

    args = parser.parse_args()

    extractor = JsonExtractor()

    if args.command == 'extract':
        result = extractor.extract_field(args.file, args.field)
        if result:
            print(result)
            sys.exit(0)
        else:
            sys.exit(1)

    elif args.command == 'extract-multiple':
        results = extractor.extract_fields(args.file, args.fields)
        for field, value in results.items():
            print(f"{field}={value}")
        sys.exit(0)

    elif args.command == 'validate':
        if extractor.validate_json(args.file):
            print(f"✓ Valid JSON: {args.file}")
            sys.exit(0)
        else:
            sys.exit(1)

    elif args.command == 'list-keys':
        keys = extractor.get_keys(args.file, args.prefix)
        for key in sorted(keys):
            print(key)
        sys.exit(0)

    else:
        parser.print_help()
        sys.exit(1)


if __name__ == '__main__':
    main()