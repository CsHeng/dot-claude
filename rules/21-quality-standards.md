# Code Quality and Standards

Comprehensive standards for maintaining high code quality across all projects and languages.

## Linting and Formatting Standards

### Universal Code Quality Principles
- Consistency: All code follows consistent style and formatting
- Readability: Code is self-documenting and easy to understand
- Maintainability: Code is easy to modify and extend
- Testability: Code is structured to enable effective testing

### Python Code Quality (Ruff)
```toml
# Complete ruff configuration for maximum code quality
[tool.ruff]
line-length = 88
target-version = "py313"
show-fixes = true
output-format = "grouped"
preview = true

[tool.ruff.lint]
select = [
    # pycodestyle
    "E",      # pycodestyle errors
    "W",      # pycodestyle warnings

    # Pyflakes
    "F",      # Pyflakes

    # pyupgrade
    "UP",     # pyupgrade

    # flake8-bugbear
    "B",      # flake8-bugbear

    # flake8-simplify
    "SIM",    # flake8-simplify

    # flake8-comprehensions
    "C4",     # flake8-comprehensions

    # isort
    "I",      # isort

    # mccabe
    "C90",    # mccabe complexity

    # pep8-naming
    "N",      # pep8-naming

    # flake8-docstrings
    "D",      # pydocstyle

    # flake8-bandit (security)
    "S",      # flake8-bandit

    # flake8-builtins
    "A",      # flake8-builtins

    # flake8-return
    "RET",    # flake8-return

    # flake8-raise
    "RSE",    # flake8-raise

    # flake8-errmsg
    "EM",     # flake8-errmsg

    # flake8-unused-arguments
    "ARG",    # flake8-unused-arguments

    # flake8-slots
    "SLOT",   # flake8-slots

    # flake8-annotations
    "ANN",    # flake8-annotations

    # flake8-type-checking
    "TCH",    # flake8-type-checking

    # flake8-import-conventions
    "ICN",    # flake8-import-conventions

    # flake8-pyi
    "PYI",    # flake8-pyi

    # flake8-gettext
    "INT",    # flake8-gettext

    # flake8-logging-format
    "G",      # flake8-logging-format

    # flake8-async
    "ASYNC",  # flake8-async

    # flake8-trio
    "TRIO",   # flake8-trio

    # flake8-logging
    "LOG",    # flake8-logging

    # flake8-boolean-trap
    "FBT",    # flake8-boolean-trap

    # flake8-print
    "T20",    # flake8-print

    # flake8-debugger
    "T10",    # flake8-debugger

    # flake8-quotes
    "Q",      # flake8-quotes

    # flake8-commas
    "COM",    # flake8-commas

    # flake8-datetimez
    "DTZ",    # flake8-datetimez

    # flake8-executable
    "EXE",    # flake8-executable

    # flake8-implicit-str-concat
    "ISC",    # flake8-implicit-str-concat

    # flake8-import-order
    # "TID",   # flake8-tidy-imports (replaced by Ruff's built-in)

    # flake8-no-pep420
    "INP",    # flake8-no-pep420

    # flake8-pie
    "PIE",    # flake8-pie

    # flake8-numeric-namespace
    "NUM",    # flake8-numeric-namespace

    # flake8-broken-line
    "PL",     # Pylint

    # flake8-use-pathlib
    "PTH",    # flake8-use-pathlib

    # flake8-simplify-try-except
    "TRY",    # tryceratops

    # flake8-raise
    "RUF",    # Ruff-specific rules

    # flake8- eradicate
    "ERA",    # eradicate

    # flake8-pytest-style
    "PT",     # flake8-pytest-style

    # flake8-typing-imports
    "TID251", # flake8-typing-imports

    # flake8-copyright
    "CPY",    # flake8-copyright

    # Perflint
    "PERF",   # Perflint

    # Ruff-specific
    "RUF",    # Ruff-specific rules
]

ignore = [
    "E501",   # line too long (handled by formatter)
    "B008",   # do not perform function calls in argument defaults
    "B904",   # raise from ... inside except, use raise ... from ...
    "D203",   # 1 blank line required before class docstring
    "D212",   # multi-line docstring summary should start at the first line
    "D100",   # missing docstring in public module
    "D101",   # missing docstring in public class
    "D102",   # missing docstring in public method
    "D103",   # missing docstring in public function
    "D104",   # missing docstring in public package
    "D105",   # missing docstring in magic method
    "D107",   # missing docstring in __init__
    "D401",   # first line is in imperative mood
    "D415",   # first line should end with a period, question mark, or exclamation point
    "ANN101", # missing type annotation for self in method
    "ANN102", # missing type annotation for cls in classmethod
    "ANN401", # dynamically typed expressions (typing.Any) are disallowed
    "S101",   # use of assert detected
    "S311",   # standard pseudo-random generators are not suitable for cryptographic purposes
    "S603",   # subprocess call - check for execution of untrusted input
    "ARG001", # unused function argument: `ctx`
    "ARG002", # unused method argument: `request`
    "PLR2004", # magic value used in comparison, consider replacing with a constant
    "TRY003", # avoid specifying long messages outside the exception class
    "TRY400", # logging.error instead of logging.exception for OOPS
]

[tool.ruff.lint.per-file-ignores]
"tests/*" = [
    "S101",   # use of assert detected
    "S106",   # possible hardcoded password
    "ARG001", # unused function argument
    "ARG002", # unused method argument
    "PLR2004", # magic value used in comparison
    "ANN001", # missing type annotation for function argument
    "ANN201", # missing return type annotation for public function
    "ANN202", # missing return type annotation for private function
    "D100",   # missing docstring in public module
    "D101",   # missing docstring in public class
    "D102",   # missing docstring in public method
    "D103",   # missing docstring in public function
    "D104",   # missing docstring in public package
    "D105",   # missing docstring in magic method
    "D107",   # missing docstring in __init__
    "S105",   # possible hardcoded password assignment
    "S108",   # possible hardcoded temporary file and directory
    "S311",   # standard pseudo-random generators are not suitable for cryptographic purposes
    "S603",   # subprocess call - check for execution of untrusted input
    "S607",   # starting a process with a shell, possible injection detected
    "SLF001", # private member accessed
]
"__init__.py" = ["F401"]  # unused import
"migrations/*" = ["D101", "D102", "D103", "D106"]  # migration files

[tool.ruff.lint.mccabe]
max-complexity = 10

[tool.ruff.lint.pydocstyle]
convention = "google"

[tool.ruff.lint.isort]
known-first-party = ["myproject"]
split-on-trailing-comma = true
combine-as-imports = true
force-sort-within-sections = true

[tool.ruff.lint.flake8-quotes]
docstring-quotes = "double"
inline-quotes = "double"

[tool.ruff.lint.flake8-annotations]
suppress-none-returning = true

[tool.ruff.lint.flake8-type-checking]
strict = true
exempt-modules = ["typing", "typing_extensions"]

[tool.ruff.format]
quote-style = "double"
indent-style = "space"
skip-magic-trailing-comma = false
line-ending = "auto"

[tool.ruff.lint.flake8-unused-arguments]
ignore-variadic-names = true
```

