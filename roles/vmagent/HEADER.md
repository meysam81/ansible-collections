# VMAgent

Install [vmagent](https://docs.victoriametrics.com/vmagent/) from GitHub releases. Scrapes Prometheus targets and remote-writes to VictoriaMetrics.

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
    - name: meysam81.general.vmagent
      vars:
        vmagent_version: "1.113.0"
        vmagent_remote_write_url: https://vm.example.com/api/v1/write
        vmagent_remote_write_username: metrics
        vmagent_remote_write_password: "{{ lookup('env', 'VM_PASSWORD') }}"
        vmagent_node_exporter_enabled: true
```
