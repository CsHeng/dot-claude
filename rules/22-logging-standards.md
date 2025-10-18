# Logging and Observability Standards

Comprehensive standards for logging, monitoring, and observability across all applications and services.

## Required Log Format

### Standard Log Format
```
+0800 2025-08-06 15:22:30 INFO main.go(180) | Descriptive message
```

### Format Components
- **Timezone**: +0800 (or appropriate timezone)
- **Timestamp**: 2025-08-06 15:22:30 (YYYY-MM-DD HH:MM:SS)
- **Level**: INFO (default levels: DEBUG, INFO, WARN, ERROR, FATAL)
- **File and Line**: main.go(180) (filename.extension(line_number))
- **Separator**: | (pipe character)
- **Message**: Descriptive message (clear, actionable information)

### Log Level Guidelines
- **DEBUG**: Detailed diagnostic information for development
- **INFO**: General information about application flow
- **WARN**: Unexpected situations that don't prevent the application from continuing
- **ERROR**: Error events that might still allow the application to continue
- **FATAL**: Very severe error events that will presumably lead the application to abort

## Implementation by Language

### Python Logging Implementation
```python
import logging
import sys
from datetime import datetime
from typing import Optional, Dict, Any

class CustomFormatter(logging.Formatter):
    """Custom log formatter matching required format."""

    def format(self, record: logging.LogRecord) -> str:
        # Get timezone info
        timezone = datetime.now().astimezone().strftime('%z')
        timestamp = datetime.fromtimestamp(record.created).strftime('%Y-%m-%d %H:%M:%S')

        # Format: +0800 2025-08-06 15:22:30 INFO main.py(180) | Descriptive message
        return f"{timezone} {timestamp} {record.levelname} {record.filename}({record.lineno}) | {record.getMessage()}"

class StructuredLogger:
    """Structured logger with context support."""

    def __init__(self, name: str, level: int = logging.INFO):
        self.logger = logging.getLogger(name)
        self.logger.setLevel(level)

        # Create console handler with custom formatter
        handler = logging.StreamHandler(sys.stdout)
        handler.setFormatter(CustomFormatter())
        self.logger.addHandler(handler)

        # Add file handler if configured
        # file_handler = logging.FileHandler('app.log')
        # file_handler.setFormatter(CustomFormatter())
        # self.logger.addHandler(file_handler)

    def _log_with_context(self, level: int, message: str, **context) -> None:
        """Log with additional context."""
        if context:
            context_str = " ".join([f"{k}={v}" for k, v in context.items()])
            message = f"{message} [{context_str}]"

        self.logger.log(level, message)

    def debug(self, message: str, **context) -> None:
        """Log debug message."""
        self._log_with_context(logging.DEBUG, message, **context)

    def info(self, message: str, **context) -> None:
        """Log info message."""
        self._log_with_context(logging.INFO, message, **context)

    def warning(self, message: str, **context) -> None:
        """Log warning message."""
        self._log_with_context(logging.WARNING, message, **context)

    def error(self, message: str, **context) -> None:
        """Log error message."""
        self._log_with_context(logging.ERROR, message, **context)

    def fatal(self, message: str, **context) -> None:
        """Log fatal message."""
        self._log_with_context(logging.FATAL, message, **context)

# Usage example
logger = StructuredLogger(__name__)

# Basic logging
logger.info("Application started")

# With context
logger.info("User logged in", user_id=123, ip_address="192.168.1.1")
logger.error("Database connection failed", database="postgres", error_code=08001)

# Request logging with correlation ID
def log_request(request_id: str, method: str, path: str, status_code: int, duration: float):
    logger.info("HTTP request completed",
                request_id=request_id,
                method=method,
                path=path,
                status_code=status_code,
                duration_ms=duration * 1000)
```

