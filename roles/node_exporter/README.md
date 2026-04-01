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

Install node-exporter from GitHub release

## Table of contents

- [Requirements](#requirements)
- [Default Variables](#default-variables)
  - [node_exporter_arch](#node_exporter_arch)
  - [node_exporter_create_user](#node_exporter_create_user)
  - [node_exporter_download_url](#node_exporter_download_url)
  - [node_exporter_extra_collectors](#node_exporter_extra_collectors)
  - [node_exporter_group](#node_exporter_group)
  - [node_exporter_healthcheck_enabled](#node_exporter_healthcheck_enabled)
  - [node_exporter_os](#node_exporter_os)
  - [node_exporter_owner](#node_exporter_owner)
  - [node_exporter_sha256sum_url](#node_exporter_sha256sum_url)
  - [node_exporter_supervisord_enabled](#node_exporter_supervisord_enabled)
  - [node_exporter_supervisord_url](#node_exporter_supervisord_url)
  - [node_exporter_version](#node_exporter_version)
- [Dependencies](#dependencies)
- [License](#license)
- [Author](#author)

---

## Requirements

- Minimum Ansible version: `2.17`

## Default Variables

### node_exporter_arch

#### Default value

```YAML
node_exporter_arch: "{{ (ansible_architecture | default('amd64')) | replace('x86_64', 'amd64') | replace('aarch64', 'arm64') }}"
```

### node_exporter_create_user

#### Default value

```YAML
node_exporter_create_user: true
```

### node_exporter_download_url

#### Default value

```YAML
node_exporter_download_url: https://github.com/prometheus/node_exporter/releases/download/v{{ node_exporter_version | regex_replace('^v', '') }}/node_exporter-{{ node_exporter_version | regex_replace('^v', '') }}.{{ node_exporter_os }}-{{ node_exporter_arch }}.tar.gz
```

### node_exporter_extra_collectors

#### Default value

```YAML
node_exporter_extra_collectors:
  - tcpstat
  - systemd
  - sysctl
  - network_route
  - mountstats
  - cgroups
```

### node_exporter_group

#### Default value

```YAML
node_exporter_group: node-exporter
```

### node_exporter_healthcheck_enabled

#### Default value

```YAML
node_exporter_healthcheck_enabled: true
```

### node_exporter_os

#### Default value

```YAML
node_exporter_os: linux
```

### node_exporter_owner

#### Default value

```YAML
node_exporter_owner: node-exporter
```

### node_exporter_sha256sum_url

#### Default value

```YAML
node_exporter_sha256sum_url: https://github.com/prometheus/node_exporter/releases/download/v{{ node_exporter_version | regex_replace('^v', '') }}/sha256sums.txt
```

### node_exporter_supervisord_enabled

#### Default value

```YAML
node_exporter_supervisord_enabled: false
```

### node_exporter_supervisord_url

#### Default value

```YAML
node_exporter_supervisord_url: http://localhost:9001/RPC2
```

### node_exporter_version

#### Default value

```YAML
node_exporter_version: 1.8.2
```

## Dependencies

None.

## License

Apache-2.0

## Author

Meysam Azad
