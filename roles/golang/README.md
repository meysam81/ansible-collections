
Install Go from go.dev/dl

## Table of content

- [Requirements](#requirements)
- [Default Variables](#default-variables)
  - [go_arch](#go_arch)
  - [go_checksum_url](#go_checksum_url)
  - [go_download_url](#go_download_url)
  - [go_install_dir](#go_install_dir)
  - [go_os](#go_os)
  - [go_version](#go_version)
- [Dependencies](#dependencies)
- [License](#license)
- [Author](#author)

---

## Requirements

- Minimum Ansible version: `2.15`

## Default Variables

### go_arch

#### Default value

```YAML
go_arch: "{{ 'arm64' if ansible_architecture == 'aarch64' else 'amd64' }}"
```

### go_checksum_url

#### Default value

```YAML
go_checksum_url: '{{ go_download_url }}.sha256'
```

### go_download_url

#### Default value

```YAML
go_download_url: https://go.dev/dl/go{{ go_version }}.{{ go_os }}-{{ go_arch }}.tar.gz
```

### go_install_dir

#### Default value

```YAML
go_install_dir: /usr/local
```

### go_os

#### Default value

```YAML
go_os: linux
```

### go_version

#### Default value

```YAML
go_version: 1.26.0
```



## Dependencies

None.

## License

Apache-2.0
