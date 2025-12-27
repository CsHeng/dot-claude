#!/usr/bin/env python3
"""
LLM Specification Validator

Validate skills, agents, commands, rules, governance files, and memory files against
the manifest and prompt-writing rules used by this repository.

This validator uses config.yaml as the Single Source of Truth (SSOT)
for all validation rules.
"""

import re
import yaml
import sys
from pathlib import Path
from typing import Dict, List, Optional, Any, Tuple

from schema_loader import SchemaLoader


class ValidationError:
    """Represents a validation error with context."""

    def __init__(self, severity: str, file_path: str, message: str, line: Optional[int] = None):
        self.severity = severity  # 'critical', 'warning', 'info'
        self.file_path = file_path
        self.message = message
        self.line = line

    def __str__(self):
        location = self.file_path
        if self.line:
            location += f":{self.line}"
        return f"[{self.severity.upper()}] {location}: {self.message}"


class LLMSpecValidator:
    """Validates files against manifest and prompt-writing specifications."""

    def __init__(self, schema_path: Optional[Path] = None):
        """Initialize validator with schema from config.yaml.

        Args:
            schema_path: Path to config.yaml file
        """
        self.schema = SchemaLoader.load(schema_path)
        self.errors: List[ValidationError] = []
        self.warnings: List[ValidationError] = []

    def validate_file(self, file_path: Path) -> List[ValidationError]:
        """Validate a single file based on its type and location."""
        errors: List[ValidationError] = []

        # Determine file type from path
        if file_path.name == "SKILL.md":
            errors.extend(self._validate_skill(file_path))
        elif file_path.name == "AGENT.md":
            errors.extend(self._validate_agent(file_path))
        elif "commands" in file_path.parts and file_path.suffix == ".md" and file_path.name != "README.md":
            errors.extend(self._validate_command(file_path))
        elif file_path.name in ["CLAUDE.md", "AGENTS.md"]:
            errors.extend(self._validate_memory(file_path))
        elif "rules" in file_path.parts and file_path.suffix == ".md":
            errors.extend(self._validate_rule(file_path))
        elif "governance/rules" in str(file_path) and file_path.suffix == ".md":
            errors.extend(self._validate_rule_block(file_path))
        elif "governance/routers" in str(file_path) and file_path.suffix == ".md":
            errors.extend(self._validate_router(file_path))
        elif "governance/entrypoints" in str(file_path) and file_path.suffix == ".md":
            errors.extend(self._validate_entrypoint(file_path))
        elif "governance/styles" in str(file_path) and file_path.suffix == ".md":
            errors.extend(self._validate_output_style(file_path))

        return errors

    def _parse_frontmatter(self, file_path: Path) -> Tuple[Optional[Dict[str, Any]], List[str], List[str]]:
        """Parse YAML frontmatter from a markdown file.

        Returns:
            Tuple of (frontmatter_dict, content_lines, parse_errors)
        """
        try:
            with open(file_path, 'r', encoding='utf-8') as f:
                lines = f.readlines()

            if not lines or not lines[0].strip() == '---':
                return None, lines, ["Missing frontmatter"]

            frontmatter_lines: List[str] = []
            found_end = False

            # Find the closing --- marker
            for i, line in enumerate(lines[1:], 1):
                if line.strip() == '---':
                    found_end = True
                    break
                frontmatter_lines.append(line)

            if not found_end:
                return None, lines, ["Missing closing frontmatter marker ---"]

            frontmatter_text = ''.join(frontmatter_lines)
            frontmatter = yaml.safe_load(frontmatter_text)
            content_lines = lines[i+1:]  # Skip closing ---

            # Validate YAML structure for frontmatter
            if frontmatter is None:
                return None, content_lines, ["Empty frontmatter"], []

            return frontmatter, content_lines, []

        except yaml.YAMLError as e:
            error_msg = f"YAML parsing error: {e}"
            if 'indentation' in str(e).lower():
                error_msg = f"YAML indentation error: Check that array items and fields are properly indented with 2 spaces"
            elif 'mapping values' in str(e).lower():
                error_msg = f"YAML structure error: Missing colon or improper key-value format"
            elif 'scanner' in str(e).lower():
                error_msg = f"YAML scanner error: Check for invalid characters or unquoted strings"
            return None, [], [error_msg]
        except Exception as e:
            return None, [], [f"File reading error: {e}"]

    def _validate_skill(self, file_path: Path) -> List[ValidationError]:
        """Validate a SKILL.md file against specifications."""
        errors: List[ValidationError] = []

        frontmatter, content, parse_errors = self._parse_frontmatter(file_path)
        if parse_errors:
            return [ValidationError('critical', str(file_path), err) for err in parse_errors]

        if not frontmatter:
            errors.append(ValidationError('critical', str(file_path), "Missing frontmatter"))
            return errors

        # Required official fields
        required_fields = SchemaLoader.get_required_fields('skill', self.schema)
        missing_required = [field for field in required_fields if field not in frontmatter]
        if missing_required:
            errors.append(ValidationError('critical', str(file_path), f"Missing required field(s): {', '.join(sorted(missing_required))}"))

        # Name validation
        if 'name' in frontmatter:
            name = frontmatter['name']
            if not isinstance(name, str):
                errors.append(ValidationError('critical', str(file_path), "name must be a string"))
            elif not re.match(r'^[a-z0-9-:]+$', name):
                errors.append(ValidationError('critical', str(file_path), "name must use lowercase letters, numbers, hyphens, and colons only"))

        # Description validation
        if 'description' in frontmatter:
            desc = frontmatter['description']
            if not isinstance(desc, str):
                errors.append(ValidationError('critical', str(file_path), "description must be a string"))
            elif len(desc) > 1024:
                errors.append(ValidationError('warning', str(file_path), "description exceeds 1024 character limit"))

        # Allowed-tools validation (optional official field)
        if 'allowed-tools' in frontmatter:
            allowed_tools = frontmatter['allowed-tools']
            if isinstance(allowed_tools, list):
                for tool in allowed_tools:
                    if not isinstance(tool, str):
                        errors.append(ValidationError('critical', str(file_path), "each allowed-tools entry must be a string"))

        # Content validation
        content_text = ''.join(content)

        if self._has_narrative_content(content_text):
            errors.append(ValidationError('warning', str(file_path), "Content appears to contain narrative text"))

        bold_in_body = self._count_bold_markers(content_text)
        if bold_in_body > 0:
            errors.append(ValidationError('critical', str(file_path), f"Found {bold_in_body} bold markers in body content"))

        if self._has_emojis(content_text):
            errors.append(ValidationError('critical', str(file_path), "Content contains emojis"))

        errors.extend(self._check_modal_verbs(file_path, content_text))

        return errors

    def _validate_command(self, file_path: Path) -> List[ValidationError]:
        """Validate a command markdown file."""
        errors: List[ValidationError] = []

        frontmatter, content, parse_errors = self._parse_frontmatter(file_path)
        if parse_errors:
            return [ValidationError('critical', str(file_path), err) for err in parse_errors]

        if not frontmatter:
            errors.append(ValidationError('critical', str(file_path), "Missing frontmatter"))
            return errors

        # Required official command fields
        required_fields = SchemaLoader.get_required_fields('command', self.schema)
        missing_required = [field for field in required_fields if field not in frontmatter]
        if missing_required:
            errors.append(ValidationError('critical', str(file_path), f"Missing required field(s): {', '.join(sorted(missing_required))}"))

        # Name validation (optional)
        if 'name' in frontmatter:
            name = frontmatter['name']
            if not isinstance(name, str):
                errors.append(ValidationError('critical', str(file_path), "name must be a string"))
            elif not re.match(r'^[a-z0-9-]+$', name):
                errors.append(ValidationError('critical', str(file_path), "name must use lowercase letters, numbers, and hyphens only"))

        # Description validation
        if 'description' in frontmatter:
            if not isinstance(frontmatter['description'], str):
                errors.append(ValidationError('critical', str(file_path), "description must be a string"))

        # Allowed-tools validation
        if 'allowed-tools' in frontmatter:
            allowed = frontmatter.get('allowed-tools')
            if isinstance(allowed, list):
                for tool in allowed:
                    if not isinstance(tool, str):
                        errors.append(ValidationError('critical', str(file_path), "each allowed-tools entry must be a string"))
            elif not isinstance(allowed, str):
                errors.append(ValidationError('critical', str(file_path), "allowed-tools must be a list or comma-separated string"))

        # Content validation
        content_text = ''.join(content)
        errors.extend(self._check_modal_verbs(file_path, content_text))

        return errors

    def _validate_agent(self, file_path: Path) -> List[ValidationError]:
        """Validate an AGENT.md file."""
        errors: List[ValidationError] = []

        frontmatter, content, parse_errors = self._parse_frontmatter(file_path)
        if parse_errors:
            return [ValidationError('critical', str(file_path), err) for err in parse_errors]

        if not frontmatter:
            errors.append(ValidationError('critical', str(file_path), "Missing frontmatter"))
            return errors

        # Required official fields
        required_fields = SchemaLoader.get_required_fields('agent', self.schema)
        missing_required = [field for field in required_fields if field not in frontmatter]
        if missing_required:
            errors.append(ValidationError('critical', str(file_path), f"Missing required field(s): {', '.join(sorted(missing_required))}"))

        # Name validation
        if 'name' in frontmatter:
            name = frontmatter['name']
            if not isinstance(name, str):
                errors.append(ValidationError('critical', str(file_path), "name must be a string"))
            elif not re.match(r'^[a-z0-9-:]+$', name):
                errors.append(ValidationError('critical', str(file_path), "name must use lowercase letters, numbers, hyphens, and colons only"))

        # Description validation
        if 'description' in frontmatter:
            if not isinstance(frontmatter['description'], str):
                errors.append(ValidationError('critical', str(file_path), "description must be a string"))

        # Allowed tools validation
        tools_field = frontmatter.get('allowed-tools')
        if tools_field is not None:
            if isinstance(tools_field, list):
                for tool in tools_field:
                    if not isinstance(tool, str):
                        errors.append(ValidationError('critical', str(file_path), "each tool entry must be a string"))
            elif not isinstance(tools_field, str):
                errors.append(ValidationError('critical', str(file_path), "tools/allowed-tools must be a list or comma-separated string"))

        # Content validation
        content_text = ''.join(content)
        errors.extend(self._check_modal_verbs(file_path, content_text))

        return errors

    def _validate_memory(self, file_path: Path) -> List[ValidationError]:
        """Validate memory files (CLAUDE.md, AGENTS.md)."""
        errors: List[ValidationError] = []

        frontmatter, content, parse_errors = self._parse_frontmatter(file_path)

        # Memory files may not have frontmatter, so don't error on missing
        if parse_errors and "Missing frontmatter" not in parse_errors[0]:
            return [ValidationError('critical', str(file_path), err) for err in parse_errors]

        content_text = ''.join(content)

        if 'skill:' not in content_text:
            errors.append(ValidationError('info', str(file_path), "Consider adding skill references"))

        return errors

    def _validate_rule(self, file_path: Path) -> List[ValidationError]:
        """Validate a rule file."""
        errors: List[ValidationError] = []

        content_text = ''
        try:
            with open(file_path, 'r', encoding='utf-8') as f:
                content_text = f.read()
        except Exception as e:
            return [ValidationError('critical', str(file_path), f"Cannot read file: {e}")]

        # Rules should be imperative only
        if self._has_narrative_content(content_text):
            errors.append(ValidationError('critical', str(file_path), "Rule files should not contain narrative content"))

        # Check for rule formatting
        if 'REQUIRED:' not in content_text and 'PROHIBITED:' not in content_text and 'OPTIONAL:' not in content_text:
            errors.append(ValidationError('warning', str(file_path), "Consider using REQUIRED/PROHIBITED/OPTIONAL formatting"))

        # Validate heading order for rules files
        errors.extend(self._validate_heading_order(file_path, content_text))

        return errors

    def _validate_rule_block(self, file_path: Path) -> List[ValidationError]:
        """Validate a governance rule-block file."""
        errors: List[ValidationError] = []

        frontmatter, content, parse_errors = self._parse_frontmatter(file_path)
        if parse_errors:
            return [ValidationError('critical', str(file_path), err) for err in parse_errors]

        if not frontmatter:
            errors.append(ValidationError('critical', str(file_path), "Missing frontmatter"))
            return errors

        return errors

    def _validate_router(self, file_path: Path) -> List[ValidationError]:
        """Validate a governance router file."""
        errors: List[ValidationError] = []

        frontmatter, content, parse_errors = self._parse_frontmatter(file_path)
        if parse_errors:
            return [ValidationError('critical', str(file_path), err) for err in parse_errors]

        return errors

    def _validate_entrypoint(self, file_path: Path) -> List[ValidationError]:
        """Validate a governance entrypoint file."""
        errors: List[ValidationError] = []

        frontmatter, content, parse_errors = self._parse_frontmatter(file_path)
        if parse_errors:
            return [ValidationError('critical', str(file_path), err) for err in parse_errors]

        return errors

    def _validate_output_style(self, file_path: Path) -> List[ValidationError]:
        """Validate a governance output-style file."""
        errors: List[ValidationError] = []

        frontmatter, content, parse_errors = self._parse_frontmatter(file_path)
        if parse_errors:
            return [ValidationError('critical', str(file_path), err) for err in parse_errors]

        if not frontmatter:
            errors.append(ValidationError('critical', str(file_path), "Missing frontmatter"))
            return errors

        # Validate required fields
        required_fields = SchemaLoader.get_required_fields('output-style', self.schema)
        for field in required_fields:
            if field not in frontmatter:
                errors.append(ValidationError('critical', str(file_path), f"Missing required field: {field}"))

        return errors

    def _has_narrative_content(self, text: str) -> bool:
        """Detect if text contains narrative content."""
        lines = text.split('\n')
        narrative_indicators = [
            'typically', 'usually', 'generally', 'often', 'sometimes',
        ]

        in_code_block = False

        for line in lines:
            line = line.strip()

            # Track code blocks
            if line.startswith('```'):
                in_code_block = not in_code_block
                continue

            # Skip headings, list items, code blocks, numbered items, and directive lines
            if not line or line.startswith('#') or line.startswith('-') or line.startswith('*') or line.startswith('`') or in_code_block:
                continue
            # Skip numbered list items (like "1. Item description")
            if re.match(r'^\d+\.', line):
                continue
            if line.startswith('REQUIRED:') or line.startswith('PROHIBITED:') or line.startswith('OPTIONAL:') or line.startswith('PREFERRED:'):
                continue

            for indicator in narrative_indicators:
                if indicator in line.lower():
                    return True

            sentences = re.split(r'[.!?]+', line)
            if len([s for s in sentences if s.strip()]) > 1:
                if not re.match(r'^(Check|Validate|Ensure|Use|Apply|Execute|Implement|Consider)', line):
                    return True

        return False

    def _count_bold_markers(self, text: str) -> int:
        """Count bold markers in text body."""
        parts = text.split('---')
        body = '---'.join(parts[2:]) if len(parts) > 2 else text

        clean_body = body
        clean_body = re.sub(r'```.*?```', '', clean_body, flags=re.DOTALL)

        return len(re.findall(r'\*\*[^*\s]+\*\*', clean_body))

    def _has_emojis(self, text: str) -> bool:
        """Check if text contains emojis."""
        emoji_pattern = re.compile(
            "["
            "\U0001F600-\U0001F64F"
            "\U0001F300-\U0001F5FF"
            "\U0001F680-\U0001F6FF"
            "\U0001F1E0-\U0001F1FF"
            "]+", flags=re.UNICODE
        )
        return bool(emoji_pattern.search(text))

    def _validate_heading_order(self, file_path: Path, content: str) -> List[ValidationError]:
        """Validate heading order for rules files."""
        errors: List[ValidationError] = []

        if "rules" not in file_path.parts:
            return errors

        expected_headings = [
            'scope',
            'absolute-prohibitions',
            'communication-protocol',
            'structural-rules',
            'language-rules',
            'formatting-rules',
            'naming-rules',
            'validation-rules',
        ]

        heading_pattern = r'^##\s+(.+)$'
        headings = re.findall(heading_pattern, content, re.MULTILINE)
        headings_lower = [h.strip().lower() for h in headings]

        seen_indices = []
        for heading in headings_lower:
            if heading in expected_headings:
                idx = expected_headings.index(heading)
                seen_indices.append((idx, heading))

        if seen_indices:
            last_idx = -1
            for idx, heading in seen_indices:
                if idx < last_idx:
                    errors.append(ValidationError('warning', str(file_path), f"Heading '{heading}' is out of order"))
                    break
                last_idx = idx

        return errors

    def _check_modal_verbs(self, file_path: Path, content: str) -> List[ValidationError]:
        """Check for modal verbs in body content (excluding code blocks)."""
        errors: List[ValidationError] = []

        if not any(part in ['commands', 'skills', 'agents', 'rules'] for part in file_path.parts):
            if file_path.name not in ['CLAUDE.md', 'AGENTS.md']:
                return errors

        content_no_code = re.sub(r'```.*?```', '', content, flags=re.DOTALL)
        content_no_code = re.sub(r'`[^`]+`', '', content_no_code)

        parts = content_no_code.split('---')
        if len(parts) > 2:
            content_no_code = '---'.join(parts[2:])

        modal_pattern = r'\b(may|might|could)\b'
        lines = content_no_code.split('\n')

        for line_num, line in enumerate(lines, 1):
            matches = list(re.finditer(modal_pattern, line, re.IGNORECASE))
            if matches:
                if line.strip().startswith('-') or line.strip().startswith('*'):
                    if 'normative' in line.lower() or 'exception' in line.lower():
                        continue

                for match in matches:
                    errors.append(ValidationError('warning', str(file_path), f"Modal verb '{match.group()}' found in line {line_num}. Consider using imperative form instead."))

        return errors

    def validate_directory(self, directory: Path) -> Dict[str, List[ValidationError]]:
        """Validate all relevant files in a directory."""
        results: Dict[str, List[ValidationError]] = {}

        patterns = [
            "**/SKILL.md",
            "**/AGENT.md",
            "**/commands/**/*.md",
            "CLAUDE.md",
            "AGENTS.md",
            "**/rules/**/*.md"
        ]

        for pattern in patterns:
            for file_path in directory.glob(pattern):
                if not file_path.is_file():
                    continue
                if any(part == "backup" for part in file_path.parts):
                    continue
                errors = self.validate_file(file_path)
                if errors:
                    results[str(file_path)] = errors

        return results