### Go Logging Implementation
```go
package logging

import (
    "fmt"
    "log/slog"
    "os"
    "runtime"
    "strings"
    "time"
)

type CustomHandler struct {
    handler slog.Handler
}

func (h *CustomHandler) Handle(ctx context.Context, record slog.Record) error {
    // Get caller information
    pc, file, line, ok := runtime.Caller(4)
    if !ok {
        file = "unknown"
        line = 0
    } else {
        // Get just the filename
        parts := strings.Split(file, "/")
        file = parts[len(parts)-1]
    }

    // Get function name
    fn := runtime.FuncForPC(pc)
    var funcName string
    if fn != nil {
        funcName = fn.Name()
        parts := strings.Split(funcName, ".")
        funcName = parts[len(parts)-1]
    }

    // Format timestamp
    timestamp := record.Time.Format("2006-01-02 15:04:05")
    timezone := time.Now().Format("-0700")

    // Format: +0800 2025-08-06 15:22:30 INFO main.go(180) | Descriptive message
    message := fmt.Sprintf("%s %s %s %s(%d) | %s",
        timezone,
        timestamp,
        record.Level.String(),
        file,
        line,
        record.Message)

    // Add attributes as context
    if record.NumAttrs() > 0 {
        var attrs []string
        record.Attrs(func(attr slog.Attr) bool {
            attrs = append(attrs, fmt.Sprintf("%s=%v", attr.Key, attr.Value))
            return true
        })
        if len(attrs) > 0 {
            message += fmt.Sprintf(" [%s]", strings.Join(attrs, " "))
        }
    }

    // Output to stdout
    fmt.Println(message)
    return nil
}

func (h *CustomHandler) Enabled(ctx context.Context, level slog.Level) bool {
    return h.handler.Enabled(ctx, level)
}

func (h *CustomHandler) WithAttrs(attrs []slog.Attr) slog.Handler {
    return &CustomHandler{handler: h.handler.WithAttrs(attrs)}
}

func (h *CustomHandler) WithGroup(name string) slog.Handler {
    return &CustomHandler{handler: h.handler.WithGroup(name)}
}

func NewLogger() *slog.Logger {
    handler := &CustomHandler{
        handler: slog.NewJSONHandler(os.Stdout, &slog.HandlerOptions{
            Level: slog.LevelInfo,
        }),
    }

    return slog.New(handler)
}

// Usage example
var logger = NewLogger()

func main() {
    // Basic logging
    logger.Info("Application started")

    // With context
    logger.Info("User logged in",
        slog.Int("user_id", 123),
        slog.String("ip_address", "192.168.1.1"))

    // Error logging
    logger.Error("Database connection failed",
        slog.String("database", "postgres"),
        slog.String("error_code", "08001"))

    // Request logging
    LogRequest("req-123", "GET", "/api/users", 200, 0.045)
}

func LogRequest(requestID, method, path string, statusCode int, duration time.Duration) {
    logger.Info("HTTP request completed",
        slog.String("request_id", requestID),
        slog.String("method", method),
        slog.String("path", path),
        slog.Int("status_code", statusCode),
        slog.Float64("duration_ms", float64(duration.Nanoseconds())/1e6))
}
```

### Shell Script Logging
```bash
#!/bin/bash

# Logging functions following required format
setup_logging() {
    local log_level="${LOG_LEVEL:-INFO}"
    local log_file="${LOG_FILE:-}"

    # Set up log file if specified
    if [[ -n "$log_file" ]]; then
        exec 1> >(tee -a "$log_file")
        exec 2> >(tee -a "$log_file" >&2)
    fi
}

log_message() {
    local level="$1"
    local message="$2"
    local context="$3"

    # Get caller information
    local caller_file="${BASH_SOURCE[2]:-unknown}"
    local caller_line="${BASH_LINENO[1]:-0}"
    local filename
    filename=$(basename "$caller_file")

    # Format timestamp
    local timestamp
    timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    local timezone
    timezone=$(date '+%z')

    # Build log message
    local log_entry="$timezone $timestamp $level $filename($caller_line) | $message"

    # Add context if provided
    if [[ -n "$context" ]]; then
        log_entry="$log_entry [$context]"
    fi

    # Output log entry
    echo "$log_entry"
}

log_debug() {
    [[ "${DEBUG:-false}" == "true" ]] && log_message "DEBUG" "$1" "$2"
}

log_info() {
    log_message "INFO" "$1" "$2"
}

log_warning() {
    log_message "WARN" "$1" "$2"
}

log_error() {
    log_message "ERROR" "$1" "$2" >&2
}

log_fatal() {
    log_message "FATAL" "$1" "$2" >&2
    exit 1
}

# Usage examples
setup_logging

log_info "Application started"

log_info "User logged in" "user_id=123 ip_address=192.168.1.1"
log_error "Database connection failed" "database=postgres error_code=08001"

log_debug("Processing request", "request_id=req-123 method=GET path=/api/users")
```

