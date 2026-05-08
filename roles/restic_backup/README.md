# restic_backup

Encrypted, deduplicated backups via [restic](https://restic.net/) on a systemd
timer. S3-compatible backends (Wasabi, AWS S3, MinIO, etc.), local filesystem,
and SFTP are supported.

## What this role does

- Installs `restic` from apt.
- Renders an env file at `/etc/restic/.env` (mode `0600`) holding the
  repository URL, encryption password, and S3 credentials.
- Deploys a backup script at `/usr/local/bin/restic-backup.sh` that runs
  `restic backup` followed by `restic forget --prune` per the configured
  retention policy.
- Optionally deploys a check script at `/usr/local/bin/restic-check.sh` for
  periodic repository integrity verification.
- Wires both behind systemd timers with `RandomizedDelaySec` to spread load.
- Initialises the repository on first run when `restic_init_if_missing` is
  true (default). Idempotent.

## What this role does NOT do

- Does NOT generate the encryption password. Caller MUST resolve from a
  secret store and pass via `restic_password`.
- Does NOT manage S3 bucket lifecycle or retention at the bucket level.
  Restic's `forget` handles snapshot retention; bucket-level lifecycle is
  the caller's concern.
- Does NOT restore. Restore is intentionally manual to prevent accidents.

Encrypted, deduplicated backups via restic on a systemd timer with retention and periodic integrity checks. S3-compatible backends supported.

## Table of contents

- [Requirements](#requirements)
- [Default Variables](#default-variables)
  - [restic_aws_access_key_id](#restic_aws_access_key_id)
  - [restic_aws_secret_access_key](#restic_aws_secret_access_key)
  - [restic_backup_on_calendar](#restic_backup_on_calendar)
  - [restic_backup_random_delay_sec](#restic_backup_random_delay_sec)
  - [restic_cache_dir](#restic_cache_dir)
  - [restic_check_enabled](#restic_check_enabled)
  - [restic_check_on_calendar](#restic_check_on_calendar)
  - [restic_check_random_delay_sec](#restic_check_random_delay_sec)
  - [restic_check_read_data_subset](#restic_check_read_data_subset)
  - [restic_exclude_patterns](#restic_exclude_patterns)
  - [restic_extra_env](#restic_extra_env)
  - [restic_init_if_missing](#restic_init_if_missing)
  - [restic_keep_daily](#restic_keep_daily)
  - [restic_keep_monthly](#restic_keep_monthly)
  - [restic_keep_weekly](#restic_keep_weekly)
  - [restic_keep_yearly](#restic_keep_yearly)
  - [restic_password](#restic_password)
  - [restic_paths](#restic_paths)
  - [restic_repo_url](#restic_repo_url)
  - [restic_snapshot_tag](#restic_snapshot_tag)
- [Dependencies](#dependencies)
- [License](#license)
- [Author](#author)

---

## Requirements

- Minimum Ansible version: `2.15`

## Default Variables

### restic_aws_access_key_id

#### Default value

```YAML
restic_aws_access_key_id: ''
```

### restic_aws_secret_access_key

#### Default value

```YAML
restic_aws_secret_access_key: ''
```

### restic_backup_on_calendar

#### Default value

```YAML
restic_backup_on_calendar: '*-*-* 03:00:00'
```

### restic_backup_random_delay_sec

#### Default value

```YAML
restic_backup_random_delay_sec: 1800
```

### restic_cache_dir

#### Default value

```YAML
restic_cache_dir: /var/cache/restic
```

### restic_check_enabled

#### Default value

```YAML
restic_check_enabled: true
```

### restic_check_on_calendar

#### Default value

```YAML
restic_check_on_calendar: Sun *-*-* 04:00:00
```

### restic_check_random_delay_sec

#### Default value

```YAML
restic_check_random_delay_sec: 600
```

### restic_check_read_data_subset

#### Default value

```YAML
restic_check_read_data_subset: 10%
```

### restic_exclude_patterns

#### Default value

```YAML
restic_exclude_patterns: []
```

### restic_extra_env

#### Default value

```YAML
restic_extra_env: []
```

### restic_init_if_missing

#### Default value

```YAML
restic_init_if_missing: true
```

### restic_keep_daily

#### Default value

```YAML
restic_keep_daily: 7
```

### restic_keep_monthly

#### Default value

```YAML
restic_keep_monthly: 12
```

### restic_keep_weekly

#### Default value

```YAML
restic_keep_weekly: 4
```

### restic_keep_yearly

#### Default value

```YAML
restic_keep_yearly: 0
```

### restic_password

#### Default value

```YAML
restic_password: ''
```

### restic_paths

#### Default value

```YAML
restic_paths: []
```

### restic_repo_url

#### Default value

```YAML
restic_repo_url: ''
```

### restic_snapshot_tag

#### Default value

```YAML
restic_snapshot_tag: auto
```

## Dependencies

None.

## License

Apache-2.0

## Author

Meysam Azad
