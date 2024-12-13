# Oathkeeper

## Install

### requirements.yml

```yaml
collections:
  - name: meysam81.general
    version: 1.7.0
```

## Usage

### oathkeeper-server-config.yml.j2

```yaml
  authenticators:
    anonymous:
      config:
        subject: guest
      enabled: true
```

### oathkeeper-envs.yml.j2

```yaml
SERVE_API_PORT: 4456
```

### playbook.yml

```yaml
---
- name: Playbook
  gather_facts: true
  become: true
  hosts: all
  tasks:
  roles:
    - name: meysam81.general.oathkeeper
      tags: oathkeeper
      vars:
        oathkeeper_version: 0.47.0
        oathkeeper_configuration: "{{ lookup('ansible.builtin.template', 'oathkeeper-server-config.yml.j2') }}"
        oathkeeper_envs: "{{ lookup('ansible.builtin.template', 'oathkeeper-envs.yml.j2') }}"
```
