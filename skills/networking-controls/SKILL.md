---
skill: networking-controls
description: Network security and connectivity standards. Use when networking controls
  guidance is required.
---

# Network Security Implementation

## Firewall and Access Control

### Firewall Rule Configuration

Implement secure firewall policies:
- Default deny stance for all traffic
- Explicit allow rules for required services only
- Network segmentation between security zones
- Regular firewall rule audits and cleanup

Firewall rule standards:
```yaml
# Example firewall configuration
firewall_rules:
  # Inbound rules
  inbound:
    - port: 22
      source: "10.0.0.0/8"  # Internal network only
      action: "allow"
      description: "SSH from internal network"

    - port: 443
      source: "0.0.0.0/0"   # HTTPS globally
      action: "allow"
      description: "Public HTTPS access"

  # Outbound rules
  outbound:
    - port: 53
      destination: "8.8.8.8/32"   # DNS specific servers
      action: "allow"
      description: "DNS resolution"

    - port: 443
      destination: "0.0.0.0/0"   # HTTPS globally
      action: "allow"
      description: "External API access"
```

### Network Segmentation Implementation

Apply zero-trust network principles:
- Create security zones based on data sensitivity
- Implement strict access controls between zones
- Use network ACLs for micro-segmentation
- Apply least privilege access for all network flows

Security zone configuration:
```bash
#!/bin/bash
# Network security zone setup

# Create security zones
create_security_zone() {
    local zone_name="$1"
    local network_range="$2"
    local description="$3"

    # Configure network segment
    ip route add "$network_range" dev "zone-$zone_name"

    # Apply security policies
    iptables -A FORWARD -s "$network_range" -j ZONE_"$zone_name"
    iptables -A ZONE_"$zone_name" -j DROP
}

# Define security zones
create_security_zone "dmz" "192.168.100.0/24" "Public-facing services"
create_security_zone "app" "10.0.10.0/24" "Application servers"
create_security_zone "db" "10.0.20.0/24" "Database servers"
```

## Secure Service Communication

### TLS/mTLS Implementation

Implement encrypted communication for all services:
- Use TLS 1.3 or higher for all external communications
- Implement mutual TLS (mTLS) for service-to-service communication
- Configure proper certificate validation and rotation
- Apply perfect forward secrecy ciphers

TLS configuration standards:
```nginx
# Nginx TLS configuration example
server {
    listen 443 ssl http2;
    server_name api.example.com;

    # TLS certificates
    ssl_certificate /etc/ssl/certs/api.crt;
    ssl_certificate_key /etc/ssl/private/api.key;

    # TLS 1.3 only
    ssl_protocols TLSv1.3;

    # Strong cipher suites
    ssl_ciphers TLS_AES_256_GCM_SHA384:TLS_CHACHA20_POLY1305_SHA256;

    # HSTS enforcement
    add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;

    # mTLS for internal services
    ssl_client_certificate /etc/ssl/certs/ca.crt;
    ssl_verify_client on;
}

# Service mesh mTLS configuration
apiVersion: security.istio.io/v1beta1
kind: PeerAuthentication
metadata:
  name: default
  namespace: production
spec:
  mtls:
    mode: STRICT
```

### Service Mesh Security

Implement service mesh for secure communication:
- Deploy service mesh with automatic mTLS
- Configure fine-grained access policies
- Implement service-to-service authentication
- Apply network policies for additional security

Service mesh security policies:
```yaml
# Istio authorization policy
apiVersion: security.istio.io/v1beta1
kind: AuthorizationPolicy
metadata:
  name: api-access-policy
  namespace: production
spec:
  selector:
    matchLabels:
      app: api-service
  rules:
  - from:
    - source:
        principals: ["cluster.local/ns/frontend/sa/frontend-sa"]
  - to:
    - operation:
        methods: ["GET", "POST"]
        paths: ["/api/v1/*"]
```

## Connection Management Optimization

### Connection Pooling Configuration

Implement efficient connection management:
- Configure appropriate connection pool sizes
- Set connection timeouts and keep-alive settings
- Implement connection draining for graceful shutdown
- Monitor connection pool utilization

Connection pool configuration examples:
```python
# PostgreSQL connection pool configuration
import psycopg2
from psycopg2 import pool

# Create connection pool
connection_pool = psycopg2.pool.ThreadedConnectionPool(
    minconn=5,
    maxconn=20,
    host="db.example.com",
    database="app_db",
    user="app_user",
    password="secure_password",
    connect_timeout=10,
    options="-c statement_timeout=30000"
)

# Redis connection pool configuration
import redis
redis_pool = redis.ConnectionPool(
    host="redis.example.com",
    port=6379,
    password="redis_password",
    max_connections=50,
    socket_connect_timeout=5,
    socket_timeout=30,
    retry_on_timeout=True
)
```

### Timeout and Backoff Configuration

Apply appropriate timeout and retry policies:
- Set realistic connection timeouts
- Implement exponential backoff for retries
- Configure circuit breaker patterns
- Apply jitter to prevent thundering herd

