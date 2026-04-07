
Build HAProxy from source and set up system infrastructure (user, dirs, systemd)

## Table of contents

- [Requirements](#requirements)
- [Default Variables](#default-variables)
  - [haproxy_base_bin_path](#haproxy_base_bin_path)
  - [haproxy_base_certs_dir](#haproxy_base_certs_dir)
  - [haproxy_base_config_dir](#haproxy_base_config_dir)
  - [haproxy_base_errors_dir](#haproxy_base_errors_dir)
  - [haproxy_build_force_rebuild](#haproxy_build_force_rebuild)
  - [haproxy_build_source_checksum](#haproxy_build_source_checksum)
  - [haproxy_build_version](#haproxy_build_version)
- [Dependencies](#dependencies)
- [License](#license)
- [Author](#author)

---

## Requirements

- Minimum Ansible version: `2.15`

## Default Variables

### haproxy_base_bin_path

#### Default value

```YAML
haproxy_base_bin_path: /usr/local/sbin/haproxy
```

### haproxy_base_certs_dir

#### Default value

```YAML
haproxy_base_certs_dir: /etc/haproxy/certs
```

### haproxy_base_config_dir

#### Default value

```YAML
haproxy_base_config_dir: /etc/haproxy
```

### haproxy_base_errors_dir

#### Default value

```YAML
haproxy_base_errors_dir: /etc/haproxy/errors
```

### haproxy_build_force_rebuild

#### Default value

```YAML
haproxy_build_force_rebuild: false
```

### haproxy_build_source_checksum

#### Default value

```YAML
haproxy_build_source_checksum: ''
```

### haproxy_build_version

#### Default value

```YAML
haproxy_build_version: 3.3.6
```

## Dependencies

None.

## License

Apache-2.0

## Author

Meysam Azad