def main():
    """Main function for standalone usage."""
    import argparse

    parser = argparse.ArgumentParser(description='Validate LLM specification files')
    parser.add_argument('directory', help='Directory to validate')
    args = parser.parse_args()

    target = Path(args.directory)
    if not target.exists():
        print(f"Error: Path {target} does not exist")
        sys.exit(1)

    schema_path = Path(__file__).parent / "config.yaml"
    validator = LLMSpecValidator(schema_path=schema_path)

    if target.is_file():
        errors = validator.validate_file(target)
        if errors:
            results = {str(target): errors}
        else:
            results = {}
    else:
        results = validator.validate_directory(target)

    if not results:
        print("✓ All files passed validation!")
        sys.exit(0)

    critical_count = 0
    warning_count = 0

    for file_path, errors in results.items():
        print(f"\n📁 {file_path}")
        for error in errors:
            print(f"  {error}")
            if error.severity == 'critical':
                critical_count += 1
            elif error.severity == 'warning':
                warning_count += 1

    print(f"\n📊 Summary:")
    print(f"  Critical errors: {critical_count}")
    print(f"  Warnings: {warning_count}")
    print(f"  Files with issues: {len(results)}")

    if critical_count > 0:
        sys.exit(1)
    else:
        sys.exit(0)


if __name__ == '__main__':
    main()
