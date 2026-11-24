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
- Optionally runs several independent backup jobs on one host
  (`restic_backup_jobs`), each with its own repository, password, schedule,
  pre-backup commands and retention. See [Backup jobs](#backup-jobs).
- Initialises the repository on first run when `restic_init_if_missing` is
  true (default). Idempotent.

## What this role does NOT do

- Does NOT generate the encryption password. Caller MUST resolve from a
  secret store and pass via `restic_password`.
- Does NOT manage S3 bucket lifecycle or retention at the bucket level.
  Restic's `forget` handles snapshot retention; bucket-level lifecycle is
  the caller's concern.
- Does NOT restore. Restore is intentionally manual to prevent accidents.

## Backup jobs

`restic_backup_jobs` runs several backups side by side, for example one per
application, each into its own repository. With the list empty (the default)
the role renders exactly what it did before the variable existed.

```yaml
restic_backup_jobs:
  - name: app-one                  # [a-z0-9-]+, unique; suffix of every file and unit
    repo_url: "s3:https://s3.example.com/bucket/app-one"
    password: "{{ lookup('env', 'APP_ONE_RESTIC_PASSWORD') }}"
    paths: [/var/backups/app-one]
    pre_backup_commands:           # run in order before `restic backup`
      - sqlite3 /var/lib/app-one/app.db ".backup /var/backups/app-one/app.db"
    read_write_paths: [/var/backups/app-one]
    on_calendar: hourly
  - name: app-two
    repo_url: "s3:https://s3.example.com/bucket/app-two"
    password: "{{ lookup('env', 'APP_TWO_RESTIC_PASSWORD') }}"
    paths: [/var/lib/app-two]
restic_aws_access_key_id: "{{ lookup('env', 'S3_ACCESS_KEY_ID') }}"
restic_aws_secret_access_key: "{{ lookup('env', 'S3_SECRET_ACCESS_KEY') }}"
restic_backup_on_failure_unit: backup-failure-notify.service
```

Per job the role deploys:

- `/etc/restic/jobs/<name>.env` (mode `0600`): repository, password, S3 keys
  and extra environment. Rendered with `no_log`.
- `/usr/local/bin/restic-backup-<name>.sh`, `restic-backup-<name>.service` and
  `restic-backup-<name>.timer`.

A job takes the same optional keys as the role-level variables of the same
meaning (`exclude_patterns`, `keep_daily`, `keep_weekly`, `keep_monthly`,
`keep_yearly`, `tag`, `aws_access_key_id`, `aws_secret_access_key`,
`extra_env`) and falls back to them when a key is absent. `on_calendar` falls
back to `restic_backup_on_calendar`.

Behaviour worth knowing:

- Each `pre_backup_commands` entry runs as `bash -euo pipefail -c '<command>'`
  as root, with the job's env file loaded, before the repository is touched. A
  failing command fails the job: no snapshot is taken, the service exits
  non-zero (and starts `restic_backup_on_failure_unit`, if set) and the metrics
  report the failure, so stale staging data is never backed up as if fresh.
- The service is sandboxed with `ProtectSystem=strict`. A pre-backup command
  can only write to the cache dir, the metrics dir and the directories listed
  in the job's `read_write_paths`, which must exist. List the staging
  directory there, and the repository directory for a local repository.
- Each run ends in `restic forget --prune` with the job's retention, the same
  as the single backup. For a job that runs hourly with a large repository,
  `--prune` on every run is the expensive part; this role does not split it
  out.
- When `restic_backup_jobs` is non-empty, the single-repository backup and its
  integrity check are deployed only if `restic_repo_url` is set. The
  integrity check covers that single repository only; jobs have none.
- Removing a job from the list retires it on the next run: its timer is
  stopped and disabled and its env file, script, service, timer and metrics
  file are removed. Only jobs whose env file sits in `/etc/restic/jobs/` are
  considered, so units this role did not create are left alone.
- `restic_backup_on_failure_unit` is set as `OnFailure=` on the single backup
  service and on every job service.
- Metrics of a job go to `restic_backup_<name>.prom` and carry the label
  `job="<name>"`.

Validation: every job needs a unique `name` matching `^[a-z0-9-]+$`, a
`repo_url`, a `password`, a non-empty `paths` list and, for an `s3:` repository,
AWS credentials on the job or at role level. The role fails before changing
anything otherwise.

## Metrics

Set `restic_metrics_textfile_dir` to have the backup and check scripts write
node-exporter textfile metrics after every run:

```yaml
restic_metrics_textfile_dir: /var/lib/alloy/textfile  # pair with the alloy role
```

Metrics written:

- `restic_backup_last_run_timestamp_seconds{tag}`
- `restic_backup_last_exit_code{tag}`
- `restic_backup_last_success_timestamp_seconds{tag}`

Jobs write the same three with an extra `job` label,
`{job="<name>",tag="<tag>"}`.
- `restic_check_last_run_timestamp_seconds`
- `restic_check_last_exit_code`
- `restic_check_last_success_timestamp_seconds`

Example alert for a stale or failing backup:

```
time() - restic_backup_last_success_timestamp_seconds > 36 * 3600
```

Encrypted, deduplicated backups via restic on a systemd timer with retention and periodic integrity checks. S3-compatible backends supported.

## Table of contents

- [Requirements](#requirements)
- [Default Variables](#default-variables)
  - [restic_aws_access_key_id](#restic_aws_access_key_id)
  - [restic_aws_secret_access_key](#restic_aws_secret_access_key)
  - [restic_backup_jobs](#restic_backup_jobs)
  - [restic_backup_on_calendar](#restic_backup_on_calendar)
  - [restic_backup_on_failure_unit](#restic_backup_on_failure_unit)
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
  - [restic_metrics_textfile_dir](#restic_metrics_textfile_dir)
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

### restic_backup_jobs

#### Default value

```YAML
restic_backup_jobs: []
```

### restic_backup_on_calendar

#### Default value

```YAML
restic_backup_on_calendar: '*-*-* 03:00:00'
```

### restic_backup_on_failure_unit

#### Default value

```YAML
restic_backup_on_failure_unit: ''
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

### restic_metrics_textfile_dir

#### Default value

```YAML
restic_metrics_textfile_dir: ''
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
