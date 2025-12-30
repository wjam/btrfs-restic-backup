#!/usr/bin/env bash

# Script which replaces the subvolume with an existing snapshot and then runs restic

# Exit on error. Append || true if you expect an error.
set -o errexit
# Exit on error inside any functions or subshells.
set -o errtrace
# Do not allow use of undefined vars. Use ${VAR:-} to use an undefined VAR
set -o nounset
# Catch the error in case mysqldump fails (but gzip succeeds) in `mysqldump |gzip`
set -o pipefail
# Turn on traces, useful while debugging but commented out by default
#set -o xtrace

subvolume="$BTRFS_SUBVOL"
btrfs_dev="$(findmnt --types btrfs --options subvol --target "$subvolume" --nofsroot --output source --noheadings)"

echo "Replacing subvolume with snapshot"
umount --verbose "$subvolume" 2>&1

mount --types btrfs --options "subvol=$SNAPSHOT_NAME" "$btrfs_dev" "$subvolume"

restic "$@"
