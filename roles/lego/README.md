# Lego

Install [lego](https://github.com/go-acme/lego) ACME client from GitHub releases.

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
    - name: meysam81.general.lego
      vars:
        lego_version: "4.33.0"
```

## Table of content

- [Requirements](#requirements)
- [Default Variables](#default-variables)
  - [lego_arch](#lego_arch)
  - [lego_bin_dir](#lego_bin_dir)
  - [lego_checksums_url](#lego_checksums_url)
  - [lego_download_url](#lego_download_url)
  - [lego_os](#lego_os)
  - [lego_version](#lego_version)
- [Dependencies](#dependencies)
- [License](#license)
- [Author](#author)

---

## Requirements

None.

## Default Variables

### lego_arch

#### Default value

```YAML
lego_arch: "{{ 'arm64' if ansible_architecture == 'aarch64' else 'amd64' }}"
```

### lego_bin_dir

#### Default value

```YAML
lego_bin_dir: /usr/local/bin
```

### lego_checksums_url

#### Default value

```YAML
lego_checksums_url: https://github.com/go-acme/lego/releases/download/v{{ lego_version
  }}/lego_{{ lego_version }}_checksums.txt
```

### lego_download_url

#### Default value

```YAML
lego_download_url: https://github.com/go-acme/lego/releases/download/v{{ lego_version
  }}/lego_v{{ lego_version }}_{{ lego_os }}_{{ lego_arch }}.tar.gz
```

### lego_os

#### Default value

```YAML
lego_os: linux
```

### lego_version

#### Default value

```YAML
lego_version: 4.33.0
```



## Dependencies

None.
