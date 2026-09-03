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
- `restic_check_last_run_timestamp_seconds`
- `restic_check_last_exit_code`
- `restic_check_last_success_timestamp_seconds`

Example alert for a stale or failing backup:

```
time() - restic_backup_last_success_timestamp_seconds > 36 * 3600
```
