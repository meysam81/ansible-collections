# sysctl

Manage Linux kernel parameters via sysctl drop-in configuration files in
`/etc/sysctl.d/`.

## Install

### requirements.yml

```yaml
collections:
  - name: meysam81.general
    version: 1.11.0
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
    - name: meysam81.general.sysctl
      vars:
        sysctl_params:
          net.ipv4.ip_forward: 1
          net.core.somaxconn: 65535
```

### Custom drop-in file path

```yaml
        sysctl_file: /etc/sysctl.d/50-network-tuning.conf
        sysctl_params:
          net.ipv4.tcp_max_syn_backlog: 4096
```

### Deploy without immediate reload

```yaml
        sysctl_reload: false
        sysctl_params:
          vm.swappiness: 10
```