## Structured Logging Standards

### Log Context Standards
```python
# Context should include relevant identifiers and metrics
def log_user_action(action: str, user_id: int, **kwargs):
    """Log user action with standard context."""
    logger.info(f"User action: {action}",
                user_id=user_id,
                action=action,
                timestamp=datetime.utcnow().isoformat(),
                **kwargs)

def log_api_request(request_id: str, method: str, path: str,
                   status_code: int, duration: float, **kwargs):
    """Log API request with standard context."""
    logger.info("API request completed",
                request_id=request_id,
                method=method,
                path=path,
                status_code=status_code,
                duration_ms=duration * 1000,
                **kwargs)

def log_database_operation(operation: str, table: str, duration: float,
                          affected_rows: int = None, **kwargs):
    """Log database operation with standard context."""
    logger.debug(f"Database {operation}",
                operation=operation,
                table=table,
                duration_ms=duration * 1000,
                affected_rows=affected_rows,
                **kwargs)
```

### Error Logging Standards
```python
import traceback
from typing import Optional

def log_error_with_traceback(error: Exception, context: Optional[Dict] = None):
    """Log error with full traceback and context."""
    error_context = {
        "error_type": type(error).__name__,
        "error_message": str(error),
        "traceback": traceback.format_exc()
    }

    if context:
        error_context.update(context)

    logger.error("Error occurred", **error_context)

def log_validation_error(field: str, value: str, constraint: str, **context):
    """Log validation error with specific context."""
    logger.warning("Validation failed",
                  field=field,
                  value=value,
                  constraint=constraint,
                  **context)

def log_security_event(event_type: str, user_id: Optional[int] = None,
                      ip_address: Optional[str] = None, **context):
    """Log security event with audit context."""
    security_context = {
        "event_type": event_type,
        "user_id": user_id,
        "ip_address": ip_address,
        "timestamp": datetime.utcnow().isoformat()
    }
    security_context.update(context)

    logger.warning(f"Security event: {event_type}", **security_context)
```

## Performance Logging

### Performance Metrics Logging
```python
import time
from functools import wraps
from typing import Callable

def log_performance(operation_name: str):
    """Decorator to log performance metrics."""
    def decorator(func: Callable):
        @wraps(func)
        def wrapper(*args, **kwargs):
            start_time = time.time()
            try:
                result = func(*args, **kwargs)
                duration = time.time() - start_time
                logger.info(f"Operation completed: {operation_name}",
                           operation=operation_name,
                           duration_ms=duration * 1000,
                           success=True)
                return result
            except Exception as e:
                duration = time.time() - start_time
                logger.error(f"Operation failed: {operation_name}",
                           operation=operation_name,
                           duration_ms=duration * 1000,
                           success=False,
                           error_type=type(e).__name__,
                           error_message=str(e))
                raise
        return wrapper
    return decorator

# Usage
@log_performance("database_query")
def execute_query(query: str):
    # Execute database query
    pass

@log_performance("api_call")
def make_api_request(url: str):
    # Make API request
    pass
```

### Resource Usage Logging
```python
import psutil
import threading

class ResourceMonitor:
    """Monitor and log resource usage."""

    def __init__(self, interval: int = 60):
        self.interval = interval
        self.running = False

    def start_monitoring(self):
        """Start resource monitoring in background thread."""
        self.running = True
        thread = threading.Thread(target=self._monitor_loop, daemon=True)
        thread.start()

    def stop_monitoring(self):
        """Stop resource monitoring."""
        self.running = False

    def _monitor_loop(self):
        """Main monitoring loop."""
        while self.running:
            self._log_resource_usage()
            time.sleep(self.interval)

    def _log_resource_usage(self):
        """Log current resource usage."""
        cpu_percent = psutil.cpu_percent(interval=1)
        memory = psutil.virtual_memory()
        disk = psutil.disk_usage('/')

        logger.info("Resource usage snapshot",
                   cpu_percent=cpu_percent,
                   memory_percent=memory.percent,
                   memory_used_mb=memory.used // 1024 // 1024,
                   disk_percent=disk.percent,
                   disk_used_gb=disk.used // 1024 // 1024 // 1024)

# Usage
monitor = ResourceMonitor(interval=30)
monitor.start_monitoring()
```

