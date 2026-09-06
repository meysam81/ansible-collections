# crowdsec_firewall_bouncer

Install the [CrowdSec firewall bouncer](https://github.com/crowdsecurity/cs-firewall-bouncer)
(nftables by default, iptables optional) for host-wide IP remediation: every
CrowdSec decision (local scenarios + CAPI blocklists) becomes a drop rule at
the packet-filter level, in front of every listening port.

This role is independent of `crowdsec_haproxy_bouncer` — that one blocks at
the HTTP/TCP layer inside HAProxy; this one blocks at the kernel firewall,
covering ports HAProxy never sees (SSH, DNS, etc). Run both together for
full coverage on an edge host.

Standalone by design (own apt repo tasks, duplicated from `crowdsec_agent`)
so it can be consumed on its own via Galaxy — but it needs a local or
reachable LAPI to pull decisions from, normally provided by `crowdsec_agent`
on the same host.

## What this role does NOT do

- Does not touch `ufw` or any other firewall tool's rules. The bouncer
  installs its own nftables table (`crowdsec`/`crowdsec6`) at a negative
  priority (`crowdsec_firewall_bouncer_nftables_priority`, default `-10`),
  which coexists with `ufw`'s own tables rather than replacing them.
- Does not generate a CrowdSec API key itself. The package's postinst
  already does this via `cscli bouncers add` when `cscli`/`crowdsec` is
  present at install time; this role slurps that key back out of the
  config file the postinst wrote and reuses it. Set
  `crowdsec_firewall_bouncer_api_key` explicitly for a remote/central LAPI
  this host cannot self-register against.

## Install

### requirements.yml

```yaml
collections:
  - name: meysam81.general
    version: 1.12.0
```

## Usage

### Default (local LAPI, nftables backend)

```yaml
---
- name: Playbook
  gather_facts: true
  become: true
  hosts: all
  roles:
    - name: meysam81.general.crowdsec_agent
    - name: meysam81.general.crowdsec_firewall_bouncer
```

### Remote LAPI with an explicit API key

```yaml
    - name: meysam81.general.crowdsec_firewall_bouncer
      vars:
        crowdsec_firewall_bouncer_api_url: "http://192.0.2.10:8080/"
        crowdsec_firewall_bouncer_api_key: "{{ vault_crowdsec_bouncer_key }}"
```

### iptables backend

```yaml
    - name: meysam81.general.crowdsec_firewall_bouncer
      vars:
        crowdsec_firewall_bouncer_backend: iptables
```

## Default Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `crowdsec_firewall_bouncer_api_key` | `""` | API key for the local LAPI. Empty slurps the key the package postinst auto-registered. |
| `crowdsec_firewall_bouncer_api_url` | `http://127.0.0.1:8080/` | LAPI base URL to pull decisions from. |
| `crowdsec_firewall_bouncer_apt_codename` | detected release, `trixie` mapped to `bookworm` | apt suite codename. |
| `crowdsec_firewall_bouncer_backend` | `nftables` | `nftables` or `iptables`; also selects the apt package suffix. |
| `crowdsec_firewall_bouncer_deny_action` | `DROP` | Action applied to banned traffic (`DROP` or `REJECT`). |
| `crowdsec_firewall_bouncer_deny_log` | `true` | Log denied packets via the kernel (`dmesg`/journal). |
| `crowdsec_firewall_bouncer_deny_log_prefix` | `"crowdsec: "` | Prefix on kernel log lines for denied packets. |
| `crowdsec_firewall_bouncer_disable_ipv6` | `false` | Skip IPv6 decisions and the `crowdsec6` nftables table entirely. |
| `crowdsec_firewall_bouncer_hooks` | `[input, forward]` | Netfilter hooks the crowdsec chain attaches to (uppercased for the iptables backend). |
| `crowdsec_firewall_bouncer_log_level` | `info` | Bouncer log verbosity. |
| `crowdsec_firewall_bouncer_nftables_priority` | `-10` | Priority of the crowdsec table's base chains; negative runs before the default filter table. |
| `crowdsec_firewall_bouncer_prometheus_enabled` | `true` | Expose Prometheus metrics. |
| `crowdsec_firewall_bouncer_prometheus_listen_addr` | `127.0.0.1` | Prometheus metrics bind address. |
| `crowdsec_firewall_bouncer_prometheus_listen_port` | `60601` | Prometheus metrics bind port. |
| `crowdsec_firewall_bouncer_update_frequency` | `10s` | How often the bouncer polls the LAPI for new decisions. |

Install the CrowdSec firewall bouncer (nftables/iptables) for host-wide IP remediation

## Table of contents

- [Requirements](#requirements)
- [Default Variables](#default-variables)
  - [crowdsec_firewall_bouncer_api_key](#crowdsec_firewall_bouncer_api_key)
  - [crowdsec_firewall_bouncer_api_url](#crowdsec_firewall_bouncer_api_url)
  - [crowdsec_firewall_bouncer_apt_codename](#crowdsec_firewall_bouncer_apt_codename)
  - [crowdsec_firewall_bouncer_backend](#crowdsec_firewall_bouncer_backend)
  - [crowdsec_firewall_bouncer_deny_action](#crowdsec_firewall_bouncer_deny_action)
  - [crowdsec_firewall_bouncer_deny_log](#crowdsec_firewall_bouncer_deny_log)
  - [crowdsec_firewall_bouncer_deny_log_prefix](#crowdsec_firewall_bouncer_deny_log_prefix)
  - [crowdsec_firewall_bouncer_disable_ipv6](#crowdsec_firewall_bouncer_disable_ipv6)
  - [crowdsec_firewall_bouncer_hooks](#crowdsec_firewall_bouncer_hooks)
  - [crowdsec_firewall_bouncer_log_level](#crowdsec_firewall_bouncer_log_level)
  - [crowdsec_firewall_bouncer_nftables_priority](#crowdsec_firewall_bouncer_nftables_priority)
  - [crowdsec_firewall_bouncer_prometheus_enabled](#crowdsec_firewall_bouncer_prometheus_enabled)
  - [crowdsec_firewall_bouncer_prometheus_listen_addr](#crowdsec_firewall_bouncer_prometheus_listen_addr)
  - [crowdsec_firewall_bouncer_prometheus_listen_port](#crowdsec_firewall_bouncer_prometheus_listen_port)
  - [crowdsec_firewall_bouncer_update_frequency](#crowdsec_firewall_bouncer_update_frequency)
- [Dependencies](#dependencies)
- [License](#license)
- [Author](#author)

---

## Requirements

- Minimum Ansible version: `2.15`

## Default Variables

### crowdsec_firewall_bouncer_api_key

#### Default value

```YAML
crowdsec_firewall_bouncer_api_key: ''
```

### crowdsec_firewall_bouncer_api_url

#### Default value

```YAML
crowdsec_firewall_bouncer_api_url: http://127.0.0.1:8080/
```

### crowdsec_firewall_bouncer_apt_codename

#### Default value

```YAML
crowdsec_firewall_bouncer_apt_codename: "{{ {'trixie': 'bookworm'}[ansible_facts['distribution_release']] | default(ansible_facts['distribution_release']) }}"
```

### crowdsec_firewall_bouncer_backend

#### Default value

```YAML
crowdsec_firewall_bouncer_backend: nftables
```

### crowdsec_firewall_bouncer_deny_action

#### Default value

```YAML
crowdsec_firewall_bouncer_deny_action: DROP
```

### crowdsec_firewall_bouncer_deny_log

#### Default value

```YAML
crowdsec_firewall_bouncer_deny_log: true
```

### crowdsec_firewall_bouncer_deny_log_prefix

#### Default value

```YAML
crowdsec_firewall_bouncer_deny_log_prefix: 'crowdsec: '
```

### crowdsec_firewall_bouncer_disable_ipv6

#### Default value

```YAML
crowdsec_firewall_bouncer_disable_ipv6: false
```

### crowdsec_firewall_bouncer_hooks

#### Default value

```YAML
crowdsec_firewall_bouncer_hooks:
  - input
  - forward
```

### crowdsec_firewall_bouncer_log_level

#### Default value

```YAML
crowdsec_firewall_bouncer_log_level: info
```

### crowdsec_firewall_bouncer_nftables_priority

#### Default value

```YAML
crowdsec_firewall_bouncer_nftables_priority: -10
```

### crowdsec_firewall_bouncer_prometheus_enabled

#### Default value

```YAML
crowdsec_firewall_bouncer_prometheus_enabled: true
```

### crowdsec_firewall_bouncer_prometheus_listen_addr

#### Default value

```YAML
crowdsec_firewall_bouncer_prometheus_listen_addr: 127.0.0.1
```

### crowdsec_firewall_bouncer_prometheus_listen_port

#### Default value

```YAML
crowdsec_firewall_bouncer_prometheus_listen_port: 60601
```

### crowdsec_firewall_bouncer_update_frequency

#### Default value

```YAML
crowdsec_firewall_bouncer_update_frequency: 10s
```

## Dependencies

None.

## License

Apache-2.0

## Author

Meysam Azad
