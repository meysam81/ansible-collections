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

Issue and renew Let's Encrypt certificates via lego with Cloudflare DNS-01 and pluggable reload hooks

## Table of contents

- [Requirements](#requirements)
- [Default Variables](#default-variables)
  - [lego_certificate_cert_dir](#lego_certificate_cert_dir)
  - [lego_certificate_certs](#lego_certificate_certs)
  - [lego_certificate_cloudflare_dns_api_token](#lego_certificate_cloudflare_dns_api_token)
  - [lego_certificate_email](#lego_certificate_email)
  - [lego_certificate_lego_bin](#lego_certificate_lego_bin)
  - [lego_certificate_renew_extra_read_write_paths](#lego_certificate_renew_extra_read_write_paths)
  - [lego_certificate_renew_on_calendar](#lego_certificate_renew_on_calendar)
  - [lego_certificate_renew_random_delay_sec](#lego_certificate_renew_random_delay_sec)
- [Dependencies](#dependencies)
- [License](#license)
- [Author](#author)

---

## Requirements

- Minimum Ansible version: `2.15`

## Default Variables

### lego_certificate_cert_dir

#### Default value

```YAML
lego_certificate_cert_dir: /etc/lego/certificates
```

### lego_certificate_certs

#### Default value

```YAML
lego_certificate_certs: []
```

### lego_certificate_cloudflare_dns_api_token

#### Default value

```YAML
lego_certificate_cloudflare_dns_api_token: ''
```

### lego_certificate_email

#### Default value

```YAML
lego_certificate_email: ''
```

### lego_certificate_lego_bin

#### Default value

```YAML
lego_certificate_lego_bin: /usr/local/bin/lego
```

### lego_certificate_renew_extra_read_write_paths

#### Default value

```YAML
lego_certificate_renew_extra_read_write_paths: []
```

### lego_certificate_renew_on_calendar

#### Default value

```YAML
lego_certificate_renew_on_calendar: daily
```

### lego_certificate_renew_random_delay_sec

#### Default value

```YAML
lego_certificate_renew_random_delay_sec: 600
```

## Dependencies

- lego

## License

Apache-2.0

## Author

Meysam Azad
