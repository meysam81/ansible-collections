# HAProxy

Deploy HAProxy with full config management, TLS termination, security headers,
CORS, rate limiting, and compression. Generic backend/route system — not tied
to any specific backend technology.

Depends on `haproxy_build` (builds from source automatically).

## Install

### requirements.yml

```yaml
collections:
  - name: meysam81.general
    version: 1.11.0
```

## Usage

### Minimal (single backend)

```yaml
---
- name: Playbook
  gather_facts: true
  become: true
  hosts: all
  roles:
    - name: meysam81.general.haproxy
      vars:
        haproxy_backends:
          - name: app
            servers:
              - { name: sv0, address: "127.0.0.1", port: 3000 }
        haproxy_routes:
          - match: { host: "app.example.com" }
            backend: app
```

### Multi-backend with path routing

```yaml
        haproxy_backends:
          - name: frontend
            servers:
              - { name: sv0, address: "10.0.0.1", port: 3000 }
          - name: api
            servers:
              - { name: sv0, address: "10.0.0.2", port: 8080 }
              - { name: sv1, address: "10.0.0.3", port: 8080 }
            balance: roundrobin
            health_check: "GET /health"
        haproxy_routes:
          - match: { host: "app.example.com" }
            backend: frontend
          - match: { host: "api.example.com" }
            backend: api
```

### TCP passthrough (e.g. K8s API server)

```yaml
        haproxy_listen_sections:
          - name: apiserver
            bind: ":6443"
            mode: tcp
            servers:
              - { name: k8s, address: "127.0.0.1", port: 6443 }
            rate_limit:
              conn_rate: 10
              conn_cur: 5
```

### Feature flags

All horizontal features (security headers, rate limiting, cache control) are
enabled by default. Cloudflare enforcement is opt-in:

```yaml
        haproxy_cloudflare_enabled: false      # default
        haproxy_rate_limiting_enabled: true     # default
        haproxy_security_headers_enabled: true  # default
        haproxy_cache_control_enabled: true     # default
```

### Escape hatches

Inject raw HAProxy config lines into specific sections:

```yaml
        haproxy_global_extra:
          - "ssl-dh-param-file /etc/haproxy/dhparam.pem"
        haproxy_frontend_extra_acls:
          - "acl is_websocket hdr(Upgrade) -i websocket"
        haproxy_frontend_extra_rules:
          - "use_backend ws if is_websocket"
```
