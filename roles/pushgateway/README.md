# pushgateway

Install pushgateway from GitHub release

## Table of content

- [Requirements](#requirements)
- [Default Variables](#default-variables)
  - [pushgateway_arch](#pushgateway_arch)
  - [pushgateway_create_group](#pushgateway_create_group)
  - [pushgateway_create_user](#pushgateway_create_user)
  - [pushgateway_download_url](#pushgateway_download_url)
  - [pushgateway_group](#pushgateway_group)
  - [pushgateway_healthcheck_enabled](#pushgateway_healthcheck_enabled)
  - [pushgateway_log_format](#pushgateway_log_format)
  - [pushgateway_log_level](#pushgateway_log_level)
  - [pushgateway_os](#pushgateway_os)
  - [pushgateway_persistence_file](#pushgateway_persistence_file)
  - [pushgateway_sha256sum_url](#pushgateway_sha256sum_url)
  - [pushgateway_user](#pushgateway_user)
  - [pushgateway_version](#pushgateway_version)
  - [pushgateway_web_enable_admin_api](#pushgateway_web_enable_admin_api)
  - [pushgateway_web_enable_lifecycle](#pushgateway_web_enable_lifecycle)
  - [pushgateway_web_external_url](#pushgateway_web_external_url)
  - [pushgateway_web_listen_address](#pushgateway_web_listen_address)
- [Dependencies](#dependencies)
- [License](#license)
- [Author](#author)

---

## Requirements

- Minimum Ansible version: `2.17`

## Default Variables

### pushgateway_arch

#### Default value

```YAML
pushgateway_arch: "{{ (ansible_architecture | default('amd64')) | replace('x86_64',
  'amd64') | replace('aarch64', 'arm64') }}"
```

### pushgateway_create_group

#### Default value

```YAML
pushgateway_create_group: true
```

### pushgateway_create_user

#### Default value

```YAML
pushgateway_create_user: true
```

### pushgateway_download_url

#### Default value

```YAML
pushgateway_download_url: https://github.com/prometheus/pushgateway/releases/download/v{{
  pushgateway_version | regex_replace('^v', '') }}/pushgateway-{{ pushgateway_version
  | regex_replace('^v', '') }}.{{ pushgateway_os }}-{{ pushgateway_arch }}.tar.gz
```

### pushgateway_group

#### Default value

```YAML
pushgateway_group: pushgateway
```

### pushgateway_healthcheck_enabled

#### Default value

```YAML
pushgateway_healthcheck_enabled: true
```

### pushgateway_log_format

#### Default value

```YAML
pushgateway_log_format: logfmt
```

### pushgateway_log_level

#### Default value

```YAML
pushgateway_log_level: info
```

### pushgateway_os

#### Default value

```YAML
pushgateway_os: linux
```

### pushgateway_persistence_file

#### Default value

```YAML
pushgateway_persistence_file: ''
```

### pushgateway_sha256sum_url

#### Default value

```YAML
pushgateway_sha256sum_url: https://github.com/prometheus/pushgateway/releases/download/v{{
  pushgateway_version | regex_replace('^v', '') }}/sha256sums.txt
```

### pushgateway_user

#### Default value

```YAML
pushgateway_user: pushgateway
```

### pushgateway_version

#### Default value

```YAML
pushgateway_version: 1.10.0
```

### pushgateway_web_enable_admin_api

#### Default value

```YAML
pushgateway_web_enable_admin_api: true
```

### pushgateway_web_enable_lifecycle

#### Default value

```YAML
pushgateway_web_enable_lifecycle: true
```

### pushgateway_web_external_url

#### Default value

```YAML
pushgateway_web_external_url: ''
```

### pushgateway_web_listen_address

#### Default value

```YAML
pushgateway_web_listen_address: 127.0.0.1:9091
```



## Dependencies

None.

## License

Apache-2.0

## Author

Meysam Azad
