# dnsproxy

Install [AdguardTeam/dnsproxy](https://github.com/AdguardTeam/dnsproxy) as a
local encrypted DNS forwarder (DoH/DoT/DoQ) and disable conflicting local DNS
resolvers.

## Install

### requirements.yml

```yaml
collections:
  - name: meysam81.general
    version: 1.11.0
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
    - name: meysam81.general.dnsproxy
      vars:
        dnsproxy_version: "0.81.0"
```

### Custom upstreams

```yaml
- name: meysam81.general.dnsproxy
  vars:
    dnsproxy_upstreams:
      - "https://9.9.9.9/dns-query"
      - "https://149.112.112.112/dns-query"
    dnsproxy_fallbacks:
      - "tls://9.9.9.9:853"
      - "tls://149.112.112.112:853"
```

### Skip resolver cleanup

```yaml
- name: meysam81.general.dnsproxy
  vars:
    dnsproxy_disable_resolvers: false
    dnsproxy_manage_resolv_conf: false
```
