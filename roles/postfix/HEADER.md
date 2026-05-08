# Postfix

Install and configure Postfix as a mail server. The role is opinionated toward inbound MX deployments (no submission, no relay) but exposes enough variables to support arbitrary configurations through `postfix_extra_main_cf` and `postfix_disable_submission`.

## Install

### requirements.yml

```yaml
collections:
  - name: meysam81.general
```

## Usage

### playbook.yml — inbound-only MX

```yaml
---
- name: Playbook
  gather_facts: true
  become: true
  hosts: all
  roles:
    - name: meysam81.general.postfix
      vars:
        postfix_myhostname: mx.example.com
        postfix_mydomain: example.com
        postfix_smtpd_tls_cert_file: /etc/lego/certificates/mx.example.com.crt
        postfix_smtpd_tls_key_file:  /etc/lego/certificates/mx.example.com.key
        postfix_virtual_mailbox_domains:
          - example.com
        postfix_virtual_alias_maps:
          - { pattern: "@example.com", target: "user@localhost" }
```
