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

Install promtail from GitHub release

## Table of contents

- [Requirements](#requirements)
- [Default Variables](#default-variables)
  - [promtail_allow_insecure_url](#promtail_allow_insecure_url)
  - [promtail_arch](#promtail_arch)
  - [promtail_bearer_token_file](#promtail_bearer_token_file)
  - [promtail_group](#promtail_group)
  - [promtail_os](#promtail_os)
  - [promtail_remote_write_password](#promtail_remote_write_password)
  - [promtail_remote_write_username](#promtail_remote_write_username)
  - [promtail_scrape_paths](#promtail_scrape_paths)
  - [promtail_sha256sum_url](#promtail_sha256sum_url)
  - [promtail_url](#promtail_url)
  - [promtail_user](#promtail_user)
  - [promtail_version](#promtail_version)
- [Dependencies](#dependencies)
- [License](#license)
- [Author](#author)

---

## Requirements

- Minimum Ansible version: `2.17`

## Default Variables

### promtail_allow_insecure_url

#### Default value

```YAML
promtail_allow_insecure_url: false
```

### promtail_arch

#### Default value

```YAML
promtail_arch: "{{ (ansible_architecture | default('amd64')) | replace('x86_64', 'amd64') | replace('aarch64', 'arm64') }}"
```

### promtail_bearer_token_file

#### Default value

```YAML
promtail_bearer_token_file: ''
```

### promtail_group

#### Default value

```YAML
promtail_group: promtail
```

### promtail_os

#### Default value

```YAML
promtail_os: linux
```

### promtail_remote_write_password

#### Default value

```YAML
promtail_remote_write_password: ''
```

### promtail_remote_write_username

#### Default value

```YAML
promtail_remote_write_username: ''
```

### promtail_scrape_paths

#### Default value

```YAML
promtail_scrape_paths:
  - /var/log/*.log
  - /var/log/syslog
  - /var/log/auth.log
```

### promtail_sha256sum_url

#### Default value

```YAML
promtail_sha256sum_url: https://github.com/grafana/loki/releases/download/v{{ promtail_version | regex_replace('^v', '') }}/SHA256SUMS
```

### promtail_url

#### Default value

```YAML
promtail_url: https://github.com/grafana/loki/releases/download/v{{ promtail_version | regex_replace('^v', '') }}/promtail-{{ promtail_os }}-{{ promtail_arch }}.zip
```

### promtail_user

#### Default value

```YAML
promtail_user: promtail
```

### promtail_version

#### Default value

```YAML
promtail_version: 3.2.0
```

## Dependencies

None.

## License

Apache-2.0

## Author

Meysam Azad