## Configuration Management

### Logging Configuration
```python
# logging_config.py
import os
from typing import Dict, Any
from enum import Enum

class LogLevel(Enum):
    DEBUG = "DEBUG"
    INFO = "INFO"
    WARNING = "WARNING"
    ERROR = "ERROR"
    FATAL = "FATAL"

class LoggingConfig:
    """Centralized logging configuration."""

    def __init__(self):
        self.level = LogLevel(os.getenv('LOG_LEVEL', 'INFO'))
        self.format = os.getenv('LOG_FORMAT', 'structured')  # structured or json
        self.output = os.getenv('LOG_OUTPUT', 'console')  # console, file, both
        self.file_path = os.getenv('LOG_FILE_PATH', 'app.log')
        self.max_file_size = int(os.getenv('LOG_MAX_FILE_SIZE', '10485760'))  # 10MB
        self.backup_count = int(os.getenv('LOG_BACKUP_COUNT', '5'))
        self.enable_request_id = os.getenv('LOG_ENABLE_REQUEST_ID', 'true').lower() == 'true'
        self.include_hostname = os.getenv('LOG_INCLUDE_HOSTNAME', 'false').lower() == 'true'
        self.include_process_id = os.getenv('LOG_INCLUDE_PROCESS_ID', 'false').lower() == 'true'

    def to_dict(self) -> Dict[str, Any]:
        """Convert configuration to dictionary."""
        return {
            'level': self.level.value,
            'format': self.format,
            'output': self.output,
            'file_path': self.file_path,
            'max_file_size': self.max_file_size,
            'backup_count': self.backup_count,
            'enable_request_id': self.enable_request_id,
            'include_hostname': self.include_hostname,
            'include_process_id': self.include_process_id
        }

# Environment-specific configurations
def get_config_for_environment(env: str) -> LoggingConfig:
    """Get logging configuration for specific environment."""
    config = LoggingConfig()

    if env == 'development':
        config.level = LogLevel.DEBUG
        config.output = 'console'
        config.enable_request_id = True

    elif env == 'testing':
        config.level = LogLevel.WARNING
        config.output = 'console'

    elif env == 'staging':
        config.level = LogLevel.INFO
        config.output = 'both'
        config.enable_request_id = True
        config.include_hostname = True

    elif env == 'production':
        config.level = LogLevel.INFO
        config.output = 'file'
        config.enable_request_id = True
        config.include_hostname = True
        config.include_process_id = True

    return config
```

### Environment-Specific Configuration
```yaml
# config/logging.yml
development:
  level: DEBUG
  format: structured
  output: console
  enable_request_id: true
  include_hostname: false
  include_process_id: false

testing:
  level: WARNING
  format: structured
  output: console
  enable_request_id: false

staging:
  level: INFO
  format: json
  output: both
  file_path: /var/log/app/staging.log
  enable_request_id: true
  include_hostname: true
  include_process_id: true

production:
  level: INFO
  format: json
  output: file
  file_path: /var/log/app/production.log
  max_file_size: 52428800  # 50MB
  backup_count: 10
  enable_request_id: true
  include_hostname: true
  include_process_id: true
```

## Security and Compliance

### Security Logging Standards
```python
class SecurityLogger:
    """Specialized logger for security events."""

    def __init__(self):
        self.logger = StructuredLogger("security")

    def log_authentication_attempt(self, username: str, success: bool,
                                 ip_address: str, user_agent: str):
        """Log authentication attempt."""
        self.logger.info("Authentication attempt",
                        event_type="authentication",
                        username=username,
                        success=success,
                        ip_address=ip_address,
                        user_agent=user_agent)

    def log_authorization_failure(self, user_id: int, resource: str,
                                action: str, ip_address: str):
        """Log authorization failure."""
        self.logger.warning("Authorization failed",
                           event_type="authorization",
                           user_id=user_id,
                           resource=resource,
                           action=action,
                           ip_address=ip_address)

    def log_sensitive_data_access(self, user_id: int, data_type: str,
                                purpose: str):
        """Log access to sensitive data."""
        self.logger.info("Sensitive data accessed",
                        event_type="data_access",
                        user_id=user_id,
                        data_type=data_type,
                        purpose=purpose)

    def log_security_policy_violation(self, violation_type: str,
                                    user_id: Optional[int],
                                    details: Dict[str, Any]):
        """Log security policy violation."""
        self.logger.error("Security policy violation",
                         event_type="policy_violation",
                         violation_type=violation_type,
                         user_id=user_id,
                         **details)
```

