# sshd_hardening

A minimal, auditable OpenSSH hardening drop-in — one file, ~25 directives,
no framework. Deliberately not `devsec.hardening`'s `ssh_hardening`: that
role's defaults (`PermitRootLogin no`, `AllowTcpForwarding no`) lock
Ansible itself out of root-managed hosts and break `ProxyJump` through a
bastion. Every directive here is a plain variable instead, so a bastion
host can flip `sshd_hardening_allow_tcp_forwarding: "yes"` without
fighting the role's opinions.

## What this role does

- Writes a single drop-in at `sshd_hardening_dropin_path`
  (`/etc/ssh/sshd_config.d/00-hardening.conf` by default) — never touches
  `/etc/ssh/sshd_config` itself.
- Asserts `/etc/ssh/sshd_config` actually `Include`s `sshd_config.d/*.conf`
  before writing anything — OpenSSH ships this by default since 8.2, but a
  hand-edited config could have dropped it, which would make this role a
  silent no-op otherwise.
- Runs `sshd -t` against the real config immediately after writing the
  drop-in, and **removes the drop-in and fails** if it doesn't validate —
  a bad config never survives to the next `sshd` reload/restart.
- Ships a modern cipher/KEX/MAC list confirmed accepted by OpenSSH 9.2,
  9.6, and 10.0 (no post-quantum/hybrid KEX — not all three support it yet).

## What this role does NOT do

- Does not manage `AuthorizedKeysFile`, user accounts, or `sshd`
  installation/service enablement — it assumes a running, packaged
  `openssh-server`.
- Does not restart `sshd`; only reloads it (`systemctl reload ssh`) on
  change, which re-reads config without dropping existing connections.

## Install

### requirements.yml

```yaml
collections:
  - name: meysam81.general
    version: 1.12.0
```

## Usage

### Default (safe on any host Ansible manages over SSH)

```yaml
---
- name: Playbook
  gather_facts: true
  become: true
  hosts: all
  roles:
    - name: meysam81.general.sshd_hardening
```

### Bastion (ProxyJump target — needs TCP forwarding, root disabled)

```yaml
    - name: meysam81.general.sshd_hardening
      vars:
        sshd_hardening_permit_root_login: "no"
        sshd_hardening_allow_tcp_forwarding: "yes"
        sshd_hardening_allow_users: [meysam]
```

## Default Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `sshd_hardening_allow_agent_forwarding` | `"no"` | `AllowAgentForwarding`. |
| `sshd_hardening_allow_tcp_forwarding` | `"no"` | `AllowTcpForwarding`. `"yes"` on ProxyJump bastions. |
| `sshd_hardening_allow_users` | `[]` | `AllowUsers`; empty renders no directive (sshd's own default applies). |
| `sshd_hardening_ciphers` | modern AEAD/CTR list | `Ciphers`, accepted by OpenSSH 9.2/9.6/10.0. |
| `sshd_hardening_client_alive_count_max` | `2` | `ClientAliveCountMax`. |
| `sshd_hardening_client_alive_interval` | `300` | `ClientAliveInterval`. |
| `sshd_hardening_dropin_path` | `/etc/ssh/sshd_config.d/00-hardening.conf` | Drop-in path; `00-` sorts before other fragments. |
| `sshd_hardening_extra_options` | `{}` | `{Keyword: value}` pairs appended verbatim for anything not exposed above. |
| `sshd_hardening_kbd_interactive_authentication` | `"no"` | `KbdInteractiveAuthentication`. |
| `sshd_hardening_kex_algorithms` | modern curve25519/DH-group list | `KexAlgorithms`, accepted by OpenSSH 9.2/9.6/10.0. |
| `sshd_hardening_log_level` | `VERBOSE` | `LogLevel`. |
| `sshd_hardening_login_grace_time` | `30` | `LoginGraceTime` (seconds). |
| `sshd_hardening_macs` | modern ETM/UMAC list | `MACs`, accepted by OpenSSH 9.2/9.6/10.0. |
| `sshd_hardening_max_auth_tries` | `4` | `MaxAuthTries`. |
| `sshd_hardening_max_sessions` | `10` | `MaxSessions`. |
| `sshd_hardening_password_authentication` | `"no"` | `PasswordAuthentication`. |
| `sshd_hardening_permit_empty_passwords` | `"no"` | `PermitEmptyPasswords`. |
| `sshd_hardening_permit_root_login` | `prohibit-password` | `PermitRootLogin`. |
| `sshd_hardening_pubkey_authentication` | `"yes"` | `PubkeyAuthentication`. |
| `sshd_hardening_x11_forwarding` | `"no"` | `X11Forwarding`. |
