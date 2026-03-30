# squid

Install and configure [Squid](http://www.squid-cache.org/) as a forward proxy
with ACL-based blocklist support, structured JSON access logging, and optional
[CrowdSec](https://www.crowdsec.net/) external ACL integration.

Designed to run on a WireGuard exit node, accepting tunnel traffic and applying
threat intelligence blocklists before forwarding to the internet.

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
        squid_blocked_domains_file: /etc/egress-proxy/blocklists/urlhaus-domains.txt
        squid_blocked_ips_file: /etc/egress-proxy/blocklists/spamhaus-drop-cidrs.txt
```

### With CrowdSec integration

```yaml
    - name: meysam81.general.squid
      vars:
        squid_crowdsec_enabled: true
        squid_crowdsec_lapi_url: "http://127.0.0.1:8080"
        squid_crowdsec_ttl: 120
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
