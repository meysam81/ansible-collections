# Node Exporter

Install [node_exporter](https://github.com/prometheus/node_exporter) from GitHub releases with SHA256 verification.

## Install

### requirements.yml

```yaml
collections:
  - name: meysam81.general
    version: 1.10.13
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
    - name: meysam81.general.node_exporter
      vars:
        node_exporter_version: "1.8.2"
        node_exporter_extra_collectors:
          - tcpstat
          - systemd
```

### Textfile collector

Set `node_exporter_textfile_dir` to expose `.prom` files dropped by another
process (e.g. the `node_textfile_metrics` role) via `--collector.textfile.directory`:

```yaml
        node_exporter_textfile_dir: /var/lib/node_exporter/textfile
```

The directory is created by this role (mode `0755`, owned by root) and
added to the unit's `ReadOnlyPaths=` — node_exporter only reads from it.

## Default Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `node_exporter_arch` | derived from `ansible_architecture` | CPU architecture segment of the download URL (`amd64`/`arm64`). |
| `node_exporter_create_user` | `true` | Create the `node_exporter_owner`/`node_exporter_group` system account. |
| `node_exporter_download_url` | GitHub release tarball URL | Built from `node_exporter_version`, `node_exporter_os`, `node_exporter_arch`. |
| `node_exporter_extra_collectors` | `[tcpstat, systemd, sysctl, network_route, mountstats, cgroups]` | Extra `--collector.*` flags to enable. |
| `node_exporter_group` | `node-exporter` | System group node_exporter runs as. |
| `node_exporter_healthcheck_enabled` | `true` | Probe `node_exporter_listen_address` after deploy. |
| `node_exporter_listen_address` | `127.0.0.1:9110` | `--web.listen-address`. The healthcheck targets this same address. |
| `node_exporter_os` | `linux` | OS segment of the download URL. |
| `node_exporter_owner` | `node-exporter` | System user node_exporter runs as. |
| `node_exporter_sha256sum_url` | upstream `sha256sums.txt` URL | Used to verify the downloaded tarball. |
| `node_exporter_supervisord_enabled` | `false` | Enable `--collector.supervisord`. |
| `node_exporter_supervisord_url` | `http://localhost:9001/RPC2` | `--collector.supervisord.url`. |
| `node_exporter_textfile_dir` | `""` | Directory added as `--collector.textfile.directory`. Empty disables the textfile collector. |
| `node_exporter_version` | `1.8.2` | node_exporter release to install. |
