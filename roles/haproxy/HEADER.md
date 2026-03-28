# HAProxy

Deploy HAProxy with full config management, TLS termination, security headers, CORS, rate limiting, and compression.

Depends on `haproxy_build` (builds from source automatically).

## Install

### requirements.yml

```yaml
collections:
  - name: meysam81.general
    version: 1.10.13
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
    - name: meysam81.general.haproxy
      vars:
        haproxy_served_domains:
          - app.example.com
          - api.example.com
        haproxy_cors_allowed_domains:
          - app.example.com
```
