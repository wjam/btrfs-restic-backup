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

dev_device=${1:?/dev device required}
root_vol=${2:?root volume path required}
sub_vol=${3:?subvolume name required}
sub_vol_mount=${4:?subvolume mount path required}

sudo btrfs subvolume create "$root_vol/$sub_vol"
mkdir "$sub_vol_mount"
sudo mount --types btrfs --options "subvol=/$sub_vol" "$dev_device" "$sub_vol_mount"
