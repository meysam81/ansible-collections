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
