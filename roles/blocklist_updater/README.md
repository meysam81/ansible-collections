# blocklist_updater

Systemd timer that fetches threat intelligence blocklist feeds into a local
directory. Supports [abuse.ch URLhaus](https://urlhaus.abuse.ch/),
[ThreatFox](https://threatfox.abuse.ch/), and
[Spamhaus DROP](https://www.spamhaus.org/drop/) out of the box.

Uses atomic writes (tmp + mv) so consumers (e.g. Squid) never read partial
files. Optionally sends `SIGHUP` to a configurable process after update.

## Install

### requirements.yml

```yaml
collections:
  - name: meysam81.general
    version: 1.11.0
```

## Usage

### Default feeds (URLhaus + ThreatFox + Spamhaus DROP)

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

### Custom feeds

```yaml
    - name: meysam81.general.blocklist_updater
      vars:
        blocklist_updater_feeds:
          - name: my-feed
            url: "https://example.com/blocklist.txt"
            filter: "cat"
```

Systemd timer to fetch threat intelligence blocklist feeds

## Table of contents

- [Requirements](#requirements)
- [Default Variables](#default-variables)
  - [blocklist_updater_custom_blocklist](#blocklist_updater_custom_blocklist)
  - [blocklist_updater_dir](#blocklist_updater_dir)
  - [blocklist_updater_feeds](#blocklist_updater_feeds)
  - [blocklist_updater_interval](#blocklist_updater_interval)
  - [blocklist_updater_signal_process](#blocklist_updater_signal_process)
- [Dependencies](#dependencies)
- [License](#license)
- [Author](#author)

---

## Requirements

- Minimum Ansible version: `2.15`

## Default Variables

### blocklist_updater_custom_blocklist

#### Default value

```YAML
blocklist_updater_custom_blocklist: ''
```

### blocklist_updater_dir

#### Default value

```YAML
blocklist_updater_dir: /etc/egress-proxy/blocklists
```

### blocklist_updater_feeds

#### Default value

```YAML
blocklist_updater_feeds:
  - name: urlhaus-domains
    url: https://urlhaus.abuse.ch/downloads/hostfile/
    filter: grep -v '^#' | awk '{print $2}'
  - name: threatfox-domains
    url: https://threatfox.abuse.ch/downloads/hostfile/
    filter: grep -v '^#' | awk '{print $2}'
  - name: spamhaus-drop-cidrs
    url: https://www.spamhaus.org/drop/drop.txt
    filter: grep -v '^;' | awk '{print $1}'
```

### blocklist_updater_interval

#### Default value

```YAML
blocklist_updater_interval: '*:0/15'
```

### blocklist_updater_signal_process

#### Default value

```YAML
blocklist_updater_signal_process: ''
```

## Dependencies

None.

## License

Apache-2.0

## Author

Meysam Azad
