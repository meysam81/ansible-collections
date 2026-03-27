
CrowdSec bouncer for HAProxy (Lua-based)

## Table of content

- [Requirements](#requirements)
- [Default Variables](#default-variables)
  - [crowdsec_enabled](#crowdsec_enabled)
  - [crowdsec_html_dir](#crowdsec_html_dir)
  - [crowdsec_lua_dir](#crowdsec_lua_dir)
  - [crowdsec_spoa_addr](#crowdsec_spoa_addr)
  - [crowdsec_spoa_port](#crowdsec_spoa_port)
  - [haproxy_config_dir](#haproxy_config_dir)
- [Dependencies](#dependencies)
- [License](#license)
- [Author](#author)

---

## Requirements

- Minimum Ansible version: `2.15`

## Default Variables

### crowdsec_enabled

#### Default value

```YAML
crowdsec_enabled: true
```

### crowdsec_html_dir

#### Default value

```YAML
crowdsec_html_dir: /var/lib/crowdsec-haproxy-spoa-bouncer/html
```

### crowdsec_lua_dir

#### Default value

```YAML
crowdsec_lua_dir: /usr/lib/crowdsec-haproxy-spoa-bouncer/lua
```

### crowdsec_spoa_addr

#### Default value

```YAML
crowdsec_spoa_addr: 127.0.0.1
```

### crowdsec_spoa_port

#### Default value

```YAML
crowdsec_spoa_port: 9001
```

### haproxy_config_dir

#### Default value

```YAML
haproxy_config_dir: /etc/haproxy
```



## Dependencies

- haproxy

## License

Apache-2.0
