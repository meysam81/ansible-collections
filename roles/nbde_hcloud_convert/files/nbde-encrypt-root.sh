#!/bin/bash
# Encrypts a Hetzner Cloud Debian/Ubuntu root partition in place (LUKS2) and
# binds it to Tang (clevis sss). Runs inside the Hetzner rescue system, started
# by the nbde_hcloud_convert role (tasks/convert.yml).
#
# usage: nbde-encrypt-root.sh ROOT_PARTUUID PASSFILE PRIVATE_NIC SSS_JSON
#   PASSFILE   recovery passphrase on tmpfs, exact bytes, no newline (a keyslot of its own)
#   PRIVATE_NIC  NIC that reaches Tang in the INSTALLED system (enp7s0 on CAX/CCX)
#   SSS_JSON   clevis sss config; every tang pin has "url", "thp" and "adv" (a file
#              under /run/nbde, checked against thp before rescue)
#
# Resumable: run it again after any interruption. It detects how far it got:
#   plain ext4 -> full run; /boot already carved -> skips carving; LUKS
#   mid-reencrypt -> cryptsetup --resume-only; LUKS done -> chroot phase only.
# Exit 3: a guard failed before anything was written.
#
# Layout after: p1 = LUKS2 (ext4 /), a new last partition = ext4 /boot (1 GiB),
# ESP and BIOS-boot partitions unchanged.
# ponytail: ext4 root on a GPT partition only (every Hetzner Cloud image);
# xfs cannot shrink: rebuild and restore such a host instead.
set -euo pipefail
# Private mount namespace: rescue services with their own namespaces (resolved,
# logind, udevd) would otherwise keep copies of the chroot mounts, and
# `cryptsetup close` fails with "still in use".
# Through bash: /run, where it is copied to, may be mounted noexec.
[ -n "${NBDE_UNSHARED:-}" ] || exec env NBDE_UNSHARED=1 unshare --mount --propagation private bash "$0" "$@"
# One run at a time; the controller reads the exit status from this file
# (a run still holding the lock is attached to, never started twice).
exec 9>"${NBDE_LOCK:-/run/nbde/lock}"
flock -n 9 || { echo "another run is in progress" >&2; exit 4; }
STATUS=${NBDE_STATUS:-/run/nbde/status}
rm -f "$STATUS"
trap 'echo $? >"$STATUS"' EXIT

ROOT_PARTUUID=$1 PASSFILE=$2 PRIV_IF=$3 SSS_CFG=$4
BOOT_SECTORS=$((1024 * 2048)) # 1 GiB in 512-byte sectors
MARGIN_K=$((64 * 1024))       # fs ends 64 MiB before the partition; LUKS2 needs 32 MiB
MNT=/mnt/nbde
ESP_TYPE=c12a7328-f81f-11d2-ba4b-00a0c93ec93b

die() { echo "GUARD: $*" >&2; exit 3; }
log() { echo "== $*"; }

P1=$(readlink -f "/dev/disk/by-partuuid/$ROOT_PARTUUID")
[ -b "$P1" ] || die "no partition with PARTUUID $ROOT_PARTUUID"
# -d: the partition alone; an open cryptroot (a run that failed after
# opening it) would add its own line otherwise.
DISK=/dev/$(lsblk -dno PKNAME "$P1")
PNUM=$(cat "/sys/class/block/$(basename "$P1")/partition")
ESP=$(lsblk -lnpo NAME,PARTTYPE "$DISK" | awk -v t="$ESP_TYPE" 'tolower($2)==t{print $1}')
S1=$(sfdisk -d "$DISK" | awk -v p="$P1" '$1==p{gsub(/[^0-9]/,"",$4); print $4}')
LAST=$(sfdisk -d "$DISK" | awk '/^last-lba:/{print $2}')
P2S=$(((LAST + 1 - BOOT_SECTORS) / 2048 * 2048))
P1SIZE=$((P2S - S1))
TYPE=$(blkid -o value -s TYPE "$P1" || true)
# Our /boot is the partition starting at P2S: found by its start sector, since
# a run cut off between sfdisk and mkfs leaves it with no label yet.
BOOTP=$(lsblk -lnpo NAME,START "$DISK" | awk -v s="$P2S" '$2==s{print $1}')

# --- guards: nothing below them writes until all pass -------------------------
[ "$(uname -m)" = aarch64 ] || die "$(uname -m): only arm64 (CAX) is validated; x86 needs its own bootloader path"
[ -b "$ESP" ] || die "no EFI system partition on $DISK"
[ "$(cryptsetup --version | awk '{print $2}' | cut -d. -f1)" -ge 2 ] || die "cryptsetup 2.x required"
printf '%s' "$SSS_CFG" | python3 -c '
import json, os, sys
pins = json.load(sys.stdin)["pins"]["tang"]
assert pins, "no tang pins"
for p in pins:
    assert p.get("url") and p.get("thp"), "every pin needs url and thp: %r" % p
    assert os.path.isfile(p.get("adv", "")), "missing checked advertisement for %s" % p["url"]
