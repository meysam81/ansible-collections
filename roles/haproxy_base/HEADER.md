# HAProxy Base

Shared HAProxy infrastructure: system user, config/cert/error directories, custom error pages, and systemd service unit.

Depends on `haproxy_build` (compiles HAProxy from source).

Satellite roles (`haproxy`, `haproxy_tls_certificate`, `cloudflare_ips`, `coraza`, `crowdsec_haproxy_bouncer`) depend on this role instead of depending on the full `haproxy` config role.
