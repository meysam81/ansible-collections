#!/bin/sh
# shellcheck disable=SC2329 # the helpers run through check()
# Runs the rendered reboot-if-required script against a stubbed systemctl and
# sleep, in a shortened window.
# Run: tests/reboot-if-required.test.sh (needs ansible; no root).
set -eu

root=$(cd "$(dirname "$0")/.." && pwd)
template="$root/roles/unattended_upgrades/templates/reboot-if-required.j2"
work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT

# systemctl records its arguments and reports apt-daily-upgrade as
# $IS_ACTIVE; sleep returns at once, so a wait lasts until the deadline.
mkdir "$work/bin"
cat > "$work/bin/systemctl" << 'EOF'
#!/bin/sh
echo "$*" >> "$CALLS"
[ "$1" = is-active ] || exit 0
echo "$IS_ACTIVE"
[ "$IS_ACTIVE" = active ]
EOF
printf '#!/bin/sh\n' > "$work/bin/sleep"
chmod +x "$work/bin/systemctl" "$work/bin/sleep"

failed=0

# check DESCRIPTION COMMAND [ARG...]
check() {
  description=$1
  shift
  if ! "$@"; then
    echo "not ok - $case: $description"
    case_failed=1
    failed=1
  fi
}

not() { ! "$@"; }
line() { grep -qx -- "$1" "$2"; }
reboots() { line reboot "$dir/calls"; }

# run CASE TRIGGER REBOOT_REQUIRED_FILE(yes|no) APT_DAILY_UPGRADE_STATE
run() {
  case=$1
  case_failed=0
  dir="$work/$(echo "$case" | cut -c2)"
  status="$dir/state/status"
  mkdir -p "$dir/state"
  if [ "$3" = yes ]; then
    echo "*** System restart required ***" > "$dir/reboot-required"
    echo linux-image-generic > "$dir/reboot-required.pkgs"
  fi
  # A 2s window with a 1s random delay leaves the script 1s.
  vars=$(printf '{"unattended_upgrades_reboot_window_duration_sec": 2,
    "unattended_upgrades_reboot_window_random_delay_sec": 1,
    "unattended_upgrades_reboot_window_condition": "",
    "unattended_upgrades_reboot_window_kexec": false,
    "unattended_upgrades_reboot_window_trigger": "%s",
    "_unattended_upgrades_reboot_required_file": "%s",
    "_unattended_upgrades_reboot_status_dir": "%s"}' \
    "$2" "$dir/reboot-required" "$dir/state")
  if ! ansible localhost -m ansible.builtin.template \
    -a "src=$template dest=$dir/reboot-if-required mode=0755" \
    -e "$vars" > "$dir/render.log" 2>&1; then
    cat "$dir/render.log"
    echo "not ok - $case: render failed"
    exit 1
  fi
  : > "$dir/calls"
  rc=0
  # umask 077: the status file must come out 0644 whatever the umask.
  (
    umask 077
    CALLS="$dir/calls" IS_ACTIVE=$4 PATH="$work/bin:$PATH" \
      timeout 60 /bin/sh "$dir/reboot-if-required"
  ) > "$dir/out" 2>&1 || rc=$?
  check "exits 0 (got $rc)" test "$rc" -eq 0
  check "writes the status file" test -f "$status"
  check "status file is 0644" test -n "$(find "$status" -perm 0644 2>/dev/null)"
  check "status has a time" grep -qx 'time=[0-9][0-9]*' "$status"
  check "leaves no temp file in the status dir" test "$(ls -A "$dir/state")" = status
}

done_case() {
  if [ "$case_failed" -eq 0 ]; then
    echo "ok - $case"
  else
    sed 's/^/# /' "$dir/out"
  fi
}

run "(a) no file, no trigger" "" no inactive
check "does not reboot" not reboots
check "outcome=not-required" line outcome=not-required "$status"
done_case

run "(b) no file, trigger succeeds" "exit 0" no inactive
check "reboots" reboots
check "outcome=rebooting" line outcome=rebooting "$status"
check "reason=reboot trigger" line "reason=reboot trigger" "$status"
check "says required by: reboot trigger" grep -q "required by: reboot trigger" "$dir/out"
done_case

run "(c) file, trigger fails" "exit 1" yes inactive
check "reboots" reboots
check "outcome=rebooting" line outcome=rebooting "$status"
check "reason=reboot-required file" line "reason=reboot-required file" "$status"
check "says required by: linux-image-generic" grep -q "required by: linux-image-generic" "$dir/out"
done_case

run "(d) file, upgrade runs past the deadline" "" yes activating
check "waits on apt-daily-upgrade" line "is-active apt-daily-upgrade.service" "$dir/calls"
check "does not reboot" not reboots
check "outcome=skipped" line outcome=skipped "$status"
check "reason names apt-daily-upgrade" grep -q '^reason=.*apt-daily-upgrade' "$status"
done_case

run "(e) no file, trigger fails, upgrade runs past the deadline" "exit 1" no activating
check "waits on apt-daily-upgrade" line "is-active apt-daily-upgrade.service" "$dir/calls"
check "does not reboot" not reboots
check "outcome=not-required" line outcome=not-required "$status"
done_case

exit "$failed"