' || die "bad SSS_JSON"
[ "$(stat -c %s "$PASSFILE")" -ge 20 ] || die "passphrase file too short"
# Any partition starting after p1 other than our own /boot blocks the layout.
others=$(sfdisk -d "$DISK" | awk -v s1="$S1" -v p2s="$P2S" -F'[=,]' '/start=/{gsub(/ /,"",$2); if ($2+0 > s1+0 && $2+0 != p2s+0) print}')
[ -z "$others" ] || die "a partition follows the root; this layout is not handled: $others"
if [ "$TYPE" = ext4 ]; then
	read -r blocks free bsize < <(dumpe2fs -h "$P1" 2>/dev/null | awk -F: '/^Block count/{b=$2} /^Free blocks/{f=$2} /^Block size/{s=$2} END{print b+0, f+0, s+0}')
	used_k=$(((blocks - free) * bsize / 1024))
	[ $((used_k + 1258291)) -lt $((P1SIZE / 2 - MARGIN_K)) ] || die "root holds ${used_k} KiB; it does not fit after carving 1 GiB for /boot"
elif [ "$TYPE" != crypto_LUKS ]; then
	die "root is $TYPE, not ext4 or LUKS"
fi
log "root=$P1 disk=$DISK esp=$ESP state=$TYPE${BOOTP:+ (+/boot $BOOTP)}"

# --- 1. carve /boot at the end of the disk and move /boot there ---------------
if [ "$TYPE" = ext4 ]; then
	if [ -z "$BOOTP" ]; then
		log "shrink the root and carve /boot"
		e2fsck -fy "$P1" || [ $? -le 1 ]
		resize2fs "$P1" "$((P1SIZE / 2 - MARGIN_K))K"
		echo "start=$S1, size=$P1SIZE" | sfdisk -q --no-reread -N "$PNUM" "$DISK"
		echo "start=$P2S, type=0FC63DAF-8483-4772-8E79-3D69D8477DE4" | sfdisk -q --no-reread --append "$DISK"
		partx -u "$DISK"
		udevadm settle
		BOOTP=$(lsblk -lnpo NAME,START "$DISK" | awk -v s="$P2S" '$2==s{print $1}')
		[ -b "$BOOTP" ] || { echo "new /boot partition not found" >&2; exit 1; }
	fi
	if [ -z "$(blkid -o value -s TYPE "$BOOTP" || true)" ]; then
		# The region used to belong to the plaintext root: resize2fs moved data
		# out of it but did not erase the old copies.
		blkdiscard -z "$BOOTP" 2>/dev/null || dd if=/dev/zero of="$BOOTP" bs=4M status=none conv=fsync || true
		mkfs.ext4 -q -L boot "$BOOTP"
	fi
	mkdir -p $MNT/root $MNT/boot
	mount "$P1" $MNT/root
	mount "$BOOTP" $MNT/boot
	if [ ! -e $MNT/boot/grub ] || [ -n "$(find $MNT/root/boot -mindepth 1 -maxdepth 1 ! -name efi -print -quit)" ]; then
		log "move /boot to $BOOTP"
		cp -a $MNT/root/boot/. $MNT/boot/
		find $MNT/root/boot -mindepth 1 -maxdepth 1 ! -name efi -exec rm -rf {} +
	fi
	umount $MNT/boot $MNT/root
	e2fsck -fy "$P1" || [ $? -le 1 ]
	resize2fs "$P1" "$((P1SIZE / 2 - MARGIN_K))K"

	log "encrypt in place (resumable)"
	time cryptsetup reencrypt --encrypt --type luks2 --reduce-device-size 32M --batch-mode --key-file "$PASSFILE" "$P1"
elif cryptsetup luksDump "$P1" | grep -q 'online-reencrypt'; then
	log "resume the interrupted encryption"
	cryptsetup reencrypt --resume-only --batch-mode --key-file "$PASSFILE" "$P1"
fi
[ -b "$BOOTP" ] || BOOTP=$(lsblk -lnpo NAME,START "$DISK" | awk -v s="$P2S" '$2==s{print $1}')

# --- 2. open, grow, chroot: crypttab, fstab, clevis, initramfs, grub ----------
cryptsetup status cryptroot >/dev/null 2>&1 || cryptsetup open --allow-discards --key-file "$PASSFILE" "$P1" cryptroot
e2fsck -fy /dev/mapper/cryptroot || [ $? -le 1 ]
resize2fs /dev/mapper/cryptroot

LUKS_UUID=$(cryptsetup luksUUID "$P1")
BOOT_UUID=$(blkid -o value -s UUID "$BOOTP")
FS_UUID=$(blkid -o value -s UUID /dev/mapper/cryptroot)
mkdir -p $MNT/root
mount /dev/mapper/cryptroot $MNT/root
mount "$BOOTP" $MNT/root/boot
mount "$ESP" $MNT/root/boot/efi
for d in dev proc sys run; do mount --rbind /$d $MNT/root/$d; done

