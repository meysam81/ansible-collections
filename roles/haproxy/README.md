# HAProxy

HAProxy with full config management, TLS, and security headers

## Table of content

- [Requirements](#requirements)
- [Default Variables](#default-variables)
  - [cdn_domains](#cdn_domains)
  - [cloudflare_bypass_hosts](#cloudflare_bypass_hosts)
  - [cloudflare_ips_file](#cloudflare_ips_file)
  - [coraza_enabled](#coraza_enabled)
  - [coraza_spoa_addr](#coraza_spoa_addr)
  - [coraza_spoa_port](#coraza_spoa_port)
  - [cors_allowed_domains](#cors_allowed_domains)
  - [cors_subdomain_patterns](#cors_subdomain_patterns)
  - [haproxy_bin_path](#haproxy_bin_path)
  - [haproxy_bufsize](#haproxy_bufsize)
  - [haproxy_cache_control](#haproxy_cache_control)
  - [haproxy_cert_dir](#haproxy_cert_dir)
  - [haproxy_coep](#haproxy_coep)
  - [haproxy_config_dir](#haproxy_config_dir)
  - [haproxy_csp](#haproxy_csp)
  - [haproxy_dh_param_bits](#haproxy_dh_param_bits)
  - [haproxy_errors_dir](#haproxy_errors_dir)
  - [haproxy_maxconn](#haproxy_maxconn)
  - [haproxy_maxrewrite](#haproxy_maxrewrite)
  - [haproxy_option_forwardfor](#haproxy_option_forwardfor)
  - [haproxy_ssl_cachesize](#haproxy_ssl_cachesize)
  - [haproxy_ssl_maxrecord](#haproxy_ssl_maxrecord)
  - [haproxy_stats_auth_password](#haproxy_stats_auth_password)
  - [haproxy_stats_auth_user](#haproxy_stats_auth_user)
  - [haproxy_stats_port](#haproxy_stats_port)
  - [haproxy_threads](#haproxy_threads)
  - [haproxy_timeout_client](#haproxy_timeout_client)
  - [haproxy_timeout_connect](#haproxy_timeout_connect)
  - [haproxy_timeout_http_keep_alive](#haproxy_timeout_http_keep_alive)
  - [haproxy_timeout_http_request](#haproxy_timeout_http_request)
  - [haproxy_timeout_queue](#haproxy_timeout_queue)
  - [haproxy_timeout_server](#haproxy_timeout_server)
  - [haproxy_timeout_tunnel](#haproxy_timeout_tunnel)
  - [haproxy_tls_ciphers](#haproxy_tls_ciphers)
  - [haproxy_tls_ciphersuites](#haproxy_tls_ciphersuites)
  - [haproxy_tls_min_version](#haproxy_tls_min_version)
  - [haproxy_tls_options](#haproxy_tls_options)
  - [haproxy_version](#haproxy_version)
  - [haproxy_x_xss_protection](#haproxy_x_xss_protection)
  - [k8s_apiserver_addr](#k8s_apiserver_addr)
  - [k8s_apiserver_listen_port](#k8s_apiserver_listen_port)
  - [k8s_apiserver_port](#k8s_apiserver_port)
  - [k8s_backend_addr](#k8s_backend_addr)
  - [k8s_backend_port](#k8s_backend_port)
  - [rate_limit_api_count](#rate_limit_api_count)
  - [rate_limit_api_period](#rate_limit_api_period)
  - [rate_limit_concurrent](#rate_limit_concurrent)
  - [rate_limit_conn_count](#rate_limit_conn_count)
  - [rate_limit_conn_period](#rate_limit_conn_period)
  - [rate_limit_http_req_count](#rate_limit_http_req_count)
  - [rate_limit_http_req_period](#rate_limit_http_req_period)
  - [served_domains](#served_domains)
- [Dependencies](#dependencies)
- [License](#license)
- [Author](#author)

---

## Requirements

- Minimum Ansible version: `2.17`

## Default Variables

### cdn_domains

#### Default value

```YAML
cdn_domains: []
```

### cloudflare_bypass_hosts

#### Default value

```YAML
cloudflare_bypass_hosts: []
```

### cloudflare_ips_file

#### Default value

```YAML
cloudflare_ips_file: /etc/haproxy/cloudflare-ips.txt
```

### coraza_enabled

#### Default value

```YAML
coraza_enabled: false
```

### coraza_spoa_addr

#### Default value

```YAML
coraza_spoa_addr: 127.0.0.1
```

### coraza_spoa_port

#### Default value

```YAML
coraza_spoa_port: 9000
```

### cors_allowed_domains

#### Default value

```YAML
cors_allowed_domains: []
```

### cors_subdomain_patterns

#### Default value

```YAML
cors_subdomain_patterns: []
```

### haproxy_bin_path

#### Default value

```YAML
haproxy_bin_path: /usr/local/sbin/haproxy
```

### haproxy_bufsize

#### Default value

```YAML
haproxy_bufsize: 32768
```

### haproxy_cache_control

#### Default value

```YAML
haproxy_cache_control: no-cache, no-store, must-revalidate, private
```

### haproxy_cert_dir

#### Default value

```YAML
haproxy_cert_dir: /etc/haproxy/certs
```

### haproxy_coep

#### Default value

```YAML
haproxy_coep: require-corp
```

### haproxy_config_dir

#### Default value

```YAML
haproxy_config_dir: /etc/haproxy
```

### haproxy_csp

#### Default value

```YAML
haproxy_csp: "default-src 'self' https:; style-src 'self' 'unsafe-inline' https:;
  img-src 'self' blob: data: https:; font-src 'self' data: https:; object-src 'none';
  upgrade-insecure-requests"
```

### haproxy_dh_param_bits

#### Default value

```YAML
haproxy_dh_param_bits: 4096
```

### haproxy_errors_dir

#### Default value

```YAML
haproxy_errors_dir: /etc/haproxy/errors
```

### haproxy_maxconn

#### Default value

```YAML
haproxy_maxconn: 4096
```

### haproxy_maxrewrite

#### Default value

```YAML
haproxy_maxrewrite: 8192
```

### haproxy_option_forwardfor

#### Default value

```YAML
haproxy_option_forwardfor: true
```

### haproxy_ssl_cachesize

#### Default value

```YAML
haproxy_ssl_cachesize: 100000
```

### haproxy_ssl_maxrecord

#### Default value

```YAML
haproxy_ssl_maxrecord: 1460
```

### haproxy_stats_auth_password

#### Default value

```YAML
haproxy_stats_auth_password: ''
```

### haproxy_stats_auth_user

#### Default value

```YAML
haproxy_stats_auth_user: ''
```

### haproxy_stats_port

#### Default value

```YAML
haproxy_stats_port: 8404
```

### haproxy_threads

#### Default value

```YAML
haproxy_threads: '{{ ansible_processor_vcpus }}'
```

### haproxy_timeout_client

#### Default value

```YAML
haproxy_timeout_client: 50s
```

### haproxy_timeout_connect

#### Default value

```YAML
haproxy_timeout_connect: 5s
```

### haproxy_timeout_http_keep_alive

#### Default value

```YAML
haproxy_timeout_http_keep_alive: 15s
```

### haproxy_timeout_http_request

#### Default value

```YAML
haproxy_timeout_http_request: 15s
```

### haproxy_timeout_queue

#### Default value

```YAML
haproxy_timeout_queue: 30s
```

### haproxy_timeout_server

#### Default value

```YAML
haproxy_timeout_server: 50s
```

### haproxy_timeout_tunnel

#### Default value

```YAML
haproxy_timeout_tunnel: 3600s
```

### haproxy_tls_ciphers

#### Default value

```YAML
haproxy_tls_ciphers: 
  ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:DHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384
```

### haproxy_tls_ciphersuites

#### Default value

```YAML
haproxy_tls_ciphersuites: TLS_AES_128_GCM_SHA256:TLS_AES_256_GCM_SHA384:TLS_CHACHA20_POLY1305_SHA256
```

### haproxy_tls_min_version

#### Default value

```YAML
haproxy_tls_min_version: TLSv1.2
```

### haproxy_tls_options

#### Default value

```YAML
haproxy_tls_options: no-tls-tickets
```

### haproxy_version

#### Default value

```YAML
haproxy_version: 3.2.3
```

### haproxy_x_xss_protection

#### Default value

```YAML
haproxy_x_xss_protection: '0'
```

### k8s_apiserver_addr

#### Default value

```YAML
k8s_apiserver_addr: 127.0.0.1
```

### k8s_apiserver_listen_port

#### Default value

```YAML
k8s_apiserver_listen_port: ''
```

### k8s_apiserver_port

#### Default value

```YAML
k8s_apiserver_port: 6443
```

### k8s_backend_addr

#### Default value

```YAML
k8s_backend_addr: 127.0.0.1
```

### k8s_backend_port

#### Default value

```YAML
k8s_backend_port: 80
```

### rate_limit_api_count

#### Default value

```YAML
rate_limit_api_count: 200
```

### rate_limit_api_period

#### Default value

```YAML
rate_limit_api_period: 60
```

### rate_limit_concurrent

#### Default value

```YAML
rate_limit_concurrent: 20
```

### rate_limit_conn_count

#### Default value

```YAML
rate_limit_conn_count: 50
```

### rate_limit_conn_period

#### Default value

```YAML
rate_limit_conn_period: 10
```

### rate_limit_http_req_count

#### Default value

```YAML
rate_limit_http_req_count: 100
```

### rate_limit_http_req_period

#### Default value

```YAML
rate_limit_http_req_period: 10
```

### served_domains

#### Default value

```YAML
served_domains: []
```



## Dependencies

- haproxy_build

## License

Apache-2.0

## Author

Meysam Azad
