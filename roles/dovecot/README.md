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

## Metrics

Dovecot 2.4's native OpenMetrics endpoint is off by default. Enable it to
expose auth, IMAP command and LMTP delivery counters:

```yaml
        dovecot_metrics_enabled: true
```

`dovecot_metrics_listen_address` defaults to `127.0.0.1` — loopback,
**independent of `dovecot_listen`**, so widening `dovecot_listen` for real
mail traffic never also widens this unauthenticated endpoint. Scrape it at
`127.0.0.1:9900` (or `[::1]:9900` if you set it to `::1`) with a local
agent — see the `alloy` role.

Setting `dovecot_metrics_listen_address` emits an explicit `address =`
line, which Dovecot 2.4.0-2.4.1 accept and 2.4.5+ reject (no per-listener
bind setting exists in the 2.4.5 docs). The rendered config is validated
both by `validate: "doveconf -c %s -n"` on the template task and the
existing separate `doveconf -n` task, so on 2.4.5+ a non-empty
`dovecot_metrics_listen_address` fails the play loudly rather than
silently landing a config the daemon would reject or, worse, exposing the
endpoint some other way. On 2.4.5+, clear it to `""` to inherit every
`dovecot_listen` address instead of a single explicit one — this is the
only way to scrape the endpoint at all on that version if you can't reach
loopback, so firewall port 9900 yourself when you do this, since nothing
in this role restricts it once it is bound to non-loopback addresses.

Install and configure Dovecot 2.4 with virtual users (passwd-file), Maildir, IMAP, and LMTP for Postfix integration

## Table of contents