### Go Code Quality (golangci-lint)
```yaml
# .golangci.yml - Comprehensive golangci-lint configuration
run:
  timeout: 10m
  tests: true
  skip-dirs:
    - vendor
    - testdata
    - .git
    - .cache
  skip-files:
    - ".*\\.pb\\.go$"
    - ".*_generated\\.go$"
  modules-download-mode: readonly

linters-settings:
  gocyclo:
    min-complexity: 15
    skip-tests: true

  goconst:
    min-len: 3
    min-occurrences: 3
    ignore-tests: true
    match-constant: true
    min-len: 3
    min-occurrences: 3

  gofmt:
    simplify: true

  goimports:
    local-prefixes: myproject
    log-all: false

  golint:
    min-confidence: 0.8

  gomnd:
    settings:
      mnd:
        checks: argument,case,condition,operation,return,assign
        ignored-numbers: 0,1,2,3,4,5,6,7,8,9,10,100,1000
        ignored-functions: math.*,strconv.*,time.*

  govet:
    check-shadowing: true
    settings:
      printf:
        funcs:
          - (github.com/golangci/golangci-lint/pkg/logutils.Log).Infof
          - (github.com/golangci/golangci-lint/pkg/logutils.Log).Warnf
          - (github.com/golangci/golangci-lint/pkg/logutils.Log).Errorf
          - (github.com/golangci/golangci-lint/pkg/logutils.Log).Fatalf

  lll:
    line-length: 120

  misspell:
    locale: US
    ignore-words:
      - someword

  nolintlint:
    allow-leading-space: true
    allow-unused: false
    require-explanation: true
    require-specific: true

  rowserrcheck:
    packages:
      - github.com/jmoiron/sqlx

  gocritic:
    enabled-tags:
      - diagnostic
      - experimental
      - opinionated
      - performance
      - style
    disabled-checks:
      - dupImport
      - ifElseChain
      - octalLiteral
      - whyNoLint
      - wrapperFunc

  funlen:
    lines: 100
    statements: 50

  gocognit:
    min-complexity: 20

  nestif:
    min-complexity: 4

  gomoddirectives:
    replace-local: true
    replace-allow-list:
      - github.com/ory/dockertest
      - github.com/golangci/golangci-lint

  godot:
    scope: all
    capital: true
    period: true
    check-all: true

  gci:
    local-prefixes: myproject

  goheader:
    values:
      const:
        COMPANY: My Company
      year: 2024
    template-path: .goheader.tpl

  gofumpt:
    extra-rules: true

  revive:
    rules:
      - name: exported
        severity: warning
        disabled: false
        arguments:
          - "checkPrivateReceivers"
          - "sayRepetitiveInsteadOfStutters"
      - name: var-naming
        severity: warning
        disabled: false
        arguments:
          - [["ID"], ["Id"]]
          - [["JSON"], ["Json"]]
          - [["URL"], ["Url"]]
          - [["HTTP"], ["Http"]]
          - [["TLS"], ["Tls"]]
          - [["EOF"], ["Eof"]]
          - [["RAM"], ["Ram"]]
          - [["CPU"], ["Cpu"]]
          - [["GPU"], ["Gpu"]]
          - [["RPC"], ["Rpc"]]
          - [["DAO"], ["Dao"]]
          - [["UTC"], ["Utc"]]
          - [["UUID"], ["Uuid"]]
          - [["UID"], ["Uid"]]
          - [["XML"], ["Xml"]]
          - [["YAML"], ["Yaml"]]
          - [["API"], ["Api"]]
          - [["ASCII"], ["Ascii"]]
          - [["SQL"], ["Sql"]]
          - [["DB"], ["Db"]]
          - [["TS"], ["Ts"]]
          - [["OK"], ["Ok"]]

  depguard:
    rules:
      main:
        deny:
          - pkg: "github.com/pkg/errors"
            desc: "should be replaced by standard library errors"
        allow:
          - $gostd
          - github.com/project
        list-mode: lax

  dogsled:
    max-blank-identifiers: 2

  dupl:
    threshold: 100

  errcheck:
    check-type-assertions: true
    check-blank: false
    ignore: fmt:.*,io/ioutil:ReadAll

  exhaustive:
    default-signifies-exhaustive: false

  exhaustive-struct:
    default-signifies-exhaustive: false

  exhaustruct:
    include:
      - standard.* # packages matching "standard.*"
      - myproject/models # packages matching "myproject/models"

  forcetypeassert:
    ignore: "*"

  gochecknoinits:
    ignore-custom-test: true

  gocognit:
    min-complexity: 30

  gosec:
    excludes:
      - G404 # Use of weak random number generator

  gosimple:
    checks: [ "all" ]

  govet:
    check-shadowing: true
    enable-all: true

  nakedret:
    max-func-lines: 30

  nilerr:
    check-blank: false

  nilnil:
    checked-types:
      - ptr
      - func
      - iface

  noctx:
    allow-leading-space: false

  nolintlint:
    allow-leading-space: true
    allow-unused: false
    require-explanation: true
    require-specific: true

  prealloc:
    simple: true
    range-loops: true
    for-loops: false

  predeclared:
    ignore: ""

  promlinter:
    strict-linters: all
    promlint: false
    forbid-unused-metrics: true

  reassign:
    patterns:
      - ^.*$
      - ^[a-z][a-zA-Z0-9]*$

  staticcheck:
    checks: [ "all" ]

  stylecheck:
    checks: [ "all", "-ST1000", "-ST1003", "-ST1016", "-ST1020", "-ST1021", "-ST1022" ]
    dot-import-whitelist: [ "fmt" ]
    http-status-code-whitelist: [ "200", "400", "404", "500" ]
    functions:
      - (Errorf|Failf|Logf|Print|Printf|Sprintf|e\.Errorf)\z

  tagliatelle:
    case:
      rules:
        json: snake
        yaml: snake
        toml: snake

  testifylint:
    enable-all: true
    disable:
      - go-require
    require-check:
      - no-error
      - no-assert
    ignore-sample-fn: true

  thelper:
    all: true
    test:
      t: true
      require-error: false
      require-func: false
      compare: true
      assert: true
      require-comparison-func: false
    benchmark:
      b: true
      require-error: false
      require-func: false
    fuzz:
      f: true
      require-error: false
      require-func: false
    tb: true

  unconvert:
    safe: false

  unparam:
    check-exported: false
    disable-all: true

  unused:
    check-exported: false

  usestdlibvars:
    http-method: true
    net-ip: true
    osis: true
    time-layout: true

  whitespace:
    multi-if: false
    multi-func: false

  wrapcheck:
    ignoreSigs:
      - .Errorf(
      - errors.New(
      - errors.Unwrap(
      - .Wrap(
      - .Wrapf(
      - .WithMessage(
      - .WithStack(
    ignorePackageGlobs:
      - fmt/*
      - errors/*
    ignoreInterfacePatterns:
      - "Error()"
      - "Writer"

  wsl:
    allow-assign-and-anything: false
    allow-cuddle-declarations: false
    allow-multiline-assign: true
    allow-case-trailing-whitespace: false
    allow-trailing-comment: false
    allow-separated-leading-comment: false
    enforce-err-cuddling: true
    enforce-cuddle-lib-funcs: true
    force-case-trailing-whitespace: false
    force-err-cuddling: true
    force-short-decl-cuddling: false
    strict-append: true

linters:
  enable-all: true
  disable:
    - interfacer # deprecated
    - maligned   # deprecated
    - scopelint  # deprecated
    - exhaustivestruct # deprecated
    - deadcode   # deprecated
    - varcheck   # deprecated
    - structcheck # deprecated
    - nosnakecase
    - gochecknoglobals
    - golint     # replaced by revive
    - ifshort    # experimental
    - nosprintfhostport
    - funlen     # optional
    - gocritic   # optional
    - dupl       # optional
    - gosec      # optional
    - lll        # optional
    - gomnd      # optional

issues:
  exclude-rules:
    # Exclude some linters from running on tests files
    - path: _test\.go
      linters:
        - gocyclo
        - errcheck
        - dupl
        - gosec
        - lll
        - gocognit
        - funlen
        - goconst
        - gomnd
        - forbidigo
        - execinquery
        - gocritic
        - gomoddirectives
        - gomodguard
        - gosimple
        - maintidx
        - nestif
        - rowserrcheck
        - sqlclosecheck
        - unconvert
        - unparam
        - wastedassign

    # Exclude known linter issues
    - text: "weak cryptographic primitive"
      linters:
        - gosec

    # Exclude shadow checking on err variables
    - text: "shadow: declaration of \"err\""
      linters:
        - govet

    # Exclude certain staticcheck issues
    - text: "SA9003: empty branch"
      linters:
        - staticcheck

    # Exclude checking the error of errors.New
    - text: "error strings should not be capitalized"
      linters:
        - revive

    # Exclude shadow checking on receiver methods
    - text: "shadow: declaration of \"(.*)\" shadows declaration at"
      linters:
        - govet

    # Exclude certain golint issues
    - text: "should have a package comment"
      linters:
        - golint

    # Exclude magic number warnings in tests
    - path: _test\.go
      text: "Magic number: [0-9]+"
      linters:
        - gomnd

    # Exclude certain revive issues
    - text: "exported (type|function|var|method|const) (.+) has comment"
      linters:
        - revive

  exclude-use-default: false
  max-issues-per-linter: 0
  max-same-issues: 0
  new: false

output:
  format: colored-line-number
  print-issued-lines: true
  print-linter-name: true
  uniq-by-line: true
  sort-results: true
  show-stats: true
```

