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

TLS certificates for HAProxy via lego with Cloudflare DNS-01

## Table of content

- [Requirements](#requirements)
- [Default Variables](#default-variables)
  - [haproxy_tls_certificate_email](#haproxy_tls_certificate_email)
  - [haproxy_tls_certificate_haproxy_certs_dir](#haproxy_tls_certificate_haproxy_certs_dir)
  - [haproxy_tls_certificate_lego_cert_dir](#haproxy_tls_certificate_lego_cert_dir)
  - [haproxy_tls_certificate_served_domains](#haproxy_tls_certificate_served_domains)
- [Dependencies](#dependencies)
- [License](#license)
- [Author](#author)

---

## Requirements

- Minimum Ansible version: `2.15`

## Default Variables

### haproxy_tls_certificate_email

#### Default value

```YAML
haproxy_tls_certificate_email: ''
```

### haproxy_tls_certificate_haproxy_certs_dir

#### Default value

```YAML
haproxy_tls_certificate_haproxy_certs_dir: /etc/haproxy/certs
```

### haproxy_tls_certificate_lego_cert_dir

#### Default value

```YAML
haproxy_tls_certificate_lego_cert_dir: /etc/lego/certificates
```

### haproxy_tls_certificate_served_domains

#### Default value

```YAML
haproxy_tls_certificate_served_domains: []
```



## Dependencies

- lego
- haproxy_base

## License

Apache-2.0

## Author

Meysam Azad
