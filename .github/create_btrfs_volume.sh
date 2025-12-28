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
set -o xtrace

dev_device=${1:?/dev device required}
vol=${2:?volume path required}
sub_vol=${2:?subvolume path required}

sudo mkfs.btrfs "$dev_device"
mkdir "$vol"
sudo mount "$dev_device" "$vol"
btrfs subvolume create "$sub_vol"
