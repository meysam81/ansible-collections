# microsocks

Build and deploy [microsocks](https://github.com/rofl0r/microsocks) as a
lightweight, production-hardened SOCKS5 proxy with systemd hardening.

Designed as a distro-independent alternative to
[Dante](https://www.inet.no/dante/) for environments where the
`dante-server` package is unavailable (e.g. Debian trixie). Builds from
source — the only dependency is `build-essential`.

Best paired with the `egress_firewall` role, which provides iptables-level
port allowlisting and private destination blocking via the OUTPUT chain.

## Features

- **Build from source** — pin to any git tag; no distro package required
- **systemd hardening** — `NoNewPrivileges`, `ProtectSystem=strict`,
  restricted syscalls, locked capabilities
- **Optional authentication** — username/password via CLI flags (not
  needed when behind WireGuard — tunnel provides implicit auth)
- **Logging** — stdout captured by journald

## Role Relationships

```
┌─────────────┐     ┌──────────────────┐     ┌─────────────┐
│  wireguard   │────▶│  egress_firewall  │────▶│    squid     │
│  (tunnel)    │     │  (enforcement)    │     │   (HTTP)     │
└─────────────┘     └──────────────────┘     ├─────────────┤
                            │                 │ microsocks   │
                    ┌───────┴────────┐        │  (SOCKS5)    │
                    │blocklist_updater│        └─────────────┘
                    │ (threat feeds)  │
                    └────────────────┘
```

## Install

### requirements.yml

```yaml
collections:
  - name: meysam81.general
```

## Usage

### Minimal (localhost SOCKS proxy)

```yaml
- name: meysam81.general.microsocks
```

### WireGuard exit node

```yaml
- name: meysam81.general.microsocks
  vars:
    microsocks_listen_address: "::"
```

### With authentication

```yaml
- name: meysam81.general.microsocks
  vars:
    microsocks_auth_user: proxyuser
    microsocks_auth_password: "{{ vault_socks_password }}"
```

### Full egress stack (with port allowlisting)

```yaml
- name: meysam81.general.microsocks
  vars:
    microsocks_listen_address: "::"

- name: meysam81.general.egress_firewall
  vars:
    egress_firewall_socks_enabled: true
    egress_firewall_socks_allowed_ports:
      - 22    # SSH / git
      - 443   # HTTPS
      - 465   # SMTPS
      - 587   # SMTP submission
      - 993   # IMAPS
      - 995   # POP3S
```

## Verify

```bash
# Service status
systemctl status microsocks
journalctl -u microsocks -f

# Is it listening?
ss -tlnp | grep 1080

# Test from tunnel client
curl -x socks5h://10.99.0.1:1080 https://ifconfig.me
ssh -o ProxyCommand='nc -X 5 -x 10.99.0.1:1080 %h %p' git@github.com
```

## Limitations

- **TCP only** — microsocks does not support UDP relay (SOCKS5 UDP ASSOCIATE)
- **No native ACLs** — use `egress_firewall` for port allowlisting and
  private destination blocking
- **Single bind address** — microsocks accepts one `-i` flag; use `::` for
  dual-stack
- **No config file** — all configuration via systemd unit (CLI flags)

Build and deploy microsocks as a lightweight SOCKS5 proxy with systemd hardening

## Table of contents

- [Requirements](#requirements)
- [Default Variables](#default-variables)
  - [microsocks_auth_password](#microsocks_auth_password)
  - [microsocks_auth_user](#microsocks_auth_user)
  - [microsocks_listen_address](#microsocks_listen_address)
  - [microsocks_listen_port](#microsocks_listen_port)
  - [microsocks_user](#microsocks_user)
  - [microsocks_version](#microsocks_version)
- [Dependencies](#dependencies)
- [License](#license)
- [Author](#author)

---

## Requirements

- Minimum Ansible version: `2.15`

## Default Variables

### microsocks_auth_password

#### Default value

```YAML
microsocks_auth_password: ''
```

### microsocks_auth_user

#### Default value

```YAML
microsocks_auth_user: ''
```

### microsocks_listen_address

#### Default value

```YAML
microsocks_listen_address: '::'
```

### microsocks_listen_port

#### Default value

```YAML
microsocks_listen_port: 1080
```

### microsocks_user

#### Default value

```YAML
microsocks_user: sockd
```

### microsocks_version

#### Default value

```YAML
microsocks_version: v1.0.5
```

## Dependencies

None.

## License

Apache-2.0

## Author

Meysam Azad
