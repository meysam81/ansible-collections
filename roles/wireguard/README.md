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

### IPv6

This role enables only IPv4 forwarding (`net.ipv4.ip_forward`). For IPv6
tunnel traffic, add the IPv6 forwarding parameter via the `sysctl` role or
the escape hatches:

```yaml
wireguard_post_up_extra:
  - "sysctl -w net.ipv6.conf.all.forwarding=1"
```

Or use the `meysam81.general.sysctl` role alongside:

```yaml
sysctl_params:
  net.ipv6.conf.all.forwarding: 1
```

Install and configure WireGuard VPN tunnel with server (NAT gateway) and client (policy routing) modes

## Table of content

- [Requirements](#requirements)
- [Default Variables](#default-variables)
  - [wireguard_address](#wireguard_address)
  - [wireguard_health_check_enabled](#wireguard_health_check_enabled)
  - [wireguard_health_check_expected_ip](#wireguard_health_check_expected_ip)
  - [wireguard_health_check_interval](#wireguard_health_check_interval)
  - [wireguard_interface](#wireguard_interface)
  - [wireguard_ip_forward](#wireguard_ip_forward)
  - [wireguard_listen_port](#wireguard_listen_port)
  - [wireguard_nat_enabled](#wireguard_nat_enabled)
  - [wireguard_nat_interface](#wireguard_nat_interface)
  - [wireguard_nat_source](#wireguard_nat_source)
  - [wireguard_peers](#wireguard_peers)
  - [wireguard_post_down_extra](#wireguard_post_down_extra)
  - [wireguard_post_up_extra](#wireguard_post_up_extra)
  - [wireguard_private_key](#wireguard_private_key)
  - [wireguard_role](#wireguard_role)
- [Dependencies](#dependencies)
- [License](#license)
- [Author](#author)

---

## Requirements

- Minimum Ansible version: `2.15`

## Default Variables

### wireguard_address

#### Default value

```YAML
wireguard_address: ''
```

### wireguard_health_check_enabled

#### Default value

```YAML
wireguard_health_check_enabled: false
```

### wireguard_health_check_expected_ip

#### Default value

```YAML
wireguard_health_check_expected_ip: ''
```

### wireguard_health_check_interval

#### Default value

```YAML
wireguard_health_check_interval: 300
```

### wireguard_interface

#### Default value

```YAML
wireguard_interface: wg0
```

### wireguard_ip_forward

#### Default value

```YAML
wireguard_ip_forward: true
```

### wireguard_listen_port

#### Default value

```YAML
wireguard_listen_port: 51820
```

### wireguard_nat_enabled

#### Default value

```YAML
wireguard_nat_enabled: true
```

### wireguard_nat_interface

#### Default value

```YAML
wireguard_nat_interface: eth0
```

### wireguard_nat_source

#### Default value

```YAML
wireguard_nat_source: ''
```

### wireguard_peers

#### Default value

```YAML
wireguard_peers: []
```

### wireguard_post_down_extra

#### Default value

```YAML
wireguard_post_down_extra: []
```

### wireguard_post_up_extra

#### Default value

```YAML
wireguard_post_up_extra: []
```

### wireguard_private_key

#### Default value

```YAML
wireguard_private_key: ''
```

### wireguard_role

#### Default value

```YAML
wireguard_role: server
```



## Dependencies

None.

## License

Apache-2.0

## Author

Meysam Azad
