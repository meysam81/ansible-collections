# Lego Certificate

Issue and auto-renew Let's Encrypt (or any RFC 8555-compliant ACME) certificates with [lego](https://github.com/go-acme/lego), using Cloudflare DNS-01. Pluggable reload hooks let any number of services be restarted on certificate change.

## Install

### requirements.yml

```yaml
collections:
  - name: meysam81.general
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
    - name: meysam81.general.lego
    - name: meysam81.general.lego_certificate
      vars:
        lego_certificate_email: admin@example.com
        lego_certificate_cloudflare_dns_api_token: "{{ lookup('env', 'CLOUDFLARE_DNS_API_TOKEN') }}"
        lego_certificate_certs:
          - name: app.example.com
            domains:
              - app.example.com
              - api.example.com
            reload_commands:
              - systemctl reload nginx
```