Timeout and retry configuration:
```python
import time
from typing import Callable, Any

# Exponential backoff implementation
def exponential_backoff_retry(
    func: Callable,
    max_retries: int = 3,
    base_delay: float = 1.0,
    max_delay: float = 60.0,
    backoff_factor: float = 2.0
) -> Any:
    retry_count = 0
    current_delay = base_delay

    while retry_count < max_retries:
        try:
            return func()
        except Exception as e:
            retry_count += 1
            if retry_count >= max_retries:
                raise e

            # Add jitter to prevent thundering herd
            jitter = current_delay * 0.1 * (time.time() % 1)
            sleep_time = min(current_delay + jitter, max_delay)

            time.sleep(sleep_time)
            current_delay *= backoff_factor

# Circuit breaker implementation
class CircuitBreaker:
    def __init__(self, failure_threshold: int = 5, timeout: int = 60):
        self.failure_threshold = failure_threshold
        self.timeout = timeout
        self.failure_count = 0
        self.last_failure_time = None
        self.state = "CLOSED"  # CLOSED, OPEN, HALF_OPEN

    def call(self, func: Callable, *args, kwargs):
        if self.state == "OPEN":
            if time.time() - self.last_failure_time > self.timeout:
                self.state = "HALF_OPEN"
            else:
                raise Exception("Circuit breaker is OPEN")

        try:
            result = func(*args, kwargs)
            if self.state == "HALF_OPEN":
                self.state = "CLOSED"
                self.failure_count = 0
            return result
        except Exception as e:
            self.failure_count += 1
            self.last_failure_time = time.time()

            if self.failure_count >= self.failure_threshold:
                self.state = "OPEN"

            raise e
```

## Network Performance Optimization

### Load Balancing Configuration

Implement optimal load balancing strategies:
- Use health checks for backend service monitoring
- Apply appropriate load balancing algorithms
- Implement session affinity when required
- Configure geographic load balancing for global services

Load balancer configuration:
```yaml
# Kubernetes service with load balancing
apiVersion: v1
kind: Service
metadata:
  name: web-service
  annotations:
    service.beta.kubernetes.io/aws-load-balancer-type: "nlb"
spec:
  selector:
    app: web-app
  ports:
  - port: 80
    targetPort: 8080
  type: LoadBalancer

# Health check configuration
apiVersion: v1
kind: Pod
metadata:
  name: web-app
spec:
  containers:
  - name: web-app
    image: nginx:latest
    ports:
    - containerPort: 8080
    livenessProbe:
      httpGet:
        path: /health
        port: 8080
      initialDelaySeconds: 30
      periodSeconds: 10
    readinessProbe:
      httpGet:
        path: /ready
        port: 8080
      initialDelaySeconds: 5
      periodSeconds: 5
```

### Caching and CDN Integration

Implement comprehensive caching strategy:
- Configure reverse proxy caching for static content
- Deploy CDN for global content delivery
- Apply application-level caching for dynamic content
- Implement cache invalidation policies

Caching configuration:
```nginx
# Nginx reverse proxy caching
proxy_cache_path /var/cache/nginx levels=1:2 keys_zone=my_cache:10m max_size=10g
                 inactive=60m use_temp_path=off;

server {
    listen 443 ssl;
    server_name api.example.com;

    # Enable caching
    proxy_cache my_cache;
    proxy_cache_valid 200 302 10m;
    proxy_cache_valid 404 1m;

    # Cache key configuration
    proxy_cache_key "$scheme$request_method$host$request_uri";

    # Bypass cache for specific requests
    proxy_cache_bypass $http_authorization;
    proxy_no_cache $http_authorization;

    location /api/ {
        proxy_pass http://backend_servers;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
}
```

## Network Monitoring and Observability

### Network Metrics Collection

Implement comprehensive network monitoring:
- Monitor bandwidth utilization and throughput
- Track connection counts and response times
- Collect error rates and timeout statistics
- Monitor security events and anomalous traffic

Monitoring configuration:
```yaml
# Prometheus network monitoring rules
groups:
- name: network.rules
  rules:
  - alert: HighBandwidthUsage
    expr: rate(container_network_transmit_bytes_total[5m]) / 1024 / 1024 > 100
    for: 2m
    labels:
      severity: warning
    annotations:
      summary: "High bandwidth usage detected"
      description: "Network transmit rate is {{ $value }} MB/s"

  - alert: ConnectionPoolExhaustion
    expr: db_connections_active / db_connections_max > 0.9
    for: 1m
    labels:
      severity: critical
    annotations:
      summary: "Database connection pool nearly exhausted"
      description: "Connection pool usage is {{ $value | humanizePercentage }}"
```

### Network Security Monitoring

Implement security event monitoring:
- Monitor firewall rule hits and denials
- Track unusual traffic patterns and anomalies
- Collect DDoS attack indicators
- Monitor authentication failures and access violations

Security monitoring setup:
```bash
#!/bin/bash
# Network security monitoring script

# Monitor failed SSH connections
monitor_ssh_failures() {
    journalctl -u sshd --since "1 hour ago" | grep "Failed password" | \
        awk '{print $1, $2, $3, $11, $13}' | \
        sort | uniq -c | sort -nr
}

# Monitor unusual traffic patterns
monitor_traffic_anomalies() {
    # Check for port scanning
    nmap -sS -p 1-65535 192.168.1.0/24 --open

    # Monitor connection spikes
    netstat -an | grep :80 | awk '{print $5}' | cut -d: -f1 | sort | uniq -c | sort -nr
}

# Generate security report
generate_security_report() {
    echo "=== Network Security Report ==="
    echo "Timestamp: $(date)"
    echo ""

    echo "Failed SSH attempts:"
    monitor_ssh_failures
    echo ""

    echo "Top traffic sources:"
    monitor_traffic_anomalies | head -10
    echo ""

    echo "Firewall log summary:"
    tail -n 1000 /var/log/iptables.log | grep DROP | wc -l
}
```