# nbde_client

Binds a LUKS2 device to [Tang](https://github.com/latchset/tang) servers with
[Clevis](https://github.com/latchset/clevis) `sss`, so it unlocks itself at
boot while enough of them answer; only to advertisements signed by the keys
you pinned.

## What this role does

- Binds the device with `clevis luks bind ... sss`, each Tang pin carrying an
  advertisement the role fetched and **checked against the thumbprint you
  pinned** (`thp`). clevis refuses an advertisement that key did not sign, so a
  server answering with other keys is refused instead of trusted.
- Re-binds only when the token on the device does not already trust exactly
  the pinned keys. clevis does not store the thumbprint it was bound with, so
  the role reads the advertisement clevis embedded in the token
  (`nbde-token-thumbprints DEVICE` shows it) and compares.
- Re-binds without a stored passphrase: the current binding unlocks the key,
  a new token is bound, and only then is the old one removed. An interrupted
  run leaves an extra token, which the next run removes; it never leaves the
  device without one. `clevis luks regen` is never used: it re-trusts whatever
  the network serves.
- For a root device (`nbde_client_manage_boot`):
  - pins the initramfs network to the interface holding
    `nbde_client_private_ip` (`ip=:::::<nic>:dhcp`), since DHCP otherwise takes
    whichever NIC answers first;
  - optionally installs a boot watchdog that reboots when the root is still
    locked after `nbde_client_watchdog_seconds`. The initramfs-tools clevis
    unlocker configures the network once: after a failed DHCP it would wait at
    the console forever. The kernel parameter `nbde_watchdog=0` disables it for
    one boot, and it never arms in an initramfs that does not unlock
    `nbde_client_mapper_name`.
- Writes binding metrics for a textfile collector on a daily timer and after
  every change.

## What this role does NOT do

- Does NOT encrypt a device. Encrypt it first; this role binds an existing
  LUKS2 device.
- Does NOT store the passphrase. `nbde_client_luks_passphrase` is read once,
  for the first binding.

## Metrics

| Metric | Meaning |
|--------|---------|
| `nbde_binding_report_ok{device}` | `1` if every Tang server of the binding was checked; `0` if any could not be (unreachable, malformed answer). |
| `nbde_binding_rotated_keys{device}` | `1` if the binding uses a key its Tang server no longer advertises. Written only when `nbde_binding_report_ok` is `1`. |
| `nbde_binding_report_timestamp_seconds{device}` | Unix time of the last report run; alert on staleness. |

`clevis luks report` exits `1` for "rotated" and for "could not check" alike,
so the verdict comes from its output; a check that fails never reads as a
clean binding.

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
- name: Bind the root to Tang
  hosts: servers
  become: true
  gather_facts: true
  roles:
    - role: meysam81.general.nbde_client
      vars:
        nbde_client_device: /dev/disk/by-uuid/00000000-0000-4000-8000-000000000000
        nbde_client_tang_servers:
          - url: http://192.0.2.10
            thp: "<tang-show-keys on 192.0.2.10>"
          - url: http://192.0.2.11
            thp: "<tang-show-keys on 192.0.2.11>"
        nbde_client_private_ip: 192.0.2.20
        nbde_client_watchdog_seconds: 600
        nbde_client_textfile_dir: /var/lib/node_exporter/textfile
        # Only needed while the device has no clevis token yet.
        nbde_client_luks_passphrase: "{{ my_luks_passphrase | default('') }}"
```

After a Tang key rotation, update `thp` and run the role again: it re-binds
to the new key.

## Default Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `nbde_client_device` | `""` | Required. The LUKS2 device. |
| `nbde_client_helper_path` | `/usr/local/sbin/nbde-token-thumbprints` | Token inspection helper. |
| `nbde_client_luks_passphrase` | `""` | An existing passphrase; needed only for the first binding. |
| `nbde_client_manage_boot` | `true` | Manage the kernel command line, initramfs scripts and their rebuilds. |
| `nbde_client_mapper_name` | `cryptroot` | Root mapping name in crypttab; the watchdog waits for it. |
| `nbde_client_private_ip` | `""` | The address on the network that reaches Tang; selects the interface the initramfs configures. |
| `nbde_client_report_on_calendar` | `daily` | Report timer `OnCalendar`. |
| `nbde_client_report_path` | `/usr/local/sbin/nbde-report` | Report script. |
| `nbde_client_report_random_delay_sec` | `3600` | Report timer `RandomizedDelaySec`. |
| `nbde_client_tang_servers` | `[]` | Required. `[{url, thp}]`; `thp` is the server's signing-key thumbprint. |
| `nbde_client_textfile_dir` | `""` | Textfile collector directory; empty writes no metrics. |
| `nbde_client_threshold` | `1` | How many servers must answer to unlock. |
| `nbde_client_watchdog_seconds` | `0` | Reboot when the root is still locked this long into the initramfs; `0`: no watchdog. |

Clevis binding of a LUKS2 device to Tang servers, verified against pinned thumbprints, with an initramfs watchdog and binding-drift metrics.

## Table of contents

- [Requirements](#requirements)
- [Default Variables](#default-variables)
  - [nbde_client_device](#nbde_client_device)
  - [nbde_client_helper_path](#nbde_client_helper_path)
  - [nbde_client_luks_passphrase](#nbde_client_luks_passphrase)
  - [nbde_client_manage_boot](#nbde_client_manage_boot)
  - [nbde_client_mapper_name](#nbde_client_mapper_name)
  - [nbde_client_private_ip](#nbde_client_private_ip)
  - [nbde_client_report_on_calendar](#nbde_client_report_on_calendar)
  - [nbde_client_report_path](#nbde_client_report_path)
  - [nbde_client_report_random_delay_sec](#nbde_client_report_random_delay_sec)
  - [nbde_client_tang_servers](#nbde_client_tang_servers)
  - [nbde_client_textfile_dir](#nbde_client_textfile_dir)
  - [nbde_client_threshold](#nbde_client_threshold)
  - [nbde_client_watchdog_seconds](#nbde_client_watchdog_seconds)
- [Dependencies](#dependencies)
- [License](#license)
- [Author](#author)

---

## Requirements

- Minimum Ansible version: `2.15`

## Default Variables

### nbde_client_device

#### Default value

```YAML
nbde_client_device: ''
```

### nbde_client_helper_path

#### Default value

```YAML
nbde_client_helper_path: /usr/local/sbin/nbde-token-thumbprints
```

### nbde_client_luks_passphrase

#### Default value

```YAML
nbde_client_luks_passphrase: ''
```

### nbde_client_manage_boot

#### Default value

```YAML
nbde_client_manage_boot: true
```

### nbde_client_mapper_name

#### Default value

```YAML
nbde_client_mapper_name: cryptroot
```

### nbde_client_private_ip

#### Default value

```YAML
nbde_client_private_ip: ''
```

### nbde_client_report_on_calendar

#### Default value

```YAML
nbde_client_report_on_calendar: daily
```

### nbde_client_report_path

#### Default value

```YAML
nbde_client_report_path: /usr/local/sbin/nbde-report
```

### nbde_client_report_random_delay_sec

#### Default value

```YAML
nbde_client_report_random_delay_sec: 3600
```

### nbde_client_tang_servers

#### Default value

```YAML
nbde_client_tang_servers: []
```

### nbde_client_textfile_dir

#### Default value

```YAML
nbde_client_textfile_dir: ''
```

### nbde_client_threshold

#### Default value

```YAML
nbde_client_threshold: 1
```

### nbde_client_watchdog_seconds

#### Default value

```YAML
nbde_client_watchdog_seconds: 0
```

## Dependencies

None.

## License

Apache-2.0

## Author

Meysam Azad