## Pre-commit Hooks Configuration

### Universal Pre-commit Setup
```yaml
# .pre-commit-config.yaml
repos:
  # Python specific
  - repo: https://github.com/astral-sh/ruff-pre-commit
    rev: v0.1.0
    hooks:
      - id: ruff
        args: [--fix]
        types_or: [python, pyi]
      - id: ruff-format
        types_or: [python, pyi]

  - repo: https://github.com/pre-commit/pre-commit-hooks
    rev: v4.5.0
    hooks:
      - id: trailing-whitespace
      - id: end-of-file-fixer
      - id: check-yaml
      - id: check-added-large-files
      - id: check-merge-conflict
      - id: debug-statements
      - id: check-builddir
      - id: check-case-conflict
      - id: check-docstring-first
      - id: check-executables-have-shebangs
      - id: check-json
      - id: check-shebang-scripts-are-executable
      - id: check-toml
      - id: check-xml
      - id: check-yaml
      - id: detect-private-key
      - id: destroyed-symlinks
      - id: mixed-line-ending

  # Security scanning
  - repo: https://github.com/Yelp/detect-secrets
    rev: v1.4.0
    hooks:
      - id: detect-secrets
        args: ['--baseline', '.secrets.baseline']

  # Go specific
  - repo: https://github.com/pre-commit/mirrors-golangci-lint
    rev: v1.54.2
    hooks:
      - id: golangci-lint
        types: [go]

  - repo: local
    hooks:
      - id: go-fmt
        name: go fmt
        entry: gofmt
        language: system
        args: [-w]
        types: [go]

      - id: go-imports
        name: go imports
        entry: goimports
        language: system
        args: [-w]
        types: [go]

  # Shell scripts
  - repo: https://github.com/shellcheck-py/shellcheck-py
    rev: v0.9.0.5
    hooks:
      - id: shellcheck
        types: [shell]

  # Docker files
  - repo: https://github.com/hadolint/hadolint
    rev: v2.12.0
    hooks:
      - id: hadolint-docker
        types: [dockerfile]

  # YAML files
  - repo: https://github.com/adrienverge/yamllint
    rev: v1.32.0
    hooks:
      - id: yamllint
        types: [yaml]

  # Markdown files
  - repo: https://github.com/igorshubovych/markdownlint-cli
    rev: v0.37.0
    hooks:
      - id: markdownlint
        types: [markdown]

  # Terraform
  - repo: https://github.com/antonbabenko/pre-commit-terraform
    rev: v1.83.6
    hooks:
      - id: terraform_fmt
      - id: terraform_validate
      - id: terraform_tflint
      - id: terraform_docs
      - id: terraform_tfsec

  # JSON files
  - repo: https://github.com/python-jsonschema/check-jsonschema
    rev: 0.27.0
    hooks:
      - id: check-jsonschema
        files: '^package\.json$'
        types: [json]
        args: ["--builtin-schema", "vendor-package-json"]
```

