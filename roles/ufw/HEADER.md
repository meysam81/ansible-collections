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
