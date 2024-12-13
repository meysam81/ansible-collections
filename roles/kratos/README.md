# Kratos

## Install

### requirements.yml

```yaml
collections:
  - name: meysam81.general
    version: 1.7.0
```

## Usage

### kratos-server-config.yml.j2

```yaml
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
      url: https://github.com/ory/kratos/raw/refs/tags/v1.3.1/contrib/quickstart/kratos/email-password/identity.schema.json
```

### kratos-envs.yml.j2

```yaml
COURIER_SMTP_CONNECTION_URI: "{{ kratos_courier_smtp_connection_uri }}"
DSN: postgres://kratos:{{ postgres_kratos_password }}@localhost:5432/kratos?sslmode=disable
SECRETS_CIPHER_0: "{{ kratos_secrets_cipher }}"
SECRETS_COOKIE_0: "{{ kratos_secrets_cookie }}"
SECRETS_DEFAULT_0: "{{ kratos_secrets_default }}"
SELFSERVICE_METHODS_OIDC_CONFIG_PROVIDERS_0_CLIENT_ID: "{{ kratos_oidc_microsoft_client_id }}"
SELFSERVICE_METHODS_OIDC_CONFIG_PROVIDERS_0_CLIENT_SECRET: "{{ kratos_oidc_microsoft_client_secret }}"
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
    - name: meysam81.general.kratos
      tags: kratos
      vars:
        kratos_version: v1.3.1
        kratos_configuration: "{{ lookup('ansible.builtin.template', 'kratos-server-config.yml.j2') }}"
        kratos_envs: "{{ lookup('ansible.builtin.template', 'kratos-envs.yml.j2') }}"
```

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
