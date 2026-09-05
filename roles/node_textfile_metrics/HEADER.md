# node_textfile_metrics

Host-hygiene metrics in [node-exporter textfile
format](https://github.com/prometheus/node_exporter#textfile-collector) on a
systemd timer, so any textfile collector — node_exporter's
`--collector.textfile.directory` or Grafana Alloy's
`prometheus.exporter.unix` textfile block — can expose them.

## What this role does

- Deploys a script that writes a single `.prom` file with reboot and apt
  update-hygiene metrics.
- Wires it behind a systemd timer (`OnCalendar`, `RandomizedDelaySec`) so it
  refreshes on its own.
- Writes atomically (`mktemp` in the target directory, then `mv`), so a
  collector scraping mid-write never sees a truncated file.
- Runs the script once immediately after applying, so the file exists
  right away instead of waiting for the timer's first fire.

## What this role does NOT do

- Does NOT run `apt-get update`. The apt-related metrics reflect whatever
  is already in the local cache — refreshed by unattended-upgrades, cron,
  or a human — so this role has no network side effects of its own.
- Does NOT create or manage the textfile directory's consumer. Point
  `node_textfile_metrics_dir` at a directory a textfile collector (below)
  is already configured to read.
- Debian/Ubuntu only. `/run/reboot-required`, `apt-mark`, and `apt-get -s`
  are Debian-family concepts; the role is a no-op on other platforms.

## Metrics

| Metric | Meaning |
|--------|---------|
| `node_reboot_required` | `1` if `/run/reboot-required` exists (a pending reboot), `0` otherwise. |
| `node_reboot_required_pkgs` | Number of packages listed in `/run/reboot-required.pkgs` (`0` if absent). |
| `apt_upgrades_pending` | Number of package upgrades available in the local apt cache. |
| `apt_security_upgrades_pending` | Subset of the above tagged as security updates. |
| `apt_upgrades_held` | Number of packages held back from upgrading (`apt-mark showhold`). |
| `node_textfile_metrics_apt_error` | `1` if the apt-get upgrade simulation itself failed, `0` otherwise. Treat `apt_upgrades_pending` as unreliable while this is `1`. |
| `node_textfile_metrics_last_run_timestamp_seconds` | Unix time the script last completed — alert on staleness with `time() - node_textfile_metrics_last_run_timestamp_seconds > <threshold>`. |

## Pairing with a textfile collector

### node_exporter

```yaml
- role: meysam81.general.node_exporter
  vars:
    node_exporter_textfile_dir: /var/lib/node_exporter/textfile
- role: meysam81.general.node_textfile_metrics
  vars:
    node_textfile_metrics_dir: /var/lib/node_exporter/textfile
```

### Grafana Alloy

```yaml
- role: meysam81.general.alloy
  vars:
    alloy_config: |
      prometheus.exporter.unix "host" {
        enable_collectors = ["textfile"]
        textfile { directory = "/var/lib/alloy/textfile" }
      }
- role: meysam81.general.node_textfile_metrics
  vars:
    node_textfile_metrics_dir: /var/lib/alloy/textfile
```

Both directories must already exist and be readable by the collector —
`node_exporter_textfile_dir` and `alloy_textfile_dir` create theirs; this
role only needs the path to match.

## Install

### requirements.yml

```yaml
collections:
  - name: meysam81.general
    version: 1.12.0
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
    - name: meysam81.general.node_textfile_metrics
      vars:
        node_textfile_metrics_dir: /var/lib/node_exporter/textfile
```

## Default Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `node_textfile_metrics_dir` | `""` | Required. Directory a textfile collector reads from. |
| `node_textfile_metrics_dir_mode` | `"0755"` | Mode applied to `node_textfile_metrics_dir`. |
| `node_textfile_metrics_file_name` | `node_textfile_metrics.prom` | Filename written inside `node_textfile_metrics_dir`. |
| `node_textfile_metrics_on_calendar` | `*:0/15` | systemd `OnCalendar` schedule (default: every 15 minutes). |
| `node_textfile_metrics_random_delay_sec` | `120` | `RandomizedDelaySec` on the timer. |
| `node_textfile_metrics_script_path` | `/usr/local/bin/node-textfile-metrics.sh` | Where the metrics script is installed. |
