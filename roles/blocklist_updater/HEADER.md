# blocklist_updater

Systemd timer that fetches threat intelligence blocklist feeds into a local
directory. Supports [abuse.ch URLhaus](https://urlhaus.abuse.ch/),
[ThreatFox](https://threatfox.abuse.ch/),
[Spamhaus DROP](https://www.spamhaus.org/drop/),
[Feodo Tracker](https://feodotracker.abuse.ch/),
[Emerging Threats](https://rules.emergingthreats.net/), and
[FireHOL Level 1](https://iplists.firehol.org/) out of the box.

Uses atomic writes (tmp + mv) so consumers (e.g. Squid) never read partial
files. Optionally sends `SIGHUP` to a configurable process after update.

Features:

- **6 default feeds** — domains (URLhaus, ThreatFox) + IPs/CIDRs (Spamhaus DROP, Feodo, Emerging Threats, FireHOL L1)
- **Allowlist** — exact-match exclusions that override all feeds
- **Health logging** — per-feed entry counts, shrinkage detection (>50% drop keeps old file)
- **Bogon filtering** — strips RFC 1918 / loopback / link-local / multicast from IP feeds
- **Atomic writes** — tmp + mv prevents partial reads
- **Deduplication** — `sort -u` in all default feed filters

## Install

### requirements.yml

```yaml
collections:
  - name: meysam81.general
    version: 1.11.0
```

## Usage

### Default feeds

```yaml
---
- name: Playbook
  gather_facts: true
  become: true
  hosts: all
  roles:
    - name: meysam81.general.blocklist_updater
```

### With Squid signal and custom blocklist

```yaml
    - name: meysam81.general.blocklist_updater
      vars:
        blocklist_updater_signal_process: squid
        blocklist_updater_custom_blocklist: files/my-blocklist.txt
```

### Custom interval (hourly)

```yaml
    - name: meysam81.general.blocklist_updater
      vars:
        blocklist_updater_interval: "hourly"
```

### Allowlist (exclude false positives)

```yaml
    - name: meysam81.general.blocklist_updater
      vars:
        blocklist_updater_allowlist:
          - "cdn.example.com"
          - "api.stripe.com"
```

### Custom feeds

```yaml
    - name: meysam81.general.blocklist_updater
      vars:
        blocklist_updater_feeds:
          - name: my-feed
            url: "https://example.com/blocklist.txt"
            filter: "cat"
```

### View health logs

```bash
journalctl -u blocklist-updater --no-pager -n 50
```

Example output:

```
INFO: urlhaus-domains: 1842 entries (was 1830)
INFO: threatfox-domains: 523 entries (was 519)
INFO: spamhaus-drop-cidrs: 1102 entries (was 1098)
INFO: feodo-botnet-ips: 287 entries (was 291)
INFO: emergingthreats-ips: 2456 entries (was 2451)
INFO: firehol-level1: 18934 entries (was 18920)
INFO: Total blocklist entries: 25144
```