- [Requirements](#requirements)
- [Default Variables](#default-variables)
  - [dovecot_auth_allow_cleartext](#dovecot_auth_allow_cleartext)
  - [dovecot_default_mailboxes](#dovecot_default_mailboxes)
  - [dovecot_disable_plain_imap](#dovecot_disable_plain_imap)
  - [dovecot_expunge_enabled](#dovecot_expunge_enabled)
  - [dovecot_expunge_on_calendar](#dovecot_expunge_on_calendar)
  - [dovecot_expunge_random_delay_sec](#dovecot_expunge_random_delay_sec)
  - [dovecot_expunge_rules](#dovecot_expunge_rules)
  - [dovecot_extra_conf](#dovecot_extra_conf)
  - [dovecot_listen](#dovecot_listen)
  - [dovecot_lmtp_catchall_enabled](#dovecot_lmtp_catchall_enabled)
  - [dovecot_mail_driver](#dovecot_mail_driver)
  - [dovecot_mail_path](#dovecot_mail_path)
  - [dovecot_metrics](#dovecot_metrics)
  - [dovecot_metrics_enabled](#dovecot_metrics_enabled)
  - [dovecot_metrics_listen_address](#dovecot_metrics_listen_address)
  - [dovecot_metrics_port](#dovecot_metrics_port)
  - [dovecot_passwd_file](#dovecot_passwd_file)
  - [dovecot_passwd_scheme](#dovecot_passwd_scheme)
  - [dovecot_postfix_lmtp_socket_group](#dovecot_postfix_lmtp_socket_group)
  - [dovecot_postfix_lmtp_socket_mode](#dovecot_postfix_lmtp_socket_mode)
  - [dovecot_postfix_lmtp_socket_owner](#dovecot_postfix_lmtp_socket_owner)
  - [dovecot_postfix_lmtp_socket_path](#dovecot_postfix_lmtp_socket_path)
  - [dovecot_postmaster_address](#dovecot_postmaster_address)
  - [dovecot_protocols](#dovecot_protocols)
  - [dovecot_ssl_required](#dovecot_ssl_required)
  - [dovecot_ssl_server_cert_file](#dovecot_ssl_server_cert_file)
  - [dovecot_ssl_server_key_file](#dovecot_ssl_server_key_file)
  - [dovecot_userdb_mode](#dovecot_userdb_mode)
  - [dovecot_users](#dovecot_users)
  - [dovecot_vmail_gid](#dovecot_vmail_gid)
  - [dovecot_vmail_group](#dovecot_vmail_group)
  - [dovecot_vmail_home_base](#dovecot_vmail_home_base)
  - [dovecot_vmail_uid](#dovecot_vmail_uid)
  - [dovecot_vmail_user](#dovecot_vmail_user)
- [Dependencies](#dependencies)
- [License](#license)
- [Author](#author)

---

## Requirements

- Minimum Ansible version: `2.15`

## Default Variables

### dovecot_auth_allow_cleartext

#### Default value

```YAML
dovecot_auth_allow_cleartext: false
```

### dovecot_default_mailboxes

#### Default value

```YAML
dovecot_default_mailboxes: [INBOX]
```

### dovecot_disable_plain_imap

#### Default value

```YAML
dovecot_disable_plain_imap: true
```

### dovecot_expunge_enabled

#### Default value

```YAML
dovecot_expunge_enabled: false
```

### dovecot_expunge_on_calendar

#### Default value

```YAML
dovecot_expunge_on_calendar: daily
```

### dovecot_expunge_random_delay_sec

#### Default value

```YAML
dovecot_expunge_random_delay_sec: 600
```

### dovecot_expunge_rules

#### Default value

```YAML
dovecot_expunge_rules: []
```

### dovecot_extra_conf

#### Default value

```YAML
dovecot_extra_conf: ''
```

### dovecot_listen

#### Default value

```YAML
dovecot_listen: [127.0.0.1, ::1]
```

### dovecot_lmtp_catchall_enabled

#### Default value

```YAML
dovecot_lmtp_catchall_enabled: false
```

### dovecot_mail_driver

#### Default value

```YAML
dovecot_mail_driver: maildir
```

### dovecot_mail_path

#### Default value

```YAML
dovecot_mail_path: ~/Maildir
```

### dovecot_metrics

#### Default value

```YAML
dovecot_metrics:
  - name: auth_success
    filter: event=auth_request_finished AND success=yes
  - name: auth_failure
    filter: event=auth_request_finished AND success=no
  - name: imap_command
    filter: event=imap_command_finished
    group_by: [cmd_name, tagged_reply_state]
  - name: lmtp_delivery
    filter: event=mail_delivery_finished
  - name: lmtp_delivery_error
    filter: event=mail_delivery_finished AND error=*
```

### dovecot_metrics_enabled

#### Default value

```YAML
dovecot_metrics_enabled: false
```

### dovecot_metrics_listen_address

#### Default value

```YAML
dovecot_metrics_listen_address: 127.0.0.1
```

### dovecot_metrics_port

#### Default value

```YAML
dovecot_metrics_port: 9900
```

### dovecot_passwd_file

#### Default value

```YAML
dovecot_passwd_file: /etc/dovecot/users
```

### dovecot_passwd_scheme

#### Default value

```YAML
dovecot_passwd_scheme: ARGON2ID
```

### dovecot_postfix_lmtp_socket_group

#### Default value

```YAML
dovecot_postfix_lmtp_socket_group: postfix
```

### dovecot_postfix_lmtp_socket_mode

#### Default value

```YAML
dovecot_postfix_lmtp_socket_mode: '0660'
```

### dovecot_postfix_lmtp_socket_owner

#### Default value

```YAML
dovecot_postfix_lmtp_socket_owner: postfix
```

### dovecot_postfix_lmtp_socket_path

#### Default value

```YAML
dovecot_postfix_lmtp_socket_path: /var/spool/postfix/private/dovecot-lmtp
```

### dovecot_postmaster_address

#### Default value

```YAML
dovecot_postmaster_address: ''
```

### dovecot_protocols

#### Default value

```YAML
dovecot_protocols: [imap, lmtp]
```

### dovecot_ssl_required

#### Default value

```YAML
dovecot_ssl_required: true
```

### dovecot_ssl_server_cert_file

#### Default value

```YAML
dovecot_ssl_server_cert_file: ''
```

### dovecot_ssl_server_key_file

#### Default value

```YAML
dovecot_ssl_server_key_file: ''
```

### dovecot_userdb_mode

#### Default value

```YAML
dovecot_userdb_mode: passwd_file
```

### dovecot_users

#### Default value

```YAML
dovecot_users: []
```

### dovecot_vmail_gid

#### Default value

```YAML
dovecot_vmail_gid: 5000
```

### dovecot_vmail_group

#### Default value

```YAML
dovecot_vmail_group: vmail
```

### dovecot_vmail_home_base

#### Default value

```YAML
dovecot_vmail_home_base: /var/vmail
```

### dovecot_vmail_uid

#### Default value

```YAML
dovecot_vmail_uid: 5000
```

### dovecot_vmail_user

#### Default value

```YAML
dovecot_vmail_user: vmail
```

## Dependencies

None.

## License

Apache-2.0

## Author

Meysam Azad
