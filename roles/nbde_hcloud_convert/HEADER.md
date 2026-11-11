# nbde_hcloud_convert

Converts a running [Hetzner Cloud](https://www.hetzner.com/cloud) host to a
LUKS2-encrypted root bound to [Tang](https://github.com/latchset/tang) servers
with [Clevis](https://github.com/latchset/clevis) `sss`, in place, through the
Hetzner rescue system. Afterwards the host unlocks itself at boot while enough
Tang servers answer, and a recovery passphrase still opens it at a console.

## What this role does

- Finds the server by its private address, so no server name or id is passed,
  and refuses unless exactly one server holds it.
- Preflight on the running host, before anything changes: arm64, an ext4 root
  that is the last partition of its disk, room to carve a 1 GiB `/boot`, one
  interface holding the private address.
- Takes each Tang advertisement over SSH from the Tang server itself and
  requires it to be signed by the thumbprint you pinned (`thp`).
- Asks for the host name before the reboot into rescue, where downtime starts,
  and again before a power cycle.
- Arms rescue, attaches a firewall that admits SSH to rescue, and reboots the
  host from inside (an orderly shutdown); a power cycle only if rescue does not
  come up within `nbde_hcloud_convert_rescue_timeout`.
- Snapshots the quiet disk (the rollback point) before anything is encrypted.
- In rescue (`files/nbde-encrypt-root.sh`): shrinks the root, carves `/boot` at
  the end of the disk, encrypts the root in place (`cryptsetup reencrypt`),
  then in a chroot writes crypttab, fstab and GRUB, binds the recovery
  passphrase and a clevis `sss` token built from the checked advertisements,
  and rebuilds the initramfs.
- Reboots into the encrypted root, detaches the firewall, requires the root on
  `/dev/mapper/cryptroot` and sets `nbde_hcloud_convert_converted`.
- `tasks_from: accept` proves the result: for each Tang server, stops every
  other one and reboots; the host must come back each time. Then the recovery
  passphrase must open a keyslot, discards must reach the disk, no unit may
  fail, and a rebuilt initramfs must still hold clevis and no key file.

### Resuming

Run the role again after any interruption. The phase comes from the host, not
from the run that stopped: a host already on `cryptroot` is left alone (and a
firewall a killed run left attached is detached); an unreachable host is
expected in rescue and resumed from the controller's state file (written only
once the downtime was confirmed); a rescue run
still going is attached to, never started twice; the rescue script resumes its
own work, including an interrupted `cryptsetup reencrypt`.

## What this role does NOT do

- Does NOT store the recovery passphrase. Create and keep it in your secret
  store first; pass it in `nbde_hcloud_convert_luks_passphrase`.
- Does NOT delete the rollback snapshot or the server's Hetzner backups. Both
  hold the plaintext disk: delete them after acceptance.
- Does NOT create the rescue firewall. Declare it yourself
  (`hetzner.hcloud.firewall`): one rule, 22/tcp in, from where the controller
  reaches rescue.
- Does NOT install the boot watchdog, binding metrics or later re-binds. Run
  `meysam81.general.nbde_client` against the new device after this role.
- Does NOT handle x86 servers, xfs roots or a partition after the root.

## Requirements

- The `hetzner.hcloud` collection on the controller (part of the `ansible`
  package).
- SSH from the controller to each Tang server (`ssh_host`), and to the host's
  public IPv4 with the rescue key, directly or through
  `nbde_hcloud_convert_rescue_jump`.
- Play with `serial: 1` and `gather_facts: false`: a host being resumed is in
  rescue and cannot answer fact gathering.

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
- name: Encrypt the root and bind it to Tang
  hosts: servers
  serial: 1
  gather_facts: false
  become: true
  vars:
    tang_servers:
      - url: http://192.0.2.10
        thp: "<tang-show-keys on 192.0.2.10>"
        ssh_host: tang-1.example.com
      - url: http://192.0.2.11
        thp: "<tang-show-keys on 192.0.2.11>"
        ssh_host: tang-2.example.com
  tasks:
    - name: Convert
      ansible.builtin.include_role:
        name: meysam81.general.nbde_hcloud_convert
      vars: &convert
        nbde_hcloud_convert_private_ip: 192.0.2.20
        nbde_hcloud_convert_luks_passphrase: "{{ my_recovery_passphrase }}"
        nbde_hcloud_convert_tang_servers: "{{ tang_servers }}"
        nbde_hcloud_convert_rescue_ssh_key: rescue
        nbde_hcloud_convert_rescue_private_key_file: ~/.ssh/rescue
        nbde_hcloud_convert_rescue_firewall: rescue-ssh
        nbde_hcloud_convert_rescue_jump: bastion.example.com

    - name: Gather facts on the converted host
      ansible.builtin.setup:

    - name: Find the LUKS container behind the root
      ansible.builtin.shell:
        cmd: cryptsetup luksUUID "$(cryptsetup status cryptroot | awk '/device:/ {print $2}')"
      register: luks_uuid
      changed_when: false

    - name: Bind, watchdog, metrics
      ansible.builtin.include_role:
        name: meysam81.general.nbde_client
      vars:
        nbde_client_device: /dev/disk/by-uuid/{{ luks_uuid.stdout }}
        nbde_client_tang_servers: "{{ tang_servers }}"
        nbde_client_private_ip: 192.0.2.20
        nbde_client_watchdog_seconds: 600

    # Reboots once per Tang server: only after a conversion in this run.
    - name: Accept
      ansible.builtin.include_role:
        name: meysam81.general.nbde_hcloud_convert
        tasks_from: accept
      vars: *convert
      when: nbde_hcloud_convert_converted | default(false)
```

`--check` runs the preflight and the Tang checks and stops before the reboot
into rescue.

## Default Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `nbde_hcloud_convert_api_token` | `""` | Hetzner Cloud API token (read & write); empty reads `HCLOUD_TOKEN`. |
| `nbde_hcloud_convert_boot_timeout` | `600` | Seconds to wait for the encrypted root to boot. |
| `nbde_hcloud_convert_confirm` | `true` | Ask for the host name before the reboot into rescue. |
| `nbde_hcloud_convert_encrypt_timeout` | `7200` | Seconds to wait for the encryption; a run past it can be resumed. |
| `nbde_hcloud_convert_luks_passphrase` | `""` | Required. Recovery passphrase (20+ bytes); gets its own keyslot. |
| `nbde_hcloud_convert_private_ip` | `""` | Required. The host's private address; finds the server. |
| `nbde_hcloud_convert_rescue_firewall` | `""` | Required. Existing firewall: one rule, 22/tcp in. |
| `nbde_hcloud_convert_rescue_jump` | `""` | SSH jump host for rescue; empty connects directly. |
| `nbde_hcloud_convert_rescue_private_key_file` | `""` | Required. Local private key matching the rescue SSH key. |
| `nbde_hcloud_convert_rescue_source_ips` | `[]` | CIDRs the firewall rule must admit, exactly; empty skips the check. |
| `nbde_hcloud_convert_rescue_ssh_key` | `""` | Required. Hetzner Cloud SSH key name rescue admits. |
| `nbde_hcloud_convert_rescue_timeout` | `300` | Seconds to wait for rescue before a power cycle. |
| `nbde_hcloud_convert_state_dir` | `~/.local/state/nbde` | Controller directory for a resumed run's state. |
| `nbde_hcloud_convert_tang_servers` | `[]` | Required. `[{url, thp, ssh_host}]`. |
| `nbde_hcloud_convert_threshold` | `1` | How many servers must answer to unlock. |
