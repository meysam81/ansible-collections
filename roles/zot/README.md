# zot

Install the [zot](https://zotregistry.dev/) OCI registry from its GitHub releases (sha256-verified against the release's `checksums.sha256.txt`) and run it under a sandboxed systemd unit. zot serves as a private registry or, with its `sync` extension, as a pull-through cache in front of Docker Hub, ghcr.io, quay.io and other upstreams.

The role is deployment-agnostic: the caller passes the full zot configuration as a dict in `zot_config`, and credentials in `zot_htpasswd_entries` and `zot_sync_credentials`.

## Install

### requirements.yml

```yaml
collections:
  - name: meysam81.general
    version: 1.15.0
```

## Usage

### playbook.yml

A pull-through cache for Docker Hub on a private address, TLS from files the
caller provides, one read-only user:

```yaml
---
- name: Playbook
  gather_facts: true
  become: true
  hosts: all
  roles:
    - name: meysam81.general.zot
      vars:
        zot_requires_mounts_for: [/srv/registry]
        zot_htpasswd_entries:
          - "{{ lookup('env', 'ZOT_PULL_HTPASSWD') }}"  # htpasswd -nbBC 12 puller <password>
        zot_config:
          distSpecVersion: "1.1.1"
          storage:
            rootDirectory: /srv/registry/zot
            dedupe: true
            gc: true
            # Keep digest-pinned pulls: they are stored untagged (see below).
            retention:
              policies:
                - repositories: ["**"]
                  deleteReferrers: false
                  deleteUntagged: false
          http:
            address: 192.0.2.10
            port: "443"
            writeTimeout: 15m  # above syncTimeout (see below)
            compat: [docker2s2]
            tls:
              cert: /etc/ssl/registry.example.com.crt
              key: /etc/ssl/registry.example.com.key
            auth:
              htpasswd:
                path: "{{ zot_htpasswd_path }}"
            accessControl:
              repositories:
                "**":
                  policies:
                    - users: [puller]
                      actions: [read]
                  defaultPolicy: []
          extensions:
            sync:
              enable: true
              registries:
                - urls: ["https://registry-1.docker.io"]
                  onDemand: true
                  tlsVerify: true
                  maxRetries: 0
                  retryDelay: 1s  # zot requires it whenever maxRetries is set
                  syncTimeout: 10m
                  content:
                    - prefix: "**"
                      destination: /docker.io
```

Clients then pull `registry.example.com/docker.io/library/alpine:3`.

### Pull-through cache settings that matter

- `http.compat: ["docker2s2"]` keeps Docker-format images in their original
  media type, so a digest-pinned pull (`image@sha256:...`) gets the same
  digest from the cache as from upstream.
- `maxRetries: 0` on each sync registry: with retries, every tag pull waits
  for them while the upstream is down before the cached copy is served.
  Digest-pinned pulls are served from the cache without asking upstream.
  `zot verify` rejects `maxRetries` without a `retryDelay`, even at `0`.
- `http.writeTimeout` above every registry's `syncTimeout` (default 3h): zot
  answers a pull of an image it does not hold yet only once the whole image
  is synced, and its default 60 s write deadline cuts off any such pull that
  takes longer. The client gets an empty reply, though zot still caches the
  image.
- A retention policy with `deleteUntagged: false` for every repository: a pull
  by digest (`image@sha256:...`) is stored untagged, and with `gc: true` zot
  deletes untagged manifests 24 h after they were synced unless a matching
  policy says otherwise; a repository that matches no policy gets
  `deleteUntagged: true`. A policy without `keepTags` prunes no tags.

### Logs

Leave `zot_config.log.output` unset; the role refuses it. zot then logs to the
journal (`journalctl -u zot`). A log file set there is created root-owned by
`zot verify`, after which the service cannot open it and exits.

### Secrets

`zot_htpasswd_entries` and `zot_sync_credentials` are written with
`no_log: true` to root-owned, group-readable files and referenced from
`zot_config` through `zot_htpasswd_path` and `zot_sync_credentials_path`.
Never inline a password into `zot_config`; it is written without `no_log`.
htpasswd lines are written verbatim (pre-hashed), so re-runs stay idempotent;
changing one restarts zot.

### Storage and privileges

List the mount holding `storage.rootDirectory` in `zot_requires_mounts_for`:
otherwise a volume missing at boot makes zot start an empty store on the root
disk. When `http.port` is below 1024 the unit grants `CAP_NET_BIND_SERVICE`
and nothing else; zot always runs as `zot_user`.

Install the zot OCI registry from GitHub releases

## Table of contents

- [Requirements](#requirements)
- [Default Variables](#default-variables)
  - [zot_arch](#zot_arch)
  - [zot_bin_dir](#zot_bin_dir)
  - [zot_config](#zot_config)
  - [zot_config_dir](#zot_config_dir)
  - [zot_download_base_url](#zot_download_base_url)
  - [zot_group](#zot_group)
  - [zot_healthcheck_enabled](#zot_healthcheck_enabled)
  - [zot_healthcheck_url](#zot_healthcheck_url)
  - [zot_healthcheck_validate_certs](#zot_healthcheck_validate_certs)
  - [zot_htpasswd_entries](#zot_htpasswd_entries)
  - [zot_htpasswd_path](#zot_htpasswd_path)
  - [zot_read_write_paths](#zot_read_write_paths)
  - [zot_requires_mounts_for](#zot_requires_mounts_for)
  - [zot_sync_credentials](#zot_sync_credentials)
  - [zot_sync_credentials_path](#zot_sync_credentials_path)
  - [zot_user](#zot_user)
  - [zot_version](#zot_version)
- [Dependencies](#dependencies)
- [License](#license)
- [Author](#author)

---

## Requirements

- Minimum Ansible version: `2.17`

## Default Variables

### zot_arch

#### Default value

```YAML
zot_arch: "{{ (ansible_architecture | default('amd64')) | replace('x86_64', 'amd64') | replace('aarch64', 'arm64') }}"
```

### zot_bin_dir

#### Default value

```YAML
zot_bin_dir: /usr/local/bin
```

### zot_config

#### Default value

```YAML
zot_config: {}
```

### zot_config_dir

#### Default value

```YAML
zot_config_dir: /etc/zot
```

### zot_download_base_url

#### Default value

```YAML
zot_download_base_url: https://github.com/project-zot/zot/releases/download/v{{ zot_version }}
```

### zot_group

#### Default value

```YAML
zot_group: zot
```

### zot_healthcheck_enabled

#### Default value

```YAML
zot_healthcheck_enabled: true
```

### zot_healthcheck_url

#### Default value

```YAML
zot_healthcheck_url: "{{ 'https' if zot_config.http.tls is defined else 'http' }}://{{ zot_config.http.address }}:{{ zot_config.http.port }}/readyz"
```

### zot_healthcheck_validate_certs

#### Default value

```YAML
zot_healthcheck_validate_certs: false
```

### zot_htpasswd_entries

#### Default value

```YAML
zot_htpasswd_entries: []
```

### zot_htpasswd_path

#### Default value

```YAML
zot_htpasswd_path: '{{ zot_config_dir }}/htpasswd'
```

### zot_read_write_paths

#### Default value

```YAML
zot_read_write_paths: []
```

### zot_requires_mounts_for

#### Default value

```YAML
zot_requires_mounts_for: []
```

### zot_sync_credentials

#### Default value

```YAML
zot_sync_credentials: {}
```

### zot_sync_credentials_path

#### Default value

```YAML
zot_sync_credentials_path: '{{ zot_config_dir }}/sync-credentials.json'
```

### zot_user

#### Default value

```YAML
zot_user: zot
```

### zot_version

#### Default value

```YAML
zot_version: 2.1.23
```

## Dependencies

None.

## License

Apache-2.0

## Author

Meysam Azad
