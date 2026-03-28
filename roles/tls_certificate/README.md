
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