## Code Review Standards

### Review Checklist

#### General Code Quality
- [ ] Code follows project style guidelines
- [ ] Variable and function names are descriptive and clear
- [ ] Code is properly formatted and linted
- [ ] No commented-out code remains
- [ ] No TODO/FIXME comments without tickets
- [ ] Error handling is comprehensive and consistent
- [ ] Logging is appropriate and follows standards

#### Architecture and Design
- [ ] Code follows established architectural patterns
- [ ] Single responsibility principle is followed
- [ ] Dependencies are properly managed
- [ ] Code is modular and reusable
- [ ] Interface design is clean and consistent
- [ ] No circular dependencies

#### Security
- [ ] Input validation is comprehensive
- [ ] No hardcoded secrets or credentials
- [ ] Proper authentication and authorization
- [ ] SQL injection and XSS protection
- [ ] Security headers are properly configured
- [ ] Error messages don't leak sensitive information

#### Performance
- [ ] No obvious performance bottlenecks
- [ ] Database queries are optimized
- [ ] Proper caching strategies are used
- [ ] Memory usage is efficient
- [ ] No unnecessary computations in loops
- [ ] Proper resource cleanup

#### Testing
- [ ] Tests cover critical functionality
- [ ] Tests are well-structured and readable
- [ ] Test names are descriptive
- [ ] Mocks are used appropriately
- [ ] Edge cases are tested
- [ ] Integration tests are included where needed

