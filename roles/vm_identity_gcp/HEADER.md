# VM Identity GCP

## Install

### requirements.yml

```yaml
collections:
  - name: meysam81.general
    version: 1.9.0
```

## Usage

### playbook.yml

```yaml
---
- name: Playbook
  gather_facts: true
  become: true
  hosts: all
  tasks:
  roles:
    - name: meysam81.general.vm_identity_gcp
      vars:
        vm_identity_gcp_env_vars:
          AWS_CONFIG_FILE: /home/ec2-user/.aws/config
        vm_identity_gcp_token_audience: sts.amazonaws.com
```
