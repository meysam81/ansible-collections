# dante

Install and configure [Dante](https://www.inet.no/dante/) as a
production-hardened SOCKS5 proxy with destination port allowlisting,
source IP ACLs, and structured logging.

Designed to run alongside [Squid](http://www.squid-cache.org/) on a
WireGuard exit node — Squid handles HTTP/HTTPS, Dante handles non-HTTP
protocols (SSH, IMAPS, SMTPS, etc.).

## Features

- **Port allowlisting** — only explicitly permitted destination ports are
  reachable; default deny all others
- **Source IP ACLs** — restrict access to WireGuard tunnel subnet (no
  password auth needed — WG tunnel provides implicit authentication)
- **Private destination blocking** — blocks connections to RFC1918,
  loopback, and link-local ranges
- **Logging** — per-rule connect/disconnect/error logging to file + syslog
- **Log rotation** — daily rotation with 30-day retention, SIGHUP reopen
- **systemd hardening** — `NoNewPrivileges`, `ProtectSystem=strict`,
  restricted syscalls, locked capabilities

## Install

### requirements.yml

```yaml
collections:
  - name: meysam81.general
    version: 1.12.0
```

## Usage

### Minimal (localhost SOCKS proxy)

```yaml
---
- name: Playbook
  gather_facts: true
  become: true
  hosts: all
  roles:
    - name: meysam81.general.dante
      vars:
        dante_external_interface: eth0
```

### WireGuard exit node

```yaml
    - name: meysam81.general.dante
      vars:
        dante_listen_addresses:
          - "10.99.0.1"
        dante_allowed_sources:
          - "10.99.0.0/24"
        dante_external_interface: eth0
```

### Custom port allowlist

```yaml
    - name: meysam81.general.dante
      vars:
        dante_external_interface: eth0
        dante_listen_addresses:
          - "10.99.0.1"
        dante_allowed_sources:
          - "10.99.0.0/24"
        dante_allowed_ports:
          - 22    # SSH / git
          - 993   # IMAPS
```

### Full egress stack (WireGuard + Squid + Dante + enforcement)

```yaml
    - name: meysam81.general.wireguard
      vars:
        wireguard_role: server
        wireguard_address: "10.99.0.1/24"
        wireguard_private_key: "{{ vault_wg_server_private_key }}"
        wireguard_nat_enabled: false

    - name: meysam81.general.squid
      vars:
        squid_listen_addresses:
          - "10.99.0.1"
        squid_allowed_sources:
          - "10.99.0.0/24"

    - name: meysam81.general.dante
      vars:
        dante_external_interface: eth0
        dante_listen_addresses:
          - "10.99.0.1"
        dante_allowed_sources:
          - "10.99.0.0/24"

    - name: meysam81.general.egress_firewall
      vars:
        egress_firewall_socks_enabled: true
```

## ACL Evaluation Order

```
1. client pass from allowed_sources    (source IP check)
2. client block all                    (reject unknown sources)
3. socks block to 127.0.0.0/8         (loopback)
4. socks block to RFC1918 + link-local (if dante_block_private_destinations)
5. socks pass per allowed port         (one rule per dante_allowed_ports entry)
6. socks block all                     (default deny)
```

## Known Limitations

- **No file-based IP blocklists** — unlike Squid, Dante has no file-based ACL
  mechanism. IP-level threat feed blocking should be handled at the iptables
  layer if needed.
- **No domain-based ACLs** — SOCKS5 operates at the IP level. Clients using
  `socks5h://` send hostnames, but Dante resolves them to IPs before applying
  rules.

## Related Roles

```plaintext
┌─────────────┐     ┌──────────────────┐     ┌───────────┐
│  wireguard  │────▶│  egress_firewall │────▶│   squid   │
│  (tunnel)   │     │  (enforcement)   │     │  (HTTP)   │
└─────────────┘     └──────────────────┘     ├───────────┤
                            │                │   dante   │
                    ┌───────┴─────────┐       │  (SOCKS5) │
                    │blocklist_updater│      └───────────┘
                    │ (threat feeds)  │
                    └─────────────────┘
```

| Role | Purpose | Standalone? |
|------|---------|-------------|
| `wireguard` | VPN tunnel (server or client) | Yes |
| `squid` | HTTP/HTTPS forward proxy | Yes |
| `dante` | SOCKS5 proxy for non-HTTP traffic | Yes |
| `egress_firewall` | iptables enforcement: tunnel → proxy only | No — requires wireguard + squid/dante |
| `blocklist_updater` | Fetches threat intelligence feeds | Yes |

## Verify

From the exit node:

```bash
# Verify dante is listening
ss -tlnp | grep 1080

# Check config syntax
danted -Vf /etc/danted.conf

# Service status
systemctl status danted

# View recent logs
tail -f /var/log/danted.log
```

From a tunnel client:

```bash
# SSH via SOCKS (should succeed — port 22 allowed)
ssh -o ProxyCommand='nc -X 5 -x 10.99.0.1:1080 %h %p' git@github.com

# git clone via SOCKS
ALL_PROXY=socks5h://10.99.0.1:1080 git clone git@github.com:user/repo.git

# curl via SOCKS (should succeed — port 443 allowed)
curl -x socks5h://10.99.0.1:1080 https://ifconfig.me

# Blocked port (should fail — port 8080 not in allowlist)
nc -X 5 -x 10.99.0.1:1080 example.com 8080
```

Install and configure Dante SOCKS5 proxy with port allowlisting and source ACLs

## Table of contents

- [Requirements](#requirements)
- [Default Variables](#default-variables)
  - [dante_allowed_ports](#dante_allowed_ports)
  - [dante_allowed_sources](#dante_allowed_sources)
  - [dante_block_private_destinations](#dante_block_private_destinations)
  - [dante_error_log](#dante_error_log)
  - [dante_external_interface](#dante_external_interface)
  - [dante_listen_addresses](#dante_listen_addresses)
  - [dante_listen_port](#dante_listen_port)
  - [dante_log_connect](#dante_log_connect)
  - [dante_log_disconnect](#dante_log_disconnect)
  - [dante_log_error](#dante_log_error)
  - [dante_log_file](#dante_log_file)
  - [dante_source_sha256](#dante_source_sha256)
  - [dante_source_url](#dante_source_url)
  - [dante_timeout_connect](#dante_timeout_connect)
  - [dante_timeout_io](#dante_timeout_io)
  - [dante_timeout_negotiate](#dante_timeout_negotiate)
  - [dante_user](#dante_user)
  - [dante_version](#dante_version)
- [Dependencies](#dependencies)
- [License](#license)
- [Author](#author)

---

## Requirements

- Minimum Ansible version: `2.15`

## Default Variables

### dante_allowed_ports

#### Default value

```YAML
dante_allowed_ports:
  - 22
  - 443
  - 465
  - 587
  - 993
  - 995
```

### dante_allowed_sources

#### Default value

```YAML
dante_allowed_sources: []
```

### dante_block_private_destinations

#### Default value

```YAML
dante_block_private_destinations: true
```

### dante_error_log

#### Default value

```YAML
dante_error_log: syslog/daemon
```

### dante_external_interface

#### Default value

```YAML
dante_external_interface: '{{ ansible_default_ipv4.address }}'
```

### dante_listen_addresses

#### Default value

```YAML
dante_listen_addresses:
  - 127.0.0.1
  - ::1
```

### dante_listen_port

#### Default value

```YAML
dante_listen_port: 1080
```

### dante_log_connect

#### Default value

```YAML
dante_log_connect: true
```

### dante_log_disconnect

#### Default value

```YAML
dante_log_disconnect: true
```

### dante_log_error

#### Default value

```YAML
dante_log_error: true
```

### dante_log_file

#### Default value

```YAML
dante_log_file: /var/log/danted.log
```

### dante_source_sha256

#### Default value

```YAML
dante_source_sha256: 1973c7732f1f9f0a4c0ccf2c1ce462c7c25060b25643ea90f9b98f53a813faec
```

### dante_source_url

#### Default value

```YAML
dante_source_url: https://www.inet.no/dante/files/dante-{{ dante_version }}.tar.gz
```

### dante_timeout_connect

#### Default value

```YAML
dante_timeout_connect: 30
```

### dante_timeout_io

#### Default value

```YAML
dante_timeout_io: 86400
```

### dante_timeout_negotiate

#### Default value

```YAML
dante_timeout_negotiate: 30
```

### dante_user

#### Default value

```YAML
dante_user: sockd
```

### dante_version

#### Default value

```YAML
dante_version: 1.4.4
```

## Dependencies

None.

## License

Apache-2.0

## Author

Meysam Azad
