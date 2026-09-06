# Coraza

Build and install [coraza-spoa](https://github.com/corazawaf/coraza-spoa) WAF engine for HAProxy from source. Includes OWASP CoreRuleSet.

Depends on `golang` and `haproxy`.

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
    - name: meysam81.general.coraza
      vars:
        coraza_spoa_version: "0.3.0"
        coraza_coreruleset_version: "4.17.1"
```

## SPOE firing and logging

`coraza.cfg`'s `spoe-agent` deliberately has no `messages` directive, so
`coraza-req` is never auto-fired on `on-frontend-http-request` — that event
fires before any of the frontend's own `http-request` rules, including a
Cloudflare `set-src`, which means the WAF would otherwise inspect
Cloudflare's edge IP instead of the real client IP. `meysam81.general.haproxy_config`
fires it explicitly instead, via `http-request send-spoe-group coraza
coraza-req` placed after `set-src` (`haproxy_coraza_enabled: true`).

`log global` on the SPOE agent (one journal line per request/response pair
exchanged with coraza-spoa) is off by default — set `coraza_spoe_log_events:
true` only for short debugging sessions. The WAF verdict itself still lands
in HAProxy's own access log (`spoa-error:`/`waf-hit:` fields) independent of
this setting, whenever the consuming `haproxy_config` has
`haproxy_coraza_enabled: true`.

## Default Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `coraza_config_dir` | `/etc/coraza-spoa` | Directory for coraza-spoa's own config, CRS rules, and plugins. |
| `coraza_config_version` | `3.3.3` | `coraza.conf-recommended` version fetched from corazawaf/coraza. |
| `coraza_coreruleset_commit` | `""` | Pin CRS to a commit SHA instead of `coraza_coreruleset_version`. |
| `coraza_coreruleset_version` | `4.17.1` | OWASP CoreRuleSet version. |
| `coraza_go_install_dir` | `/usr/local` | Where the `golang` role installed the Go toolchain used to build coraza-spoa. |
| `coraza_haproxy_config_dir` | `/etc/haproxy` | Directory `coraza.cfg` (the SPOE config) is written to. |
| `coraza_spoa_addr` | `127.0.0.1` | Address coraza-spoa's own server listens on. |
| `coraza_spoa_commit` | `""` | Pin coraza-spoa to a commit SHA instead of `coraza_spoa_version`. |
| `coraza_spoa_port` | `9000` | Port coraza-spoa's own server listens on. |
| `coraza_spoa_version` | `0.3.0` | coraza-spoa version to build. |
| `coraza_spoe_log_events` | `false` | Enable the SPOE agent's `log global` (one line per request/response — high volume). |