#### Documentation
- [ ] Public functions have proper docstrings
- [ ] Complex algorithms are documented
- [ ] README is updated if necessary
- [ ] API documentation is accurate
- [ ] Configuration options are documented
- [ ] Dependencies are documented

## Quality Gates

### Automated Quality Checks
```yaml
# .github/workflows/quality-check.yml
name: Code Quality Checks

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]

jobs:
  quality-check:
    runs-on: ubuntu-latest

    steps:
    - uses: actions/checkout@v4

    - name: Set up Python
      uses: actions/setup-python@v4
      with:
        python-version: '3.13'

    - name: Set up Go
      uses: actions/setup-go@v4
      with:
        go-version: '1.23'

    - name: Install dependencies
      run: |
        python -m pip install --upgrade pip
        pip install ruff pytest pytest-cov
        go install github.com/golangci/golangci-lint/cmd/golangci-lint@latest

    - name: Run Python linting
      run: |
        ruff check .
        ruff format --check .

    - name: Run Go linting
      run: |
        golangci-lint run

    - name: Run security scan
      run: |
        pip install bandit safety
        bandit -r . -x tests/
        safety check

    - name: Run tests
      run: |
        pytest tests/ --cov=src --cov-report=xml --cov-fail-under=80

    - name: Upload coverage to Codecov
      uses: codecov/codecov-action@v3
      with:
        file: ./coverage.xml
        flags: unittests
        name: codecov-umbrella
```

