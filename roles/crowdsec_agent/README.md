# crowdsec_agent

Install the [CrowdSec](https://www.crowdsec.net/) Security Engine (agent
daemon) with configurable acquisition sources and threat detection collections.

This role installs the CrowdSec agent that parses log files and detects
threats. It is separate from bouncer roles (e.g. `crowdsec_haproxy_bouncer`) —
the agent feeds the Local API (LAPI) that bouncers query.

## Install

### requirements.yml

```yaml
collections:
  - name: meysam81.general
    version: 1.11.0
```

## Usage

### Default (linux + iptables collections)

```yaml
---
- name: Playbook
  gather_facts: true
  become: true
  hosts: all
  roles:
    - name: meysam81.general.crowdsec_agent
```

### With Squid log acquisition

```yaml
    - name: meysam81.general.crowdsec_agent
      vars:
        crowdsec_agent_acquis_extra:
          - filename: /var/log/squid/access-json.log
            labels:
              type: squid-egress
```

### With console enrollment

```yaml
    - name: meysam81.general.crowdsec_agent
      vars:
        crowdsec_agent_enrollment_key: "{{ vault_crowdsec_enrollment_key }}"
```

### Custom collections

```yaml
    - name: meysam81.general.crowdsec_agent
      vars:
        crowdsec_agent_collections:
          - crowdsecurity/iptables
          - crowdsecurity/linux
```

### journald acquisition (sshd, haproxy, postfix, dovecot, ...)

One file is written per entry under `/etc/crowdsec/acquis.d/`, independent
of `crowdsec_agent_acquis_extra` (which still targets a single file for
file-based sources). `type` is the `labels.type` value the matching
CrowdSec parser expects (`sshd`, `haproxy`, `syslog`, ...).

```yaml
    - name: meysam81.general.crowdsec_agent
      vars:
        crowdsec_agent_collections:
          - crowdsecurity/sshd
          - crowdsecurity/haproxy
        crowdsec_agent_journal_acquisitions:
          - name: sshd
            type: sshd
            units: [ssh.service]
          - name: haproxy
            type: haproxy
            units: [haproxy.service]
          - name: postfix
            type: syslog
            identifiers: [postfix/smtpd, postfix/smtp]
```

### Whitelist own infrastructure

Never let a scenario ban traffic from your own VLAN, loopback, or
monitoring egress — regardless of which collections are installed.

```yaml
    - name: meysam81.general.crowdsec_agent
      vars:
        crowdsec_agent_whitelist_cidrs:
          - "172.16.0.0/16"
          - "10.0.0.0/8"
        crowdsec_agent_whitelist_ips:
          - "192.0.2.1"
```

### Prometheus metrics and LAPI listen address

Both are rendered into `/etc/crowdsec/config.yaml.local`, an overlay
CrowdSec merges over the packaged `config.yaml` — this role never edits
`config.yaml` itself, so it stays idempotent over a host where CrowdSec
was already installed and configured by hand.

```yaml
    - name: meysam81.general.crowdsec_agent
      vars:
        crowdsec_agent_prometheus_listen_addr: "127.0.0.1"
        crowdsec_agent_prometheus_listen_port: 6060
        crowdsec_agent_lapi_listen: "127.0.0.1:8080"
```

## Default Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `crowdsec_agent_acquis_extra` | `[]` | Extra file-based acquisition sources, all written to one file (`crowdsec_agent_acquis_filename`). |
| `crowdsec_agent_acquis_filename` | `egress` | Filename (without extension) for `crowdsec_agent_acquis_extra` under `/etc/crowdsec/acquis.d/`. |
| `crowdsec_agent_apt_codename` | detected release, `trixie` mapped to `bookworm` | apt suite codename; override for other releases the upstream repo lacks. |
| `crowdsec_agent_collections` | `[crowdsecurity/linux, crowdsecurity/iptables]` | CrowdSec hub collections to install. |
| `crowdsec_agent_enrollment_key` | `""` | Console enrollment key. Empty disables enrollment. |
| `crowdsec_agent_journal_acquisitions` | `[]` | journald acquisition sources; one `/etc/crowdsec/acquis.d/<name>.yaml` per entry. See usage above. |
| `crowdsec_agent_lapi_listen` | `127.0.0.1:8080` | LAPI listen address, rendered into `config.yaml.local`. |
| `crowdsec_agent_prometheus_enabled` | `true` | Expose CrowdSec's Prometheus metrics endpoint. |
| `crowdsec_agent_prometheus_level` | `full` | Metrics detail: `full` (bucket/parser/scenario metrics) or `aggregated`. |
| `crowdsec_agent_prometheus_listen_addr` | `127.0.0.1` | Prometheus metrics bind address. |
| `crowdsec_agent_prometheus_listen_port` | `6060` | Prometheus metrics bind port. |
| `crowdsec_agent_whitelist_cidrs` | `[]` | CIDRs CrowdSec must never ban. |
| `crowdsec_agent_whitelist_ips` | `[]` | Individual IPs CrowdSec must never ban. |

