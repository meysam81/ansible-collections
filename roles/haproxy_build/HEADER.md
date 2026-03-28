# HAProxy Build

Build HAProxy from source with OpenSSL, PCRE2, Lua, and zlib support.

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
    - name: meysam81.general.haproxy_build
      vars:
        haproxy_build_version: "3.2.3"
```
