# Coraza

Build and install [coraza-spoa](https://github.com/corazawaf/coraza-spoa) WAF engine for HAProxy from source. Includes OWASP CoreRuleSet.

Depends on `golang` and `haproxy`.

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
    - name: meysam81.general.coraza
      vars:
        coraza_spoa_version: "0.3.0"
        coraza_coreruleset_version: "4.17.1"
```

## Skipping paths

`coraza_skip_paths` lists request path prefixes the agent never receives. The
role renders them as an ACL condition on the SPOE events, so HAProxy does not
even send the message: no CRS evaluation, no `set-on-error` failure, no log
noise. Typical use is machine ingest endpoints with binary bodies (metrics
remote-write, log pushes), which trip protocol-enforcement rules on every
call and can exceed the agent's frame or processing limits:

```yaml
    - name: meysam81.general.coraza
      vars:
        coraza_skip_paths:
          - /insert/
          - /api/v1/write
```

Anything else HAProxy does with those paths (rate limiting, its own path
rules) still applies; only the WAF is bypassed.

## Table of contents

- [Requirements](#requirements)
- [Default Variables](#default-variables)
  - [coraza_config_dir](#coraza_config_dir)
  - [coraza_config_version](#coraza_config_version)
  - [coraza_coreruleset_commit](#coraza_coreruleset_commit)
  - [coraza_coreruleset_version](#coraza_coreruleset_version)
  - [coraza_go_install_dir](#coraza_go_install_dir)
  - [coraza_haproxy_config_dir](#coraza_haproxy_config_dir)
  - [coraza_skip_paths](#coraza_skip_paths)
  - [coraza_spoa_addr](#coraza_spoa_addr)
  - [coraza_spoa_commit](#coraza_spoa_commit)
  - [coraza_spoa_port](#coraza_spoa_port)
  - [coraza_spoa_version](#coraza_spoa_version)
- [Dependencies](#dependencies)
- [License](#license)
- [Author](#author)

---

## Requirements

None.

## Default Variables

### coraza_config_dir

#### Default value

```YAML
coraza_config_dir: /etc/coraza-spoa
```

### coraza_config_version

#### Default value

```YAML
coraza_config_version: 3.3.3
```

### coraza_coreruleset_commit

#### Default value

```YAML
coraza_coreruleset_commit: ''
```

### coraza_coreruleset_version

#### Default value

```YAML
coraza_coreruleset_version: 4.17.1
```

### coraza_go_install_dir

#### Default value

```YAML
coraza_go_install_dir: /usr/local
```

### coraza_haproxy_config_dir

#### Default value

```YAML
coraza_haproxy_config_dir: /etc/haproxy
```

### coraza_skip_paths

#### Default value

```YAML
coraza_skip_paths: []
```

### coraza_spoa_addr

#### Default value

```YAML
coraza_spoa_addr: 127.0.0.1
```

### coraza_spoa_commit

#### Default value

```YAML
coraza_spoa_commit: ''
```

### coraza_spoa_port

#### Default value

```YAML
coraza_spoa_port: 9000
```

### coraza_spoa_version

#### Default value

```YAML
coraza_spoa_version: 0.3.0
```

## Dependencies

- golang
- haproxy
