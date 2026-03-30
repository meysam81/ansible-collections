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

Install CrowdSec Security Engine agent with acquisition sources and collections

## Table of content

- [Requirements](#requirements)
- [Default Variables](#default-variables)
  - [crowdsec_agent_acquis_extra](#crowdsec_agent_acquis_extra)
  - [crowdsec_agent_acquis_filename](#crowdsec_agent_acquis_filename)
  - [crowdsec_agent_collections](#crowdsec_agent_collections)
  - [crowdsec_agent_enrollment_key](#crowdsec_agent_enrollment_key)
  - [crowdsec_agent_lapi_listen](#crowdsec_agent_lapi_listen)
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

### crowdsec_agent_collections

#### Default value

```YAML
crowdsec_agent_collections:
  - crowdsecurity/http-probing
  - crowdsecurity/iptables
```

### crowdsec_agent_enrollment_key

#### Default value

```YAML
crowdsec_agent_enrollment_key: ''
```

### crowdsec_agent_lapi_listen

#### Default value

```YAML
crowdsec_agent_lapi_listen: 127.0.0.1:8080
```



## Dependencies

None.

## License

Apache-2.0

## Author

Meysam Azad
