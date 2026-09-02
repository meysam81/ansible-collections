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

### Listen address

`alloy_listen_addr` (default `127.0.0.1:12345`) is Alloy's own HTTP UI/API —
unauthenticated, so keep it on loopback. `alloy_custom_args` and
`alloy_healthcheck_url` both derive from it; set `alloy_listen_addr` rather
than overriding those two separately:

```yaml
        alloy_listen_addr: "127.0.0.1:9999"  # only if 12345 conflicts
```

### Secrets

`alloy_config` is written to disk without `no_log`, so its contents show up
in `--diff` and verbose task output — it is expected to be non-secret River
config text. Never inline a credential into `alloy_config`; put it in
`alloy_secrets` instead (written separately, mode `0600`, with `no_log:
true` on the task) and reference the file path from `alloy_config`, e.g.
`bearer_token_file = "/etc/alloy/secrets/remote-write-token"`.

Install Grafana Alloy from the Grafana APT repository and manage its configuration

## Table of contents

- [Requirements](#requirements)
- [Default Variables](#default-variables)
  - [alloy_apt_key_path](#alloy_apt_key_path)
  - [alloy_apt_key_url](#alloy_apt_key_url)
  - [alloy_apt_repo](#alloy_apt_repo)
  - [alloy_config](#alloy_config)
  - [alloy_config_path](#alloy_config_path)
  - [alloy_custom_args](#alloy_custom_args)
  - [alloy_extra_groups](#alloy_extra_groups)
  - [alloy_group](#alloy_group)
  - [alloy_healthcheck_enabled](#alloy_healthcheck_enabled)
  - [alloy_healthcheck_url](#alloy_healthcheck_url)
  - [alloy_listen_addr](#alloy_listen_addr)
  - [alloy_secrets](#alloy_secrets)
  - [alloy_secrets_dir](#alloy_secrets_dir)
  - [alloy_textfile_dir](#alloy_textfile_dir)
  - [alloy_user](#alloy_user)
  - [alloy_version](#alloy_version)
- [Dependencies](#dependencies)
- [License](#license)
- [Author](#author)

---

## Requirements

- Minimum Ansible version: `2.17`

## Default Variables

### alloy_apt_key_path

#### Default value

```YAML
alloy_apt_key_path: /etc/apt/keyrings/grafana.asc
```

### alloy_apt_key_url

#### Default value

```YAML
alloy_apt_key_url: https://apt.grafana.com/gpg-full.key
```

### alloy_apt_repo

#### Default value

```YAML
alloy_apt_repo: deb [signed-by=/etc/apt/keyrings/grafana.asc] https://apt.grafana.com stable main
```

### alloy_config

#### Default value

```YAML
alloy_config: ''
```

### alloy_config_path

#### Default value

```YAML
alloy_config_path: /etc/alloy/config.alloy
```

### alloy_custom_args

#### Default value

```YAML
alloy_custom_args: --server.http.listen-addr={{ alloy_listen_addr }} --disable-reporting
```

### alloy_extra_groups

#### Default value

```YAML
alloy_extra_groups:
  - systemd-journal
  - adm
```

### alloy_group

#### Default value

```YAML
alloy_group: alloy
```

### alloy_healthcheck_enabled

#### Default value

```YAML
alloy_healthcheck_enabled: true
```

### alloy_healthcheck_url

#### Default value

```YAML
alloy_healthcheck_url: http://{{ alloy_listen_addr }}/-/ready
```

### alloy_listen_addr

#### Default value

```YAML
alloy_listen_addr: 127.0.0.1:12345
```

### alloy_secrets

#### Default value

```YAML
alloy_secrets: {}
```

### alloy_secrets_dir

#### Default value

```YAML
alloy_secrets_dir: /etc/alloy/secrets
```

### alloy_textfile_dir

#### Default value

```YAML
alloy_textfile_dir: /var/lib/alloy/textfile
```

### alloy_user

#### Default value

```YAML
alloy_user: alloy
```

### alloy_version

#### Default value

```YAML
alloy_version: ''
```

## Dependencies

None.

## License

Apache-2.0

## Author

Meysam Azad
