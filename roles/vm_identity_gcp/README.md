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

Retrive GCP VM identity token and store it in a file. Best for using in OpenID Connect authentication.

## Table of content

- [Requirements](#requirements)
- [Default Variables](#default-variables)
  - [vm_identity_gcp_env_file_path](#vm_identity_gcp_env_file_path)
  - [vm_identity_gcp_env_vars](#vm_identity_gcp_env_vars)
  - [vm_identity_gcp_executable_path](#vm_identity_gcp_executable_path)
  - [vm_identity_gcp_token_audience](#vm_identity_gcp_token_audience)
  - [vm_identity_gcp_token_file_path](#vm_identity_gcp_token_file_path)
- [Dependencies](#dependencies)
- [License](#license)
- [Author](#author)

---

## Requirements

- Minimum Ansible version: `2.17`

## Default Variables

### vm_identity_gcp_env_file_path

#### Default value

```YAML
vm_identity_gcp_env_file_path: /etc/default/vm-identity-gcp
```

### vm_identity_gcp_env_vars

#### Default value

```YAML
vm_identity_gcp_env_vars: {}
```

### vm_identity_gcp_executable_path

#### Default value

```YAML
vm_identity_gcp_executable_path: /usr/local/bin/vm-identity-gcp
```

### vm_identity_gcp_token_audience

#### Default value

```YAML
vm_identity_gcp_token_audience: https://accounts.google.com
```

### vm_identity_gcp_token_file_path

#### Default value

```YAML
vm_identity_gcp_token_file_path: /var/lib/vm-identity/token
```



## Dependencies

None.

## License

Apache-2.0

## Author

Meysam Azad
