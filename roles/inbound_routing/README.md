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

Policy routing to preserve inbound reachability on hosts that use a full-tunnel VPN (e.g. WireGuard AllowedIPs = 0.0.0.0/0)

## Table of content

- [Requirements](#requirements)
- [Default Variables](#default-variables)
  - [inbound_routing_interface](#inbound_routing_interface)
  - [inbound_routing_ipv6_enabled](#inbound_routing_ipv6_enabled)
  - [inbound_routing_priority](#inbound_routing_priority)
  - [inbound_routing_tunnel_interface](#inbound_routing_tunnel_interface)
- [Dependencies](#dependencies)
- [License](#license)
- [Author](#author)

---

## Requirements

- Minimum Ansible version: `2.15`

## Default Variables

### inbound_routing_interface

#### Default value

```YAML
inbound_routing_interface: eth0
```

### inbound_routing_ipv6_enabled

#### Default value

```YAML
inbound_routing_ipv6_enabled: false
```

### inbound_routing_priority

#### Default value

```YAML
inbound_routing_priority: 10
```

### inbound_routing_tunnel_interface

#### Default value

```YAML
inbound_routing_tunnel_interface: wg0
```



## Dependencies

None.

## License

Apache-2.0

## Author

Meysam Azad
