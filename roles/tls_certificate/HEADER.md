# TLS Certificate

Obtain and renew Let's Encrypt TLS certificates using lego with Cloudflare DNS-01 challenge. Concatenates certs for HAProxy consumption.

Depends on `lego` (installed automatically).

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
    - name: meysam81.general.tls_certificate
      vars:
        tls_certificate_email: admin@example.com
        tls_certificate_served_domains:
          - app.example.com
          - api.example.com
        tls_certificate_cloudflare_dns_api_token: "{{ lookup('env', 'CLOUDFLARE_DNS_API_TOKEN') }}"
```
