# ufw

Declarative [UFW](https://wiki.ubuntu.com/UncomplicatedFirewall) firewall
management. Installs UFW, sets default policies, applies firewall rules, and
enables the firewall.

## Install

### requirements.yml

```yaml
collections:
  - name: meysam81.general
    version: 1.11.0
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
    - name: meysam81.general.ufw
      vars:
        ufw_rules:
          - { rule: allow, port: "22", proto: tcp, comment: "SSH" }
          - { rule: allow, port: "80", proto: tcp, comment: "HTTP" }
          - { rule: allow, port: "443", proto: tcp, comment: "HTTPS" }
```

### WireGuard exit node + restricted SSH

```yaml
        ufw_rules:
          - { rule: allow, port: "51820", proto: udp, comment: "WireGuard" }
          - { rule: allow, port: "22", proto: tcp, from_ip: "10.0.0.0/8", comment: "SSH from private" }
```

### Reset all rules before applying

```yaml
        ufw_reset_before_apply: true
        ufw_rules:
          - { rule: allow, port: "22", proto: tcp, comment: "SSH" }
```

## Safety Notes

**SSH lockout risk:** The default incoming policy is `deny`. If you do not
include a rule allowing SSH (port 22), you **will be locked out** of remote
hosts. Always include an SSH allow rule:

```yaml
ufw_rules:
  - { rule: allow, port: "22", proto: tcp, comment: "SSH" }
```

**Reset behaviour:** Setting `ufw_reset_before_apply: true` deletes **all**
existing rules and briefly disables the firewall before re-applying. If the
play fails mid-run, the host may be left with no firewall rules. Only use this
on hosts where you can recover access through an out-of-band console.

**Stale rules:** This role only _adds_ rules. Removing a rule from
`ufw_rules` and re-running will **not** delete it from the host. Use
`ufw_reset_before_apply: true` to converge to the exact declared rule set.

Declarative UFW firewall management with default policies and rule sets

## Table of content

- [Requirements](#requirements)
- [Default Variables](#default-variables)
  - [ufw_default_incoming](#ufw_default_incoming)
  - [ufw_default_outgoing](#ufw_default_outgoing)
  - [ufw_enabled](#ufw_enabled)
  - [ufw_logging](#ufw_logging)
  - [ufw_reset_before_apply](#ufw_reset_before_apply)
  - [ufw_rules](#ufw_rules)
- [Dependencies](#dependencies)
- [License](#license)
- [Author](#author)

---

## Requirements

- Minimum Ansible version: `2.15`

## Default Variables

### ufw_default_incoming

#### Default value

```YAML
ufw_default_incoming: deny
```

### ufw_default_outgoing

#### Default value

```YAML
ufw_default_outgoing: allow
```

### ufw_enabled

#### Default value

```YAML
ufw_enabled: true
```

### ufw_logging

#### Default value

```YAML
ufw_logging: low
```

### ufw_reset_before_apply

#### Default value

```YAML
ufw_reset_before_apply: false
```

### ufw_rules

#### Default value

```YAML
ufw_rules: []
```



## Dependencies

None.

## License

Apache-2.0

## Author

Meysam Azad
