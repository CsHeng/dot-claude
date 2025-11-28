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
        self.allowed_styles = SchemaLoader.get_style_labels(self.schema)
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
    
    def _get_field(self, frontmatter: Dict[str, Any], field_name: str) -> Any:
        """Get a field value from either top-level or metadata subfield."""
        # Check top-level first for backward compatibility
        if field_name in frontmatter:
            return frontmatter[field_name]

        # Check in metadata subfield
        metadata = frontmatter.get('metadata', {})
        if isinstance(metadata, dict) and field_name in metadata:
            return metadata[field_name]

        return None

    def _parse_frontmatter(self, file_path: Path) -> Tuple[Optional[Dict[str, Any]], List[str], List[str], Optional[List[str]]]:
        """Parse YAML frontmatter from a markdown file.
        
        Returns:
            Tuple of (frontmatter_dict, content_lines, parse_errors, key_order)
            key_order is the order of keys as they appear in the file (for validation)
        """
        try:
            with open(file_path, 'r', encoding='utf-8') as f:
                lines = f.readlines()

            if not lines or not lines[0].strip() == '---':
                return None, lines, ["Missing frontmatter"], None

            frontmatter_lines: List[str] = []
            found_end = False
            key_order: List[str] = []

            # Find the closing --- marker and extract key order
            in_metadata = False
            for i, line in enumerate(lines[1:], 1):
                if line.strip() == '---':
                    found_end = True
                    break
                frontmatter_lines.append(line)
                
                # Track if we're inside metadata section
                stripped = line.strip()
                if stripped == 'metadata:' or stripped.startswith('metadata:'):
                    in_metadata = True
                    # Add metadata to key_order when we encounter it
                    if 'metadata' not in key_order:
                        key_order.append('metadata')
                elif stripped and not line.startswith(' ') and not line.startswith('\t'):
                    # New top-level key (not indented)
                    in_metadata = False
                
                # Extract key names from lines (only top-level keys, not metadata sub-keys)
                # Match "key:" or "key: " at start of line (with no or minimal indentation)
                if not in_metadata:
                    key_match = re.match(r'^\s*([a-zA-Z0-9_-]+)\s*:', line)
                    if key_match:
                        key = key_match.group(1)
                        if key not in key_order:
                            key_order.append(key)

            if not found_end:
                return None, lines, ["Missing closing frontmatter marker ---"], None

            frontmatter_text = ''.join(frontmatter_lines)
            frontmatter = yaml.safe_load(frontmatter_text)
            content_lines = lines[i+1:]  # Skip closing ---

            # Validate YAML structure for frontmatter
            if frontmatter is None:
                return None, content_lines, ["Empty frontmatter"], None

            return frontmatter, content_lines, [], key_order

        except yaml.YAMLError as e:
            # Provide more specific error messages for common issues
            error_msg = f"YAML parsing error: {e}"
            if 'indentation' in str(e).lower():
                error_msg = f"YAML indentation error: Check that array items and metadata fields are properly indented with 2 spaces"
            elif 'mapping values' in str(e).lower():
                error_msg = f"YAML structure error: Missing colon or improper key-value format"
            elif 'scanner' in str(e).lower():
                error_msg = f"YAML scanner error: Check for invalid characters or unquoted strings"
            return None, [], [error_msg], None
        except Exception as e:
            return None, [], [f"File reading error: {e}"], None
    
    def _validate_style_field(self, frontmatter: Dict[str, Any], file_path: Path) -> List[ValidationError]:
        """Validate optional style field against controlled vocabulary from schema."""
        errors: List[ValidationError] = []
        if "style" not in frontmatter:
            return errors
        
        value = frontmatter["style"]
        styles: List[str] = []
        
        if isinstance(value, str):
            styles = [value]
        elif isinstance(value, list):
            for item in value:
                if not isinstance(item, str):
                    errors.append(ValidationError("critical", str(file_path), "style entries must be strings"))
                    return errors
            styles = value
        else:
            errors.append(ValidationError("critical", str(file_path), "style must be a string or list of strings"))
            return errors
        
        for style in styles:
            if style not in self.allowed_styles:
                errors.append(ValidationError("warning", str(file_path), f"Unknown style label: {style}"))
        
        # Optional compatibility hints: keep advisory only
        if "commands" in file_path.parts and any(s == "reasoning-first" for s in styles):
            errors.append(ValidationError("warning", str(file_path), "reasoning-first style on command manifests may reduce determinism; consider tool-first or minimal-chat"))
        
        return errors
    
    def _validate_frontmatter_key_order(self, file_path: Path, frontmatter: Dict[str, Any], key_order: List[str], manifest_type: str) -> List[ValidationError]:
        """Validate frontmatter key order: required -> optional -> metadata, with metadata keys sorted alphabetically."""
        errors: List[ValidationError] = []
        
        if not key_order:
            return errors
        
        # Get field definitions from schema (preserving order)
        required_fields = SchemaLoader.get_required_fields(manifest_type, self.schema)
        optional_fields = SchemaLoader.get_optional_fields(manifest_type, self.schema)
        
        # Filter to only keys that exist in frontmatter, preserving schema order
        present_required = [f for f in required_fields if f in frontmatter]
        present_optional = [f for f in optional_fields if f in frontmatter]
        
        # Expected order: required fields (in schema order) -> optional fields (in schema order) -> metadata
        expected_order = present_required + present_optional
        
        # Check if metadata is present
        has_metadata = 'metadata' in frontmatter
        
        if has_metadata:
            expected_order.append('metadata')
        
        # Get actual order (only official fields and metadata, preserving original order)
        actual_order = []
        for k in key_order:
            if k in expected_order:
                actual_order.append(k)
        
        # Validate order
        if actual_order != expected_order:
            errors.append(ValidationError(
                'warning',
                str(file_path),
                f"Frontmatter key order should be: {', '.join(expected_order)}. Found: {', '.join(actual_order)}"
            ))
        
        # Validate metadata keys are sorted alphabetically
        if has_metadata and isinstance(frontmatter.get('metadata'), dict):
            metadata = frontmatter['metadata']
            metadata_keys = list(metadata.keys())
            sorted_keys = sorted(metadata_keys)
            
            if metadata_keys != sorted_keys:
                errors.append(ValidationError(
                    'warning',
                    str(file_path),
                    f"Metadata keys should be alphabetically sorted. Expected: {', '.join(sorted_keys)}, Found: {', '.join(metadata_keys)}"
                ))
        
        return errors
    
    def _validate_skill(self, file_path: Path) -> List[ValidationError]:
        """Validate a SKILL.md file against specifications."""
        errors: List[ValidationError] = []

        frontmatter, content, parse_errors, key_order = self._parse_frontmatter(file_path)
        if parse_errors:
            return [ValidationError('critical', str(file_path), err) for err in parse_errors]

        if not frontmatter:
            errors.append(ValidationError('critical', str(file_path), "Missing frontmatter"))
            return errors

        # Get schema definitions from config.yaml
        official_fields = SchemaLoader.get_official_fields('skill', self.schema)
        metadata_fields = SchemaLoader.get_metadata_fields('skill', self.schema)

        # Check for non-official fields in top-level (should be in metadata)
        top_level_fields = set(frontmatter.keys())
        non_official_fields = top_level_fields - set(official_fields) - {'metadata'}

        # Check metadata structure
        metadata = frontmatter.get('metadata', {})
        if not isinstance(metadata, dict):
            errors.append(ValidationError('critical', str(file_path), "metadata must be a dictionary if present"))
        else:
            # Check for fields that should be in metadata but are at top-level
            fields_in_wrong_place = []
            for field in non_official_fields:
                if field in metadata_fields:
                    fields_in_wrong_place.append(field)

            if fields_in_wrong_place:
                errors.append(ValidationError('critical', str(file_path), f"Fields should be in metadata section: {', '.join(fields_in_wrong_place)}"))
            
            # Check for official fields that are incorrectly placed in metadata section
            official_in_metadata = []
            for field in official_fields:
                if field in metadata:
                    official_in_metadata.append(field)
            
            if official_in_metadata:
                errors.append(ValidationError('critical', str(file_path), f"Official fields should be in top-level, not metadata: {', '.join(official_in_metadata)}"))

        # Get validation rules from schema
        validation_rules = SchemaLoader.get_validation_rules('skill', self.schema)
        
        # Name validation
        if 'name' in frontmatter:
            name = frontmatter['name']
            name_rules = validation_rules.get('name', {})
            if not isinstance(name, str):
                errors.append(ValidationError('critical', str(file_path), "name must be a string"))
            elif not re.match(name_rules.get('pattern', r'^[a-z0-9-]+$'), name):
                errors.append(ValidationError('critical', str(file_path), "name must use lowercase letters, numbers, and hyphens only"))
            elif name_rules.get('max_length') and len(name) > name_rules['max_length']:
                errors.append(ValidationError('warning', str(file_path), f"name exceeds {name_rules['max_length']} character limit"))

        # Description validation
        if 'description' in frontmatter:
            desc = frontmatter['description']
            desc_rules = validation_rules.get('description', {})
            if not isinstance(desc, str):
                errors.append(ValidationError('critical', str(file_path), "description must be a string"))
            elif desc_rules.get('max_length') and len(desc) > desc_rules['max_length']:
                errors.append(ValidationError('warning', str(file_path), f"description exceeds {desc_rules['max_length']} character limit"))
            elif desc_rules.get('recommended_includes'):
                for include in desc_rules['recommended_includes']:
                    if include.lower() not in desc.lower():
                        errors.append(ValidationError('warning', str(file_path), f"description should include '{include}' for better discovery"))

        # Allowed-tools validation (optional official field)
        if 'allowed-tools' in frontmatter:
            allowed_tools = frontmatter['allowed-tools']
            if isinstance(allowed_tools, list):
                for tool in allowed_tools:
                    if not isinstance(tool, str):
                        errors.append(ValidationError('critical', str(file_path), "each allowed-tools entry must be a string"))
            elif isinstance(allowed_tools, str):
                # Accept comma-separated scalar; no further validation needed beyond type
                pass
            else:
                errors.append(ValidationError('critical', str(file_path), "allowed-tools must be a list or comma-separated string"))

        # Metadata field validation
        if isinstance(metadata, dict):
            # Capability-level validation
            if 'capability-level' in metadata:
                capability_level = metadata['capability-level']
                if not isinstance(capability_level, int):
                    errors.append(ValidationError('critical', str(file_path), "capability-level must be an integer"))
                elif capability_level < 0 or capability_level > 4:
                    errors.append(ValidationError('critical', str(file_path), "capability-level must be between 0 and 4"))

            # Mode validation
            if 'mode' in metadata and not isinstance(metadata['mode'], str):
                errors.append(ValidationError('critical', str(file_path), "mode must be a string"))

            # Style validation (optional)
            if 'style' in metadata:
                temp_frontmatter = {'style': metadata['style']}
                errors.extend(self._validate_style_field(temp_frontmatter, file_path))
        
        # Required official fields
        required_fields = SchemaLoader.get_required_fields('skill', self.schema)
        missing_required = [field for field in required_fields if field not in frontmatter]
        if missing_required:
            errors.append(ValidationError('critical', str(file_path), f"Missing required field(s): {', '.join(sorted(missing_required))}"))
        
        # Validate frontmatter key order
        if key_order:
            order_errors = self._validate_frontmatter_key_order(file_path, frontmatter, key_order, 'skill')
            errors.extend(order_errors)

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
        
        # Check for modal verbs in body (excluding code blocks)
        errors.extend(self._check_modal_verbs(file_path, content_text))

        # Capability-level structural expectations from schema
        structural_reqs = SchemaLoader.get_structural_requirements('skill', self.schema)
        if isinstance(metadata, dict) and 'capability-level' in metadata:
            capability_level = metadata['capability-level']
            if isinstance(capability_level, int) and capability_level >= 2:
                # Check for level 2+ requirements
                req_key = "capability_level_2_plus"
                if req_key in structural_reqs:
                    required_sections = structural_reqs[req_key].get('required_sections', [])
                    for section in required_sections:
                        if section not in content_text:
                            errors.append(ValidationError('warning', str(file_path), f"Capability level >= 2 but missing {section} section"))
        
        return errors
    
    def _validate_command(self, file_path: Path) -> List[ValidationError]:
        """Validate a command markdown file."""
        errors: List[ValidationError] = []

        frontmatter, content, parse_errors, key_order = self._parse_frontmatter(file_path)
        if parse_errors:
            return [ValidationError('critical', str(file_path), err) for err in parse_errors]

        if not frontmatter:
            errors.append(ValidationError('critical', str(file_path), "Missing frontmatter"))
            return errors

        # Get schema definitions from config.yaml
        official_fields = SchemaLoader.get_official_fields('command', self.schema)
        metadata_fields = SchemaLoader.get_metadata_fields('command', self.schema)
        top_level_fields = set(frontmatter.keys())
        non_official_fields = top_level_fields - official_fields - {'metadata'}
        
        # Check for custom metadata fields in top-level
        custom_fields_in_top_level = []
        for field in non_official_fields:
            if field in metadata_fields:
                custom_fields_in_top_level.append(field)
        
        if custom_fields_in_top_level:
            errors.append(
                ValidationError(
                    'critical',
                    str(file_path),
                    f"Fields should be in metadata section: {', '.join(sorted(custom_fields_in_top_level))}",
                )
            )
        
        # Check for official fields incorrectly placed in metadata section
        metadata = frontmatter.get('metadata', {})
        if isinstance(metadata, dict):
            official_in_metadata = []
            for field in official_fields:
                if field in metadata:
                    official_in_metadata.append(field)
            
            if official_in_metadata:
                errors.append(ValidationError('critical', str(file_path), f"Official fields should be in top-level, not metadata: {', '.join(sorted(official_in_metadata))}"))

        # Required official command fields
        required_fields = SchemaLoader.get_required_fields('command', self.schema)
        missing_required = [field for field in required_fields if field not in frontmatter]
        if missing_required:
            errors.append(ValidationError('critical', str(file_path), f"Missing required field(s): {', '.join(sorted(missing_required))}"))

        # Field type validation - official fields (when present)
        type_requirements = {
            'argument-hint': str,
            'description': str,
            'allowed-tools': (list, str),
            'model': str,
            'disable-model-invocation': bool,
        }

        for field, expected_type in type_requirements.items():
            if field in frontmatter and not isinstance(frontmatter[field], expected_type):
                # Produce readable type names for tuples
                expected_name = expected_type.__name__ if isinstance(expected_type, type) else "list or string"
                errors.append(ValidationError('critical', str(file_path), f"{field} must be of type {expected_name}"))

        # Name validation (optional for compatibility with internal manifests)
        if 'name' in frontmatter:
            name = frontmatter['name']
            if not isinstance(name, str):
                errors.append(ValidationError('critical', str(file_path), "name must be a string"))
            elif not re.match(r'^[a-z0-9-]+$', name):
                errors.append(ValidationError('critical', str(file_path), "name must use lowercase letters, numbers, and hyphens only"))
            elif len(name) > 64:
                errors.append(ValidationError('warning', str(file_path), "name exceeds 64 character limit"))

        # Allowed-tools entry validation
        if 'allowed-tools' in frontmatter:
            allowed = frontmatter.get('allowed-tools')
            if isinstance(allowed, list):
                for tool in allowed:
                    if not isinstance(tool, str):
                        errors.append(ValidationError('critical', str(file_path), "each allowed-tools entry must be a string"))
            elif not isinstance(allowed, str):
                errors.append(ValidationError('critical', str(file_path), "allowed-tools must be a list or comma-separated string"))

        # Check local extensions in metadata (is_background, style)
        metadata = frontmatter.get('metadata', {})
        if not isinstance(metadata, dict):
            errors.append(ValidationError('critical', str(file_path), "metadata must be a dictionary if present"))
        else:
            # Check for local extensions that should be in metadata
            local_extensions = ['is_background', 'style']
            for field in local_extensions:
                if field in frontmatter and field not in metadata:
                    errors.append(ValidationError('critical', str(file_path), f"Local extension '{field}' should be in metadata section"))

        # Style validation (optional) - check metadata
        style_value = metadata.get('style') if isinstance(metadata, dict) else None
        if style_value is not None:
            temp_frontmatter = {'style': style_value}
            errors.extend(self._validate_style_field(temp_frontmatter, file_path))

        # Content structure validation from schema
        content_text = ''.join(content)
        structural_reqs = SchemaLoader.get_structural_requirements('command', self.schema)
        recommended_sections = structural_reqs.get('recommended_sections', [])
        
        for section in recommended_sections:
            if f"## {section.title()}" not in content_text:
                errors.append(ValidationError('warning', str(file_path), f"Missing recommended section: {section}"))
        
        # Check for modal verbs in body (excluding code blocks)
        errors.extend(self._check_modal_verbs(file_path, content_text))
        
        # Validate frontmatter key order
        if key_order:
            order_errors = self._validate_frontmatter_key_order(file_path, frontmatter, key_order, 'command')
            errors.extend(order_errors)
        
        return errors
    
    def _validate_agent(self, file_path: Path) -> List[ValidationError]:
        """Validate an AGENT.md file."""
        errors: List[ValidationError] = []

        frontmatter, content, parse_errors, key_order = self._parse_frontmatter(file_path)
        if parse_errors:
            return [ValidationError('critical', str(file_path), err) for err in parse_errors]

        if not frontmatter:
            errors.append(ValidationError('critical', str(file_path), "Missing frontmatter"))
            return errors

        # Get schema definitions from config.yaml
        official_fields = SchemaLoader.get_official_fields('agent', self.schema)
        metadata_fields = SchemaLoader.get_metadata_fields('agent', self.schema)

        # Check for non-official fields in top-level (should be in metadata)
        top_level_fields = set(frontmatter.keys())
        non_official_fields = top_level_fields - set(official_fields) - {'metadata'}

        # Check metadata structure
        metadata = frontmatter.get('metadata', {})
        if not isinstance(metadata, dict):
            errors.append(ValidationError('critical', str(file_path), "metadata must be a dictionary if present"))
        else:
            # Check for fields that should be in metadata but are at top-level
            fields_in_wrong_place = []
            for field in non_official_fields:
                if field in metadata_fields:
                    fields_in_wrong_place.append(field)

            if fields_in_wrong_place:
                errors.append(ValidationError('critical', str(file_path), f"Fields should be in metadata section: {', '.join(fields_in_wrong_place)}"))
            
            # Check for official fields that are incorrectly placed in metadata section
            official_in_metadata = []
            for field in official_fields:
                if field in metadata:
                    official_in_metadata.append(field)
            
            if official_in_metadata:
                errors.append(ValidationError('critical', str(file_path), f"Official fields should be in top-level, not metadata: {', '.join(official_in_metadata)}"))

        # Required official fields
        required_fields = SchemaLoader.get_required_fields('agent', self.schema)
        missing_required = [field for field in required_fields if field not in frontmatter]
        if missing_required:
            errors.append(ValidationError('critical', str(file_path), f"Missing required field(s): {', '.join(sorted(missing_required))}"))

        # RFC manifest fields - these are now in metadata, check both locations
        missing_metadata_fields = []
        for field in metadata_fields:
            if self._get_field(frontmatter, field) is None:
                missing_metadata_fields.append(field)

        if missing_metadata_fields:
            errors.append(ValidationError('warning', str(file_path), f"Consider adding metadata fields: {', '.join(missing_metadata_fields)}"))

        # Allowed tools validation (tools/allowed-tools are optional)
        tools_field = frontmatter.get('allowed-tools')
        if tools_field is None:
            tools_field = frontmatter.get('tools')

        if tools_field is not None:
            if isinstance(tools_field, list):
                for tool in tools_field:
                    if not isinstance(tool, str):
                        errors.append(ValidationError('critical', str(file_path), "each tool entry must be a string"))
            elif not isinstance(tools_field, str):
                errors.append(ValidationError('critical', str(file_path), "tools/allowed-tools must be a list or comma-separated string"))

        # Capability axis validation for agents - check metadata
        capability_level = self._get_field(frontmatter, 'capability-level')
        if capability_level is not None:
            if isinstance(capability_level, int):
                if capability_level < 0 or capability_level > 4:
                    errors.append(ValidationError('critical', str(file_path), "capability-level must be between 0 and 4"))
            else:
                errors.append(ValidationError('critical', str(file_path), "capability-level must be an integer"))

        loop_style = self._get_field(frontmatter, 'loop-style')
        if loop_style is not None and not isinstance(loop_style, str):
            errors.append(ValidationError('critical', str(file_path), "loop-style must be a string"))

        # Style validation (optional) - check metadata
        style_value = self._get_field(frontmatter, 'style')
        if style_value is not None:
            temp_frontmatter = {'style': style_value}
            errors.extend(self._validate_style_field(temp_frontmatter, file_path))

        # Capability-level structural expectations for agents from schema
        content_text = ''.join(content)
        structural_reqs = SchemaLoader.get_structural_requirements('agent', self.schema)
        if capability_level is not None:
            if isinstance(capability_level, int) and capability_level >= 3:
                # Check for level 3+ requirements
                req_key = "capability_level_3_plus"
                if req_key in structural_reqs:
                    req_config = structural_reqs[req_key]
                    # Check required sections
                    required_sections = req_config.get('required_sections', [])
                    for section in required_sections:
                        if section not in content_text:
                            errors.append(ValidationError('warning', str(file_path), f"Capability level >= 3 but missing {section} section"))
                    # Check required fields
                    required_fields = req_config.get('required_fields', [])
                    for field in required_fields:
                        if self._get_field(frontmatter, field) is None:
                            errors.append(ValidationError('critical', str(file_path), f"Capability level >= 3 requires {field} in metadata"))
        
        # Check for modal verbs in body (excluding code blocks)
        errors.extend(self._check_modal_verbs(file_path, content_text))
        
        # Validate frontmatter key order
        if key_order:
            order_errors = self._validate_frontmatter_key_order(file_path, frontmatter, key_order, 'agent')
            errors.extend(order_errors)
        
        return errors
    
    def _validate_memory(self, file_path: Path) -> List[ValidationError]:
        """Validate memory files (CLAUDE.md, AGENTS.md)."""
        errors: List[ValidationError] = []
        
        frontmatter, content, parse_errors, _ = self._parse_frontmatter(file_path)
        
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
        
        frontmatter, content, parse_errors, key_order = self._parse_frontmatter(file_path)
        if parse_errors:
            return [ValidationError('critical', str(file_path), err) for err in parse_errors]
        
        if not frontmatter:
            errors.append(ValidationError('critical', str(file_path), "Missing frontmatter"))
            return errors
        
        # Get schema definitions from config.yaml
        try:
            official_fields = SchemaLoader.get_official_fields('rule-block', self.schema)
            metadata_fields = SchemaLoader.get_metadata_fields('rule-block', self.schema)
            validation_rules = SchemaLoader.get_validation_rules('rule-block', self.schema)
        except ValueError:
            # Schema not found for rule-block, skip detailed validation
            return errors
        
        # Validate required fields
        required_fields = SchemaLoader.get_required_fields('rule-block', self.schema)
        for field in required_fields:
            if field not in frontmatter:
                errors.append(ValidationError('critical', str(file_path), f"Missing required field: {field}"))
        
        # Check field placement (official vs metadata)
        top_level_fields = set(frontmatter.keys())
        non_official_fields = top_level_fields - set(official_fields) - {'metadata'}
        
        metadata = frontmatter.get('metadata', {})
        if not isinstance(metadata, dict):
            if metadata is not None:
                errors.append(ValidationError('critical', str(file_path), "metadata must be a dictionary if present"))
        else:
            # Check for custom fields in wrong place
            fields_in_wrong_place = []
            for field in non_official_fields:
                if field in metadata_fields:
                    fields_in_wrong_place.append(field)
            
            if fields_in_wrong_place:
                errors.append(ValidationError('critical', str(file_path), f"Fields should be in metadata section: {', '.join(fields_in_wrong_place)}"))
            
            # Check for official fields in metadata
            official_in_metadata = []
            for field in official_fields:
                if field in metadata:
                    official_in_metadata.append(field)
            
            if official_in_metadata:
                errors.append(ValidationError('critical', str(file_path), f"Official fields should be in top-level, not metadata: {', '.join(official_in_metadata)}"))
        
        # Validate name pattern
        if 'name' in frontmatter:
            name = frontmatter['name']
            name_rules = validation_rules.get('name', {})
            if not isinstance(name, str):
                errors.append(ValidationError('critical', str(file_path), "name must be a string"))
            elif not re.match(name_rules.get('pattern', r'^rule-block:[a-z0-9-]+$'), name):
                errors.append(ValidationError('critical', str(file_path), "name must follow pattern: rule-block:[a-z0-9-]+"))
        
        # Validate layer field
        layer = self._get_field(frontmatter, 'layer')
        if layer is not None:
            layer_rules = validation_rules.get('layer', {})
            if layer not in layer_rules.get('enum', []):
                errors.append(ValidationError('critical', str(file_path), f"layer must be one of: {', '.join(layer_rules.get('enum', []))}"))
        
        return errors
    
    def _validate_router(self, file_path: Path) -> List[ValidationError]:
        """Validate a governance router file."""
        errors: List[ValidationError] = []
        
        frontmatter, content, parse_errors, key_order = self._parse_frontmatter(file_path)
        if parse_errors:
            return [ValidationError('critical', str(file_path), err) for err in parse_errors]
        
        # Router files may not have frontmatter, which is OK
        if not frontmatter:
            # Validate body structure instead
            if '## Layer' not in content:
                errors.append(ValidationError('warning', str(file_path), "Router files should include ## Layer section"))
            return errors
        
        # Get schema definitions
        try:
            official_fields = SchemaLoader.get_official_fields('router', self.schema)
            metadata_fields = SchemaLoader.get_metadata_fields('router', self.schema)
        except ValueError:
            return errors
        
        # Check field placement
        top_level_fields = set(frontmatter.keys())
        non_official_fields = top_level_fields - set(official_fields) - {'metadata'}
        
        metadata = frontmatter.get('metadata', {})
        if isinstance(metadata, dict):
            # Check for custom fields in wrong place
            fields_in_wrong_place = []
            for field in non_official_fields:
                if field in metadata_fields:
                    fields_in_wrong_place.append(field)
            
            if fields_in_wrong_place:
                errors.append(ValidationError('critical', str(file_path), f"Fields should be in metadata section: {', '.join(fields_in_wrong_place)}"))
        
        return errors
    
    def _validate_entrypoint(self, file_path: Path) -> List[ValidationError]:
        """Validate a governance entrypoint file."""
        errors: List[ValidationError] = []
        
        frontmatter, content, parse_errors, key_order = self._parse_frontmatter(file_path)
        if parse_errors:
            return [ValidationError('critical', str(file_path), err) for err in parse_errors]
        
        # Entrypoint files may not have frontmatter, which is OK
        if not frontmatter:
            # Validate body structure instead
            if '## Layer' not in content:
                errors.append(ValidationError('warning', str(file_path), "Entrypoint files should include ## Layer section"))
            return errors
        
        # Get schema definitions
        try:
            official_fields = SchemaLoader.get_official_fields('entrypoint', self.schema)
            metadata_fields = SchemaLoader.get_metadata_fields('entrypoint', self.schema)
        except ValueError:
            return errors
        
        # Check field placement
        top_level_fields = set(frontmatter.keys())
        non_official_fields = top_level_fields - set(official_fields) - {'metadata'}
        
        metadata = frontmatter.get('metadata', {})
        if isinstance(metadata, dict):
            # Check for custom fields in wrong place
            fields_in_wrong_place = []
            for field in non_official_fields:
                if field in metadata_fields:
                    fields_in_wrong_place.append(field)
            
            if fields_in_wrong_place:
                errors.append(ValidationError('critical', str(file_path), f"Fields should be in metadata section: {', '.join(fields_in_wrong_place)}"))
        
        return errors
    
    def _validate_output_style(self, file_path: Path) -> List[ValidationError]:
        """Validate a governance output-style file."""
        errors: List[ValidationError] = []
        
        frontmatter, content, parse_errors, key_order = self._parse_frontmatter(file_path)
        if parse_errors:
            return [ValidationError('critical', str(file_path), err) for err in parse_errors]
        
        if not frontmatter:
            errors.append(ValidationError('critical', str(file_path), "Missing frontmatter"))
            return errors
        
        # Get schema definitions
        try:
            official_fields = SchemaLoader.get_official_fields('output-style', self.schema)
            metadata_fields = SchemaLoader.get_metadata_fields('output-style', self.schema)
            validation_rules = SchemaLoader.get_validation_rules('output-style', self.schema)
        except ValueError:
            return errors
        
        # Validate required fields
        required_fields = SchemaLoader.get_required_fields('output-style', self.schema)
        for field in required_fields:
            if field not in frontmatter:
                errors.append(ValidationError('critical', str(file_path), f"Missing required field: {field}"))
        
        # Check field placement
        top_level_fields = set(frontmatter.keys())
        non_official_fields = top_level_fields - set(official_fields) - {'metadata'}
        
        metadata = frontmatter.get('metadata', {})
        if not isinstance(metadata, dict):
            if metadata is not None:
                errors.append(ValidationError('critical', str(file_path), "metadata must be a dictionary if present"))
        else:
            # Check for custom fields in wrong place
            fields_in_wrong_place = []
            for field in non_official_fields:
                if field in metadata_fields:
                    fields_in_wrong_place.append(field)
            
            if fields_in_wrong_place:
                errors.append(ValidationError('critical', str(file_path), f"Fields should be in metadata section: {', '.join(fields_in_wrong_place)}"))
            
            # Check for official fields in metadata
            official_in_metadata = []
            for field in official_fields:
                if field in metadata:
                    official_in_metadata.append(field)
            
            if official_in_metadata:
                errors.append(ValidationError('critical', str(file_path), f"Official fields should be in top-level, not metadata: {', '.join(official_in_metadata)}"))
        
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
        # Count **text** patterns but ignore YAML frontmatter and code fences
        parts = text.split('---')
        body = '---'.join(parts[2:]) if len(parts) > 2 else text

        # Remove code fence content to avoid false positives
        # This is a simple approach - more robust would be to parse markdown properly
        clean_body = body

        # Remove content between triple backticks
        import re
        clean_body = re.sub(r'```.*?```', '', clean_body, flags=re.DOTALL)

        # Count actual **bold** markers not in code
        return len(re.findall(r'\*\*[^*\s]+\*\*', clean_body))
    
    def _has_emojis(self, text: str) -> bool:
        """Check if text contains emojis."""
        emoji_pattern = re.compile(
            "["
            "\U0001F600-\U0001F64F"  # emoticons / smileys
            "\U0001F300-\U0001F5FF"  # symbols & pictographs
            "\U0001F680-\U0001F6FF"  # transport & map symbols
            "\U0001F1E0-\U0001F1FF"  # regional indicator flags
            "]+", flags=re.UNICODE
        )
        return bool(emoji_pattern.search(text))
    
    def _validate_heading_order(self, file_path: Path, content: str) -> List[ValidationError]:
        """Validate heading order for rules files."""
        errors: List[ValidationError] = []
        
        # Only validate rules files
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
            'narrative-detection',
            'depth-compatibility',
        ]
        
        # Extract headings using regex (## Heading format)
        heading_pattern = r'^##\s+(.+)$'
        headings = re.findall(heading_pattern, content, re.MULTILINE)
        headings_lower = [h.strip().lower() for h in headings]
        
        # Check order
        seen_indices = []
        for heading in headings_lower:
            if heading in expected_headings:
                idx = expected_headings.index(heading)
                seen_indices.append((idx, heading))
        
        # Check if headings are in order
        if seen_indices:
            last_idx = -1
            for idx, heading in seen_indices:
                if idx < last_idx:
                    errors.append(ValidationError('warning', str(file_path), f"Heading '{heading}' is out of order. Headings must follow canonical order: {', '.join(expected_headings)}"))
                    break
                last_idx = idx
        
        # Check for missing required headings
        seen_headings = {h for _, h in seen_indices}
        missing = [h for h in expected_headings if h not in seen_headings]
        if missing:
            errors.append(ValidationError('warning', str(file_path), f"Missing recommended headings: {', '.join(missing)}"))
        
        return errors
    
    def _check_modal_verbs(self, file_path: Path, content: str) -> List[ValidationError]:
        """Check for modal verbs in body content (excluding code blocks)."""
        errors: List[ValidationError] = []
        
        # Only check LLM-facing files
        if not any(part in ['commands', 'skills', 'agents', 'rules'] for part in file_path.parts):
            if file_path.name not in ['CLAUDE.md', 'AGENTS.md']:
                return errors
        
        # Remove code blocks to avoid false positives
        content_no_code = re.sub(r'```.*?```', '', content, flags=re.DOTALL)
        content_no_code = re.sub(r'`[^`]+`', '', content_no_code)
        
        # Remove frontmatter
        parts = content_no_code.split('---')
        if len(parts) > 2:
            content_no_code = '---'.join(parts[2:])
        
        # Check for modal verbs
        modal_pattern = r'\b(may|might|could)\b'
        lines = content_no_code.split('\n')
        
        for line_num, line in enumerate(lines, 1):
            matches = list(re.finditer(modal_pattern, line, re.IGNORECASE))
            if matches:
                # Skip if in a list item that might be normative
                if line.strip().startswith('-') or line.strip().startswith('*'):
                    # Check if it's a normative rule definition
                    if 'normative' in line.lower() or 'exception' in line.lower():
                        continue
                
                for match in matches:
                    errors.append(ValidationError('warning', str(file_path), f"Modal verb '{match.group()}' found in line {line_num}. Consider using imperative form instead."))
        
        return errors
    
    def validate_directory(self, directory: Path) -> Dict[str, List[ValidationError]]:
        """Validate all relevant files in a directory."""
        results: Dict[str, List[ValidationError]] = {}
        
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
                if not file_path.is_file():
                    continue
                # Skip backup and rollback artefacts; validation targets live manifests and rules only
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
    
    # Load schema from same directory as this script
    schema_path = Path(__file__).parent / "config.yaml"
    validator = LLMSpecValidator(schema_path=schema_path)
    
    # Handle both files and directories
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
