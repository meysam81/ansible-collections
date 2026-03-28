# Pushgateway

Install [pushgateway](https://github.com/prometheus/pushgateway) from GitHub releases with SHA256 verification.

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
    - name: meysam81.general.pushgateway
      vars:
        pushgateway_version: "1.10.0"
        pushgateway_web_listen_address: "0.0.0.0:9091"
```
