# needrestart

[needrestart](https://github.com/liske/needrestart) after every apt or dpkg
run, unattended upgrades included: services still running a replaced library
are restarted, so a library security fix (OpenSSL, glibc, PAM) is in effect
as soon as it is installed, without a reboot.

## What this role does

- Installs `needrestart`. Its dpkg `Post-Invoke` hook runs it after every
  package run, which is how unattended-upgrades reaches it.
- Writes `/etc/needrestart/conf.d/50-ansible.conf` (checked with `perl -c`);
  the package's `needrestart.conf` stays untouched.
- `needrestart_restart_mode: a` restarts affected services. needrestart's own
  list still defers units that are unsafe to restart (dbus, systemd-logind,
  getty, display managers); `needrestart_skip_services` adds to it.
- Kernel and microcode updates still need a reboot: needrestart only reports
  them. Pair with `unattended_upgrades`' reboot window for those.

## Pairing with other roles

- `unattended_upgrades`: installs the fixes, this role puts library fixes in
  effect, its reboot window takes care of kernels.

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
    - name: meysam81.general.unattended_upgrades
    - name: meysam81.general.needrestart
```

### Leave a front door to a manual restart

```yaml
      vars:
        needrestart_skip_services:
          - ^haproxy\.service$
```

## Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `needrestart_restart_mode` | `a` | `a` restarts services running replaced libraries, `l` only lists them, `i` asks. |
| `needrestart_skip_services` | `[]` | Perl regexes of units never restarted automatically, added to needrestart's own list. |

needrestart restarts services still running replaced libraries after every apt or dpkg run, unattended upgrades included.

## Table of contents

- [Requirements](#requirements)
- [Default Variables](#default-variables)
  - [needrestart_restart_mode](#needrestart_restart_mode)
  - [needrestart_skip_services](#needrestart_skip_services)
- [Dependencies](#dependencies)
- [License](#license)
- [Author](#author)

---

## Requirements

- Minimum Ansible version: `2.15`

## Default Variables

### needrestart_restart_mode

#### Default value

```YAML
needrestart_restart_mode: a
```

### needrestart_skip_services

#### Default value

```YAML
needrestart_skip_services: []
```

## Dependencies

None.

## License

Apache-2.0

## Author

Meysam Azad
