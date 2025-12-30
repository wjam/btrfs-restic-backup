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
# TODO disable xtrace

btrfs_dev="$(findmnt --types btrfs --options subvol --target "$BTRFS_SUBVOL" --nofsroot --output source --noheadings)"

# The BTRFS volume was mounted either by administrator and/or the create snapshot script
btrfs_vol="$(findmnt --types btrfs --options subvol --source "$btrfs_dev" --options subvol=/ --first-only --output target --noheadings)"

btrfs subvolume delete "$btrfs_vol/$SNAPSHOT_NAME"