Install CrowdSec Security Engine agent with acquisition sources and collections

## Table of contents

- [Requirements](#requirements)
- [Default Variables](#default-variables)
  - [crowdsec_agent_acquis_extra](#crowdsec_agent_acquis_extra)
  - [crowdsec_agent_acquis_filename](#crowdsec_agent_acquis_filename)
  - [crowdsec_agent_apt_codename](#crowdsec_agent_apt_codename)
  - [crowdsec_agent_collections](#crowdsec_agent_collections)
  - [crowdsec_agent_enrollment_key](#crowdsec_agent_enrollment_key)
  - [crowdsec_agent_journal_acquisitions](#crowdsec_agent_journal_acquisitions)
  - [crowdsec_agent_lapi_listen](#crowdsec_agent_lapi_listen)
  - [crowdsec_agent_prometheus_enabled](#crowdsec_agent_prometheus_enabled)
  - [crowdsec_agent_prometheus_level](#crowdsec_agent_prometheus_level)
  - [crowdsec_agent_prometheus_listen_addr](#crowdsec_agent_prometheus_listen_addr)
  - [crowdsec_agent_prometheus_listen_port](#crowdsec_agent_prometheus_listen_port)
  - [crowdsec_agent_whitelist_cidrs](#crowdsec_agent_whitelist_cidrs)
  - [crowdsec_agent_whitelist_ips](#crowdsec_agent_whitelist_ips)
- [Dependencies](#dependencies)
- [License](#license)
- [Author](#author)

---

## Requirements

- Minimum Ansible version: `2.15`

## Default Variables

### crowdsec_agent_acquis_extra

#### Default value

```YAML
crowdsec_agent_acquis_extra: []
```

### crowdsec_agent_acquis_filename

#### Default value

```YAML
crowdsec_agent_acquis_filename: egress
```

### crowdsec_agent_apt_codename

#### Default value

```YAML
crowdsec_agent_apt_codename: "{{ {'trixie': 'bookworm'}[ansible_facts['distribution_release']] | default(ansible_facts['distribution_release']) }}"
```

### crowdsec_agent_collections

#### Default value

```YAML
crowdsec_agent_collections:
  - crowdsecurity/linux
  - crowdsecurity/iptables
```

### crowdsec_agent_enrollment_key

#### Default value

```YAML
crowdsec_agent_enrollment_key: ''
```

### crowdsec_agent_journal_acquisitions

#### Default value

```YAML
crowdsec_agent_journal_acquisitions: []
```

### crowdsec_agent_lapi_listen

#### Default value

```YAML
crowdsec_agent_lapi_listen: 127.0.0.1:8080
```

### crowdsec_agent_prometheus_enabled

#### Default value

```YAML
crowdsec_agent_prometheus_enabled: true
```

### crowdsec_agent_prometheus_level

#### Default value

```YAML
crowdsec_agent_prometheus_level: full
```

### crowdsec_agent_prometheus_listen_addr

#### Default value

```YAML
crowdsec_agent_prometheus_listen_addr: 127.0.0.1
```

### crowdsec_agent_prometheus_listen_port

#### Default value

```YAML
crowdsec_agent_prometheus_listen_port: 6060
```

### crowdsec_agent_whitelist_cidrs

#### Default value

```YAML
crowdsec_agent_whitelist_cidrs: []
```

### crowdsec_agent_whitelist_ips

#### Default value

```YAML
crowdsec_agent_whitelist_ips: []
```

## Dependencies

None.

## License

Apache-2.0

## Author

Meysam Azad