### Quality Metrics

#### Code Coverage Requirements
- Minimum Coverage: 80% line coverage
- Critical Paths: 95% coverage for critical business logic
- Integration Tests: Cover all major workflows
- Edge Cases: Test all error conditions and edge cases

#### Complexity Limits
- Cyclomatic Complexity: Maximum 15 per function
- Function Length: Maximum 50 lines
- File Length: Maximum 500 lines
- Nesting Depth: Maximum 4 levels

#### Security Standards
- No High-Severity Vulnerabilities: Zero high-severity security issues
- Dependencies: All dependencies must be scanned and approved
- Secrets: No hardcoded secrets or API keys
- Input Validation: 100% input validation coverage

## Continuous Quality Improvement

### Quality Metrics Tracking
```yaml
# quality-metrics.yml
quality_targets:
  code_coverage:
    minimum: 80
    target: 90
    critical_paths: 95

  complexity:
    max_cyclomatic: 15
    max_function_length: 50
    max_file_length: 500
    max_nesting_depth: 4

  security:
    max_high_vulnerabilities: 0
    max_medium_vulnerabilities: 5
    secrets_scanning: required
    dependency_scanning: required

  performance:
    max_test_duration: 300s
    max_build_time: 600s
    memory_usage_threshold: 512MB

  maintainability:
    technical_debt_ratio: "< 5%"
    duplicated_code: "< 3%"
    code_churn: "< 10% per release"
```

