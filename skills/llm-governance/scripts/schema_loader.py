#!/usr/bin/env python3
"""
Schema Loader for LLM Governance Validation

Loads and provides access to the config.yaml definition file (SSOT).
"""

import yaml
from pathlib import Path
from typing import Dict, Any, Optional, Set, List


class SchemaLoader:
    """Loads and provides access to validation schema definitions."""
    
    _schema_cache: Optional[Dict[str, Any]] = None
    _schema_path: Optional[Path] = None
    
    @classmethod
    def load(cls, schema_path: Optional[Path] = None) -> Dict[str, Any]:
        """Load schema from YAML file."""
        if schema_path is None:
            # Default to config.yaml in the same directory as this script (SSOT)
            schema_path = Path(__file__).parent / "config.yaml"
        
        # Use cache if same path
        if cls._schema_cache is not None and cls._schema_path == schema_path:
            return cls._schema_cache
        
        if not schema_path.exists():
            raise FileNotFoundError(f"Schema file not found: {schema_path}")
        
        with open(schema_path, 'r', encoding='utf-8') as f:
            schema = yaml.safe_load(f)
        
        if not schema:
            raise ValueError(f"Schema file is empty or invalid: {schema_path}")
        
        cls._schema_cache = schema
        cls._schema_path = schema_path
        return schema
    
    @classmethod
    def get_style_labels(cls, schema: Optional[Dict[str, Any]] = None) -> Set[str]:
        """Get allowed style labels."""
        if schema is None:
            schema = cls.load()
        return set(schema.get('style_labels', {}).get('allowed', []))
    
    @classmethod
    def get_frontmatter_schema(cls, manifest_type: str, schema: Optional[Dict[str, Any]] = None) -> Dict[str, Any]:
        """Get frontmatter schema for a manifest type (skill/command/agent)."""
        if schema is None:
            schema = cls.load()
        
        schemas = schema.get('frontmatter_schemas', {})
        if manifest_type not in schemas:
            raise ValueError(f"Unknown manifest type: {manifest_type}")
        
        return schemas[manifest_type]
    
    @classmethod
    def get_required_fields(cls, manifest_type: str, schema: Optional[Dict[str, Any]] = None) -> List[str]:
        """Get required official fields for a manifest type (preserving schema order)."""
        fm_schema = cls.get_frontmatter_schema(manifest_type, schema)
        official = fm_schema.get('official_fields', {})
        return list(official.get('required', []))
    
    @classmethod
    def get_optional_fields(cls, manifest_type: str, schema: Optional[Dict[str, Any]] = None) -> List[str]:
        """Get optional official fields for a manifest type (preserving schema order)."""
        fm_schema = cls.get_frontmatter_schema(manifest_type, schema)
        official = fm_schema.get('official_fields', {})
        return list(official.get('optional', []))
    
    @classmethod
    def get_official_fields(cls, manifest_type: str, schema: Optional[Dict[str, Any]] = None) -> Set[str]:
        """Get all official fields (required + optional) for a manifest type."""
        required = cls.get_required_fields(manifest_type, schema)
        optional = cls.get_optional_fields(manifest_type, schema)
        return set(required) | set(optional)
    
    @classmethod
    def get_metadata_fields(cls, manifest_type: str, schema: Optional[Dict[str, Any]] = None) -> List[str]:
        """Get metadata fields for a manifest type."""
        fm_schema = cls.get_frontmatter_schema(manifest_type, schema)
        return fm_schema.get('metadata_fields', [])
    
    @classmethod
    def get_validation_rules(cls, manifest_type: str, schema: Optional[Dict[str, Any]] = None) -> Dict[str, Any]:
        """Get validation rules for a manifest type."""
        fm_schema = cls.get_frontmatter_schema(manifest_type, schema)
        return fm_schema.get('validation_rules', {})
    
    @classmethod
    def get_structural_requirements(cls, manifest_type: str, schema: Optional[Dict[str, Any]] = None) -> Dict[str, Any]:
        """Get structural requirements for a manifest type."""
        fm_schema = cls.get_frontmatter_schema(manifest_type, schema)
        return fm_schema.get('structural_requirements', {})
    
    @classmethod
    def get_content_rules(cls, schema: Optional[Dict[str, Any]] = None) -> Dict[str, Any]:
        """Get content validation rules."""
        if schema is None:
            schema = cls.load()
        return schema.get('content_rules', {})
    
    @classmethod
    def clear_cache(cls):
        """Clear schema cache (useful for testing)."""
        cls._schema_cache = None
        cls._schema_path = None

