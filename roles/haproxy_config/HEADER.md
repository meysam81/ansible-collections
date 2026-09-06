# HAProxy

Deploy HAProxy with full config management, TLS termination, security headers,
CORS, rate limiting, and compression. Generic backend/route system — not tied
to any specific backend technology.

Depends on `haproxy_base` (user, dirs, error pages, systemd service).

## Safe by default

Defaults are tuned for production-grade public exposure:

- **TLS posture targets SSL Labs A+ / Mozilla "Modern intermediate":**
  TLS 1.2+1.3 only, ECDHE-only AEAD cipher list with `@SECLEVEL=2` (no DHE,
  no CBC, no SHA-1 in handshake or MAC), session tickets disabled,
  TLS_FALLBACK_SCSV honoured, OCSP stapling on by default.
- **Dual-stack bind by default:** the frontend listens on every IPv4 and
  every IPv6 address on the host. Override `haproxy_bind_addresses` to
  pin to specific NICs or disable a family.
- **Security headers default-on:** HSTS (2-year max-age, includeSubDomains,
  preload), CSP, COEP/COOP/CORP, X-Frame-Options, Referrer-Policy,
  Permissions-Policy. These apply to *every* response — backend, redirect,
  errorfile, and inline-responder — via `http-after-response`.
- **Rate limiting default-on** with conservative per-IP burst limits.

Loosening any of these is the caller's explicit decision via overrides.

> **HAProxy version:** OCSP stapling is enabled via the global
> `ocsp-update.mode on` directive, which requires HAProxy >= 3.0. Set
> `haproxy_ocsp_stapling_enabled: false` to use this role on older HAProxy.

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

### Stats

The stats/Prometheus frontend (`/metrics`, `/stats`) binds loopback only by
default. Set `haproxy_stats_bind_address` to a private-NIC address to let an
external scraper reach it:

```yaml
        haproxy_stats_bind_address: "192.0.2.10"  # private NIC, not loopback
        haproxy_stats_auth_user: "prometheus"
        haproxy_stats_auth_password: "{{ lookup('env', 'HAPROXY_STATS_PASSWORD') }}"
```

`stats auth` only protects `/stats` (the HAProxy stats page), and only when
`haproxy_stats_auth_password` is set — `/metrics` (the Prometheus exporter) is
**always unauthenticated**, regardless of that setting. A non-loopback
`haproxy_stats_bind_address` must therefore be a private NIC address
protected by a firewall, never a public one. Setting
`haproxy_stats_auth_user`/`haproxy_stats_auth_password` is recommended
whenever you bind off loopback, to keep `/stats` from being wide open too.
`haproxy.cfg` itself is written mode `0644`, so `haproxy_stats_auth_password`
is readable by any local user on the host and shows up in `--diff` output —
it is not a substitute for network-level protection. Prefer the
firewall + private-NIC posture above over relying on `stats auth` alone.

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

### WAF (Coraza) and CrowdSec IP ban

Both are SPOE filters fired **explicitly**, never on SPOE's own automatic
`event`. The frontend evaluates rules in this fixed order:

```
set-src (Cloudflare, if enabled)
  -> send-spoe-group coraza coraza-req      (if haproxy_coraza_enabled)
  -> return 403/503 on coraza.fail/error
  -> send-spoe-group crowdsec crowdsec-ip           (if haproxy_crowdsec_enabled)
  -> send-spoe-group crowdsec crowdsec-http-no-body
  -> return 403 on crowdsec.remediation == "ban"
```

Explicit firing (instead of SPOE's `event on-frontend-http-request`, which
fires before *any* of the frontend's own rules) is what makes a Cloudflare
`set-src` actually apply before the WAF/bouncer see the request — otherwise
both evaluate Cloudflare's edge IP instead of the real client IP. This block
renders at the same point in the frontend whether or not Cloudflare is
enabled, so the ordering guarantee holds either way (there is simply no
`set-src` to be "after" when Cloudflare is off).

```yaml
        haproxy_coraza_enabled: true                # meysam81.general.coraza deploys coraza.cfg
        haproxy_crowdsec_enabled: true               # meysam81.general.crowdsec_haproxy_bouncer deploys crowdsec.cfg
        haproxy_crowdsec_spoa_addr: "127.0.0.1"
        haproxy_crowdsec_spoa_port: 9001              # Coraza's SPOA owns 9000 on the same host
```

CrowdSec's ban response mirrors the upstream bouncer's own recipe: a 403
HTML page (`lf-file` from `haproxy_crowdsec_html_dir`) when the client's
`Accept` header can render HTML, otherwise plain text — no captcha, no
AppSec, both deferred. Fail-open: with `haproxy_crowdsec_enabled: false`
(the default) none of this renders — behaviour is identical to the role
without CrowdSec.

### Header logging

`haproxy_log_request_headers` (default `false`) gates capturing full
request/response headers — including `Authorization` and `Cookie`
verbatim — into the access log. Leave it off in production; the
Coraza-specific `spoa-error:`/`waf-hit:` log fields are independent and
still appear whenever `haproxy_coraza_enabled` is true.
