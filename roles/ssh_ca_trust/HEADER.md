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
  `/usr/sbin/nologin`, `authorized_keys` and `authorized_keys2` emptied. The
  user the play connects as (`ansible_user`, or `SUDO_USER` under become) is
  refused.
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

1. If `ssh-ca-trust-rollback.timer` is still armed from an earlier run, that
   change was never confirmed: the role stops and lets the timer restore it
   (or `systemctl stop ssh-ca-trust-rollback.timer` by hand).
2. Before the first write it saves every path it manages, and records the
   ones that do not exist yet, in `/var/lib/ssh_ca_trust/snapshot-<epoch>/`
   (the newest 10 are kept; a run that changes nothing removes its own).
3. Still before the first write it arms `systemd-run
   --unit=ssh-ca-trust-rollback --on-active=<ssh_ca_trust_rollback_seconds>`,
   which runs `/usr/local/sbin/ssh-ca-trust-rollback <snapshot>`. A run that
   dies or loses the host halfway is restored by the timer.
4. If nothing changed, it disarms the timer and drops the snapshot.
5. If anything changed, it runs `sshd -t`, checks with `sshd -T` that the
   drop-in is in effect, and runs `systemctl try-reload-or-restart
   ssh.service`, then drops the connection and opens a fresh one (30 s
   timeout).
6. Once the fresh connection works and the timer has not fired, it disarms
   the timer.

Any failure while the host is reachable (a write, `sshd -t`, `sshd -T`, the
reload, a timer that fired too early) restores the snapshot at once, disarms
the timer and stops. If the fresh connection fails, the play stops with "the
rollback restores the previous SSH config in N s" and the host does it by
itself. `ssh_ca_trust_rollback_seconds` covers the whole run from the first
write, so raise it for a slow connection or many users.

A restore refuses a damaged snapshot without touching anything. Otherwise it
extracts the saved files, removes the drop-in if it did not exist, and reloads
sshd only if `sshd -t` accepts the result; only then does it delete the other
paths that did not exist. `revoked_keys` and its directory are never deleted
(an empty `revoked_keys` is harmless, a missing one makes sshd refuse every
key). User accounts, locked passwords and shells are not part of the
snapshot, which is why the role refuses to lock the user it connects as.

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
