# HAProxy TLS Certificate

Obtain and renew Let's Encrypt TLS certificates using lego with Cloudflare DNS-01 challenge. Concatenates certs for HAProxy consumption.

Depends on `lego` and `haproxy_base`.

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
    - name: meysam81.general.haproxy_tls_certificate
      vars:
        haproxy_tls_certificate_email: admin@example.com
        haproxy_tls_certificate_served_domains:
          - app.example.com
          - api.example.com
        haproxy_tls_certificate_cloudflare_dns_api_token: "{{ lookup('env', 'CLOUDFLARE_DNS_API_TOKEN') }}"
```

### Hosts running a local recursive resolver

lego verifies DNS-01 propagation through the system resolver. A local
recursive resolver (unbound, dnsmasq, systemd-resolved with caching)
negatively caches `_acme-challenge.<domain>` for the zone's SOA minimum
TTL, so the check keeps failing after the record is live and the renewal
times out. Point the check at public resolvers instead:

```yaml
haproxy_tls_certificate_dns_resolvers:
  - "1.1.1.1:53"
  - "8.8.8.8:53"
```
