# ssh_ca_trust

OpenSSH certificate trust for login users: short-lived certificates from a
user CA replace static keys, each CA is bound to the users it may log in as,
break-glass keys stay in place, and any sshd change that breaks the next login
rolls itself back on the host.

## What this role does

- Creates login users (`ssh_ca_trust_users`), with NOPASSWD sudo through
  `/etc/sudoers.d/ssh-ca-trust-<name>` (checked with `visudo`) where asked.
- Writes `/etc/ssh/ssh_ca_trust/`:
  - `user_ca_keys`: the CAs sshd trusts for every user (`TrustedUserCAKeys`).
  - `principals/<user>`: the certificate principals each user accepts
    (`AuthorizedPrincipalsFile`). A user without a file accepts no
    certificate from `user_ca_keys`; files of users no longer listed are
    removed.
  - `revoked_keys`: keys and certificates sshd refuses (`RevokedKeys`). It
    always exists, empty by default: sshd refuses every public key, static
    ones included, when `RevokedKeys` names a missing file.
- Manages `authorized_keys` per user (`ssh_ca_trust_authorized_keys`): adds
  lines and keeps the rest, or renders the whole file with `exclusive: true`.
  This is where a second CA is bound to exactly one user, with a
  `cert-authority,principals="..."` line, instead of trusting it for everyone.
- Locks users (`ssh_ca_trust_locked_users`): password locked, shell
  `/usr/sbin/nologin`, `authorized_keys` and `authorized_keys2` emptied.
- Writes `/etc/ssh/sshd_config.d/10-ssh-ca-trust.conf` last:

  ```text
  TrustedUserCAKeys /etc/ssh/ssh_ca_trust/user_ca_keys
  AuthorizedPrincipalsFile /etc/ssh/ssh_ca_trust/principals/%u
  RevokedKeys /etc/ssh/ssh_ca_trust/revoked_keys
  ```

These paths are fixed, so other provisioning (cloud-init, images) can write
the same files.

## Dead-man rollback

`authorized_keys` and principals files are read on every login, so a bad
change can lock the operator out without any sshd reload. The role guards
every run:

1. Before the first write it saves every path it manages, and records the
   ones that do not exist yet, in `/var/lib/ssh_ca_trust/snapshot-<epoch>/`
   (the newest 10 are kept; a run that changes nothing removes its own).
2. If a write fails, it restores the snapshot at once and stops.
3. If anything changed, it runs `sshd -t`, checks with `sshd -T` that the
   drop-in is in effect, and restores the snapshot if either fails.
4. It arms `systemd-run --unit=ssh-ca-trust-rollback
   --on-active=<ssh_ca_trust_rollback_seconds>`, which runs
   `/usr/local/sbin/ssh-ca-trust-rollback <snapshot>`.
5. It runs `systemctl try-reload-or-restart ssh.service`, drops the
   connection and opens a fresh one (30 s timeout).
6. Once the fresh connection works it stops the timer. If it does not, the
   play fails with "the rollback restores the previous SSH config in N s",
   and the host restores the snapshot and reloads sshd by itself.

The restore deletes the paths that did not exist, extracts the saved ones,
and reloads sshd only if `sshd -t` accepts the result. User accounts, locked
passwords and shells are not part of the snapshot.

By hand:

```sh
/usr/local/sbin/ssh-ca-trust-rollback --snapshot /etc/ssh/ssh_ca_trust/user_ca_keys
/usr/local/sbin/ssh-ca-trust-rollback /var/lib/ssh_ca_trust/snapshot-1700000000
```

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
    - name: meysam81.general.ssh_ca_trust
      vars:
        ssh_ca_trust_user_ca_keys:
          - ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAA... operator-ca
        ssh_ca_trust_principals:
          admin:
            - operator
        ssh_ca_trust_users:
          - name: admin
            sudo: true
          - name: deploy
            sudo: true
        ssh_ca_trust_authorized_keys:
          # Only certificates from the CI CA with principal "deploy" log in
          # as deploy; the CI CA is not trusted for any other user.
          - user: deploy
            keys:
              - cert-authority,principals="deploy" ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAA... ci-ca
          # Break-glass: the whole file, nothing else.
          - user: root
            exclusive: true
            keys:
              - sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAA... break-glass-1
        ssh_ca_trust_locked_users:
          - olduser
