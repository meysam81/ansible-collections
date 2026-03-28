# Cloudflare IPs

Fetch Cloudflare IP ranges and write them to a file for HAProxy `src` ACLs.

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
    - name: meysam81.general.cloudflare_ips
      vars:
        cloudflare_ips_file: /etc/haproxy/cloudflare-ips.txt
```

## Table of content

- [Requirements](#requirements)
- [Default Variables](#default-variables)
  - [cloudflare_ips_file](#cloudflare_ips_file)
  - [cloudflare_ips_haproxy_config_dir](#cloudflare_ips_haproxy_config_dir)
- [Dependencies](#dependencies)
- [License](#license)
- [Author](#author)

---

## Requirements

None.

## Default Variables

### cloudflare_ips_file

#### Default value

```YAML
cloudflare_ips_file: /etc/haproxy/cloudflare-ips.txt
```

### cloudflare_ips_haproxy_config_dir

#### Default value

```YAML
cloudflare_ips_haproxy_config_dir: /etc/haproxy
```



## Dependencies

None.
