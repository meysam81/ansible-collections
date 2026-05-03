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
