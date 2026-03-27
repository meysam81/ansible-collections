
## Table of content

- [Requirements](#requirements)
- [Default Variables](#default-variables)
  - [haproxy_cert_dir](#haproxy_cert_dir)
  - [lego_cert_dir](#lego_cert_dir)
  - [served_domains](#served_domains)
  - [tls_cert_email](#tls_cert_email)
- [Dependencies](#dependencies)
- [License](#license)
- [Author](#author)

---

## Requirements

None.

## Default Variables

### haproxy_cert_dir

#### Default value

```YAML
haproxy_cert_dir: /etc/haproxy/certs
```

### lego_cert_dir

#### Default value

```YAML
lego_cert_dir: /etc/lego/certificates
```

### served_domains

#### Default value

```YAML
served_domains: []
```

### tls_cert_email

#### Default value

```YAML
tls_cert_email: ''
```



## Dependencies

- lego