chroot $MNT/root /bin/bash -euo pipefail -s -- "$P1" "$PASSFILE" "$PRIV_IF" "$SSS_CFG" "$LUKS_UUID" "$BOOT_UUID" "$FS_UUID" <<'CHROOT'
P1=$1 PASSFILE=$2 PRIV_IF=$3 SSS_CFG=$4 LUKS_UUID=$5 BOOT_UUID=$6 FS_UUID=$7
echo "cryptroot UUID=$LUKS_UUID none luks,discard,initramfs" > /etc/crypttab
# The root line may name p1 by PARTUUID (Debian's own cloud images) or LABEL:
# p1 is now the LUKS container, so mount the filesystem inside by its UUID.
awk -v u="$FS_UUID" '$1 !~ /^#/ && $2 == "/" { $1 = "UUID=" u } { print }' /etc/fstab >/etc/fstab.nbde
mv /etc/fstab.nbde /etc/fstab
grep -qE '[[:space:]]/boot[[:space:]]' /etc/fstab || echo "UUID=$BOOT_UUID /boot ext4 defaults 0 2" >> /etc/fstab
echo "GRUB_CMDLINE_LINUX=\"\$GRUB_CMDLINE_LINUX ip=:::::$PRIV_IF:dhcp\"" > /etc/default/grub.d/90-nbde.cfg
# Cloud images boot root=PARTUUID=<p1>, now the LUKS container: Ubuntu through
# GRUB_FORCE_PARTUUID, Debian's own images through GRUB_DISABLE_LINUX_UUID.
# Boot root=UUID=<the filesystem inside> instead.
printf '%s\n' 'GRUB_FORCE_PARTUUID=' 'GRUB_DISABLE_LINUX_UUID=false' 'GRUB_DISABLE_LINUX_PARTUUID=true' \
	> /etc/default/grub.d/99-nbde-root-uuid.cfg
# A token from an earlier attempt is replaced, never stacked. A token's
# keyslot claim can be stale (after a volume-key change the slots are
# renumbered), so a keyslot goes only when the recovery passphrase does not
# open it: the passphrase slot survives whatever the tokens say.
cryptsetup open --test-passphrase --key-file "$PASSFILE" "$P1" || { echo "the recovery passphrase opens no keyslot" >&2; exit 1; }
cryptsetup luksDump --dump-json-metadata "$P1" | python3 -c '
import json, sys
for tid, t in json.load(sys.stdin)["tokens"].items():
    if t.get("type") == "clevis":
        print(tid, " ".join(t.get("keyslots", [])))
' | while read -r tid slots; do
	cryptsetup token remove --token-id "$tid" "$P1"
	for s in $slots; do
		cryptsetup open --test-passphrase --key-slot "$s" --key-file "$PASSFILE" "$P1" 2>/dev/null ||
			cryptsetup luksKillSlot -q "$P1" "$s"
	done
done
clevis luks bind -d "$P1" -k "$PASSFILE" sss "$SSS_CFG"
update-initramfs -u -k all
update-grub
grub-install --target=arm64-efi --efi-directory=/boot/efi --removable --no-nvram
findmnt --fstab --evaluate -no SOURCE / | grep -qx /dev/mapper/cryptroot || { echo "fstab / does not resolve to cryptroot" >&2; exit 1; }
! grep -q 'root=PARTUUID' /boot/grub/grub.cfg || { echo "grub.cfg still boots root=PARTUUID" >&2; exit 1; }
# Listed to a file first: `lsinitramfs | grep -q` under pipefail fails on the
# SIGPIPE grep causes, and a negated one would pass for the same reason.
list=$(mktemp)
lsinitramfs "/boot/initrd.img-$(ls /lib/modules | sort -V | tail -1)" >"$list"
for f in usr/bin/clevis-decrypt-tang cryptroot/crypttab usr/bin/curl; do
	grep -qx "$f" "$list" || { echo "initramfs lacks $f" >&2; exit 1; }
done
if grep -q luks-keys "$list"; then echo "a LUKS key file is in the initramfs" >&2; exit 1; fi
rm -f "$list"
clevis luks list -d "$P1"
CHROOT

sync
umount -R $MNT/root
# Any keyslot: after a volume-key change (cryptsetup reencrypt) the slots are
# renumbered, and clevis may hold slot 0.
cryptsetup open --test-passphrase --key-file "$PASSFILE" "$P1" || { echo "no keyslot takes the recovery passphrase" >&2; exit 1; }
for i in 1 2 3 4 5; do
	udevadm settle
	cryptsetup close cryptroot && break
	[ "$i" = 5 ] && { echo "cryptroot is still in use" >&2; exit 1; }
	sleep 2
done
cryptsetup luksDump "$P1" | grep -E '^(Version|UUID)|^  [0-9]: (luks2|clevis)|Keyslot:'
lsblk -o NAME,SIZE,FSTYPE,LABEL "$DISK"
echo "LUKS_UUID=$LUKS_UUID"
echo DONE
