# Golang

Install Go from [go.dev/dl](https://go.dev/dl/).

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
    - name: meysam81.general.golang
      vars:
        golang_version: "1.26.0"
```
