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

root_vol=${1:?root volume path required}
sub_vol=${2:?subvolume name required}
sub_vol_mount=${3:?subvolume mount path required}

sudo umount "$sub_vol_mount"
sudo btrfs subvolume delete "$root_vol/$sub_vol"
