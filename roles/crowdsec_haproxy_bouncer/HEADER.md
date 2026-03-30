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
