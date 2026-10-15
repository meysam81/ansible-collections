# unattended_upgrades

Automatic package upgrades with
[unattended-upgrades](https://github.com/mvo5/unattended-upgrades): security
updates install as soon as they are released, regular updates install from an
[APT archive snapshot](https://snapshot.ubuntu.com/) a fixed number of days
old, and reboots happen only when required, optionally inside a recurring
window.

## What this role does

- Installs `unattended-upgrades` and writes the whole `APT::Periodic` and
  `Unattended-Upgrade` configuration to
  `/etc/apt/apt.conf.d/52unattended-upgrades-local`. The vendor
  `50unattended-upgrades` stays untouched (no dpkg conffile prompts); `#clear`
  lines drop its values, so the effective configuration is exactly this file.
- **Delayed regular updates** (`unattended_upgrades_delay_days`, default 14):
  - `/usr/local/sbin/apt-delay-snapshot` writes
    `APT::Snapshot "<today − N days>T000000Z"` to
    `/etc/apt/apt.conf.d/99delay-snapshot`, run before every `apt-daily`
    update through a `apt-daily.service.d/50-delay-snapshot.conf` drop-in.
  - Security sources are marked `Snapshot: no` (deb822) or `[snapshot=no]`
    (one-line) in place, so security updates always install live. Mirrors and
    everything else in the sources files are left untouched.
  - The `-updates` origins are allowed only while the delay is active, so
    regular updates are either at least N days old or not installed at all.
  - Debian's `-updates` and `-backports` Release files expire after 7 days,
    so a snapshot looks expired: the same file extends
    `Acquire::Min-ValidTime` for the `Debian` and `Debian Backports` labels by
    the delay plus two days. The live `Debian-Security` label keeps its full
    freshness check.
- **Reboot window** (opt-in, `unattended_upgrades_reboot_window_enabled`): a
  `reboot-if-required.timer` reboots only when `/run/reboot-required` exists,
  waits for a running `apt-daily-upgrade` (a oneshot unit, so `activating`
  counts as running), and gives up when the window closes. The service
  refuses manual starts, so a stray `systemctl start` cannot reboot the host
  outside the window; a missed window does not fire at boot.
- Ensures `apt-daily.timer` and `apt-daily-upgrade.timer` are enabled.
- Every feature is reversible: disabling it removes its files and units.

### Daily flow

1. `apt-daily.service` runs `apt-delay-snapshot`, then `apt update`: archive
   indexes come from the snapshot server, security indexes live.
2. `apt-daily-upgrade.service` runs unattended-upgrade. APT picks the highest
   available version, so a security fix installs on the next run.
3. Packages that need a reboot (kernel, libc) create `/run/reboot-required`.
4. With the reboot window on: at the window start (plus up to
   `unattended_upgrades_reboot_window_random_delay_sec`), the host reboots if
   that file exists.

## Platform support

The delay needs APT snapshot support. The role reads the installed apt
version and acts on it:

| Distro | apt | Delay | How |
|--------|-----|-------|-----|
| Ubuntu 23.10+ (incl. 24.04) | 2.7+ | yes | every source with a known snapshot server; security marked `Snapshot: no` |
| Debian 13 trixie | 3.0 | yes | same |
| Ubuntu 22.04 / 20.04 | ≥ 2.4.11 / ≥ 2.0.10 | yes | official pockets in the distro's own sources files opted in with `snapshot=yes`, security `snapshot=no` |
| Debian 12 bookworm, older apt | < 2.7 | no | warning; **security updates only** |

Where the delay cannot apply, the role still configures unattended-upgrades
but leaves the regular-update origins out, so nothing installs undelayed.

### Sources

- A deb822 stanza mixing a `-security` suite with other suites (common on
  some cloud images) fails the play: `Snapshot:` applies to the whole stanza.
  Move the security suite into a stanza of its own.
- On apt 2.7+, sources with no known snapshot server (most third-party repos,
  Ubuntu Pro/ESM) silently stay live. Launchpad PPAs have one
  (`snapshot.ppa.launchpadcontent.net`) and are delayed like the archive.
- On Ubuntu 22.04/20.04, only `/etc/apt/sources.list` and
  `/etc/apt/sources.list.d/{ubuntu,debian}.sources` get opt-ins: third-party
  repos reuse codename suites but have no snapshot server, and an opt-in there
  breaks `apt update`. Keep third-party repos in their own files.
- Disabling the delay leaves the `Snapshot` options in place: without
  `APT::Snapshot` they do nothing.

### Network

Hosts need outbound HTTPS to `snapshot.ubuntu.com` or `snapshot.debian.org`
(allow it in `egress_firewall` or the proxy behind `proxy_client`, if used).
If the snapshot server is unreachable, archive indexes fail to update and no
regular updates install that day. Security indexes still refresh and security
updates still install.

## Pairing with other roles

- `node_textfile_metrics` exports `node_reboot_required` from the same
  `/run/reboot-required`: alert on hosts that stay pending past a window.
- `proxy_client` sets apt's proxy; snapshot fetches go through it.

## Runbook

Urgent non-security fix that can't wait for the delay:

```sh
sudo rm /etc/apt/apt.conf.d/99delay-snapshot
sudo apt update && sudo apt install <pkg>
sudo /usr/local/sbin/apt-delay-snapshot && sudo apt update
```

Check that the delay works: `apt-get update` must fetch the `-security`
suite from its usual host and everything else from `snapshot.*/…/<date>`.

## Install

### requirements.yml

```yaml
collections:
  - name: meysam81.general
    version: 1.13.0
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
    - name: meysam81.general.unattended_upgrades
```

Defaults: security live, regular updates delayed 14 days, no automatic
reboot.

### Reboot window, Sunday 00:00–02:00 UTC

```yaml
      vars:
        unattended_upgrades_reboot_window_enabled: true
```

### Weekday reboot window in local time, 1h

```yaml
      vars:
        unattended_upgrades_reboot_window_enabled: true
        unattended_upgrades_reboot_window_on_calendar: Mon..Fri *-*-* 03:00:00 Europe/Berlin
        unattended_upgrades_reboot_window_duration_sec: 3600
        unattended_upgrades_reboot_window_random_delay_sec: 600
```

### Security only, no delay

```yaml
      vars:
        unattended_upgrades_delay_days: 0
```

### Extra origin, mail on errors

```yaml
      vars:
        unattended_upgrades_origins_patterns: >-
          {{ unattended_upgrades_distro_origins[ansible_facts['distribution']].live
             + ['origin=Docker,label=Docker CE'] }}
        unattended_upgrades_mail: ops@example.com
        unattended_upgrades_mail_report: only-on-error
```

### Debian derivatives

Only Debian and Ubuntu have default origins. Elsewhere,
`unattended_upgrades_origins_patterns` is required and the play fails without
it. List the origins from `apt-cache policy`.

## Variables

Defaults follow unattended-upgrades and apt upstream except where noted.

### Delay and origins

| Variable | Default | Description |
|----------|---------|-------------|
| `unattended_upgrades_delay_days` | `14` | Age of the snapshot regular updates come from. `0` disables the delay and the regular-update origins. |
| `unattended_upgrades_origins_patterns` | distro security origins | `Origins-Pattern` entries installed live. Required on non-Debian/Ubuntu derivatives. |
| `unattended_upgrades_delayed_origins_patterns` | distro `-updates` (and Debian's point-release) origins | `Origins-Pattern` entries installed only while the delay is active. |

### Package selection

| Variable | Default | Description |
|----------|---------|-------------|
| `unattended_upgrades_package_blacklist` | `[]` | `Package-Blacklist`: Python regexes never upgraded. |
| `unattended_upgrades_package_whitelist` | `[]` | `Package-Whitelist`: when set, only matching packages are upgraded. |
| `unattended_upgrades_package_whitelist_strict` | `false` | `Package-Whitelist-Strict`: also hold back dependencies not on the whitelist. |

### Upgrade behaviour

| Variable | Default | Description |
|----------|---------|-------------|
| `unattended_upgrades_allow_apt_mark_fallback` | `true` | `Allow-APT-Mark-Fallback`. |
| `unattended_upgrades_allow_downgrade` | `false` | `Allow-downgrade` when a pin has priority > 1000. |
| `unattended_upgrades_auto_fix_interrupted_dpkg` | `true` | `AutoFixInterruptedDpkg`. |
| `unattended_upgrades_dev_release` | `auto` | `DevRelease`: `auto`, `true` or `false`. |
| `unattended_upgrades_dl_limit` | `0` | `Acquire::http::Dl-Limit` in kB/s; rendered only when > 0 (host-wide). |
| `unattended_upgrades_dpkg_options` | `[]` | `Dpkg::Options`; rendered only when set (host-wide). |
| `unattended_upgrades_install_on_shutdown` | `false` | `InstallOnShutdown`. |
| `unattended_upgrades_keep_debs_after_install` | `false` | `Keep-Debs-After-Install`. |
| `unattended_upgrades_minimal_steps` | `true` | `MinimalSteps`. |
| `unattended_upgrades_only_on_ac_power` | `true` | `OnlyOnACPower`. |
| `unattended_upgrades_skip_updates_on_metered_connections` | `true` | `Skip-Updates-On-Metered-Connections`. |
| `unattended_upgrades_update_days` | `[]` | `Update-Days`, e.g. `["Mon", "Fri"]`; empty is every day. Also holds back security updates. |

### Cleanup

| Variable | Default | Description |
|----------|---------|-------------|
| `unattended_upgrades_remove_new_unused_dependencies` | `true` | `Remove-New-Unused-Dependencies`. |
| `unattended_upgrades_remove_unused_dependencies` | `false` | `Remove-Unused-Dependencies`. |
| `unattended_upgrades_remove_unused_kernel_packages` | `true` | `Remove-Unused-Kernel-Packages`. |

### Mail and logging

| Variable | Default | Description |
|----------|---------|-------------|
| `unattended_upgrades_debug` | `false` | `Debug`. |
| `unattended_upgrades_mail` | `""` | `Mail` recipient; empty sends nothing. Needs a local MTA and mailx. |
| `unattended_upgrades_mail_report` | `on-change` | `MailReport`: `always`, `only-on-error` or `on-change`. |
| `unattended_upgrades_sender` | `root` | `Sender`. |
| `unattended_upgrades_syslog_enable` | `false` | `SyslogEnable`. |
| `unattended_upgrades_syslog_facility` | `daemon` | `SyslogFacility`. |
| `unattended_upgrades_verbose` | `false` | `Verbose`. |

### Reboot

| Variable | Default | Description |
|----------|---------|-------------|
| `unattended_upgrades_automatic_reboot` | `false` | `Automatic-Reboot`: unattended-upgrades' own reboot. Mutually exclusive with the reboot window. |
| `unattended_upgrades_automatic_reboot_ignored_users` | `[]` | `Automatic-Reboot-IgnoredUsers`. |
| `unattended_upgrades_automatic_reboot_time` | `now` | `Automatic-Reboot-Time`: `now` or `HH:MM`. |
| `unattended_upgrades_automatic_reboot_with_system_users` | `true` | `Automatic-Reboot-WithSystemUsers`. |
| `unattended_upgrades_automatic_reboot_with_users` | `true` | `Automatic-Reboot-WithUsers`. |
| `unattended_upgrades_reboot_window_duration_sec` | `7200` | The reboot happens within this many seconds of the window start, or not at all. |
| `unattended_upgrades_reboot_window_enabled` | `false` | Reboot only inside the window, only when required. |
| `unattended_upgrades_reboot_window_on_calendar` | `Sun *-*-* 00:00:00 UTC` | systemd `OnCalendar` of the window start. |
| `unattended_upgrades_reboot_window_random_delay_sec` | `1800` | `RandomizedDelaySec`; must be shorter than the window. |

### APT::Periodic

Intervals are days, or take an `s`/`m`/`h`/`d` suffix, or `always`.

| Variable | Default | Description |
|----------|---------|-------------|
| `unattended_upgrades_periodic_autoclean_interval` | `"0"` | `AutocleanInterval`. |
| `unattended_upgrades_periodic_backup_archive_interval` | `"0"` | `BackupArchiveInterval`. |
| `unattended_upgrades_periodic_backup_level` | `"3"` | `BackupLevel`. |
| `unattended_upgrades_periodic_clean_interval` | `"0"` | `CleanInterval`. |
| `unattended_upgrades_periodic_download_upgradeable_packages` | `"0"` | `Download-Upgradeable-Packages`. |
| `unattended_upgrades_periodic_download_upgradeable_packages_debdelta` | `"1"` | `Download-Upgradeable-Packages-Debdelta`. |
| `unattended_upgrades_periodic_enable` | `true` | `Enable`. |
| `unattended_upgrades_periodic_max_age` | `"0"` | `MaxAge`. |
| `unattended_upgrades_periodic_max_size` | `"0"` | `MaxSize` in MB. |
| `unattended_upgrades_periodic_min_age` | `"2"` | `MinAge`. |
| `unattended_upgrades_periodic_unattended_upgrade` | `"1"` | `Unattended-Upgrade` (upstream `0`). |
| `unattended_upgrades_periodic_update_package_lists` | `"1"` | `Update-Package-Lists` (upstream `0`). |
| `unattended_upgrades_periodic_verbose` | `"0"` | `Verbose`: 0 none, 1 progress, 2 command output, 3 trace. |
