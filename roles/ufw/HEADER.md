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

**Sysctl side effect:** `ufw enable` re-applies `/etc/ufw/sysctl.conf`
(several net.ipv4/net.ipv6 sysctls — log_martians, accept_redirects,
icmp_echo_ignore_broadcasts, ...) on **every** run, not just the first
disabled->enabled transition. If another role or policy also manages
overlapping sysctl keys, ufw's re-apply on every idempotent run will
silently fight it — set `ufw_manage_sysctl: false` to stop ufw from
touching sysctls at all and let the other policy be authoritative.
