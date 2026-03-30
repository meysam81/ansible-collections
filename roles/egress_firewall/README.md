# egress_firewall

iptables enforcement ensuring [WireGuard](https://www.wireguard.com/) tunnel
traffic passes through [Squid](http://www.squid-cache.org/) proxy — no direct
egress possible.

Deploys persistent custom iptables chains via a systemd service. Only the
proxy user's outbound connections reach the internet; all direct forwarding
from the tunnel interface is dropped. Survives tunnel restarts and reboots
(fail-closed).

## Role Relationships

These roles are designed to compose on a WireGuard exit node. Each is
independently deployable — you can use any subset:

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
wireguard role — the egress_firewall role handles NAT (restricted to
the proxy user only).

## Install

### requirements.yml

```yaml
collections:
  - name: meysam81.general
    version: 1.11.0
```

## Usage

### Full exit node (WireGuard + Squid + enforcement + blocklists)

```yaml
---
- name: Playbook
  gather_facts: true
  become: true
  hosts: all
  roles:
    - name: meysam81.general.wireguard
      vars:
        wireguard_role: server
        wireguard_address: "10.99.0.1/24"
        wireguard_private_key: "{{ vault_wg_server_private_key }}"
        wireguard_nat_enabled: false  # egress_firewall handles NAT
        wireguard_peers:
          - public_key: "CLIENT_PUBLIC_KEY_HERE"
            allowed_ips: "10.99.0.2/32"

    - name: meysam81.general.squid
      vars:
        squid_listen_address: "10.99.0.1"
        squid_allowed_sources:
          - "10.99.0.0/24"
        squid_blocked_domains_file: /etc/egress-proxy/blocklists/urlhaus-domains.txt
        squid_blocked_ips_file: /etc/egress-proxy/blocklists/spamhaus-drop-cidrs.txt

    - name: meysam81.general.egress_firewall

    - name: meysam81.general.blocklist_updater
      vars:
        blocklist_updater_signal_process: squid
```

### With FORWARD exceptions (non-HTTP traffic)

```yaml
    - name: meysam81.general.egress_firewall
      vars:
        egress_firewall_forward_exceptions:
          - proto: tcp
            dport: 587
            comment: "SMTP to any destination"
          - proto: tcp
            dport: 587
            dest: "203.0.113.10/32"
            comment: "SMTP to specific relay only"
```

### With INPUT exceptions

```yaml
    - name: meysam81.general.egress_firewall
      vars:
        egress_firewall_input_exceptions:
          - proto: tcp
            dport: 9100
            comment: "Prometheus node exporter"
```

### With IPv6

```yaml
    - name: meysam81.general.egress_firewall
      vars:
        egress_firewall_ipv6_enabled: true
```

## Verify

From the exit node:

```bash
# View enforcement chains
iptables -L EGRESS-WG-INPUT -v -n
iptables -L EGRESS-WG-FORWARD -v -n
iptables -t nat -L EGRESS-WG-NAT -v -n

# Service status
systemctl status egress-firewall
```

From a tunnel client:

```bash
# Should succeed — goes through Squid
curl -x http://10.99.0.1:3128 https://ifconfig.me

# Should FAIL (timeout) — direct connection hits FORWARD DROP
curl --max-time 5 https://ifconfig.me

# Should also FAIL — non-HTTP port hits FORWARD DROP
nc -w 5 8.8.8.8 53
```

## How It Works

The role creates three custom iptables chains:

- **EGRESS-WG-INPUT** — allows tunnel traffic to reach Squid and DNS only, drops everything else
- **EGRESS-WG-FORWARD** — drops all direct forwarding from tunnel to internet (with optional exceptions)
- **EGRESS-WG-NAT** — MASQUERADE only for the proxy user's outbound connections

Jump rules from built-in chains to custom chains are managed idempotently
(`iptables -C` check before `-I` insert). Rules are loaded atomically via
`iptables-restore --noflush` so only the custom chains are affected — no
collision with UFW or other firewall tools.

iptables enforcement ensuring WireGuard tunnel traffic passes through Squid proxy — no direct egress possible

## Table of content

- [Requirements](#requirements)
- [Default Variables](#default-variables)
  - [egress_firewall_dns_port](#egress_firewall_dns_port)
  - [egress_firewall_forward_exceptions](#egress_firewall_forward_exceptions)
  - [egress_firewall_input_exceptions](#egress_firewall_input_exceptions)
  - [egress_firewall_ipv6_enabled](#egress_firewall_ipv6_enabled)
  - [egress_firewall_nat_interface](#egress_firewall_nat_interface)
  - [egress_firewall_proxy_port](#egress_firewall_proxy_port)
  - [egress_firewall_proxy_user](#egress_firewall_proxy_user)
  - [egress_firewall_tunnel_interface](#egress_firewall_tunnel_interface)
- [Dependencies](#dependencies)
- [License](#license)
- [Author](#author)

---

## Requirements

- Minimum Ansible version: `2.15`

## Default Variables

### egress_firewall_dns_port

#### Default value

```YAML
egress_firewall_dns_port: 53
```

### egress_firewall_forward_exceptions

#### Default value

```YAML
egress_firewall_forward_exceptions: []
```

### egress_firewall_input_exceptions

#### Default value

```YAML
egress_firewall_input_exceptions: []
```

### egress_firewall_ipv6_enabled

#### Default value

```YAML
egress_firewall_ipv6_enabled: false
```

### egress_firewall_nat_interface

#### Default value

```YAML
egress_firewall_nat_interface: eth0
```

### egress_firewall_proxy_port

#### Default value

```YAML
egress_firewall_proxy_port: 3128
```

### egress_firewall_proxy_user

#### Default value

```YAML
egress_firewall_proxy_user: proxy
```

### egress_firewall_tunnel_interface

#### Default value

```YAML
egress_firewall_tunnel_interface: wg0
```



## Dependencies

None.

## License

Apache-2.0

## Author

Meysam Azad
