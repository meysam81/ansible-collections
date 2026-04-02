# proxy_client

System-wide HTTP/HTTPS and SOCKS proxy configuration. Configures shells,
[systemd](https://systemd.io/) services, and
[APT](https://wiki.debian.org/Apt) to route traffic through forward
proxies. Optional git-over-SSH SOCKS proxy support.

Deploys drop-in config files — never overwrites existing system files.
Both lowercase and uppercase env vars are set for maximum compatibility.

## Role Relationships

Designed as a client-side companion to the egress proxy stack:

```
┌─────────────┐     ┌──────────────────┐     ┌───────────┐
│  wireguard  │────▶│  egress_firewall │────▶│   squid   │
│  (tunnel)   │     │  (enforcement)   │     │  (HTTP)   │
└─────────────┘     └──────────────────┘     ├───────────┤
       │                                     │   dante   │
       │            ┌───────────────┐        │  (SOCKS5) │
       └───────────▶│ proxy_client  │───────▶└───────────┘
                    │ (env config)  │
                    └───────────────┘
```

| Role | Where | Purpose |
|------|-------|---------|
| `wireguard` | Server + Client | VPN tunnel |
| `squid` | Server | HTTP/HTTPS forward proxy |
| `dante` | Server | SOCKS5 proxy |
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

### With SOCKS proxy

```yaml
    - name: meysam81.general.proxy_client
      vars:
        proxy_client_proxy_url: "http://10.99.0.1:3128"
        proxy_client_socks_url: "socks5h://10.99.0.1:1080"
```

### With git SSH proxy

```yaml
    - name: meysam81.general.proxy_client
      vars:
        proxy_client_proxy_url: "http://10.99.0.1:3128"
        proxy_client_socks_url: "socks5h://10.99.0.1:1080"
        proxy_client_configure_git_ssh: true
```

## What gets configured

| File | Purpose | Scope |
|------|---------|-------|
| `/etc/profile.d/proxy.sh` | Shell sessions | Interactive + login shells |
| `/etc/environment.d/99-proxy.conf` | PAM / systemd-environment-d | Non-interactive sessions, cron |
| `/etc/apt/apt.conf.d/99proxy` | APT package manager | `apt update`, `apt install` |
| `/etc/systemd/system.conf.d/99-proxy.conf` | systemd `DefaultEnvironment` | All systemd services |
| `/etc/profile.d/git-ssh-proxy.sh` | Git SSH ProxyCommand | `git clone git@...` over SOCKS |

## Verify

```bash
# New shell session picks up proxy
su - $(whoami) -c 'echo $http_proxy'

# systemd services
systemctl show-environment | grep -i proxy

# APT
apt-config dump | grep -i proxy

# SOCKS proxy (when configured)
su - $(whoami) -c 'echo $ALL_PROXY'

# Git SSH proxy (when configured)
su - $(whoami) -c 'echo $GIT_SSH_COMMAND'
```

System-wide HTTP/HTTPS proxy configuration for shells, systemd services, and apt

## Table of contents

- [Requirements](#requirements)
- [Default Variables](#default-variables)
  - [proxy_client_configure_apt](#proxy_client_configure_apt)
  - [proxy_client_configure_git_ssh](#proxy_client_configure_git_ssh)
  - [proxy_client_configure_systemd](#proxy_client_configure_systemd)
  - [proxy_client_no_proxy](#proxy_client_no_proxy)
  - [proxy_client_proxy_url](#proxy_client_proxy_url)
  - [proxy_client_socks_url](#proxy_client_socks_url)
- [Dependencies](#dependencies)
- [License](#license)
- [Author](#author)

---

## Requirements

- Minimum Ansible version: `2.15`

## Default Variables

### proxy_client_configure_apt

#### Default value

```YAML
proxy_client_configure_apt: true
```

### proxy_client_configure_git_ssh

#### Default value

```YAML
proxy_client_configure_git_ssh: false
```

### proxy_client_configure_systemd

#### Default value

```YAML
proxy_client_configure_systemd: true
```

### proxy_client_no_proxy

#### Default value

```YAML
proxy_client_no_proxy:
  - localhost
  - 127.0.0.1
```

### proxy_client_proxy_url

#### Default value

```YAML
proxy_client_proxy_url: ''
```

### proxy_client_socks_url

#### Default value

```YAML
proxy_client_socks_url: ''
```

## Dependencies

None.

## License

Apache-2.0

## Author

Meysam Azad
