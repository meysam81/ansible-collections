# crowdsec_haproxy_bouncer

Install the [CrowdSec HAProxy SPOA bouncer](https://github.com/crowdsecurity/cs-haproxy-spoa-bouncer)
0.3.x — the current Go/SPOA bouncer, not the retired Lua-based one. IP-level
and HTTP-level CrowdSec decisions become HAProxy `403` responses through the
Stream Processing Offload Engine (SPOE), with no `event` auto-fire: every
SPOE message is sent explicitly with `http-request send-spoe-group`, wired
by `meysam81.general.haproxy_config` (`haproxy_crowdsec_enabled: true`) at a
point in the frontend chosen by the caller, not by SPOE's own automatic
timing.

That ordering matters: HAProxy's `on-frontend-http-request` SPOE event fires
before *any* of the frontend's own `http-request` rules, including a
Cloudflare `set-src`. Auto-firing there evaluates Cloudflare's edge IP, not
the real client IP. Sending the group explicitly, after `set-src`, fixes it.

This role only installs the bouncer and writes
`{{ crowdsec_haproxy_bouncer_haproxy_config_dir }}/crowdsec.cfg` (the SPOE
config). It does not touch `haproxy.cfg` itself or reload HAProxy — that is
`haproxy_config`'s job, triggered by its own config-change handler.

## What this role does NOT do

- Does not enable CrowdSec AppSec (full-body inspection) or captcha
  remediation — both deferred. `crowdsec_haproxy_bouncer_appsec_enabled`
  only makes the `crowdsec-http-body` SPOE message available to send; no
  shipped frontend wiring sends it.
- Does not generate a CrowdSec API key itself — see
  `crowdsec_haproxy_bouncer_api_key` below.

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
    - name: meysam81.general.crowdsec_agent
    - name: meysam81.general.crowdsec_haproxy_bouncer
    - name: meysam81.general.haproxy_config
      vars:
        haproxy_crowdsec_enabled: true
```

### Remote LAPI with an explicit API key

```yaml
    - name: meysam81.general.crowdsec_haproxy_bouncer
      vars:
        crowdsec_haproxy_bouncer_api_url: "http://172.16.16.2:8080/"
        crowdsec_haproxy_bouncer_api_key: "{{ vault_crowdsec_bouncer_key }}"
```

## Default Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `crowdsec_haproxy_bouncer_apt_codename` | detected release, `trixie` mapped to `bookworm` | apt suite codename. |
| `crowdsec_haproxy_bouncer_api_key` | `""` | API key for the local LAPI. Empty slurps the key the package postinst auto-registered. |
| `crowdsec_haproxy_bouncer_api_url` | `http://127.0.0.1:8080/` | LAPI base URL to pull decisions from. |
| `crowdsec_haproxy_bouncer_appsec_enabled` | `false` | Adds the `crowdsec-http-body` SPOE message/group (see above); nothing sends it by default. |
| `crowdsec_haproxy_bouncer_haproxy_config_dir` | `/etc/haproxy` | Directory `crowdsec.cfg` (the SPOE config) is written to. |
| `crowdsec_haproxy_bouncer_html_dir` | `/var/lib/crowdsec-haproxy-spoa-bouncer/html` | Ban HTML templates; installed by the package itself, override only if relocated. |
| `crowdsec_haproxy_bouncer_listen_addr` | `127.0.0.1:9001` | TCP address the bouncer's own SPOA server listens on. Coraza's SPOA owns `9000` on the same host. |
| `crowdsec_haproxy_bouncer_log_level` | `info` | Bouncer log verbosity. |
| `crowdsec_haproxy_bouncer_prometheus_enabled` | `true` | Expose Prometheus metrics. |
| `crowdsec_haproxy_bouncer_prometheus_listen` | `127.0.0.1:60602` | Prometheus metrics `host:port`. |
