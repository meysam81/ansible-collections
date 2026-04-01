# inbound_routing

Policy routing to preserve inbound reachability on hosts that use a full-tunnel
VPN (e.g. WireGuard `AllowedIPs = 0.0.0.0/0`). Installs a systemd oneshot
service that adds `ip rule` / `ip route` entries so replies to inbound
connections leave via the original public interface instead of the tunnel.

## Install

### requirements.yml

```yaml
collections:
  - name: meysam81.general
```

## Usage

### playbook.yml

```yaml
---
- name: Playbook
  gather_facts: true
  become: true
  hosts: all
  roles:
    - name: meysam81.general.inbound_routing
```

### Custom interface and priority

```yaml
    - name: meysam81.general.inbound_routing
      vars:
        inbound_routing_interface: ens3
        inbound_routing_priority: 5
```

### With IPv6

```yaml
    - name: meysam81.general.inbound_routing
      vars:
        inbound_routing_ipv6_enabled: true
```
