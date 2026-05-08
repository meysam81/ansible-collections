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

Install and configure Postfix, opinionated toward inbound-only MX deployments

## Table of contents

- [Requirements](#requirements)
- [Default Variables](#default-variables)
  - [postfix_compatibility_level](#postfix_compatibility_level)
  - [postfix_disable_submission](#postfix_disable_submission)
  - [postfix_disable_vrfy](#postfix_disable_vrfy)
  - [postfix_extra_main_cf](#postfix_extra_main_cf)
  - [postfix_helo_restrictions](#postfix_helo_restrictions)
  - [postfix_inet_interfaces](#postfix_inet_interfaces)
  - [postfix_inet_protocols](#postfix_inet_protocols)
  - [postfix_local_root_alias](#postfix_local_root_alias)
  - [postfix_message_size_limit](#postfix_message_size_limit)
  - [postfix_mydomain](#postfix_mydomain)
  - [postfix_myhostname](#postfix_myhostname)
  - [postfix_mynetworks](#postfix_mynetworks)
  - [postfix_pure_virtual](#postfix_pure_virtual)
  - [postfix_recipient_restrictions](#postfix_recipient_restrictions)
  - [postfix_relay_restrictions](#postfix_relay_restrictions)
  - [postfix_smtpd_client_connection_count_limit](#postfix_smtpd_client_connection_count_limit)
  - [postfix_smtpd_client_connection_rate_limit](#postfix_smtpd_client_connection_rate_limit)
  - [postfix_smtpd_helo_required](#postfix_smtpd_helo_required)
  - [postfix_smtpd_recipient_limit](#postfix_smtpd_recipient_limit)
  - [postfix_smtpd_sasl_auth_enable](#postfix_smtpd_sasl_auth_enable)
  - [postfix_smtpd_sender_restrictions](#postfix_smtpd_sender_restrictions)
  - [postfix_smtpd_tls_cert_file](#postfix_smtpd_tls_cert_file)
  - [postfix_smtpd_tls_key_file](#postfix_smtpd_tls_key_file)
  - [postfix_smtpd_tls_protocols](#postfix_smtpd_tls_protocols)
  - [postfix_smtpd_tls_security_level](#postfix_smtpd_tls_security_level)
  - [postfix_virtual_alias_maps](#postfix_virtual_alias_maps)
  - [postfix_virtual_mailbox_domains](#postfix_virtual_mailbox_domains)
  - [postfix_virtual_transport](#postfix_virtual_transport)
- [Dependencies](#dependencies)
- [License](#license)
- [Author](#author)

---

## Requirements

- Minimum Ansible version: `2.15`

## Default Variables

### postfix_compatibility_level

#### Default value

```YAML
postfix_compatibility_level: '3.6'
```

### postfix_disable_submission

#### Default value

```YAML
postfix_disable_submission: true
```

### postfix_disable_vrfy

#### Default value

```YAML
postfix_disable_vrfy: true
```

### postfix_extra_main_cf

#### Default value

```YAML
postfix_extra_main_cf: {}
```

### postfix_helo_restrictions

#### Default value

```YAML
postfix_helo_restrictions:
  - permit_mynetworks
  - reject_invalid_helo_hostname
  - reject_non_fqdn_helo_hostname
  - permit
```

### postfix_inet_interfaces

#### Default value

```YAML
postfix_inet_interfaces: all
```

### postfix_inet_protocols

#### Default value

```YAML
postfix_inet_protocols: all
```

### postfix_local_root_alias

#### Default value

```YAML
postfix_local_root_alias: ''
```

### postfix_message_size_limit

#### Default value

```YAML
postfix_message_size_limit: 52428800
```

### postfix_mydomain

#### Default value

```YAML
postfix_mydomain: ''
```

### postfix_myhostname

#### Default value

```YAML
postfix_myhostname: ''
```

### postfix_mynetworks

#### Default value

```YAML
postfix_mynetworks:
  - 127.0.0.0/8
  - '[::1]/128'
```

### postfix_pure_virtual

#### Default value

```YAML
postfix_pure_virtual: false
```

### postfix_recipient_restrictions

#### Default value

```YAML
postfix_recipient_restrictions:
  - permit_mynetworks
  - reject_non_fqdn_recipient
  - reject_unknown_recipient_domain
  - reject_unauth_destination
  - permit
```

### postfix_relay_restrictions

#### Default value

```YAML
postfix_relay_restrictions:
  - permit_mynetworks
  - reject_unauth_destination
```

### postfix_smtpd_client_connection_count_limit

#### Default value

```YAML
postfix_smtpd_client_connection_count_limit: 50
```

### postfix_smtpd_client_connection_rate_limit

#### Default value

```YAML
postfix_smtpd_client_connection_rate_limit: 100
```

### postfix_smtpd_helo_required

#### Default value

```YAML
postfix_smtpd_helo_required: true
```

### postfix_smtpd_recipient_limit

#### Default value

```YAML
postfix_smtpd_recipient_limit: 10
```

### postfix_smtpd_sasl_auth_enable

#### Default value

```YAML
postfix_smtpd_sasl_auth_enable: false
```

### postfix_smtpd_sender_restrictions

#### Default value

```YAML
postfix_smtpd_sender_restrictions:
  - permit_mynetworks
  - reject_non_fqdn_sender
  - reject_unknown_sender_domain
```

### postfix_smtpd_tls_cert_file

#### Default value

```YAML
postfix_smtpd_tls_cert_file: ''
```

### postfix_smtpd_tls_key_file

#### Default value

```YAML
postfix_smtpd_tls_key_file: ''
```

### postfix_smtpd_tls_protocols

#### Default value

```YAML
postfix_smtpd_tls_protocols: '>=TLSv1.2'
```

### postfix_smtpd_tls_security_level

#### Default value

```YAML
postfix_smtpd_tls_security_level: may
```

### postfix_virtual_alias_maps

#### Default value

```YAML
postfix_virtual_alias_maps: []
```

### postfix_virtual_mailbox_domains

#### Default value

```YAML
postfix_virtual_mailbox_domains: []
```

### postfix_virtual_transport

#### Default value

```YAML
postfix_virtual_transport: lmtp:unix:private/dovecot-lmtp
```

## Dependencies

None.

## License

Apache-2.0

## Author

Meysam Azad
