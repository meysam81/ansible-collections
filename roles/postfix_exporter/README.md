# Postfix Exporter

Install [postfix_exporter](https://github.com/Hsn723/postfix_exporter) (the maintained fork) from GitHub releases with SHA256 verification. The `systemd` build reads Postfix's log lines from journald and queue state from the `showq` socket, exposing delivery, deferral, bounce and queue-size metrics.

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
    - name: meysam81.general.postfix
    - name: meysam81.general.postfix_exporter
```

Metrics are served on `postfix_exporter_listen` (default `127.0.0.1:9154`). Scrape them with a local agent (see the `alloy` role) rather than exposing the port.

### Journal unit

`postfix_exporter_systemd_unit` defaults to `postfix@-.service` — on
Debian/Ubuntu, `postfix.service` is only a `RemainAfterExit` wrapper with no
log lines of its own; every Postfix daemon (`smtpd`, `qmgr`, `lmtp`,
`cleanup`, ...) actually logs under the instance unit `postfix@-.service`.
Pointing this at `postfix.service` leaves every log-derived metric at zero.
A multi-instance Postfix (`postmulti`) setup uses `postfix@<instance>.service`
instead — set `postfix_exporter_systemd_unit` accordingly per instance.

Install postfix_exporter (Hsn723) from GitHub releases with SHA256 verification

## Table of contents

- [Requirements](#requirements)
- [Default Variables](#default-variables)
  - [postfix_exporter_arch](#postfix_exporter_arch)
  - [postfix_exporter_bin](#postfix_exporter_bin)
  - [postfix_exporter_checksums_url](#postfix_exporter_checksums_url)
  - [postfix_exporter_download_url](#postfix_exporter_download_url)
  - [postfix_exporter_extra_groups](#postfix_exporter_extra_groups)
  - [postfix_exporter_group](#postfix_exporter_group)
  - [postfix_exporter_healthcheck_enabled](#postfix_exporter_healthcheck_enabled)
  - [postfix_exporter_listen](#postfix_exporter_listen)
  - [postfix_exporter_showq_path](#postfix_exporter_showq_path)
  - [postfix_exporter_systemd_unit](#postfix_exporter_systemd_unit)
  - [postfix_exporter_user](#postfix_exporter_user)
  - [postfix_exporter_version](#postfix_exporter_version)
- [Dependencies](#dependencies)
- [License](#license)
- [Author](#author)

---

## Requirements

- Minimum Ansible version: `2.17`

## Default Variables

### postfix_exporter_arch

#### Default value

```YAML
postfix_exporter_arch: "{{ (ansible_architecture | default('amd64')) | replace('x86_64', 'amd64') | replace('aarch64', 'arm64') }}"
```

### postfix_exporter_bin

#### Default value

```YAML
postfix_exporter_bin: /usr/local/bin/postfix_exporter
```

### postfix_exporter_checksums_url

#### Default value

```YAML
postfix_exporter_checksums_url: https://github.com/Hsn723/postfix_exporter/releases/download/v{{ postfix_exporter_version }}/checksums.txt
```

### postfix_exporter_download_url

#### Default value

```YAML
postfix_exporter_download_url: >-
  https://github.com/Hsn723/postfix_exporter/releases/download/v{{
  postfix_exporter_version }}/postfix_exporter_systemd_{{
  postfix_exporter_version }}_linux_{{ postfix_exporter_arch }}.tar.gz
```

### postfix_exporter_extra_groups

#### Default value

```YAML
postfix_exporter_extra_groups:
  - systemd-journal
  - postdrop
```

### postfix_exporter_group

#### Default value

```YAML
postfix_exporter_group: postfix-exporter
```

### postfix_exporter_healthcheck_enabled

#### Default value

```YAML
postfix_exporter_healthcheck_enabled: true
```

### postfix_exporter_listen

#### Default value

```YAML
postfix_exporter_listen: 127.0.0.1:9154
```

### postfix_exporter_showq_path

#### Default value

```YAML
postfix_exporter_showq_path: /var/spool/postfix/public/showq
```

### postfix_exporter_systemd_unit

#### Default value

```YAML
postfix_exporter_systemd_unit: postfix@-.service
```

### postfix_exporter_user

#### Default value

```YAML
postfix_exporter_user: postfix-exporter
```

### postfix_exporter_version

#### Default value

```YAML
postfix_exporter_version: 0.20.4
```

## Dependencies

None.

## License

Apache-2.0

## Author

Meysam Azad
