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

`postfix_exporter_extra_groups` includes `postdrop` by default so the
exporter can traverse into `/var/spool/postfix/public` to reach the showq
socket. That same group membership also grants write access to
`/var/spool/postfix/public/cleanup` (local mail injection, the same
mechanism `postdrop`/`sendmail` use) — the standard price of reading
showq, since Postfix does not offer a narrower group for one without the
other.

### Journal unit

`postfix_exporter_systemd_unit` is detected when left empty: on Debian 12 and
Ubuntu 24.04, `postfix.service` is only a `RemainAfterExit` wrapper and every
Postfix daemon (`smtpd`, `qmgr`, `lmtp`, `cleanup`, ...) logs under the
instance unit `postfix@-.service`; on Debian 13, `postfix.service` is the main
instance itself and `postfix@-.service` stays inactive. The role reads
`RemainAfterExit` off `postfix.service` to pick the right one, because the
wrong unit leaves every log-derived metric at zero while `/metrics` keeps
returning 200. A multi-instance setup (`postmulti`) uses
`postfix@<instance>.service` instead — set `postfix_exporter_systemd_unit`
explicitly per instance.

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
postfix_exporter_systemd_unit: ''
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
