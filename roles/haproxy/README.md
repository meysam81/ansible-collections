# HAProxy

Builds HAProxy from the upstream source tarball (QUIC, Prometheus exporter,
Lua, kTLS, OpenSSL, PCRE2) and installs it to `haproxy_base_bin_path`.

## Version and checksum

`haproxy_build_version` defaults to `3.4.7` (the 3.4 LTS branch). The tarball
is verified against `haproxy_build_source_checksum`, which defaults to the
digest listed for that version in `haproxy_build_source_checksums`. Overriding
only the version therefore never checks a different release against the wrong
digest: an unlisted version gets no verification unless you also set the
checksum:

```yaml
        haproxy_build_version: "3.3.6"
        haproxy_build_source_checksum: "sha256:<digest from haproxy.org>"
```

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
  - [haproxy_build_source_checksums](#haproxy_build_source_checksums)
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
haproxy_build_source_checksum: "{{ haproxy_build_source_checksums[haproxy_build_version] | default('') }}"
```

### haproxy_build_source_checksums

#### Default value

```YAML
haproxy_build_source_checksums:
  3.4.7: sha256:ccfd342f3724c2cd659574044d788f44e20b212467c6bd5edbbfc517a2775dca
```

### haproxy_build_version

#### Default value

```YAML
haproxy_build_version: 3.4.7
```

## Dependencies

None.

## License

Apache-2.0

## Author

Meysam Azad
