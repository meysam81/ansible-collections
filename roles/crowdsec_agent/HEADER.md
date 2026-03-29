# crowdsec_agent

Install the [CrowdSec](https://www.crowdsec.net/) Security Engine (agent
daemon) with configurable acquisition sources and threat detection collections.

This role installs the CrowdSec agent that parses log files and detects
threats. It is separate from bouncer roles (e.g. `crowdsec` for HAProxy) —
the agent feeds the Local API (LAPI) that bouncers query.

## Install

### requirements.yml

```yaml
collections:
  - name: meysam81.general
    version: 1.11.0
```

## Usage

### Default (http-probing + iptables collections)

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
          - crowdsecurity/http-probing
          - crowdsecurity/iptables
          - crowdsecurity/linux
```
