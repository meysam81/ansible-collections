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
