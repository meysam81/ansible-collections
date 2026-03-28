
CrowdSec bouncer for HAProxy (Lua-based)

## Table of content

- [Requirements](#requirements)
- [Default Variables](#default-variables)
  - [crowdsec_enabled](#crowdsec_enabled)
  - [crowdsec_haproxy_config_dir](#crowdsec_haproxy_config_dir)
  - [crowdsec_html_dir](#crowdsec_html_dir)
  - [crowdsec_lua_dir](#crowdsec_lua_dir)
  - [crowdsec_spoa_addr](#crowdsec_spoa_addr)
  - [crowdsec_spoa_port](#crowdsec_spoa_port)
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

### crowdsec_haproxy_config_dir

#### Default value

```YAML
crowdsec_haproxy_config_dir: /etc/haproxy
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



## Dependencies

- haproxy

## License

Apache-2.0

## Author

Meysam Azad
