# vmagent

Install vmagent from GitHub release

## Table of content

- [Requirements](#requirements)
- [Default Variables](#default-variables)
  - [vmagent_arch](#vmagent_arch)
  - [vmagent_bin](#vmagent_bin)
  - [vmagent_docker_enabled](#vmagent_docker_enabled)
  - [vmagent_fail2ban_enabled](#vmagent_fail2ban_enabled)
  - [vmagent_group](#vmagent_group)
  - [vmagent_haproxy_exporter_enabled](#vmagent_haproxy_exporter_enabled)
  - [vmagent_http_listen_addr](#vmagent_http_listen_addr)
  - [vmagent_instance_label](#vmagent_instance_label)
  - [vmagent_mongo_exporter_enabled](#vmagent_mongo_exporter_enabled)
  - [vmagent_node_exporter_enabled](#vmagent_node_exporter_enabled)
  - [vmagent_os](#vmagent_os)
  - [vmagent_redis_exporter_enabled](#vmagent_redis_exporter_enabled)
  - [vmagent_remote_write_password](#vmagent_remote_write_password)
  - [vmagent_remote_write_token_file](#vmagent_remote_write_token_file)
  - [vmagent_remote_write_username](#vmagent_remote_write_username)
  - [vmagent_scrape_interval](#vmagent_scrape_interval)
  - [vmagent_user](#vmagent_user)
  - [vmagent_version](#vmagent_version)
  - [vmagent_vmutils_url](#vmagent_vmutils_url)
- [Dependencies](#dependencies)
- [License](#license)
- [Author](#author)

---

## Requirements

- Minimum Ansible version: `2.17`

## Default Variables

### vmagent_arch

#### Default value

```YAML
vmagent_arch: "{{ (ansible_architecture | default('amd64')) | replace('x86_64', 'amd64')
  | replace('aarch64', 'arm64') }}"
```

### vmagent_bin

#### Default value

```YAML
vmagent_bin: /usr/local/bin/vmagent-prod
```

### vmagent_docker_enabled

#### Default value

```YAML
vmagent_docker_enabled: false
```

### vmagent_fail2ban_enabled

#### Default value

```YAML
vmagent_fail2ban_enabled: false
```

### vmagent_group

#### Default value

```YAML
vmagent_group: vmagent
```

### vmagent_haproxy_exporter_enabled

#### Default value

```YAML
vmagent_haproxy_exporter_enabled: false
```

### vmagent_http_listen_addr

#### Default value

```YAML
vmagent_http_listen_addr: 127.0.0.1:8429
```

### vmagent_instance_label

#### Default value

```YAML
vmagent_instance_label: ''
```

### vmagent_mongo_exporter_enabled

#### Default value

```YAML
vmagent_mongo_exporter_enabled: false
```

### vmagent_node_exporter_enabled

#### Default value

```YAML
vmagent_node_exporter_enabled: false
```

### vmagent_os

#### Default value

```YAML
vmagent_os: linux
```

### vmagent_redis_exporter_enabled

#### Default value

```YAML
vmagent_redis_exporter_enabled: false
```

### vmagent_remote_write_password

#### Default value

```YAML
vmagent_remote_write_password: ''
```

### vmagent_remote_write_token_file

#### Default value

```YAML
vmagent_remote_write_token_file: ''
```

### vmagent_remote_write_username

#### Default value

```YAML
vmagent_remote_write_username: ''
```

### vmagent_scrape_interval

#### Default value

```YAML
vmagent_scrape_interval: 30s
```

### vmagent_user

#### Default value

```YAML
vmagent_user: vmagent
```

### vmagent_version

#### Default value

```YAML
vmagent_version: 1.104.0
```

### vmagent_vmutils_url

#### Default value

```YAML
vmagent_vmutils_url: https://github.com/VictoriaMetrics/VictoriaMetrics/releases/download/v{{
  vmagent_version | regex_replace('^v', '') }}/vmutils-{{ vmagent_os }}-{{ vmagent_arch
  }}-v{{ vmagent_version | regex_replace('^v', '') }}.tar.gz
```



## Dependencies

None.

## License

Apache-2.0

## Author

Meysam Azad
