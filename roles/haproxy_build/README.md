# HAProxy Build

Build HAProxy from source with OpenSSL, QUIC, PCRE2, Lua, and Prometheus support.

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
    - name: meysam81.general.haproxy_build
      vars:
        haproxy_build_version: "3.3.6"
```

Build HAProxy from source

## Table of content

- [Requirements](#requirements)
- [Default Variables](#default-variables)
  - [haproxy_build_source_checksum](#haproxy_build_source_checksum)
  - [haproxy_build_version](#haproxy_build_version)
  - [haproxy_force_rebuild](#haproxy_force_rebuild)
- [Dependencies](#dependencies)
- [License](#license)
- [Author](#author)

---

## Requirements

- Minimum Ansible version: `2.15`

## Default Variables

### haproxy_build_source_checksum

#### Default value

```YAML
haproxy_build_source_checksum: ''
```

### haproxy_build_version

#### Default value

```YAML
haproxy_build_version: 3.3.6
```

### haproxy_force_rebuild

#### Default value

```YAML
haproxy_force_rebuild: false
```



## Dependencies

None.

## License

MIT

## Author

Meysam Azad
