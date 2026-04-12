# HAProxy

Deploy HAProxy with full config management, TLS termination, security headers,
CORS, rate limiting, and compression. Generic backend/route system — not tied
to any specific backend technology.

Depends on `haproxy_base` (user, dirs, error pages, systemd service).

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

HAProxy with full config management, TLS, and security headers

## Table of contents

- [Requirements](#requirements)
- [Default Variables](#default-variables)
  - [haproxy_allow_options_all_origins](#haproxy_allow_options_all_origins)
  - [haproxy_alt_svc_enabled](#haproxy_alt_svc_enabled)
  - [haproxy_backends](#haproxy_backends)
  - [haproxy_blocked_extensions](#haproxy_blocked_extensions)
  - [haproxy_blocked_user_agents](#haproxy_blocked_user_agents)
  - [haproxy_bufsize](#haproxy_bufsize)
  - [haproxy_cache_control_default](#haproxy_cache_control_default)
  - [haproxy_cache_control_enabled](#haproxy_cache_control_enabled)
  - [haproxy_cache_control_hashed](#haproxy_cache_control_hashed)
  - [haproxy_cache_control_static](#haproxy_cache_control_static)
  - [haproxy_cdn_domains](#haproxy_cdn_domains)
  - [haproxy_cloudflare_bypass_hosts](#haproxy_cloudflare_bypass_hosts)
  - [haproxy_cloudflare_enabled](#haproxy_cloudflare_enabled)
  - [haproxy_cloudflare_ips_file](#haproxy_cloudflare_ips_file)
  - [haproxy_coep](#haproxy_coep)
  - [haproxy_compression_types](#haproxy_compression_types)
  - [haproxy_coop](#haproxy_coop)
  - [haproxy_coraza_enabled](#haproxy_coraza_enabled)
  - [haproxy_coraza_spoa_addr](#haproxy_coraza_spoa_addr)
  - [haproxy_coraza_spoa_port](#haproxy_coraza_spoa_port)
  - [haproxy_corp](#haproxy_corp)
  - [haproxy_cors_allow_credentials](#haproxy_cors_allow_credentials)
  - [haproxy_cors_allowed_domains](#haproxy_cors_allowed_domains)
  - [haproxy_cors_allowed_headers](#haproxy_cors_allowed_headers)
  - [haproxy_cors_allowed_methods](#haproxy_cors_allowed_methods)
  - [haproxy_cors_expose_headers](#haproxy_cors_expose_headers)
  - [haproxy_cors_max_age](#haproxy_cors_max_age)
  - [haproxy_cors_subdomain_patterns](#haproxy_cors_subdomain_patterns)
  - [haproxy_csp](#haproxy_csp)
  - [haproxy_defaults_extra](#haproxy_defaults_extra)
  - [haproxy_dh_param_bits](#haproxy_dh_param_bits)
  - [haproxy_frontend_extra_acls](#haproxy_frontend_extra_acls)
  - [haproxy_frontend_extra_rules](#haproxy_frontend_extra_rules)
  - [haproxy_global_extra](#haproxy_global_extra)
  - [haproxy_hashed_asset_regex](#haproxy_hashed_asset_regex)
  - [haproxy_honeypot_enabled](#haproxy_honeypot_enabled)
  - [haproxy_honeypot_fields](#haproxy_honeypot_fields)
  - [haproxy_hsts_include_subdomains](#haproxy_hsts_include_subdomains)
  - [haproxy_hsts_max_age](#haproxy_hsts_max_age)
  - [haproxy_hsts_preload](#haproxy_hsts_preload)
  - [haproxy_listen_sections](#haproxy_listen_sections)
  - [haproxy_maxconn](#haproxy_maxconn)
  - [haproxy_maxrewrite](#haproxy_maxrewrite)
  - [haproxy_option_forwardfor](#haproxy_option_forwardfor)
  - [haproxy_permissions_policy](#haproxy_permissions_policy)
  - [haproxy_rate_limit_api_count](#haproxy_rate_limit_api_count)
  - [haproxy_rate_limit_api_path_prefix](#haproxy_rate_limit_api_path_prefix)
  - [haproxy_rate_limit_api_period](#haproxy_rate_limit_api_period)
  - [haproxy_rate_limit_concurrent](#haproxy_rate_limit_concurrent)
  - [haproxy_rate_limit_conn_count](#haproxy_rate_limit_conn_count)
  - [haproxy_rate_limit_conn_period](#haproxy_rate_limit_conn_period)
  - [haproxy_rate_limit_http_req_count](#haproxy_rate_limit_http_req_count)
  - [haproxy_rate_limit_http_req_period](#haproxy_rate_limit_http_req_period)
  - [haproxy_rate_limiting_enabled](#haproxy_rate_limiting_enabled)
  - [haproxy_referrer_policy](#haproxy_referrer_policy)
  - [haproxy_routes](#haproxy_routes)
  - [haproxy_security_headers_enabled](#haproxy_security_headers_enabled)
  - [haproxy_ssl_cachesize](#haproxy_ssl_cachesize)
  - [haproxy_ssl_maxrecord](#haproxy_ssl_maxrecord)
  - [haproxy_static_extensions](#haproxy_static_extensions)
  - [haproxy_stats_auth_password](#haproxy_stats_auth_password)
  - [haproxy_stats_auth_user](#haproxy_stats_auth_user)
  - [haproxy_stats_port](#haproxy_stats_port)
  - [haproxy_threads](#haproxy_threads)
  - [haproxy_timeout_client](#haproxy_timeout_client)
  - [haproxy_timeout_connect](#haproxy_timeout_connect)
  - [haproxy_timeout_http_keep_alive](#haproxy_timeout_http_keep_alive)
  - [haproxy_timeout_http_request](#haproxy_timeout_http_request)
  - [haproxy_timeout_queue](#haproxy_timeout_queue)
  - [haproxy_timeout_server](#haproxy_timeout_server)
  - [haproxy_timeout_tunnel](#haproxy_timeout_tunnel)
  - [haproxy_tls_allow_dhe](#haproxy_tls_allow_dhe)
  - [haproxy_tls_ciphers](#haproxy_tls_ciphers)
  - [haproxy_tls_ciphersuites](#haproxy_tls_ciphersuites)
  - [haproxy_tls_min_version](#haproxy_tls_min_version)
  - [haproxy_tls_options](#haproxy_tls_options)
  - [haproxy_x_frame_options](#haproxy_x_frame_options)
  - [haproxy_x_xss_protection](#haproxy_x_xss_protection)
- [Dependencies](#dependencies)
- [License](#license)
- [Author](#author)

---

## Requirements

- Minimum Ansible version: `2.17`

## Default Variables

### haproxy_allow_options_all_origins

#### Default value

```YAML
haproxy_allow_options_all_origins: false
```

### haproxy_alt_svc_enabled

#### Default value

```YAML
haproxy_alt_svc_enabled: true
```

### haproxy_backends

#### Default value

```YAML
haproxy_backends: []
```

### haproxy_blocked_extensions

#### Default value

```YAML
haproxy_blocked_extensions:
  - php
  - asp
  - aspx
  - jsp
```

### haproxy_blocked_user_agents

#### Default value

```YAML
haproxy_blocked_user_agents:
  - nmap
  - nikto
  - sqlmap
  - dirb
  - masscan
```

### haproxy_bufsize

#### Default value

```YAML
haproxy_bufsize: 32768
```

### haproxy_cache_control_default

#### Default value

```YAML
haproxy_cache_control_default: no-cache
```

### haproxy_cache_control_enabled

#### Default value

```YAML
haproxy_cache_control_enabled: true
```

### haproxy_cache_control_hashed

#### Default value

```YAML
haproxy_cache_control_hashed: public, max-age=31536000, immutable
```

### haproxy_cache_control_static

#### Default value

```YAML
haproxy_cache_control_static: public, max-age=86400, must-revalidate
```

### haproxy_cdn_domains

#### Default value

```YAML
haproxy_cdn_domains: []
```

### haproxy_cloudflare_bypass_hosts

#### Default value

```YAML
haproxy_cloudflare_bypass_hosts: []
```

### haproxy_cloudflare_enabled

#### Default value

```YAML
haproxy_cloudflare_enabled: false
```

### haproxy_cloudflare_ips_file

#### Default value

```YAML
haproxy_cloudflare_ips_file: /etc/haproxy/cloudflare-ips.txt
```

### haproxy_coep

#### Default value

```YAML
haproxy_coep: unsafe-none
```

### haproxy_compression_types

#### Default value

```YAML
haproxy_compression_types:
  - text/html
  - text/plain
  - text/css
  - text/javascript
  - application/javascript
  - application/json
  - application/xml
  - image/svg+xml
  - application/wasm
  - application/manifest+json
```

### haproxy_coop

#### Default value

```YAML
haproxy_coop: same-origin
```

### haproxy_coraza_enabled

#### Default value

```YAML
haproxy_coraza_enabled: false
```

### haproxy_coraza_spoa_addr

#### Default value

```YAML
haproxy_coraza_spoa_addr: 127.0.0.1
```

### haproxy_coraza_spoa_port

#### Default value

```YAML
haproxy_coraza_spoa_port: 9000
```

### haproxy_corp

#### Default value

```YAML
haproxy_corp: same-site
```

### haproxy_cors_allow_credentials

#### Default value

```YAML
haproxy_cors_allow_credentials: true
```

### haproxy_cors_allowed_domains

#### Default value

```YAML
haproxy_cors_allowed_domains: []
```

### haproxy_cors_allowed_headers

#### Default value

```YAML
haproxy_cors_allowed_headers: Content-Type, Authorization, X-Requested-With, Accept, Origin, X-CSRF-Token, X-Unique-ID
```

### haproxy_cors_allowed_methods

#### Default value

```YAML
haproxy_cors_allowed_methods: GET, POST, PUT, PATCH, DELETE, OPTIONS
```

### haproxy_cors_expose_headers

#### Default value

```YAML
haproxy_cors_expose_headers: X-Unique-ID, X-Request-ID, Content-Length, Content-Type, Date
```

### haproxy_cors_max_age

#### Default value

```YAML
haproxy_cors_max_age: '3600'
```

### haproxy_cors_subdomain_patterns

#### Default value

```YAML
haproxy_cors_subdomain_patterns: []
```

### haproxy_csp

#### Default value

```YAML
haproxy_csp: >-
  default-src 'self' https:;
  style-src 'self' 'unsafe-inline' https:;
  img-src 'self' blob: data: https:;
  font-src 'self' data: https:;
  object-src 'none';
  upgrade-insecure-requests
```

### haproxy_defaults_extra

#### Default value

```YAML
haproxy_defaults_extra: []
```

### haproxy_dh_param_bits

#### Default value

```YAML
haproxy_dh_param_bits: 4096
```

### haproxy_frontend_extra_acls

#### Default value

```YAML
haproxy_frontend_extra_acls: []
```

### haproxy_frontend_extra_rules

#### Default value

```YAML
haproxy_frontend_extra_rules: []
```

### haproxy_global_extra

#### Default value

```YAML
haproxy_global_extra: []
```

### haproxy_hashed_asset_regex

#### Default value

```YAML
haproxy_hashed_asset_regex: (/|[.~_-])[A-Za-z0-9_-]{6,64}\\.(js|css|woff2?|ttf|png|jpe?g|gif|svg|webp|avif|ico|map)$
```

### haproxy_honeypot_enabled

#### Default value

```YAML
haproxy_honeypot_enabled: true
```

### haproxy_honeypot_fields

#### Default value

```YAML
haproxy_honeypot_fields:
  - name
  - company
  - website
```

### haproxy_hsts_include_subdomains

#### Default value

```YAML
haproxy_hsts_include_subdomains: true
```

### haproxy_hsts_max_age

#### Default value

```YAML
haproxy_hsts_max_age: 63072000
```

### haproxy_hsts_preload

#### Default value

```YAML
haproxy_hsts_preload: true
```

### haproxy_listen_sections

#### Default value

```YAML
haproxy_listen_sections: []
```

### haproxy_maxconn

#### Default value

```YAML
haproxy_maxconn: 4096
```

### haproxy_maxrewrite

#### Default value

```YAML
haproxy_maxrewrite: 8192
```

### haproxy_option_forwardfor

#### Default value

```YAML
haproxy_option_forwardfor: true
```

### haproxy_permissions_policy

#### Default value

```YAML
haproxy_permissions_policy: geolocation=(), microphone=(), camera=(), payment=(), usb=(), magnetometer=(), gyroscope=(), fullscreen=(self), sync-xhr=()
```

### haproxy_rate_limit_api_count

#### Default value

```YAML
haproxy_rate_limit_api_count: 200
```

### haproxy_rate_limit_api_path_prefix

#### Default value

```YAML
haproxy_rate_limit_api_path_prefix: /api/
```

### haproxy_rate_limit_api_period

#### Default value

```YAML
haproxy_rate_limit_api_period: 60
```

### haproxy_rate_limit_concurrent

#### Default value

```YAML
haproxy_rate_limit_concurrent: 20
```

### haproxy_rate_limit_conn_count

#### Default value

```YAML
haproxy_rate_limit_conn_count: 50
```

### haproxy_rate_limit_conn_period

#### Default value

```YAML
haproxy_rate_limit_conn_period: 10
```

### haproxy_rate_limit_http_req_count

#### Default value

```YAML
haproxy_rate_limit_http_req_count: 100
```

### haproxy_rate_limit_http_req_period

#### Default value

```YAML
haproxy_rate_limit_http_req_period: 10
```

### haproxy_rate_limiting_enabled

#### Default value

```YAML
haproxy_rate_limiting_enabled: true
```

### haproxy_referrer_policy

#### Default value

```YAML
haproxy_referrer_policy: strict-origin-when-cross-origin
```

### haproxy_routes

#### Default value

```YAML
haproxy_routes: []
```

### haproxy_security_headers_enabled

#### Default value

```YAML
haproxy_security_headers_enabled: true
```

### haproxy_ssl_cachesize

#### Default value

```YAML
haproxy_ssl_cachesize: 100000
```

### haproxy_ssl_maxrecord

#### Default value

```YAML
haproxy_ssl_maxrecord: 1460
```

### haproxy_static_extensions

#### Default value

```YAML
haproxy_static_extensions:
  - js
  - css
  - woff
  - woff2
  - ttf
  - eot
  - svg
  - png
  - jpg
  - jpeg
  - gif
  - ico
  - webp
  - avif
```

### haproxy_stats_auth_password

#### Default value

```YAML
haproxy_stats_auth_password: ''
```

### haproxy_stats_auth_user

#### Default value

```YAML
haproxy_stats_auth_user: ''
```

### haproxy_stats_port

#### Default value

```YAML
haproxy_stats_port: 8404
```

### haproxy_threads

#### Default value

```YAML
haproxy_threads: "{{ ansible_facts['processor_vcpus'] }}"
```

### haproxy_timeout_client

#### Default value

```YAML
haproxy_timeout_client: 50s
```

### haproxy_timeout_connect

#### Default value

```YAML
haproxy_timeout_connect: 5s
```

### haproxy_timeout_http_keep_alive

#### Default value

```YAML
haproxy_timeout_http_keep_alive: 15s
```

### haproxy_timeout_http_request

#### Default value

```YAML
haproxy_timeout_http_request: 15s
```

### haproxy_timeout_queue

#### Default value

```YAML
haproxy_timeout_queue: 30s
```

### haproxy_timeout_server

#### Default value

```YAML
haproxy_timeout_server: 50s
```

### haproxy_timeout_tunnel

#### Default value

```YAML
haproxy_timeout_tunnel: 3600s
```

### haproxy_tls_allow_dhe

#### Default value

```YAML
haproxy_tls_allow_dhe: true
```

### haproxy_tls_ciphers

#### Default value

```YAML
haproxy_tls_ciphers: >-
  ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:DHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384
```

### haproxy_tls_ciphersuites

#### Default value

```YAML
haproxy_tls_ciphersuites: TLS_AES_128_GCM_SHA256:TLS_AES_256_GCM_SHA384:TLS_CHACHA20_POLY1305_SHA256
```

### haproxy_tls_min_version

#### Default value

```YAML
haproxy_tls_min_version: TLSv1.2
```

### haproxy_tls_options

#### Default value

```YAML
haproxy_tls_options: no-tls-tickets
```

### haproxy_x_frame_options

#### Default value

```YAML
haproxy_x_frame_options: SAMEORIGIN
```

### haproxy_x_xss_protection

#### Default value

```YAML
haproxy_x_xss_protection: 1; mode=block
```

## Dependencies

None.

## License

Apache-2.0

## Author

Meysam Azad
