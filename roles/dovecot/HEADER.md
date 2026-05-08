# Dovecot

Install and configure Dovecot 2.4 IMAP + LMTP server. Targets virtual-user, passwd-file authentication with Maildir storage. Includes optional `doveadm expunge` retention timer.

## Install

### requirements.yml

```yaml
collections:
  - name: meysam81.general
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
    - name: meysam81.general.dovecot
      vars:
        dovecot_listen: ["10.0.0.1", "::1"]
        dovecot_ssl_server_cert_file: /etc/lego/certificates/mx.example.com.crt
        dovecot_ssl_server_key_file:  /etc/lego/certificates/mx.example.com.key
        dovecot_users:
          - name: alice
            password_hash: "{ARGON2ID}$argon2id$..."
            home: /var/vmail/alice
        dovecot_default_mailboxes: ["INBOX", "PROCESSED"]
```
