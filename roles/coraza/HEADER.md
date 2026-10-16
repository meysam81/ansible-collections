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

## Skipping paths

`coraza_skip_paths` lists request path prefixes the agent never receives. The
role renders them as an ACL condition on the SPOE events, so HAProxy does not
even send the message: no CRS evaluation, no `set-on-error` failure, no log
noise. Typical use is machine ingest endpoints with binary bodies (metrics
remote-write, log pushes), which trip protocol-enforcement rules on every
call and can exceed the agent's frame or processing limits:

```yaml
    - name: meysam81.general.coraza
      vars:
        coraza_skip_paths:
          - /insert/
          - /api/v1/write
```

Anything else HAProxy does with those paths (rate limiting, its own path
rules) still applies; only the WAF is bypassed.
