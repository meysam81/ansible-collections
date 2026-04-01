# K3s

Install [K3s](https://k3s.io) lightweight Kubernetes from GitHub releases.

## Install

### requirements.yml

```yaml
collections:
  - name: meysam81.general
    version: 1.11.1
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
    - name: meysam81.general.k3s
      vars:
        k3s_token: "{{ cluster_token }}"
```

### TLS SANs + OIDC federation

```yaml
- name: meysam81.general.k3s
  vars:
    k3s_token: "{{ cluster_token }}"
    k3s_tls_san:
      - "203.0.113.10"
      - "2001:db8::1"
    k3s_kube_apiserver_args:
      - "service-account-issuer=https://example.com/oidc"
      - "service-account-jwks-uri=https://example.com/oidc/jwks"
```

### Flannel enabled (default CNI)

```yaml
- name: meysam81.general.k3s
  vars:
    k3s_token: "{{ cluster_token }}"
    k3s_flannel_backend: "vxlan"
    k3s_disable_network_policy: false
```

Install and configure K3s lightweight Kubernetes distribution

## Table of contents

- [Requirements](#requirements)
- [Default Variables](#default-variables)
  - [k3s_arch](#k3s_arch)
  - [k3s_binary_suffix](#k3s_binary_suffix)
  - [k3s_disable_components](#k3s_disable_components)
  - [k3s_disable_network_policy](#k3s_disable_network_policy)
  - [k3s_download_url](#k3s_download_url)
  - [k3s_embedded_registry](#k3s_embedded_registry)
  - [k3s_extra_args](#k3s_extra_args)
  - [k3s_flannel_backend](#k3s_flannel_backend)
  - [k3s_force_download](#k3s_force_download)
  - [k3s_kube_apiserver_args](#k3s_kube_apiserver_args)
  - [k3s_secrets_encryption](#k3s_secrets_encryption)
  - [k3s_tls_san](#k3s_tls_san)
  - [k3s_token](#k3s_token)
  - [k3s_token_file](#k3s_token_file)
  - [k3s_version](#k3s_version)
- [Dependencies](#dependencies)
- [License](#license)
- [Author](#author)

---

## Requirements

- Minimum Ansible version: `2.15`

## Default Variables

### k3s_arch

#### Default value

```YAML
k3s_arch: "{{ 'arm64' if ansible_facts['architecture'] == 'aarch64' else 'amd64' }}"
```

### k3s_binary_suffix

#### Default value

```YAML
k3s_binary_suffix: "{{ '-arm64' if k3s_arch == 'arm64' else '' }}"
```

### k3s_disable_components

#### Default value

```YAML
k3s_disable_components:
  - traefik
```

### k3s_disable_network_policy

#### Default value

```YAML
k3s_disable_network_policy: true
```

### k3s_download_url

#### Default value

```YAML
k3s_download_url: >-
  https://github.com/k3s-io/k3s/releases/download/v{{ k3s_version }}/k3s{{ k3s_binary_suffix }}
```

### k3s_embedded_registry

#### Default value

```YAML
k3s_embedded_registry: true
```

### k3s_extra_args

#### Default value

```YAML
k3s_extra_args: []
```

### k3s_flannel_backend

#### Default value

```YAML
k3s_flannel_backend: none
```

### k3s_force_download

#### Default value

```YAML
k3s_force_download: false
```

### k3s_kube_apiserver_args

#### Default value

```YAML
k3s_kube_apiserver_args: []
```

### k3s_secrets_encryption

#### Default value

```YAML
k3s_secrets_encryption: true
```

### k3s_tls_san

#### Default value

```YAML
k3s_tls_san: []
```

### k3s_token

#### Default value

```YAML
k3s_token: ''
```

### k3s_token_file

#### Default value

```YAML
k3s_token_file: /var/lib/k3s-token
```

### k3s_version

#### Default value

```YAML
k3s_version: 1.35.3+k3s1
```

## Dependencies

None.

## License

Apache-2.0

## Author

Meysam Azad