### Quality Dashboards
```python
# quality_dashboard.py - Example quality metrics collector
import subprocess
import json
import time
from typing import Dict, Any

class QualityMetricsCollector:
    def collect_all_metrics(self) -> Dict[str, Any]:
        """Collect all quality metrics."""
        metrics = {
            'timestamp': time.time(),
            'code_coverage': self.get_code_coverage(),
            'complexity': self.get_complexity_metrics(),
            'security': self.get_security_metrics(),
            'performance': self.get_performance_metrics(),
            'maintainability': self.get_maintainability_metrics()
        }
        return metrics

    def get_code_coverage(self) -> Dict[str, float]:
        """Get code coverage metrics."""
        try:
            result = subprocess.run(
                ['pytest', '--cov=src', '--cov-report=json'],
                capture_output=True,
                text=True
            )
            coverage_data = json.loads(result.stdout)
            return {
                'total_coverage': coverage_data['totals']['percent_covered'],
                'lines_covered': coverage_data['totals']['covered_lines'],
                'lines_missing': coverage_data['totals']['missing_lines']
            }
        except Exception as e:
            return {'error': str(e)}

    def get_complexity_metrics(self) -> Dict[str, Any]:
        """Get code complexity metrics."""
        # Implement complexity analysis
        return {
            'max_cyclomatic_complexity': 12,
            'average_function_length': 25,
            'max_nesting_depth': 3
        }

    def get_security_metrics(self) -> Dict[str, Any]:
        """Get security scan results."""
        # Implement security metrics collection
        return {
            'high_vulnerabilities': 0,
            'medium_vulnerabilities': 2,
            'dependency_vulnerabilities': 0
        }

    def get_performance_metrics(self) -> Dict[str, Any]:
        """Get performance metrics."""
        return {
            'test_duration': 180,
            'build_time': 420,
            'memory_usage': '256MB'
        }

    def get_maintainability_metrics(self) -> Dict[str, Any]:
        """Get maintainability metrics."""
        return {
            'technical_debt_ratio': '3.2%',
            'duplicated_code': '2.1%',
            'code_churn': '7.5%'
        }

# Usage example
if __name__ == "__main__":
    collector = QualityMetricsCollector()
    metrics = collector.collect_all_metrics()
    print(json.dumps(metrics, indent=2))
```

## Quality Improvement Process

### Regular Quality Reviews
1. Weekly: Review quality metrics and trends
2. Monthly: Deep dive into quality issues and improvements
3. Quarterly: Quality goals and process improvements
4. Annually: Quality standards review and updates

### Quality Training
1. Onboarding: Quality standards and tools training
2. Monthly: Quality best practices workshops
3. Quarterly: Code review training
4. As Needed: Tool-specific training sessions

### Quality Incentives
1. Recognition: Acknowledge high-quality contributions
2. Metrics: Track individual and team quality metrics
3. Improvement: Celebrate quality improvements
4. Learning: Share quality lessons learned