```

### A jump host user: forwarding to listed targets, no shell

```yaml
        ssh_ca_trust_users:
          - name: jump
            shell: /usr/sbin/nologin
        ssh_ca_trust_authorized_keys:
          - user: jump
            exclusive: true
            keys:
              - >-
                restrict,port-forwarding,permitopen="192.0.2.10:22",permitopen="192.0.2.11:22",command="/usr/sbin/nologin",cert-authority,principals="jump"
                ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAA... ci-ca
```

Then `ssh -J jump@bastion.example.com deploy@192.0.2.10` works and nothing
else does: no shell on the jump host, no forward to an unlisted `host:port`.

## Caveats

- Keep a working way in (a static key, or a break-glass key in `root`'s
  `authorized_keys`) until a certificate login has been proven on the host.
- Non-exclusive `authorized_keys` entries never remove lines; use
  `exclusive: true` to retire old keys.
- `--check` works on hosts where every listed user already exists.
- sshd must include `/etc/ssh/sshd_config.d/*.conf` (the Debian and Ubuntu
  default) and no earlier file may set the three keywords; the role checks
  this with `sshd -T` and rolls back otherwise.

## Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `ssh_ca_trust_authorized_keys` | `[]` | `[{user, keys: [line, ...], exclusive: false}]`; `exclusive` renders the whole file, otherwise each line is added. |
| `ssh_ca_trust_locked_users` | `[]` | Existing users to lock out: password locked, `nologin`, `authorized_keys` emptied. Missing users are skipped. |
| `ssh_ca_trust_principals` | `{}` | Required. `{user: [principal, ...]}`, one principals file per user; unlisted users' files are removed. |
| `ssh_ca_trust_revoked_keys` | `[]` | Lines of `revoked_keys` (`RevokedKeys`). The file always exists. |
| `ssh_ca_trust_rollback_seconds` | `120` | Seconds before an unconfirmed change rolls back. At least 60. |
| `ssh_ca_trust_service` | `ssh` | systemd unit (without `.service`) reloaded after a change. |
| `ssh_ca_trust_user_ca_keys` | `[]` | Required. Lines of `user_ca_keys` (`TrustedUserCAKeys`). |
| `ssh_ca_trust_users` | `[]` | `[{name, sudo: false, shell: /bin/bash}]` login users to create; `sudo` grants NOPASSWD sudo. |

OpenSSH certificate trust: a trusted user CA with per-user principals, per-user CA binding in authorized_keys, break-glass keys, users and sudoers, with a dead-man rollback of every sshd change.

## Table of contents

- [Requirements](#requirements)
- [Default Variables](#default-variables)
  - [ssh_ca_trust_authorized_keys](#ssh_ca_trust_authorized_keys)
  - [ssh_ca_trust_locked_users](#ssh_ca_trust_locked_users)
  - [ssh_ca_trust_principals](#ssh_ca_trust_principals)
  - [ssh_ca_trust_revoked_keys](#ssh_ca_trust_revoked_keys)
  - [ssh_ca_trust_rollback_seconds](#ssh_ca_trust_rollback_seconds)
  - [ssh_ca_trust_service](#ssh_ca_trust_service)
  - [ssh_ca_trust_user_ca_keys](#ssh_ca_trust_user_ca_keys)
  - [ssh_ca_trust_users](#ssh_ca_trust_users)
- [Dependencies](#dependencies)
- [License](#license)
- [Author](#author)

---

## Requirements

- Minimum Ansible version: `2.15`

## Default Variables

### ssh_ca_trust_authorized_keys

#### Default value

```YAML
ssh_ca_trust_authorized_keys: []
```

### ssh_ca_trust_locked_users

#### Default value

```YAML
ssh_ca_trust_locked_users: []
```

### ssh_ca_trust_principals

#### Default value

```YAML
ssh_ca_trust_principals: {}
```

### ssh_ca_trust_revoked_keys

#### Default value

```YAML
ssh_ca_trust_revoked_keys: []
```

### ssh_ca_trust_rollback_seconds

#### Default value

```YAML
ssh_ca_trust_rollback_seconds: 120
```

### ssh_ca_trust_service

#### Default value

```YAML
ssh_ca_trust_service: ssh
```

### ssh_ca_trust_user_ca_keys

#### Default value

```YAML
ssh_ca_trust_user_ca_keys: []
```

### ssh_ca_trust_users

#### Default value

```YAML
ssh_ca_trust_users: []
```

## Dependencies

None.

## License

Apache-2.0

## Author

Meysam Azad
