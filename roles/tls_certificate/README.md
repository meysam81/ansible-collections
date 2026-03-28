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

## Table of content

- [Requirements](#requirements)
- [Default Variables](#default-variables)
  - [tls_certificate_email](#tls_certificate_email)
  - [tls_certificate_haproxy_cert_dir](#tls_certificate_haproxy_cert_dir)
  - [tls_certificate_lego_cert_dir](#tls_certificate_lego_cert_dir)
  - [tls_certificate_served_domains](#tls_certificate_served_domains)
- [Dependencies](#dependencies)
- [License](#license)
- [Author](#author)

---

## Requirements

None.

## Default Variables

### tls_certificate_email

#### Default value

```YAML
tls_certificate_email: ''
```

### tls_certificate_haproxy_cert_dir

#### Default value

```YAML
tls_certificate_haproxy_cert_dir: /etc/haproxy/certs
```

### tls_certificate_lego_cert_dir

#### Default value

```YAML
tls_certificate_lego_cert_dir: /etc/lego/certificates
```

### tls_certificate_served_domains

#### Default value

```YAML
tls_certificate_served_domains: []
```



## Dependencies

- lego
