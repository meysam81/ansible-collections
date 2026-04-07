# dnsproxy

Install [AdguardTeam/dnsproxy](https://github.com/AdguardTeam/dnsproxy) as a
local encrypted DNS forwarder (DoH/DoT/DoQ) and disable conflicting local DNS
resolvers.

## Install

### requirements.yml

```yaml
collections:
  - name: meysam81.general
    version: 1.11.0
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
    - name: meysam81.general.dnsproxy
      vars:
        dnsproxy_version: "0.81.0"
```

### Custom upstreams

```yaml
- name: meysam81.general.dnsproxy
  vars:
    dnsproxy_upstreams:
      - "https://9.9.9.9/dns-query"
      - "https://149.112.112.112/dns-query"
    dnsproxy_fallbacks:
      - "tls://9.9.9.9:853"
      - "tls://149.112.112.112:853"
```

### Skip resolver cleanup

```yaml
- name: meysam81.general.dnsproxy
  vars:
    dnsproxy_disable_resolvers: false
    dnsproxy_manage_resolv_conf: false
```

Install and configure AdguardTeam/dnsproxy as a local encrypted DNS forwarder

## Table of contents

- [Requirements](#requirements)
- [Default Variables](#default-variables)
  - [dnsproxy_arch](#dnsproxy_arch)
  - [dnsproxy_cache](#dnsproxy_cache)
  - [dnsproxy_cache_max_ttl](#dnsproxy_cache_max_ttl)
  - [dnsproxy_cache_min_ttl](#dnsproxy_cache_min_ttl)
  - [dnsproxy_cache_optimistic](#dnsproxy_cache_optimistic)
  - [dnsproxy_cache_size](#dnsproxy_cache_size)
  - [dnsproxy_disable_resolvers](#dnsproxy_disable_resolvers)
  - [dnsproxy_download_url](#dnsproxy_download_url)
  - [dnsproxy_extra_args](#dnsproxy_extra_args)
  - [dnsproxy_fallbacks](#dnsproxy_fallbacks)
  - [dnsproxy_force_download](#dnsproxy_force_download)
  - [dnsproxy_http3](#dnsproxy_http3)
  - [dnsproxy_listen](#dnsproxy_listen)
  - [dnsproxy_manage_resolv_conf](#dnsproxy_manage_resolv_conf)
  - [dnsproxy_max_goroutines](#dnsproxy_max_goroutines)
  - [dnsproxy_pending_requests](#dnsproxy_pending_requests)
  - [dnsproxy_port](#dnsproxy_port)
  - [dnsproxy_refuse_any](#dnsproxy_refuse_any)
  - [dnsproxy_timeout](#dnsproxy_timeout)
  - [dnsproxy_upstream_mode](#dnsproxy_upstream_mode)
  - [dnsproxy_upstreams](#dnsproxy_upstreams)
  - [dnsproxy_version](#dnsproxy_version)
- [Dependencies](#dependencies)
- [License](#license)
- [Author](#author)

---

## Requirements

- Minimum Ansible version: `2.15`

## Default Variables

### dnsproxy_arch

#### Default value

```YAML
dnsproxy_arch: "{{ 'arm64' if ansible_facts['architecture'] == 'aarch64' else 'amd64' }}"
```

### dnsproxy_cache

#### Default value

```YAML
dnsproxy_cache: true
```

### dnsproxy_cache_max_ttl

#### Default value

```YAML
dnsproxy_cache_max_ttl: 86400
```

### dnsproxy_cache_min_ttl

#### Default value

```YAML
dnsproxy_cache_min_ttl: 60
```

### dnsproxy_cache_optimistic

#### Default value

```YAML
dnsproxy_cache_optimistic: true
```

### dnsproxy_cache_size

#### Default value

```YAML
dnsproxy_cache_size: 4194304
```

### dnsproxy_disable_resolvers

#### Default value

```YAML
dnsproxy_disable_resolvers: true
```

### dnsproxy_download_url

#### Default value

```YAML
dnsproxy_download_url: >-
  https://github.com/AdguardTeam/dnsproxy/releases/download/v{{ dnsproxy_version
  }}/dnsproxy-linux-{{ dnsproxy_arch }}-v{{ dnsproxy_version }}.tar.gz
```

### dnsproxy_extra_args

#### Default value

```YAML
dnsproxy_extra_args: []
```

### dnsproxy_fallbacks

#### Default value

```YAML
dnsproxy_fallbacks:
  - tls://1.1.1.1:853
  - tls://1.0.0.1:853
  - tls://8.8.8.8:853
  - tls://8.8.4.4:853
```

### dnsproxy_force_download

#### Default value

```YAML
dnsproxy_force_download: false
```

### dnsproxy_http3

#### Default value

```YAML
dnsproxy_http3: true
```

### dnsproxy_listen

#### Default value

```YAML
dnsproxy_listen: ''
```

### dnsproxy_manage_resolv_conf

#### Default value

```YAML
dnsproxy_manage_resolv_conf: true
```

### dnsproxy_max_goroutines

#### Default value

```YAML
dnsproxy_max_goroutines: 1000
```

### dnsproxy_pending_requests

#### Default value

```YAML
dnsproxy_pending_requests: true
```

### dnsproxy_port

#### Default value

```YAML
dnsproxy_port: 53
```

### dnsproxy_refuse_any

#### Default value

```YAML
dnsproxy_refuse_any: true
```

### dnsproxy_timeout

#### Default value

```YAML
dnsproxy_timeout: 10s
```

### dnsproxy_upstream_mode

#### Default value

```YAML
dnsproxy_upstream_mode: fastest_addr
```

### dnsproxy_upstreams

#### Default value

```YAML
dnsproxy_upstreams:
  - https://1.1.1.1/dns-query
  - https://1.0.0.1/dns-query
  - https://8.8.8.8/dns-query
  - https://8.8.4.4/dns-query
```

### dnsproxy_version

#### Default value

```YAML
dnsproxy_version: 0.81.0
```

## Dependencies

None.

## License

Apache-2.0

## Author

Meysam Azad
