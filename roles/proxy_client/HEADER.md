# proxy_client

System-wide HTTP/HTTPS proxy configuration. Configures shells,
[systemd](https://systemd.io/) services, and
[APT](https://wiki.debian.org/Apt) to route traffic through a forward
proxy.

Deploys drop-in config files — never overwrites existing system files.
Both lowercase and uppercase env vars are set for maximum compatibility.

## Role Relationships

Designed as a client-side companion to the egress proxy stack:

```
┌─────────────┐     ┌──────────────────┐     ┌───────────┐
│  wireguard   │────▶│  egress_firewall  │────▶│   squid    │
│  (tunnel)    │     │  (enforcement)    │     │  (proxy)   │
└─────────────┘     └──────────────────┘     └───────────┘
       │                                            ▲
       │            ┌───────────────┐               │
       └───────────▶│ proxy_client  │───────────────┘
                    │ (env config)  │
                    └───────────────┘
```

| Role | Where | Purpose |
|------|-------|---------|
| `wireguard` | Server + Client | VPN tunnel |
| `squid` | Server | Forward proxy |
| `egress_firewall` | Server | iptables enforcement |
| `proxy_client` | Client | System-wide proxy env vars |

## Install

### requirements.yml

```yaml
collections:
  - name: meysam81.general
    version: 1.12.0
```

## Usage

### Basic

```yaml
---
- name: Playbook
  gather_facts: true
  become: true
  hosts: all
  roles:
    - name: meysam81.general.proxy_client
      vars:
        proxy_client_proxy_url: "http://10.99.0.1:3128"
```

### With extra no_proxy entries

```yaml
    - name: meysam81.general.proxy_client
      vars:
        proxy_client_proxy_url: "http://10.99.0.1:3128"
        proxy_client_no_proxy:
          - localhost
          - 127.0.0.1
          - 10.99.0.1
          - ".internal.example.com"
```

### Without APT proxy

```yaml
    - name: meysam81.general.proxy_client
      vars:
        proxy_client_proxy_url: "http://10.99.0.1:3128"
        proxy_client_configure_apt: false
```

## What gets configured

| File | Purpose | Scope |
|------|---------|-------|
| `/etc/profile.d/proxy.sh` | Shell sessions | Interactive + login shells |
| `/etc/environment.d/99-proxy.conf` | PAM / systemd-environment-d | Non-interactive sessions, cron |
| `/etc/apt/apt.conf.d/99proxy` | APT package manager | `apt update`, `apt install` |
| `/etc/systemd/system.conf.d/99-proxy.conf` | systemd `DefaultEnvironment` | All systemd services |

## Verify

```bash
# New shell session picks up proxy
su - $(whoami) -c 'echo $http_proxy'

# systemd services
systemctl show-environment | grep -i proxy

# APT
apt-config dump | grep -i proxy
```
