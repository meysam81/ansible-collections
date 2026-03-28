# Lego

Install [lego](https://github.com/go-acme/lego) ACME client from GitHub releases.

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
    - name: meysam81.general.lego
      vars:
        lego_version: "4.33.0"
```
