# auditd_laurel

`auditd` with a curated, low-noise ruleset, plus
[Laurel](https://github.com/threathunters-io/laurel) — an `auditd` plugin
that turns raw audit events into structured, correlated JSON lines
(`EXECVE` argv reassembled, PID/PPID/exe context attached) suitable for a
log pipeline instead of `ausearch`.

Laurel ships as a pinned, checksummed release tarball
(`laurel-<version>-<arch>-glibc.tar.gz`) — no build toolchain required.

## What this role does NOT do

- Does not set `-e 2` (immutable audit rules) anywhere — that requires a
  reboot to change rules again, which breaks re-running this role.
- Does not watch every `execve` or time-change syscall — both are
  extremely high-volume on a host running k3s/systemd-timesyncd and add
  little signal. `auditd_laurel_rules_extra` is the escape hatch if a
  specific host needs more.
- Does not `systemctl restart auditd` — auditd's unit sets
  `RefuseManualStop`, so a full restart is refused. Rule changes go
  through `augenrules --load` (loads straight into the kernel via
  `auditctl`, no auditd involvement); config/plugin changes go through
  `systemctl reload auditd` (SIGHUP, respawns the plugin dispatcher
  without stopping the daemon).

## Install

### requirements.yml

```yaml
collections:
  - name: meysam81.general
    version: 1.12.0
```

## Usage

```yaml
---
- name: Playbook
  gather_facts: true
  become: true
  hosts: all
  roles:
    - name: meysam81.general.auditd_laurel
```

### Grant a log shipper read access

```yaml
    - name: meysam81.general.auditd_laurel
      vars:
        auditd_laurel_read_users: [alloy]
```

### Extra rules for one host

```yaml
    - name: meysam81.general.auditd_laurel
      vars:
        auditd_laurel_rules_extra: |
          -w /var/vmail -p wa -k mailstore
```

## Default Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `auditd_laurel_backlog_limit` | `8192` | `-b`: kernel audit backlog buffer size. |
| `auditd_laurel_checksums` | pinned per-arch sha256 | sha256 of `laurel-<version>-<arch>-glibc.tar.gz`, keyed by `ansible_facts['architecture']`. |
| `auditd_laurel_failure_mode` | `1` | `-f`: `1` = printk and continue on backlog overflow, never silently drop. |
| `auditd_laurel_install_path` | `/usr/local/sbin/laurel` | Where the `laurel` binary is installed. |
| `auditd_laurel_log_dir` | `/var/log/laurel` | Laurel's own log directory (also its `_laurel` user's home). |
| `auditd_laurel_log_generations` | `10` | `audit.log` rotation generations kept. |
| `auditd_laurel_log_size` | `5000000` | `audit.log` rotation size in bytes. |
| `auditd_laurel_read_users` | `[]` | POSIX ACL read grants on the log files, for a non-root log shipper. |
| `auditd_laurel_rules` | curated identity/sudoers/sshd/cron/systemd/module/mount/rootcmd watches | `auditctl`-style lines, one per list entry. |
| `auditd_laurel_rules_extra` | `""` | Raw text appended verbatim after `auditd_laurel_rules`. |
| `auditd_laurel_transform_execve_argv` | `[array, string]` | Laurel's `EXECVE.ARGV` output forms. |
| `auditd_laurel_user` | `_laurel` | System user Laurel drops privileges to. |
| `auditd_laurel_version` | `0.8.2` | Laurel release to install. |

auditd with curated rules and Laurel (structured JSON audit log enrichment)

## Table of contents

