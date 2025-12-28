#!/usr/bin/env bash

# Exit on error. Append || true if you expect an error.
set -o errexit
# Exit on error inside any functions or subshells.
set -o errtrace
# Do not allow use of undefined vars. Use ${VAR:-} to use an undefined VAR
set -o nounset
# Catch the error in case mysqldump fails (but gzip succeeds) in `mysqldump |gzip`
set -o pipefail
# Turn on traces, useful while debugging but commented out by default
if [[ -n "${RUNNER_DEBUG:-}" ]]; then
  set -o xtrace
fi

block_device=${1:?Block device required}
dev_device=${2:?/dev device required}

# create a 200M file that'll be used by the loopback device
dd if=/dev/zero of="$block_device" bs=1M count=200

# create the loopback block device
# 200 hopefully won't collide with `ls -l /dev/loop*`
sudo mknod "$dev_device" b "$(grep 'loop' /proc/devices | awk '{print $1}')" 200

sudo losetup "$dev_device" "$block_device"
