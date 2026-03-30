# CrowdSec HAProxy Bouncer

Install the CrowdSec HAProxy bouncer (Lua-based SPOE).

> **Note:** This role installs the bouncer but does not wire it into `haproxy.cfg`. See `crowdsec_haproxy_bouncer_enabled` and the defaults file for integration instructions.

Depends on `haproxy_base`.

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
    - name: meysam81.general.crowdsec_haproxy_bouncer
```

CrowdSec HAProxy bouncer (Lua-based SPOE)

## Table of content

- [Requirements](#requirements)
- [Default Variables](#default-variables)
  - [crowdsec_haproxy_bouncer_config_dir](#crowdsec_haproxy_bouncer_config_dir)
  - [crowdsec_haproxy_bouncer_enabled](#crowdsec_haproxy_bouncer_enabled)
  - [crowdsec_haproxy_bouncer_html_dir](#crowdsec_haproxy_bouncer_html_dir)
  - [crowdsec_haproxy_bouncer_lua_dir](#crowdsec_haproxy_bouncer_lua_dir)
  - [crowdsec_haproxy_bouncer_spoa_addr](#crowdsec_haproxy_bouncer_spoa_addr)
  - [crowdsec_haproxy_bouncer_spoa_port](#crowdsec_haproxy_bouncer_spoa_port)
- [Dependencies](#dependencies)
- [License](#license)
- [Author](#author)

---

## Requirements

- Minimum Ansible version: `2.15`

## Default Variables

### crowdsec_haproxy_bouncer_config_dir

#### Default value

```YAML
crowdsec_haproxy_bouncer_config_dir: /etc/haproxy
```

### crowdsec_haproxy_bouncer_enabled

#### Default value

```YAML
crowdsec_haproxy_bouncer_enabled: true
```

### crowdsec_haproxy_bouncer_html_dir

#### Default value

```YAML
crowdsec_haproxy_bouncer_html_dir: /var/lib/crowdsec-haproxy-spoa-bouncer/html
```

### crowdsec_haproxy_bouncer_lua_dir

#### Default value

```YAML
crowdsec_haproxy_bouncer_lua_dir: /usr/lib/crowdsec-haproxy-spoa-bouncer/lua
```

### crowdsec_haproxy_bouncer_spoa_addr

#### Default value

```YAML
crowdsec_haproxy_bouncer_spoa_addr: 127.0.0.1
```

### crowdsec_haproxy_bouncer_spoa_port

#### Default value

```YAML
crowdsec_haproxy_bouncer_spoa_port: 9001
```



## Dependencies

- haproxy_base

## License

Apache-2.0

## Author

Meysam Azad
