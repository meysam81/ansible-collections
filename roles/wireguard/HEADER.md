# wireguard

Install and configure a [WireGuard](https://www.wireguard.com/) VPN tunnel.
Supports two modes: **server** (exit node with NAT masquerade) and **client**
(production server routing traffic through the tunnel).

Installs `wireguard-tools`, manages the interface configuration, and optionally
deploys an egress IP health check timer.

## Install

### requirements.yml

```yaml
collections:
  - name: meysam81.general
    version: 1.11.0
```

## Key Generation

### Shell

```bash
wg genkey | tee privatekey | wg pubkey > publickey
```

### Ansible Vault (inline)

```bash
ansible-vault encrypt_string "$(wg genkey)" --name wireguard_private_key
```

### Ansible Vault (file)

```bash
wg genkey > /path/to/wg-private.key
ansible-vault encrypt /path/to/wg-private.key
```

Then reference in your playbook:

```yaml
wireguard_private_key: "{{ lookup('file', '/path/to/wg-private.key') }}"
```

## Usage

### Server (exit node with NAT)

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
        wireguard_nat_interface: eth0
        wireguard_nat_source: "10.99.0.0/24"
        wireguard_peers:
          - public_key: "CLIENT_PUBLIC_KEY_HERE"
            allowed_ips: "10.99.0.2/32"
```

### Client (production server)

```yaml
        wireguard_role: client
        wireguard_address: "10.99.0.2/24"
        wireguard_private_key: "{{ vault_wg_client_private_key }}"
        wireguard_peers:
          - public_key: "SERVER_PUBLIC_KEY_HERE"
            endpoint: "203.0.113.50:51820"
            allowed_ips: "0.0.0.0/0"
            persistent_keepalive: 25
```

### Client with policy routing (selective egress)

```yaml
        wireguard_role: client
        wireguard_address: "10.99.0.2/24"
        wireguard_private_key: "{{ vault_wg_client_private_key }}"
        wireguard_peers:
          - public_key: "SERVER_PUBLIC_KEY_HERE"
            endpoint: "203.0.113.50:51820"
            allowed_ips: "0.0.0.0/0"
            persistent_keepalive: 25
        wireguard_post_up_extra:
          - "ip rule add fwmark 1 table 100"
          - "ip route add default via 10.99.0.1 dev wg0 table 100"
          - "iptables -t mangle -A OUTPUT -s 10.42.0.0/16 -j MARK --set-mark 1"
          - "iptables -t mangle -I OUTPUT -d 10.0.0.0/8 -j RETURN"
          - "iptables -t mangle -I OUTPUT -d 172.16.0.0/12 -j RETURN"
          - "iptables -t mangle -I OUTPUT -d 192.168.0.0/16 -j RETURN"
          - "iptables -A OUTPUT -m mark --mark 1 ! -o wg0 -j DROP"
        wireguard_post_down_extra:
          - "ip rule del fwmark 1 table 100 || true"
          - "iptables -t mangle -D OUTPUT -s 10.42.0.0/16 -j MARK --set-mark 1 || true"
          - "iptables -D OUTPUT -m mark --mark 1 ! -o wg0 -j DROP || true"
```

### With health check

```yaml
        wireguard_health_check_enabled: true
        wireguard_health_check_expected_ip: "203.0.113.50"
        wireguard_health_check_interval: 300
```

### Hub-and-spoke scaling (multiple clients)

Add peers to the server's `wireguard_peers` list. Each entry gets its own
`[Peer]` block. Config changes use `wg syncconf` to hot-reload peers without
dropping existing tunnels.

```yaml
        wireguard_role: server
        wireguard_address: "10.99.0.1/24"
        wireguard_private_key: "{{ vault_wg_server_private_key }}"
        wireguard_nat_source: "10.99.0.0/24"
        wireguard_peers:
          - name: "us-east-1"
            public_key: "{{ vault_wg_peer1_pubkey }}"
            allowed_ips: "10.99.0.2/32"
          - name: "eu-west-1"
            public_key: "{{ vault_wg_peer2_pubkey }}"
            allowed_ips: "10.99.0.3/32"
          - name: "ap-south-1"
            public_key: "{{ vault_wg_peer3_pubkey }}"
            allowed_ips: "10.99.0.4/32"
            preshared_key: "{{ vault_wg_psk_ap_south }}"
```

**To add a new node:**

1. Generate a keypair: `wg genkey | tee privatekey | wg pubkey > publickey`
2. Append a peer entry with its public key and a unique IP
3. Run the playbook against the server — `wg syncconf` applies the change live

**Note:** Interface-level changes (address, listen port, NAT rules) still
require a full service restart: `systemctl restart wg-quick@wg0`.

### Server (dual-stack exit node)

```yaml
        wireguard_role: server
        wireguard_address: "10.99.0.1/24, fd00:99::1/64"
        wireguard_private_key: "{{ vault_wg_server_private_key }}"
        wireguard_nat_interface: eth0
        wireguard_nat_source: "10.99.0.0/24"
        wireguard_nat_source_ipv6: "fd00:99::/64"
        wireguard_peers:
          - public_key: "CLIENT_PUBLIC_KEY_HERE"
            allowed_ips: "10.99.0.2/32, fd00:99::2/128"
```

### Client (dual-stack full tunnel)

```yaml
        wireguard_role: client
        wireguard_address: "10.99.0.2/24, fd00:99::2/64"
        wireguard_private_key: "{{ vault_wg_client_private_key }}"
        wireguard_peers:
          - public_key: "SERVER_PUBLIC_KEY_HERE"
            endpoint: "203.0.113.50:51820"
            allowed_ips: "0.0.0.0/0, ::/0"
            persistent_keepalive: 25
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
