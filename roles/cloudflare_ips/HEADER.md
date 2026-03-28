# Cloudflare IPs

Fetch Cloudflare IP ranges and write them to a file for HAProxy `src` ACLs.

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
    - name: meysam81.general.cloudflare_ips
      vars:
        cloudflare_ips_file: /etc/haproxy/cloudflare-ips.txt
```
