# Oathkeeper

## Install

### requirements.yml

```yaml
collections:
  - name: meysam81.general
    version: 1.7.0
```

## Usage

### oathkeeper-server-config.yml.j2

```yaml
  authenticators:
    anonymous:
      config:
        subject: guest
      enabled: true
```

### oathkeeper-envs.yml.j2

```yaml
SERVE_API_PORT: 4456
```

### playbook.yml

```yaml
---
- name: Playbook
  gather_facts: true
  become: true
  hosts: all
  tasks:
  roles:
    - name: meysam81.general.oathkeeper
      tags: oathkeeper
      vars:
        oathkeeper_version: 0.47.0
        oathkeeper_configuration: "{{ lookup('ansible.builtin.template', 'oathkeeper-server-config.yml.j2') }}"
        oathkeeper_envs: "{{ lookup('ansible.builtin.template', 'oathkeeper-envs.yml.j2') }}"
```

Ansible role for deploying Ory Oathkeeper Access Proxy

## Table of content

- [Requirements](#requirements)
- [Default Variables](#default-variables)
  - [oathkeeper_arch](#oathkeeper_arch)
  - [oathkeeper_checksum_url](#oathkeeper_checksum_url)
  - [oathkeeper_configuration](#oathkeeper_configuration)
  - [oathkeeper_download_url](#oathkeeper_download_url)
  - [oathkeeper_envs](#oathkeeper_envs)
  - [oathkeeper_exec_cmd](#oathkeeper_exec_cmd)
  - [oathkeeper_group](#oathkeeper_group)
  - [oathkeeper_libmusl](#oathkeeper_libmusl)
  - [oathkeeper_os](#oathkeeper_os)
  - [oathkeeper_sqlite](#oathkeeper_sqlite)
  - [oathkeeper_user](#oathkeeper_user)
  - [oathkeeper_version](#oathkeeper_version)
- [Dependencies](#dependencies)
- [License](#license)
- [Author](#author)

---

## Requirements

- Minimum Ansible version: `2.17`

## Default Variables

### oathkeeper_arch

#### Default value

```YAML
oathkeeper_arch: "{{ (ansible_architecture | default('amd64')) | replace('x86_64',
  '64bit') | replace('aarch64', 'arm64') }}"
```

### oathkeeper_checksum_url

#### Default value

```YAML
oathkeeper_checksum_url: https://github.com/ory/oathkeeper/releases/download/v{{ oathkeeper_version
  | regex_replace('^v', '') }}/checksums.txt
```

### oathkeeper_configuration

#### Default value

```YAML
oathkeeper_configuration: |
  access_rules:
    matching_strategy: regexp
  authenticators:
    anonymous:
      config:
        subject: guest
      enabled: true
```

### oathkeeper_download_url

#### Default value

```YAML
oathkeeper_download_url: >-
  https://github.com/ory/oathkeeper/releases/download/v{{ oathkeeper_version | regex_replace('^v',
  '') }}/oathkeeper_{{ oathkeeper_version | regex_replace('^v', '') }}-{{ oathkeeper_os
  }}{{ oathkeeper_sqlite | ternary('_sqlite', '') }}{{ oathkeeper_libmusl | ternary('_libmusl',
  '') }}_{{ oathkeeper_arch }}.tar.gz
```

### oathkeeper_envs

#### Default value

```YAML
oathkeeper_envs: {}
```

### oathkeeper_exec_cmd

#### Default value

```YAML
oathkeeper_exec_cmd: /usr/local/bin/oathkeeper serve
```

### oathkeeper_group

#### Default value

```YAML
oathkeeper_group: oathkeeper
```

### oathkeeper_libmusl

#### Default value

```YAML
oathkeeper_libmusl: false
```

### oathkeeper_os

#### Default value

```YAML
oathkeeper_os: linux
```

### oathkeeper_sqlite

#### Default value

```YAML
oathkeeper_sqlite: true
```

### oathkeeper_user

#### Default value

```YAML
oathkeeper_user: oathkeeper
```

### oathkeeper_version

#### Default value

```YAML
oathkeeper_version: 0.40.7
```



## Dependencies

None.

## License

Apache-2.0

## Author

Meysam Azad
