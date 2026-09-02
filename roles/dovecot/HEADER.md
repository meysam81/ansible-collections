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

By default the stats listener binds the same addresses as `dovecot_listen`;
scrape it on one of those (e.g. `[::1]:9900`) with a local agent (see the
`alloy` role) — never exposed directly. Setting
`dovecot_metrics_listen_address` emits an explicit `address =` line, which
Dovecot 2.4.0-2.4.1 accept and 2.4.5+ reject (no per-listener bind setting
exists in the 2.4.5 docs) — leave it empty on newer releases. The rendered
config is validated both by `validate: "doveconf -c %s -n"` on the template
task and the existing separate `doveconf -n` task, so a misconfigured
`filter` (or an `address =` a newer Dovecot rejects) fails the play rather
than the daemon.
