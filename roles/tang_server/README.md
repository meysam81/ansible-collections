# tang_server

A [Tang](https://github.com/latchset/tang) server for network-bound disk
encryption: clients bound with [Clevis](https://github.com/latchset/clevis)
unlock their LUKS volumes at boot as long as they can reach it.

## What this role does

- Installs `tang` with its socket listening on one address plus loopback,
  never on every interface. Loopback stays because `tang-show-keys` queries
  `localhost`.
- Writes the listener, the connection limits and the sandbox **before** the
  package is installed. The package's postinst starts the socket, and `tangd`
  writes a fresh key pair on the first request to an empty key directory; done
  in this order, the very first start already serves the intended keys on the
  intended address.
- Restores a key set exactly (`tang_server_keys`), so a rebuilt server keeps
  the identity its clients pinned; or generates one key pair once.
- Rotates keys and purges rotated keys on request.
- Caps connections per source (`MaxConnectionsPerSource`) and the lifetime of
  each connection (`RuntimeMaxSec`): `tangd` blocks in `read()` with no
  timeout, so a handful of idle connections would otherwise fill every slot.
- Runs `tangd` under `ProtectSystem=strict`: it can read its keys but never
  write one.
- Exposes `tang_server_current_keys` (`{file name: JWK}`, hidden keys
  included) and `tang_server_thumbprints` (signing-key thumbprints, as
  `tang-show-keys` prints them) for the caller to back up and to pin.

## What this role does NOT do

- Does NOT back up the keys anywhere. Store `tang_server_current_keys`
  (secret: these keys decrypt every client bound to this server) in your own
  secret store and feed them back through `tang_server_keys`.
- Does NOT decide when rotated keys may be purged. Purge only after every
  client re-bound to the current keys.
- Does NOT configure a firewall. Tang answers anyone who reaches it; admit only
  your clients.

## Install

### requirements.yml

```yaml
collections:
  - name: meysam81.general
```

## Usage

### playbook.yml

```yaml
---
- name: Tang
  hosts: tang
  become: true
  gather_facts: true
  roles:
    - role: meysam81.general.tang_server
      vars:
        tang_server_listen_address: 192.0.2.10
        # From your secret store; {} on the very first run.
        tang_server_keys: "{{ my_backed_up_tang_keys | default({}) }}"
  post_tasks:
    - name: Pin these on the clients
      ansible.builtin.debug:
        var: tang_server_thumbprints
```

Rotation: run once with `tang_server_rotate_keys: true`, back up the new key
set, re-bind every client, then run with `tang_server_purge_rotated_keys: true`
and back up again.

## Default Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `tang_server_keys` | `{}` | Keys to install as `{file name: JWK JSON}`, hidden `.<thumbprint>.jwk` included. Non-empty: the key directory holds exactly this set. Empty: generate once. |
| `tang_server_keys_dir` | `/var/lib/tang` | Key directory. |
| `tang_server_libexec_dir` | `/usr/libexec` | Where `tangd-keygen` and `tangd-rotate-keys` live. |
| `tang_server_listen_address` | `""` | Required. Address the socket listens on, besides `127.0.0.1`. |
| `tang_server_max_connections_per_source` | `4` | Concurrent connections one source may hold. |
| `tang_server_port` | `80` | Listen port. |
| `tang_server_purge_rotated_keys` | `false` | Delete hidden (rotated) keys. |
| `tang_server_rotate_keys` | `false` | Generate a new key pair; old keys become hidden and keep working until purged. |
| `tang_server_runtime_max_sec` | `10` | Lifetime cap of one connection. |

Tang server for network-bound disk encryption, listening on one address, with exact key restore, rotation and connection limits.

## Table of contents

- [Requirements](#requirements)
- [Default Variables](#default-variables)
  - [tang_server_keys](#tang_server_keys)
  - [tang_server_keys_dir](#tang_server_keys_dir)
  - [tang_server_libexec_dir](#tang_server_libexec_dir)
  - [tang_server_listen_address](#tang_server_listen_address)
  - [tang_server_max_connections_per_source](#tang_server_max_connections_per_source)
  - [tang_server_port](#tang_server_port)
  - [tang_server_purge_rotated_keys](#tang_server_purge_rotated_keys)
  - [tang_server_rotate_keys](#tang_server_rotate_keys)
  - [tang_server_runtime_max_sec](#tang_server_runtime_max_sec)
- [Dependencies](#dependencies)
- [License](#license)
- [Author](#author)

---

## Requirements

- Minimum Ansible version: `2.15`

## Default Variables

### tang_server_keys

#### Default value

```YAML
tang_server_keys: {}
```

### tang_server_keys_dir

#### Default value

```YAML
tang_server_keys_dir: /var/lib/tang
```

### tang_server_libexec_dir

#### Default value

```YAML
tang_server_libexec_dir: /usr/libexec
```

### tang_server_listen_address

#### Default value

```YAML
tang_server_listen_address: ''
```

### tang_server_max_connections_per_source

#### Default value

```YAML
tang_server_max_connections_per_source: 4
```

### tang_server_port

#### Default value

```YAML
tang_server_port: 80
```

### tang_server_purge_rotated_keys

#### Default value

```YAML
tang_server_purge_rotated_keys: false
```

### tang_server_rotate_keys

#### Default value

```YAML
tang_server_rotate_keys: false
```

### tang_server_runtime_max_sec

#### Default value

```YAML
tang_server_runtime_max_sec: 10
```

## Dependencies

None.

## License

Apache-2.0

## Author

Meysam Azad
