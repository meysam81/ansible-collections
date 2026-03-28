# Kubernetes OpenID Connect GitHub Pages

Fetch the Kubernetes OIDC discovery document and JWKS keys, then push them to a GitHub Pages repository. Enables trust federation between K8s pods and external providers (e.g., AWS IRSA).

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
    - name: meysam81.general.k8s_oidc_github_pages
      vars:
        k8s_oidc_github_pages_repository_owner: myorg
        k8s_oidc_github_pages_repository_name: k8s-oidc
        k8s_oidc_github_pages_github_deploy_key: "{{ lookup('env', 'GITHUB_DEPLOY_KEY') }}"
```
