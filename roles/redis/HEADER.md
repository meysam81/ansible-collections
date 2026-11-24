# redis

Install [Redis](https://redis.io/) from the distribution package (`redis-server`
on Debian trixie and Ubuntu noble) as a loopback-only, password-protected
datastore with append-only persistence and no key eviction.

## What this role does

- Installs `redis-server` (which brings `redis-cli`) and enables and starts the
  `redis-server` unit.
- Writes a managed config to `/etc/redis/redis.d/50-managed.conf`
  (`root:redis`, mode `0640`, rendered with `no_log`) holding `bind`, `port`,
  `protected-mode yes`, `requirepass`, `appendonly`, `maxmemory`,
  `maxmemory-policy` and `redis_extra_config`.
- Appends a single `include /etc/redis/redis.d/*.conf` block to the end of the
  packaged `/etc/redis/redis.conf`. Redis applies later directives over earlier
  ones, so the managed file overrides the distro defaults while the rest of the
  packaged config stays as shipped. Other `*.conf` files you drop in
  `/etc/redis/redis.d/` are included too (in alphabetical order, after
  `50-managed.conf` if they sort later).
- Restarts redis through a handler when either file changes, and flushes it at
  the end of the role so the password and bind apply before later tasks use
  redis.

## Safe by default

- Listens on `127.0.0.1` only; `protected-mode yes` is always set.
- `redis_requirepass` has no default and the role fails when it is empty or
  spans several lines. It never appears in task output.
- `appendonly yes`: a crash loses about a second of writes at most.
- `maxmemory-policy noeviction`: when `redis_maxmemory` is reached Redis refuses
  writes instead of silently dropping keys. Use `allkeys-lru` for a pure cache.

## What this role does NOT do

- Does NOT validate the config before restarting: Redis has no config test
  mode. A bad directive in `redis_extra_config` makes the restart handler fail,
  which stops the play at that point.
- Does NOT open the firewall or enable TLS. Binding beyond loopback is the
  caller's explicit decision (`redis_bind`), together with their own firewall.
- Does NOT set up replication, Sentinel or Cluster.
- Does NOT generate the password. Caller MUST resolve it from a secret store.

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
- name: Playbook
  gather_facts: true
  become: true
  hosts: all
  roles:
    - name: meysam81.general.redis
      vars:
        redis_requirepass: "{{ lookup('env', 'REDIS_PASSWORD') }}"
        redis_maxmemory: 256mb
```

### Connecting

```bash
REDISCLI_AUTH="$REDIS_PASSWORD" redis-cli -h 127.0.0.1 ping
```

Client URL: `redis://:<password>@127.0.0.1:6379/0` (percent-encode special
characters in the password).

### Backing up

With AOF on, `redis-cli --rdb /path/dump.rdb` (password via `REDISCLI_AUTH`)
produces a consistent snapshot to back up, for example as a
`pre_backup_commands` entry of the `restic_backup` role.

### Using Redis as a cache

```yaml
redis_maxmemory: 512mb
redis_maxmemory_policy: allkeys-lru
redis_appendonly: false
```
