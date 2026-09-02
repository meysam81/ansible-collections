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
