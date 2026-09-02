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
