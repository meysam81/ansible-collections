# kratos

Ansible role for deploying Ory Kratos Identity Server

## Table of content

- [Requirements](#requirements)
- [Default Variables](#default-variables)
  - [kratos_arch](#kratos_arch)
  - [kratos_checksum_url](#kratos_checksum_url)
  - [kratos_configuration](#kratos_configuration)
  - [kratos_download_url](#kratos_download_url)
  - [kratos_envs](#kratos_envs)
  - [kratos_exec_cmd](#kratos_exec_cmd)
  - [kratos_group](#kratos_group)
  - [kratos_libmusl](#kratos_libmusl)
  - [kratos_os](#kratos_os)
  - [kratos_sqlite](#kratos_sqlite)
  - [kratos_user](#kratos_user)
  - [kratos_version](#kratos_version)
- [Dependencies](#dependencies)
- [License](#license)
- [Author](#author)

---

## Requirements

- Minimum Ansible version: `2.17`

## Default Variables

### kratos_arch

#### Default value

```YAML
kratos_arch: "{{ (ansible_architecture | default('amd64')) | replace('x86_64', '64bit')
  | replace('aarch64', 'arm64') }}"
```

### kratos_checksum_url

#### Default value

```YAML
kratos_checksum_url: https://github.com/ory/kratos/releases/download/v{{ kratos_version
  | regex_replace('^v', '') }}/checksums.txt
```

### kratos_configuration

#### Default value

```YAML
kratos_configuration: |
  dsn: memory

  courier:
    smtp:
      # checkov:skip=CKV_SECRET_4:Basic Auth Credentials
      connection_uri: smtps://test:test@mailslurper:1025/?skip_ssl_verify=true

  selfservice:
    default_browser_return_url: http://example.com

  identity:
    schemas:
      - id: default
        url: https://github.com/ory/kratos/raw/refs/tags/v{{ kratos_version | regex_replace('^v', '') }}/contrib/quickstart/kratos/email-password/identity.schema.json
```

### kratos_download_url

#### Default value

```YAML
kratos_download_url: >-
  https://github.com/ory/kratos/releases/download/v{{ kratos_version | regex_replace('^v',
  '') }}/kratos_{{ kratos_version | regex_replace('^v', '') }}-{{ kratos_os }}{{ kratos_sqlite
  | ternary('_sqlite', '') }}{{ kratos_libmusl | ternary('_libmusl', '') }}_{{ kratos_arch
  }}.tar.gz
```

### kratos_envs

#### Default value

```YAML
kratos_envs: {}
```

### kratos_exec_cmd

#### Default value

```YAML
kratos_exec_cmd: /usr/local/bin/kratos serve
```

### kratos_group

#### Default value

```YAML
kratos_group: kratos
```

### kratos_libmusl

#### Default value

```YAML
kratos_libmusl: false
```

### kratos_os

#### Default value

```YAML
kratos_os: linux
```

### kratos_sqlite

#### Default value

```YAML
kratos_sqlite: true
```

### kratos_user

#### Default value

```YAML
kratos_user: kratos
```

### kratos_version

#### Default value

```YAML
kratos_version: 1.3.1
```



## Dependencies

None.

## License

Apache-2.0

## Author

Meysam Azad
