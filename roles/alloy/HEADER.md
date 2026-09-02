# Alloy

Install [Grafana Alloy](https://grafana.com/docs/alloy/latest/) from the Grafana APT repository and manage its configuration, secrets and systemd hardening. One agent for host metrics (`prometheus.exporter.unix`), journal logs (`loki.source.journal`), exporter scraping and blackbox probes.

The role is deployment-agnostic: the caller passes the full River configuration in `alloy_config` (typically rendered from its own template) and any credentials in `alloy_secrets`.

## Install

### requirements.yml

```yaml
collections:
  - name: meysam81.general
    version: 1.13.0
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
    - name: meysam81.general.alloy
      vars:
        alloy_secrets:
          remote-write-token: "{{ lookup('env', 'REMOTE_WRITE_TOKEN') }}"
        alloy_config: |
          prometheus.exporter.unix "host" {
            enable_collectors = ["systemd", "textfile"]
            textfile { directory = "/var/lib/alloy/textfile" }
          }
          prometheus.scrape "host" {
            targets    = prometheus.exporter.unix.host.targets
            forward_to = [prometheus.remote_write.default.receiver]
          }
          prometheus.remote_write "default" {
            endpoint {
              url = "https://metrics.example.com/api/v1/write"
              bearer_token_file = "/etc/alloy/secrets/remote-write-token"
            }
          }
```

Textfile metrics: any `*.prom` file placed in `alloy_textfile_dir` (default `/var/lib/alloy/textfile`) is exposed by the `textfile` collector. Pair with `restic_backup`'s `restic_metrics_textfile_dir`.
