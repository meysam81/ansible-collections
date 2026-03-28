# Node Exporter

Install [node_exporter](https://github.com/prometheus/node_exporter) from GitHub releases with SHA256 verification.

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
    - name: meysam81.general.node_exporter
      vars:
        node_exporter_version: "1.8.2"
        node_exporter_extra_collectors:
          - tcpstat
          - systemd
```
