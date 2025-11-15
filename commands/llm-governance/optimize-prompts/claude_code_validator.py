#!/usr/bin/env python3
"""
Claude Code Official Specification Validator

This script validates that skills, agents, and commands comply with
the official Claude Code specifications from docs.claude.com
"""

import re
import yaml
import sys
from pathlib import Path
from typing import Dict, List, Optional, Any, Tuple


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


class ClaudeCodeValidator:
    """Validates files against Claude Code official specifications."""
    
    def __init__(self):
        self.errors = []
        self.warnings = []
    
    def validate_file(self, file_path: Path) -> List[ValidationError]:
        """Validate a single file based on its type and location."""
        errors = []
        
        # Determine file type from path
        if file_path.name == "SKILL.md":
            errors.extend(self._validate_skill(file_path))
        elif file_path.name == "AGENT.md":
            errors.extend(self._validate_agent(file_path))
        elif "commands" in file_path.parts and file_path.suffix == ".md":
            errors.extend(self._validate_command(file_path))
        elif file_path.name in ["CLAUDE.md", "AGENTS.md"]:
            errors.extend(self._validate_memory(file_path))
        elif "rules" in file_path.parts and file_path.suffix == ".md":
            errors.extend(self._validate_rule(file_path))
        
        return errors
    
    def _parse_frontmatter(self, file_path: Path) -> Tuple[Optional[Dict], List[str], List[str]]:
        """Parse YAML frontmatter from a markdown file."""
        try:
            with open(file_path, 'r', encoding='utf-8') as f:
                lines = f.readlines()
            
            if not lines or not lines[0].strip() == '---':
                return None, lines, ["Missing frontmatter"]
            
            frontmatter_lines = []
            i = 1
            for i, line in enumerate(lines[1:], 1):
                if line.strip() == '---':
                    break
                frontmatter_lines.append(line)
            
            frontmatter_text = ''.join(frontmatter_lines)
            frontmatter = yaml.safe_load(frontmatter_text)
            content_lines = lines[i+1:]  # Skip closing ---
            
            return frontmatter, content_lines, []
            
        except yaml.YAMLError as e:
            return None, [], [f"YAML parsing error: {e}"]
        except Exception as e:
            return None, [], [f"File reading error: {e}"]
    
    def _validate_skill(self, file_path: Path) -> List[ValidationError]:
        """Validate a SKILL.md file against official specifications."""
        errors = []
        
        frontmatter, content, parse_errors = self._parse_frontmatter(file_path)
        if parse_errors:
            return [ValidationError('critical', str(file_path), err) for err in parse_errors]
        
        if not frontmatter:
            errors.append(ValidationError('critical', str(file_path), "Missing frontmatter"))
            return errors
        
        # Required fields validation
        required_fields = ['name', 'description']
        for field in required_fields:
            if field not in frontmatter:
                errors.append(ValidationError('critical', str(file_path), f"Missing required field: {field}"))
        
        # Name validation
        if 'name' in frontmatter:
            name = frontmatter['name']
            if not isinstance(name, str):
                errors.append(ValidationError('critical', str(file_path), "name must be a string"))
            elif not re.match(r'^[a-z0-9-]+$', name):
                errors.append(ValidationError('critical', str(file_path), "name must use lowercase letters, numbers, and hyphens only"))
            elif len(name) > 64:
                errors.append(ValidationError('warning', str(file_path), "name exceeds 64 character limit"))
        
        # Description validation
        if 'description' in frontmatter:
            desc = frontmatter['description']
            if not isinstance(desc, str):
                errors.append(ValidationError('critical', str(file_path), "description must be a string"))
            elif len(desc) > 1024:
                errors.append(ValidationError('warning', str(file_path), "description exceeds 1024 character limit"))
            elif 'use when' not in desc.lower():
                errors.append(ValidationError('warning', str(file_path), "description should include 'Use when' for better discovery"))
        
        # Allowed-tools validation
        if 'allowed-tools' in frontmatter:
            allowed_tools = frontmatter['allowed-tools']
            if not isinstance(allowed_tools, list):
                errors.append(ValidationError('critical', str(file_path), "allowed-tools must be a list"))
            else:
                valid_tools = [
                    'Read', 'Write', 'Edit', 'Create', 'Delete', 'List', 'Search',
                    'Bash', 'Execute', 'Grep', 'Glob', 'LSP', 'Browser', 'WebSearch'
                ]
                for tool in allowed_tools:
                    if tool not in valid_tools:
                        errors.append(ValidationError('warning', str(file_path), f"Unknown tool in allowed-tools: {tool}"))
        
        # Content validation
        content_text = ''.join(content)
        
        # Check for narrative content
        if self._has_narrative_content(content_text):
            errors.append(ValidationError('warning', str(file_path), "Content appears to contain narrative text"))
        
        # Check for bold markers in body
        bold_in_body = self._count_bold_markers(content_text)
        if bold_in_body > 0:
            errors.append(ValidationError('critical', str(file_path), f"Found {bold_in_body} bold markers in body content"))
        
        # Check for emojis
        if self._has_emojis(content_text):
            errors.append(ValidationError('critical', str(file_path), "Content contains emojis"))
        
        return errors
    
    def _validate_command(self, file_path: Path) -> List[ValidationError]:
        """Validate a command markdown file."""
        errors = []
        
        frontmatter, content, parse_errors = self._parse_frontmatter(file_path)
        if parse_errors:
            return [ValidationError('critical', str(file_path), err) for err in parse_errors]
        
        if not frontmatter:
            errors.append(ValidationError('critical', str(file_path), "Missing frontmatter"))
            return errors
        
        # Required fields for commands
        required_fields = ['name', 'description', 'argument-hint', 'allowed-tools']
        for field in required_fields:
            if field not in frontmatter:
                errors.append(ValidationError('critical', str(file_path), f"Missing required field: {field}"))
        
        # Field type validation
        type_requirements = {
            'name': str,
            'description': str,
            'argument-hint': str,
            'allowed-tools': list,
            'is_background': bool
        }
        
        for field, expected_type in type_requirements.items():
            if field in frontmatter and not isinstance(frontmatter[field], expected_type):
                errors.append(ValidationError('critical', str(file_path), f"{field} must be of type {expected_type.__name__}"))
        
        # Content structure validation
        content_text = ''.join(content)
        required_sections = ['usage', 'arguments', 'workflow', 'output']
        
        for section in required_sections:
            if f"## {section.title()}" not in content_text:
                errors.append(ValidationError('warning', str(file_path), f"Missing section: {section}"))
        
        return errors
    
    def _validate_agent(self, file_path: Path) -> List[ValidationError]:
        """Validate an AGENT.md file."""
        errors = []
        
        frontmatter, content, parse_errors = self._parse_frontmatter(file_path)
        if parse_errors:
            return [ValidationError('critical', str(file_path), err) for err in parse_errors]
        
        if not frontmatter:
            errors.append(ValidationError('critical', str(file_path), "Missing frontmatter"))
            return errors
        
        # Agent-specific fields
        required_fields = ['name', 'description', 'tools']
        for field in required_fields:
            if field not in frontmatter:
                errors.append(ValidationError('critical', str(file_path), f"Missing required field: {field}"))
        
        # RFC manifest fields
        rfc_fields = ['default-skills', 'optional-skills', 'supported-commands', 'inputs', 'outputs', 'fail-fast', 'escalation', 'permissions']
        missing_rfc = [field for field in rfc_fields if field not in frontmatter]
        if missing_rfc:
            errors.append(ValidationError('warning', str(file_path), f"Consider adding RFC fields: {', '.join(missing_rfc)}"))
        
        return errors
    
    def _validate_memory(self, file_path: Path) -> List[ValidationError]:
        """Validate memory files (CLAUDE.md, AGENTS.md)."""
        errors = []
        
        frontmatter, content, parse_errors = self._parse_frontmatter(file_path)
        
        # Memory files may not have frontmatter, so don't error on missing
        if parse_errors and "Missing frontmatter" not in parse_errors[0]:
            return [ValidationError('critical', str(file_path), err) for err in parse_errors]
        
        content_text = ''.join(content)
        
        # Check for routing tables and agent mappings
        if 'agent:' not in content_text and file_path.name == "CLAUDE.md":
            errors.append(ValidationError('warning', str(file_path), "CLAUDE.md should contain agent mappings"))
        
        if 'skill:' not in content_text:
            errors.append(ValidationError('info', str(file_path), "Consider adding skill references"))
        
        return errors
    
    def _validate_rule(self, file_path: Path) -> List[ValidationError]:
        """Validate a rule file."""
        errors = []
        
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
        
        return errors
    
    def _has_narrative_content(self, text: str) -> bool:
        """Detect if text contains narrative content."""
        lines = text.split('\n')
        narrative_indicators = [
            'typically', 'usually', 'generally', 'often', 'sometimes',
            'may', 'might', 'could', 'should', 'would'
        ]
        
        for line in lines:
            line = line.strip()
            if not line or line.startswith('#') or line.startswith('-') or line.startswith('*'):
                continue
            
            # Check for narrative indicators
            for indicator in narrative_indicators:
                if indicator in line.lower():
                    return True
            
            # Check for multiple sentences without directives
            sentences = re.split(r'[.!?]+', line)
            if len([s for s in sentences if s.strip()]) > 1:
                # Check if it starts with an action verb
                if not re.match(r'^(Check|Validate|Ensure|Use|Apply|Execute|Implement)', line):
                    return True
        
        return False
    
    def _count_bold_markers(self, text: str) -> int:
        """Count bold markers in text body."""
        # Count **text** patterns but ignore YAML frontmatter
        parts = text.split('---')
        body = '---'.join(parts[2:]) if len(parts) > 2 else text
        return len(re.findall(r'\*\*[^*]+\*\*', body))
    
    def _has_emojis(self, text: str) -> bool:
        """Check if text contains emojis."""
        emoji_pattern = re.compile(
            "["
            "\U0001F600-\U0001F64F"  # emoticons
            "\U0001F300-\U0001F5FF"  # symbols & pictographs
            "\U0001F680-\U0001F6FF"  # transport & map symbols
            "\U0001F1E0-\U0001F1FF"  # flags (iOS)
            "\U00002702-\U000027B0"
            "\U000024C2-\U0001F251"
            "]+", flags=re.UNICODE
        )
        return bool(emoji_pattern.search(text))
    
    def validate_directory(self, directory: Path) -> Dict[str, List[ValidationError]]:
        """Validate all relevant files in a directory."""
        results = {}
        
        # Find all relevant files
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
                if file_path.is_file():
                    errors = self.validate_file(file_path)
                    if errors:
                        results[str(file_path)] = errors
        
        return results


def main():
    """Main function for standalone usage."""
    if len(sys.argv) != 2:
        print("Usage: python3 claude_code_validator.py <directory>")
        sys.exit(1)
    
    directory = Path(sys.argv[1])
    if not directory.exists():
        print(f"Error: Directory {directory} does not exist")
        sys.exit(1)
    
    validator = ClaudeCodeValidator()
    results = validator.validate_directory(directory)
    
    if not results:
        print("✓ All files passed validation!")
        sys.exit(0)
    
    # Print results
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
