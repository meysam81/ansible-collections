# unbound

Install and configure [unbound](https://www.nlnetlabs.nl/projects/unbound/about/)
as a fully recursive local DNS resolver — no forwarders, DNSSEC validation,
strict-TTL caching, and a bundled Prometheus exporter. Designed for hosts
that need their DNS queries to egress from their own IP (DNSBL clients,
mail relays, reputation lookups) rather than a shared public resolver.

## Install

### requirements.yml

```yaml
collections:
  - name: meysam81.general
    version: 1.13.0
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
    - name: meysam81.general.unbound
```

### Disable the bundled Prometheus exporter

```yaml
- name: meysam81.general.unbound
  vars:
    unbound_exporter_enabled: false
```

### Skip resolver cleanup (keep existing systemd-resolved running)

```yaml
- name: meysam81.general.unbound
  vars:
    unbound_disable_resolvers: false
    unbound_manage_resolv_conf: false
```

### Add custom unbound.conf snippets

```yaml
- name: meysam81.general.unbound
  vars:
    unbound_extra_config: |
      local-zone: "internal.example.com." static
      local-data: "host1.internal.example.com. A 10.0.0.1"
```

## Why a recursive resolver instead of a forwarder?

DNS-based blocklists (Spamhaus, SenderScore, Barracuda, SORBS) and similar
reputation services rate-limit by **the recursive resolver's egress IP** that
hits their authoritative servers — not by the client IP. Public resolvers
(`1.1.1.1`, `8.8.8.8`, etc.) are shared by hundreds of millions of users and
their egress IPs are perpetually throttled or refused outright by these
providers. Running unbound in fully recursive mode makes your queries egress
from your own host's IP, putting you back inside the per-IP free-tier quota.

## Why these cache defaults?

`cache-min-ttl: 0` and `prefetch: no`: DNSBL operators (Spamhaus and Validity
explicitly state this in their terms of service) forbid extending TTLs beyond
the authoritative response or pre-fetching records on their behalf. The
default configuration here is ToS-safe for any DNS-based reputation service.

## Failure mode

The role's handler chain validates `unbound.conf` with `unbound-checkconf`
**before** swapping it into place. A bad config fails the playbook; the live
service keeps running its previous valid config.

At runtime, `unbound.service` has `Restart=always RestartSec=2`. If unbound
crashes, systemd restarts it within 2 seconds. There is no fallback nameserver
in `/etc/resolv.conf` — running a fallback that "works" but uses a public
resolver silently undoes the entire reason for installing this role.

## Conflicts

The shipped systemd unit declares `Conflicts=` against the common port-53
binders (`dnsproxy`, `systemd-resolved`, `dnsmasq`, `bind9`, `named`,
`stubby`). Setting `unbound_disable_resolvers: true` (the default) also
masks them at install time.

Install and configure unbound as a fully-recursive local DNS resolver

## Table of contents

- [Requirements](#requirements)
- [Default Variables](#default-variables)
  - [unbound_apt_package](#unbound_apt_package)
  - [unbound_cache_max_ttl](#unbound_cache_max_ttl)
  - [unbound_cache_min_ttl](#unbound_cache_min_ttl)
  - [unbound_disable_resolvers](#unbound_disable_resolvers)
  - [unbound_dnssec_enabled](#unbound_dnssec_enabled)
  - [unbound_edns_buffer_size](#unbound_edns_buffer_size)
  - [unbound_exporter_binary_path](#unbound_exporter_binary_path)
  - [unbound_exporter_control_socket](#unbound_exporter_control_socket)
  - [unbound_exporter_deb_arch](#unbound_exporter_deb_arch)
  - [unbound_exporter_download_url](#unbound_exporter_download_url)
  - [unbound_exporter_enabled](#unbound_exporter_enabled)
  - [unbound_exporter_listen](#unbound_exporter_listen)
  - [unbound_exporter_version](#unbound_exporter_version)
  - [unbound_extra_config](#unbound_extra_config)
  - [unbound_install_method](#unbound_install_method)
  - [unbound_listen](#unbound_listen)
  - [unbound_manage_resolv_conf](#unbound_manage_resolv_conf)
  - [unbound_msg_cache_size](#unbound_msg_cache_size)
  - [unbound_num_threads](#unbound_num_threads)
  - [unbound_port](#unbound_port)
  - [unbound_prefetch](#unbound_prefetch)
  - [unbound_qname_minimisation](#unbound_qname_minimisation)
  - [unbound_refuse_any](#unbound_refuse_any)
  - [unbound_resolvconf_nameservers](#unbound_resolvconf_nameservers)
  - [unbound_root_hints_path](#unbound_root_hints_path)
  - [unbound_rrset_cache_size](#unbound_rrset_cache_size)
  - [unbound_serve_expired](#unbound_serve_expired)
  - [unbound_trust_anchor_path](#unbound_trust_anchor_path)
- [Dependencies](#dependencies)
- [License](#license)
- [Author](#author)

---

## Requirements

- Minimum Ansible version: `2.15`

## Default Variables

### unbound_apt_package

#### Default value

```YAML
unbound_apt_package: unbound
```

### unbound_cache_max_ttl

#### Default value

```YAML
unbound_cache_max_ttl: 86400
```

### unbound_cache_min_ttl

#### Default value

```YAML
unbound_cache_min_ttl: 0
```

### unbound_disable_resolvers

#### Default value

```YAML
unbound_disable_resolvers: true
```

### unbound_dnssec_enabled

#### Default value

```YAML
unbound_dnssec_enabled: true
```

### unbound_edns_buffer_size

#### Default value

```YAML
unbound_edns_buffer_size: 1232
```

### unbound_exporter_binary_path

#### Default value

```YAML
unbound_exporter_binary_path: /usr/bin/unbound_exporter
```

### unbound_exporter_control_socket

#### Default value

```YAML
unbound_exporter_control_socket: /run/unbound/control.sock
```

### unbound_exporter_deb_arch

#### Default value

```YAML
unbound_exporter_deb_arch: >-
  {{ 'arm64' if ansible_facts['architecture'] == 'aarch64' else 'x86_64' }}
```

### unbound_exporter_download_url

#### Default value

```YAML
unbound_exporter_download_url: >-
  https://github.com/letsencrypt/unbound_exporter/releases/download/v{{
  unbound_exporter_version }}/unbound_exporter-v{{ unbound_exporter_version
  }}.{{ unbound_exporter_deb_arch }}.deb
```

### unbound_exporter_enabled

#### Default value

```YAML
unbound_exporter_enabled: true
```

### unbound_exporter_listen

#### Default value

```YAML
unbound_exporter_listen: 127.0.0.1:9167
```

### unbound_exporter_version

#### Default value

```YAML
unbound_exporter_version: 0.6.0
```

### unbound_extra_config

#### Default value

```YAML
unbound_extra_config: ''
```

### unbound_install_method

#### Default value

```YAML
unbound_install_method: apt
```

### unbound_listen

#### Default value

```YAML
unbound_listen: 127.0.0.1
```

### unbound_manage_resolv_conf

#### Default value

```YAML
unbound_manage_resolv_conf: true
```

### unbound_msg_cache_size

#### Default value

```YAML
unbound_msg_cache_size: 32m
```

### unbound_num_threads

#### Default value

```YAML
unbound_num_threads: 2
```

### unbound_port

#### Default value

```YAML
unbound_port: 53
```

### unbound_prefetch

#### Default value

```YAML
unbound_prefetch: false
```

### unbound_qname_minimisation

#### Default value

```YAML
unbound_qname_minimisation: true
```

### unbound_refuse_any

#### Default value

```YAML
unbound_refuse_any: true
```

### unbound_resolvconf_nameservers

#### Default value

```YAML
unbound_resolvconf_nameservers: |
  nameserver 127.0.0.1
  nameserver ::1
```

### unbound_root_hints_path

#### Default value

```YAML
unbound_root_hints_path: /var/lib/unbound/root.hints
```

### unbound_rrset_cache_size

#### Default value

```YAML
unbound_rrset_cache_size: 64m
```

### unbound_serve_expired

#### Default value

```YAML
unbound_serve_expired: false
```

### unbound_trust_anchor_path

#### Default value

```YAML
unbound_trust_anchor_path: /var/lib/unbound/root.key
```

## Dependencies

None.

## License

Apache-2.0

## Author

Meysam Azad
