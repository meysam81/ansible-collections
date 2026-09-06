# lynis

[Lynis](https://cisofy.com/lynis/) security auditing on a systemd timer,
exposing the hardening index and finding counts as [node-exporter textfile
format](https://github.com/prometheus/node_exporter#textfile-collector)
metrics — pairs with `node_exporter` or Grafana Alloy exactly like
`node_textfile_metrics` (see that role's HEADER.md for the two pairing
recipes; the pattern is identical here).

## What this role does

- Deploys a script that runs `lynis audit system --cronjob --quiet
  --no-colors`, parses `/var/log/lynis-report.dat`, and writes a single
  `.prom` file with the hardening index, warning/suggestion counts, run
  timestamp, and success flag.
- Wires it behind a systemd timer (`OnCalendar`, `RandomizedDelaySec`).
- Writes atomically (`mktemp` in the target directory, then `mv`).
- Runs once immediately after applying, so metrics exist right away.

## Metrics

| Metric | Meaning |
|--------|---------|
| `lynis_hardening_index` | Lynis' own 0-100 hardening score from the last completed run. |
| `lynis_warnings_total` | Number of `warning[]=` entries in the last report. |
| `lynis_suggestions_total` | Number of `suggestion[]=` entries in the last report. |
| `lynis_last_run_timestamp_seconds` | Unix time the script last completed — alert on staleness. |
| `lynis_last_run_success` | `1` if both the audit run and report parsing succeeded, `0` otherwise. |
| `lynis_info{version="..."}` | Lynis version that produced the last report, as a label (constant `1` value). |

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
    - name: meysam81.general.lynis
      vars:
        lynis_textfile_dir: /var/lib/node_exporter/textfile
```

### Skip tests that don't apply

```yaml
    - name: meysam81.general.lynis
      vars:
        lynis_skip_tests:
          - FILE-6310
          - STRG-1846
```

## Default Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `lynis_file_name` | `lynis.prom` | Filename inside `lynis_textfile_dir`. |
| `lynis_on_calendar` | `daily` | systemd `OnCalendar` schedule. |
| `lynis_profile_extra` | `""` | Raw lines appended verbatim to `/etc/lynis/custom.prf`. |
| `lynis_randomized_delay` | `1h` | `RandomizedDelaySec` on the timer. |
| `lynis_script_path` | `/usr/local/bin/lynis-metrics` | Where the metrics script is installed. |
| `lynis_skip_tests` | `[]` | Lynis test IDs to skip, one `skip-test=` line each in `/etc/lynis/custom.prf`. |
| `lynis_textfile_dir` | `/var/lib/node_exporter/textfile` | Directory a textfile collector reads from. |
