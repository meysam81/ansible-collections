# Promtail

Install [promtail](https://github.com/grafana/loki) log agent from GitHub releases. Ships logs to a Loki-compatible endpoint.

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
    - name: meysam81.general.promtail
      vars:
        promtail_version: "3.2.0"
        promtail_remote_write_url: https://loki.example.com/loki/api/v1/push
        promtail_remote_write_username: loki
        promtail_remote_write_password: "{{ lookup('env', 'LOKI_PASSWORD') }}"
        promtail_scrape_paths:
          - /var/log/*.log
          - /var/log/syslog
```
