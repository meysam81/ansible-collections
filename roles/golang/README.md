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

Install Go from go.dev/dl

## Table of contents

- [Requirements](#requirements)
- [Default Variables](#default-variables)
  - [golang_arch](#golang_arch)
  - [golang_checksum_url](#golang_checksum_url)
  - [golang_download_url](#golang_download_url)
  - [golang_install_dir](#golang_install_dir)
  - [golang_os](#golang_os)
  - [golang_version](#golang_version)
- [Dependencies](#dependencies)
- [License](#license)
- [Author](#author)

---

## Requirements

- Minimum Ansible version: `2.15`

## Default Variables

### golang_arch

#### Default value

```YAML
golang_arch: "{{ 'arm64' if ansible_architecture == 'aarch64' else 'amd64' }}"
```

### golang_checksum_url

#### Default value

```YAML
golang_checksum_url: '{{ golang_download_url }}.sha256'
```

### golang_download_url

#### Default value

```YAML
golang_download_url: https://go.dev/dl/go{{ golang_version }}.{{ golang_os }}-{{ golang_arch }}.tar.gz
```

### golang_install_dir

#### Default value

```YAML
golang_install_dir: /usr/local
```

### golang_os

#### Default value

```YAML
golang_os: linux
```

### golang_version

#### Default value

```YAML
golang_version: 1.26.0
```

## Dependencies

None.

## License

Apache-2.0

## Author

Meysam Azad
