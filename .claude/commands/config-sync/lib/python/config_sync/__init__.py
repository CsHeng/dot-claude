"""
Config Sync Library - Configuration synchronization utilities for CLI tools

This library provides modular, testable utilities for:
- Path resolution using JSON manifests
- Configuration validation
- File processing and synchronization
"""

__version__ = "1.0.0"
__author__ = "Claude Code"

from .path_resolver import PathResolver
from .config_validator import ConfigValidator
from .json_extractor import JsonExtractor
from .file_processor import FileProcessor

__all__ = [
    "PathResolver",
    "ConfigValidator",
    "JsonExtractor",
    "FileProcessor"
]