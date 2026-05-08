# dane_publish

Publish DANE TLSA records (`3 1 1`, DANE-EE / SPKI / SHA-256) to Cloudflare,
keyed off live cert files on disk. Designed to hook into lego cert-renewal
so the published TLSA hash stays in lockstep with the cert's
SubjectPublicKeyInfo.

## What this role does

- Installs a small bash script at `/usr/local/bin/dane-publish.sh`.
- Renders an env file at `/etc/dane/.env` with the Cloudflare API token and
  zone ID (mode `0600`).
- Renders a config file at `/etc/dane/certs.conf` listing each cert path,
  host, port, and protocol.
- When `dane_enabled = true`, runs the script once to publish initial TLSA
  records.

## What this role does NOT do

- Does NOT wire itself into lego's `reload_commands`. Caller is responsible
  for adding `/usr/local/bin/dane-publish.sh` to the relevant cert's
  reload_commands list when ready to enable DANE.
- Does NOT delete old TLSA records. Add-only is intentional; deletion is a
  manual operation post-rollover to give DNS caches time to flush.
- Does NOT manage CAA, DNSSEC, or any other DANE prerequisite. The zone MUST
  be DNSSEC-signed end-to-end for TLSA records to actually be honoured by
  validating receivers.

## Operational discipline

- Use `lego --reuse-key` so the SPKI is stable across renewals; otherwise
  every renewal becomes a key rotation that needs dual-publish.
- After an intentional key rotation: publish the new TLSA, wait 2x the prior
  TTL, then manually delete the old record via the Cloudflare dashboard.
