# aide

[AIDE](https://aide.github.io/) (Advanced Intrusion Detection Environment)
file integrity monitoring on a systemd timer, with curated excludes and
[node-exporter textfile
format](https://github.com/prometheus/node_exporter#textfile-collector)
metrics — pairs with `node_exporter` or Grafana Alloy exactly like
`node_textfile_metrics` (see that role's HEADER.md for the two pairing
recipes).

## What this role does

- Installs `aide` + `aide-common` (the latter provides `aideinit` and the
  `/etc/aide/aide.conf.d/` include mechanism).
- Disables Debian's own `dailyaidecheck.timer` — this role's timer replaces
  it with a textfile-metrics-oriented check instead of the mail-oriented
  default.
- Writes `/etc/aide/aide.conf.d/99_ansible` with recursive excludes
  (`aide_exclude_paths`). **The filename has no extension on purpose** —
  Debian's `aide.conf` pulls this directory in via `@@x_include
  /etc/aide/aide.conf.d ^[a-zA-Z0-9_-]+$`, and a dot in the filename would
  make the fragment silently invisible to AIDE.
- Runs `aideinit --yes --force` to create the initial database when one
  doesn't exist yet.
- Deploys a script that runs `aide --update`, parses the added/removed/
  changed counts from its report, writes a `.prom` file, and — when
  `aide_auto_accept` is true — moves the freshly-written `aide.db.new`
  over `aide.db`, so a real change alerts exactly once instead of every
  run until someone manually re-baselines.
- Wires the script behind a systemd timer and runs it once immediately
  after applying, so metrics exist right away.

## What this role does NOT do

- Does not treat AIDE exit codes 1-7 as failures — they are a documented
  bitmask (`1`=added, `2`=removed, `4`=changed) describing what the
  comparison found, not whether the run itself worked. Only `run_success`
  going to `0` (an actual error — see the script) should page.

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
    - name: meysam81.general.aide
      vars:
        aide_textfile_dir: /var/lib/node_exporter/textfile
```

### A host with extra churn (mail spool, backups)

```yaml
    - name: meysam81.general.aide
      vars:
        aide_exclude_paths:
          - /var/log
          - /var/cache
          - /var/tmp
          - /tmp
          - /var/lib/apt/lists
          - /var/lib/aide
          - /var/backups
          - /run
          - /var/vmail
          - /var/spool/postfix
          - /var/lib/dovecot
          - /var/cache/restic
```

## Metrics

| Metric | Meaning |
|--------|---------|
| `aide_last_run_timestamp_seconds` | Unix time the script last completed — alert on staleness. |
| `aide_last_run_success` | `1` if the AIDE run completed without an operational error, `0` otherwise (exit codes 1-7 still count as success — see above). |
| `aide_check_duration_seconds` | Wall-clock duration of the last `aide --update` run. |
| `aide_entries_added` | Entries added since the last accepted database. |
| `aide_entries_removed` | Entries removed since the last accepted database. |
| `aide_entries_changed` | Entries changed since the last accepted database. |

## Default Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `aide_auto_accept` | `true` | Install the freshly-written database automatically after a successful run. |
| `aide_config_extra` | `""` | Raw lines appended verbatim to the `99_ansible` fragment. |
| `aide_exclude_paths` | see below | Recursive excludes (`!/regex` rules) — log/cache/temp/AIDE's own state. |
| `aide_file_name` | `aide.prom` | Filename inside `aide_textfile_dir`. |
| `aide_on_calendar` | `daily` | systemd `OnCalendar` schedule. |
| `aide_randomized_delay` | `1h` | `RandomizedDelaySec` on the timer. |
| `aide_script_path` | `/usr/local/bin/aide-check-metrics` | Where the metrics script is installed. |
| `aide_textfile_dir` | `""` | Required. Directory a textfile collector reads from. |
