# squid

Install and configure [Squid](http://www.squid-cache.org/) as a forward proxy
with ACL-based blocklist support, structured JSON access logging, and optional
[CrowdSec](https://www.crowdsec.net/) external ACL integration.

Designed to run on a WireGuard exit node, accepting tunnel traffic and applying
threat intelligence blocklists before forwarding to the internet.

## Install

### requirements.yml

```yaml
collections:
  - name: meysam81.general
    version: 1.11.0
```

## Usage

### Minimal (localhost proxy)

```yaml
---
- name: Playbook
  gather_facts: true
  become: true
  hosts: all
  roles:
    - name: meysam81.general.squid
```

### WireGuard exit node with blocklists

```yaml
    - name: meysam81.general.squid
      vars:
        squid_listen_address: "10.99.0.1"
        squid_allowed_sources:
          - "10.99.0.0/24"
        squid_blocked_domains_file: /etc/egress-proxy/blocklists/urlhaus-domains.txt
        squid_blocked_ips_file: /etc/egress-proxy/blocklists/spamhaus-drop-cidrs.txt
```

### With CrowdSec integration

```yaml
    - name: meysam81.general.squid
      vars:
        squid_crowdsec_enabled: true
        squid_crowdsec_lapi_url: "http://127.0.0.1:8080"
        squid_crowdsec_ttl: 120
```

### Custom ACLs and rules (escape hatch)

```yaml
    - name: meysam81.general.squid
      vars:
        squid_extra_acls:
          - "acl internal_nets src 192.168.0.0/16"
        squid_extra_rules:
          - "http_access allow internal_nets"
```

Install and configure Squid forward proxy with blocklist and CrowdSec support

## Table of content

- [Requirements](#requirements)
- [Default Variables](#default-variables)
  - [squid_allowed_sources](#squid_allowed_sources)
  - [squid_blocked_domains_file](#squid_blocked_domains_file)
  - [squid_blocked_ips_file](#squid_blocked_ips_file)
  - [squid_cache_enabled](#squid_cache_enabled)
  - [squid_crowdsec_children_max](#squid_crowdsec_children_max)
  - [squid_crowdsec_children_startup](#squid_crowdsec_children_startup)
  - [squid_crowdsec_enabled](#squid_crowdsec_enabled)
  - [squid_crowdsec_fail_mode](#squid_crowdsec_fail_mode)
  - [squid_crowdsec_lapi_url](#squid_crowdsec_lapi_url)
  - [squid_crowdsec_ttl](#squid_crowdsec_ttl)
  - [squid_extra_acls](#squid_extra_acls)
  - [squid_extra_rules](#squid_extra_rules)
  - [squid_listen_address](#squid_listen_address)
  - [squid_listen_port](#squid_listen_port)
  - [squid_workers](#squid_workers)
- [Dependencies](#dependencies)
- [License](#license)
- [Author](#author)

---

## Requirements

- Minimum Ansible version: `2.15`

## Default Variables

### squid_allowed_sources

#### Default value

```YAML
squid_allowed_sources:
  - 10.99.0.0/24
```

### squid_blocked_domains_file

#### Default value

```YAML
squid_blocked_domains_file: ''
```

### squid_blocked_ips_file

#### Default value

```YAML
squid_blocked_ips_file: ''
```

### squid_cache_enabled

#### Default value

```YAML
squid_cache_enabled: false
```

### squid_crowdsec_children_max

#### Default value

```YAML
squid_crowdsec_children_max: 10
```

### squid_crowdsec_children_startup

#### Default value

```YAML
squid_crowdsec_children_startup: 2
```

### squid_crowdsec_enabled

#### Default value

```YAML
squid_crowdsec_enabled: false
```

### squid_crowdsec_fail_mode

#### Default value

```YAML
squid_crowdsec_fail_mode: open
```

### squid_crowdsec_lapi_url

#### Default value

```YAML
squid_crowdsec_lapi_url: http://127.0.0.1:8080
```

### squid_crowdsec_ttl

#### Default value

```YAML
squid_crowdsec_ttl: 60
```

### squid_extra_acls

#### Default value

```YAML
squid_extra_acls: []
```

### squid_extra_rules

#### Default value

```YAML
squid_extra_rules: []
```

### squid_listen_address

#### Default value

```YAML
squid_listen_address: 127.0.0.1
```

### squid_listen_port

#### Default value

```YAML
squid_listen_port: 3128
```

### squid_workers

#### Default value

```YAML
squid_workers: 2
```



## Dependencies

None.

## License

Apache-2.0

## Author

Meysam Azad
