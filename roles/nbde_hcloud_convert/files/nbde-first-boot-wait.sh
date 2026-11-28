#!/usr/bin/env bash
# Run on the host by the nbde_hcloud_convert role (tasks/first-boot.yml) before
# anything changes: waits until cloud-init has finished, then watches for the
# reboot a first boot may schedule (cloud-init power_state: `shutdown -r +N`).
# Converting while that reboot is pending would cut the package install or the
# rescue boot short.
#
# Exit: 0 ready; 77 a reboot or shutdown is scheduled; 124 cloud-init still running after
# NBDE_WAIT_TIMEOUT; anything else: `cloud-init status --wait` failed oddly.
# A cloud-init that finished with errors (an old first boot) only warns.
#
# Env: NBDE_SETTLE        seconds to watch for a scheduled reboot (default 30);
#      NBDE_WAIT_TIMEOUT  cap on `cloud-init status --wait` (default 900);
#      NBDE_SHUTDOWN_DIR  where systemd records a scheduled shutdown
#                         (default /run/systemd/shutdown).
set -u

settle=${NBDE_SETTLE:-30}
wait_timeout=${NBDE_WAIT_TIMEOUT:-900}
dir=${NBDE_SHUTDOWN_DIR:-/run/systemd/shutdown}

if command -v cloud-init > /dev/null 2>&1; then
  timeout "$wait_timeout" cloud-init status --wait > /dev/null 2>&1
  rc=$?
  case $rc in
    0) ;;
    124)
      echo "cloud-init is still running after ${wait_timeout} s"
      exit 124
      ;;
    1 | 2)
      echo "warning: cloud-init finished with errors (rc $rc):"
      cloud-init status --long 2>&1
      ;;
    *)
      echo "cloud-init status --wait failed (rc $rc)"
      exit "$rc"
      ;;
  esac
fi

# power_state runs from a child that waits for cloud-init to exit, so the
# schedule appears only after the status above reads done: keep looking.
for ((i = 0; i <= settle; i++)); do
  if [ -e "$dir/scheduled" ]; then
    echo "a reboot or shutdown is scheduled: $(tr '\n' ' ' < "$dir/scheduled")"
    exit 77
  fi
  if ((i < settle)); then sleep 1; fi
done
exit 0