- [Requirements](#requirements)
- [Default Variables](#default-variables)
  - [auditd_laurel_backlog_limit](#auditd_laurel_backlog_limit)
  - [auditd_laurel_checksums](#auditd_laurel_checksums)
  - [auditd_laurel_failure_mode](#auditd_laurel_failure_mode)
  - [auditd_laurel_install_path](#auditd_laurel_install_path)
  - [auditd_laurel_log_dir](#auditd_laurel_log_dir)
  - [auditd_laurel_log_generations](#auditd_laurel_log_generations)
  - [auditd_laurel_log_size](#auditd_laurel_log_size)
  - [auditd_laurel_read_users](#auditd_laurel_read_users)
  - [auditd_laurel_rules](#auditd_laurel_rules)
  - [auditd_laurel_rules_extra](#auditd_laurel_rules_extra)
  - [auditd_laurel_transform_execve_argv](#auditd_laurel_transform_execve_argv)
  - [auditd_laurel_user](#auditd_laurel_user)
  - [auditd_laurel_version](#auditd_laurel_version)
- [Dependencies](#dependencies)
- [License](#license)
- [Author](#author)

---

## Requirements

- Minimum Ansible version: `2.15`

## Default Variables

### auditd_laurel_backlog_limit

#### Default value

```YAML
auditd_laurel_backlog_limit: 8192
```

### auditd_laurel_checksums

#### Default value

```YAML
auditd_laurel_checksums:
  x86_64: c9b495acf67e9941760b24308145b513b2ee2a0a5bfe0a5bd70d5133c27c6e6c
  aarch64: fb15e9ff013a9ec65b8c81e76aed684a13d4f72ba68dcd8fdf8c1ba4e35c6a50
```

### auditd_laurel_failure_mode

#### Default value

```YAML
auditd_laurel_failure_mode: 1
```

### auditd_laurel_install_path

#### Default value

```YAML
auditd_laurel_install_path: /usr/local/sbin/laurel
```

### auditd_laurel_log_dir

#### Default value

```YAML
auditd_laurel_log_dir: /var/log/laurel
```

### auditd_laurel_log_generations

#### Default value

```YAML
auditd_laurel_log_generations: 10
```

### auditd_laurel_log_size

#### Default value

```YAML
auditd_laurel_log_size: 5000000
```

### auditd_laurel_read_users

#### Default value

```YAML
auditd_laurel_read_users: []
```

### auditd_laurel_rules

#### Default value

```YAML
auditd_laurel_rules:
  - -w /etc/passwd -p wa -k identity
  - -w /etc/shadow -p wa -k identity
  - -w /etc/group -p wa -k identity
  - -w /etc/gshadow -p wa -k identity
  - -w /etc/sudoers -p wa -k sudoers
  - -w /etc/sudoers.d/ -p wa -k sudoers
  - -w /etc/ssh/sshd_config -p wa -k sshd
  - -w /etc/ssh/sshd_config.d/ -p wa -k sshd
  - -w /root/.ssh/ -p wa -k rootkey
  - -w /etc/cron.d/ -p wa -k cron
  - -w /etc/crontab -p wa -k cron
  - -w /var/spool/cron/ -p wa -k cron
  - -w /etc/systemd/system/ -p wa -k systemd
  - -w /etc/audit/ -p wa -k auditconfig
  - -w /etc/laurel/ -p wa -k auditconfig
  - -a always,exit -F arch=b64 -S init_module,finit_module,delete_module -k modules
  - -a always,exit -F arch=b64 -S mount -F auid>=1000 -F auid!=-1 -k mount
  - -a always,exit -F arch=b64 -S execve -F euid=0 -F auid>=1000 -F auid!=-1 -k rootcmd
```

### auditd_laurel_rules_extra

#### Default value

```YAML
auditd_laurel_rules_extra: ''
```

### auditd_laurel_transform_execve_argv

#### Default value

```YAML
auditd_laurel_transform_execve_argv:
  - array
  - string
```

### auditd_laurel_user

#### Default value

```YAML
auditd_laurel_user: _laurel
```

### auditd_laurel_version

#### Default value

```YAML
auditd_laurel_version: 0.8.2
```

## Dependencies

None.

## License

Apache-2.0

## Author

Meysam Azad