### GDPR Compliance Logging
```python
class GDPRLogger:
    """Logger for GDPR compliance events."""

    def __init__(self):
        self.logger = StructuredLogger("gdpr")

    def log_consent_recorded(self, user_id: int, consent_type: str,
                           granted: bool, timestamp: datetime):
        """Record consent."""
        self.logger.info("Consent recorded",
                        event_type="consent",
                        user_id=user_id,
                        consent_type=consent_type,
                        granted=granted,
                        consent_timestamp=timestamp.isoformat())

    def log_data_processing(self, user_id: int, processing_type: str,
                          legal_basis: str, purpose: str):
        """Log data processing activity."""
        self.logger.info("Data processing",
                        event_type="data_processing",
                        user_id=user_id,
                        processing_type=processing_type,
                        legal_basis=legal_basis,
                        purpose=purpose)

    def log_data_access_request(self, request_id: str, user_id: int,
                              request_type: str):
        """Log data access request."""
        self.logger.info("Data access request",
                        event_type="access_request",
                        request_id=request_id,
                        user_id=user_id,
                        request_type=request_type)

    def log_data_deletion(self, user_id: int, data_types: List[str],
                        requester: str):
        """Log data deletion."""
        self.logger.info("Data deletion",
                        event_type="data_deletion",
                        user_id=user_id,
                        data_types=",".join(data_types),
                        requester=requester)
```

## Monitoring and Alerting

### Log-Based Monitoring
```python
class LogMonitor:
    """Monitor logs for specific patterns and trigger alerts."""

    def __init__(self):
        self.alert_thresholds = {
            'error_rate': 0.05,  # 5% error rate
            'response_time_p95': 1000,  # 1 second
            'memory_usage': 0.85,  # 85% memory usage
            'disk_usage': 0.90,  # 90% disk usage
        }

    def check_error_rate(self, logs: List[Dict], window_minutes: int = 5):
        """Check error rate within time window."""
        total_logs = len(logs)
        error_logs = sum(1 for log in logs if log.get('level') in ['ERROR', 'FATAL'])

        if total_logs > 0:
            error_rate = error_logs / total_logs
            if error_rate > self.alert_thresholds['error_rate']:
                self.trigger_alert('high_error_rate',
                                 f'Error rate: {error_rate:.2%} ({error_logs}/{total_logs})')

    def check_response_time(self, response_times: List[float]):
        """Check 95th percentile response time."""
        if response_times:
            sorted_times = sorted(response_times)
            p95_index = int(len(sorted_times) * 0.95)
            p95_time = sorted_times[min(p95_index, len(sorted_times) - 1)]

            if p95_time > self.alert_thresholds['response_time_p95']:
                self.trigger_alert('high_response_time',
                                 f'95th percentile response time: {p95_time:.0f}ms')

    def trigger_alert(self, alert_type: str, message: str):
        """Trigger alert."""
        logger.error("Alert triggered",
                    alert_type=alert_type,
                    message=message,
                    timestamp=datetime.utcnow().isoformat())

        # Send to monitoring system
        # send_to_monitoring_system(alert_type, message)
```

## Best Practices

### Do's and Don'ts

#### DO:
- Use structured logging with consistent format
- Include relevant context (user IDs, request IDs, correlation IDs)
- Log at appropriate levels (DEBUG for development, INFO for production)
- Use correlation IDs for request tracing
- Log security events and audit trails
- Include performance metrics in logs
- Use JSON format for machine parsing in production
- Implement log rotation and retention policies

#### DON'T:
- Log sensitive information (passwords, tokens, PII)
- Log excessive DEBUG messages in production
- Use different log formats inconsistently
- Include stack traces in user-facing error messages
- Log the same information multiple times
- Use logging for control flow (avoid log-based branching)
- Log in hot paths without considering performance impact
- Forget to implement proper log cleanup and archival