# HAProxy Base

Shared HAProxy infrastructure: system user, config/cert/error directories, custom error pages, and systemd service unit.

Depends on `haproxy_build` (compiles HAProxy from source).

Satellite roles (`haproxy`, `haproxy_tls_certificate`, `cloudflare_ips`, `coraza`, `crowdsec_haproxy_bouncer`) depend on this role instead of depending on the full `haproxy` config role.

HAProxy shared infrastructure (user, dirs, error pages, systemd service)

## Table of content

- [Requirements](#requirements)
- [Default Variables](#default-variables)
  - [haproxy_bin_path](#haproxy_bin_path)
  - [haproxy_certs_dir](#haproxy_certs_dir)
  - [haproxy_config_dir](#haproxy_config_dir)
  - [haproxy_errors_dir](#haproxy_errors_dir)
- [Dependencies](#dependencies)
- [License](#license)
- [Author](#author)

---

## Requirements

- Minimum Ansible version: `2.15`

## Default Variables

### haproxy_bin_path

#### Default value

```YAML
haproxy_bin_path: /usr/local/sbin/haproxy
```

### haproxy_certs_dir

#### Default value

```YAML
haproxy_certs_dir: /etc/haproxy/certs
```

### haproxy_config_dir

#### Default value

```YAML
haproxy_config_dir: /etc/haproxy
```

### haproxy_errors_dir

#### Default value

```YAML
haproxy_errors_dir: /etc/haproxy/errors
```



## Dependencies

- haproxy_build

## License

Apache-2.0

## Author

Meysam Azad
