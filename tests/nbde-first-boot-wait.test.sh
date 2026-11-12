#!/usr/bin/env bash
# shellcheck disable=SC2329 # the helpers run through check()
# Runs nbde_hcloud_convert's first-boot guard against a stubbed cloud-init and
# a temporary stand-in for /run/systemd/shutdown, with PATH reduced to the few
# tools it needs, so a cloud-init installed on this machine is never found.
# Run: tests/nbde-first-boot-wait.test.sh (no root, no ansible).
set -eu

root=$(cd "$(dirname "$0")/.." && pwd)
script="$root/roles/nbde_hcloud_convert/files/nbde-first-boot-wait.sh"
work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT

failed=0

# check DESCRIPTION COMMAND [ARG...]
check() {
  description=$1
  shift
  if ! "$@"; then
    echo "not ok - $case: $description"
    echo "  output: $(tr '\n' ' ' < "$out")"
    failed=1
  fi
}

# new_case NAME STATUS_RC: a PATH with the guard's tools and, unless
# STATUS_RC is "none", a cloud-init whose `status --wait` exits STATUS_RC
# ("hang" never returns).
new_case() {
  case=$1
  dir="$work/$case"
  mkdir -p "$dir/bin" "$dir/shutdown"
  for tool in timeout sleep tr; do ln -s "$(command -v "$tool")" "$dir/bin/$tool"; done
  out="$dir/out"
  [ "$2" = none ] && return
  cat > "$dir/bin/cloud-init" << EOF
#!$BASH
case "\$*" in
  *--wait*) [ "$2" = hang ] && exec sleep 30; exit $2 ;;
  *) printf 'status: error\ndetail: stub\n' ;;
esac
EOF
  chmod +x "$dir/bin/cloud-init"
}

# run: the guard under the case's PATH; sets rc.
run() {
  rc=0
  env -i PATH="$dir/bin" NBDE_SHUTDOWN_DIR="$dir/shutdown" NBDE_SETTLE=1 NBDE_WAIT_TIMEOUT=2 \
    "$BASH" "$script" > "$out" 2>&1 || rc=$?
}

new_case finished 0
run
check "ready: rc 0 (got $rc)" test "$rc" = 0

new_case error 1
run
check "an old error only warns: rc 0 (got $rc)" test "$rc" = 0
check "says warning" grep -q '^warning:' "$out"

new_case degraded 2
run
check "degraded only warns: rc 0 (got $rc)" test "$rc" = 0
check "says warning" grep -q '^warning:' "$out"

new_case hang hang
run
check "still running: rc 124 (got $rc)" test "$rc" = 124
check "says still running" grep -q 'still running' "$out"

new_case scheduled 0
touch "$dir/shutdown/scheduled"
run
check "reboot scheduled: rc 77 (got $rc)" test "$rc" = 77
check "says a reboot is scheduled" grep -q 'a reboot is scheduled' "$out"

# The schedule shows up after cloud-init reads done, as power_state's does.
new_case scheduled-late 0
(sleep 0.5 && touch "$dir/shutdown/scheduled") &
run
wait
check "reboot scheduled after done: rc 77 (got $rc)" test "$rc" = 77

new_case no-cloud-init-scheduled none
touch "$dir/shutdown/scheduled"
run
check "no cloud-init, reboot scheduled: rc 77 (got $rc)" test "$rc" = 77

new_case no-cloud-init none
run
check "no cloud-init, nothing scheduled: rc 0 (got $rc)" test "$rc" = 0

[ "$failed" = 0 ] && echo "ok - nbde-first-boot-wait: 8 cases"
exit "$failed"
