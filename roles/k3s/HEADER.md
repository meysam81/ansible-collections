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
