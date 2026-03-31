# squid

Install and configure [Squid](http://www.squid-cache.org/) as a production-hardened
forward proxy with multi-file blocklist support, structured JSON access logging,
and optional [CrowdSec](https://www.crowdsec.net/) external ACL integration.

Designed to run on a WireGuard exit node, accepting tunnel traffic and applying
threat intelligence blocklists before forwarding to the internet.

## Features

- **Security hardening** — stealth mode (strips Via, X-Forwarded-For, version),
  header access controls, Safe Ports/SSL Ports enforcement, TLS 1.2+ outbound,
  cache manager disabled
- **Multi-file blocklists** — accepts lists of domain and IP/CIDR blocklist files;
  Squid merges them into unified ACLs
- **Structured logging** — JSON access log at `/var/log/squid/access-json.log`
  for CrowdSec parsing, plus syslog for journalctl
- **Timeout tuning** — tight defaults for API traffic (30s connect, 2m request,
  5m read), retry on error, fast shutdown
- **DNS tuning** — local resolver support, tuned TTLs and cache sizes
- **Memory-only cache** — optional in-memory cache with GDSF replacement policy,
  no disk I/O
- **CrowdSec integration** — external ACL helper with fail-open/fail-closed modes

## Install

### requirements.yml

```yaml
collections:
  - name: meysam81.general
    version: 1.11.0
```

## Usage

### Minimal (localhost proxy)

```yaml
---
- name: Playbook
  gather_facts: true
  become: true
  hosts: all
  roles:
    - name: meysam81.general.squid
```

### WireGuard exit node with blocklists

```yaml
    - name: meysam81.general.squid
      vars:
        squid_listen_address: "10.99.0.1"
        squid_allowed_sources:
          - "10.99.0.0/24"
        squid_blocked_domains_files:
          - /etc/egress-proxy/blocklists/urlhaus-domains.txt
          - /etc/egress-proxy/blocklists/threatfox-domains.txt
        squid_blocked_ips_files:
          - /etc/egress-proxy/blocklists/spamhaus-drop-cidrs.txt
          - /etc/egress-proxy/blocklists/feodo-botnet-ips.txt
          - /etc/egress-proxy/blocklists/emergingthreats-ips.txt
          - /etc/egress-proxy/blocklists/firehol-level1.txt
```

### With CrowdSec integration

```yaml
    - name: meysam81.general.squid
      vars:
        squid_crowdsec_enabled: true
        squid_crowdsec_lapi_url: "http://127.0.0.1:8080"
        squid_crowdsec_ttl: 120
```

### Memory-only cache

```yaml
    - name: meysam81.general.squid
      vars:
        squid_cache_enabled: true
        squid_cache_mem: "512 MB"
        squid_max_object_size_in_memory: "2 MB"
```

### Custom ACLs and rules (escape hatch)

```yaml
    - name: meysam81.general.squid
      vars:
        squid_extra_acls:
          - "acl internal_nets src 192.168.0.0/16"
        squid_extra_rules:
          - "http_access allow internal_nets"
```

## Default Variables

### Network

| Variable | Default | Description |
|----------|---------|-------------|
| `squid_listen_address` | `127.0.0.1` | Bind address |
| `squid_listen_port` | `3128` | Bind port |
| `squid_allowed_sources` | `["10.99.0.0/24"]` | Allowed client CIDRs |
| `squid_workers` | `2` | Worker processes |

### Blocklists

| Variable | Default | Description |
|----------|---------|-------------|
| `squid_blocked_domains_files` | `[]` | List of domain blocklist file paths |
| `squid_blocked_ips_files` | `[]` | List of IP/CIDR blocklist file paths |

Multiple files are merged into a single ACL — Squid evaluates all files under
the same `blocked_domains` or `blocked_ips` ACL name.

### Security

| Variable | Default | Description |
|----------|---------|-------------|
| `squid_visible_hostname` | `proxy` | Hostname in error pages |
| `squid_request_body_max_size` | `64 MB` | Max upload body size |

Hardcoded: `via off`, `forwarded_for delete`, `httpd_suppress_version_string on`,
Safe Ports / SSL Ports enforcement, `tls_outgoing_options min-version=1.2`,
`cachemgr_passwd disable all`, `uri_whitespace encode`.

### Timeouts

| Variable | Default | Description |
|----------|---------|-------------|
| `squid_connect_timeout` | `30 seconds` | TCP connect timeout |
| `squid_forward_timeout` | `2 minutes` | Forwarding path timeout |
| `squid_request_timeout` | `2 minutes` | Request header timeout |
| `squid_request_start_timeout` | `30 seconds` | First byte timeout |
| `squid_read_timeout` | `5 minutes` | Data read inactivity timeout |
| `squid_client_lifetime` | `8 hours` | Max client connection lifetime |
| `squid_client_idle_pconn_timeout` | `1 minute` | Idle client keepalive |
| `squid_server_idle_pconn_timeout` | `30 seconds` | Idle upstream keepalive |
| `squid_pconn_lifetime` | `1 hour` | Max persistent connection age |
| `squid_shutdown_lifetime` | `10 seconds` | Grace period on restart |
| `squid_connect_retries` | `2` | TCP connect retry attempts (0-10) |

### Cache

| Variable | Default | Description |
|----------|---------|-------------|
| `squid_cache_enabled` | `false` | Enable memory-only cache |
| `squid_cache_mem` | `256 MB` | Memory cache size |
| `squid_max_object_size_in_memory` | `1 MB` | Max cached object size |

### Performance

| Variable | Default | Description |
|----------|---------|-------------|
| `squid_max_filedescriptors` | `65535` | Max file descriptors |
| `squid_client_ip_max_connections` | `200` | Per-IP connection limit |

### DNS

| Variable | Default | Description |
|----------|---------|-------------|
| `squid_dns_nameservers` | `127.0.0.1` | DNS resolver(s) |
| `squid_dns_timeout` | `10 seconds` | DNS query timeout |
| `squid_positive_dns_ttl` | `6 hours` | Successful DNS cache TTL |
| `squid_negative_dns_ttl` | `30 seconds` | Failed DNS cache TTL |
| `squid_ipcache_size` | `4096` | IP address cache entries |
| `squid_fqdncache_size` | `4096` | FQDN cache entries |

### CrowdSec

| Variable | Default | Description |
|----------|---------|-------------|
| `squid_crowdsec_enabled` | `false` | Enable CrowdSec external ACL |
| `squid_crowdsec_lapi_url` | `http://127.0.0.1:8080` | LAPI endpoint |
| `squid_crowdsec_ttl` | `60` | Decision cache TTL (seconds) |
| `squid_crowdsec_fail_mode` | `open` | `open` (allow) or `closed` (block) on LAPI failure |
| `squid_crowdsec_children_max` | `10` | Max helper processes |
| `squid_crowdsec_children_startup` | `2` | Initial helper processes |

### Escape Hatches

| Variable | Default | Description |
|----------|---------|-------------|
| `squid_extra_acls` | `[]` | Raw ACL lines injected before access rules |
| `squid_extra_rules` | `[]` | Raw `http_access` lines injected before allow/deny |

## Logging

The role configures dual access logging:

- **JSON file** at `/var/log/squid/access-json.log` — structured format for
  CrowdSec parsing and log aggregation
- **Syslog** — for `journalctl -u squid` convenience

JSON log fields: `time`, `client`, `method`, `url`, `status`, `size`,
`response_time`, `result`, `hierarchy`, `peer`, `mime`.

Query strings are stripped from logged URLs (`strip_query_terms on`).

## ACL Evaluation Order

```
1. deny !Safe_ports
2. deny CONNECT !SSL_ports
3. deny blocked_domains      (if squid_blocked_domains_files is non-empty)
4. deny blocked_ips           (if squid_blocked_ips_files is non-empty)
5. deny crowdsec_blocked      (if squid_crowdsec_enabled)
6. <squid_extra_rules>
7. allow wg_clients
8. deny all
```

## Related Roles

These roles compose on a WireGuard exit node — each is independently deployable:

```
┌─────────────┐     ┌──────────────────┐     ┌───────────┐
│  wireguard   │────▶│  egress_firewall  │────▶│   squid    │
│  (tunnel)    │     │  (enforcement)    │     │  (proxy)   │
└─────────────┘     └──────────────────┘     └───────────┘
                            │
                    ┌───────┴────────┐
                    │blocklist_updater│
                    │ (threat feeds)  │
                    └────────────────┘
```

| Role | Purpose | Standalone? |
|------|---------|-------------|
| `wireguard` | VPN tunnel (server or client) | Yes — works as plain VPN with its own NAT |
| `squid` | Forward proxy with ACL blocklists | Yes — works as localhost proxy |
| `egress_firewall` | iptables enforcement: tunnel → proxy only | No — requires wireguard + squid |
| `blocklist_updater` | Fetches threat intelligence feeds to disk | Yes — any consumer can read the files |

When composing all roles, set `wireguard_nat_enabled: false` on the
wireguard role — the `egress_firewall` role handles NAT (restricted to
the proxy user only).
