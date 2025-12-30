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

# TODO Given the subvolume path, can the btrfs volume & subvolume name be found?
# If so, when using PrivateTmp, the root can be mounted to /tmp/btrfs and actions performed there
# thus avoiding the need for the root volume to be always mounted - something the flat layout says isn't needed

# TODO can we get the BTRFS_VOL from the BTRFS_SUBVOL?
snapshot="$BTRFS_VOL/$SNAPSHOT_NAME"
subvolume="$BTRFS_SUBVOL"
# TODO lookup device?
btrfs_dev="$BTRFS_DEVICE"

# clean old snapshot
if btrfs subvolume delete "$snapshot"; then
  echo "WARNING: previous run did not cleanly finish, removed old snapshot"
fi

echo "Creating snapshot"

btrfs subvolume snapshot -r "$subvolume" "$snapshot"

echo "Replacing subvolume with snapshot"
umount --verbose "$subvolume" 2>&1

mount --types btrfs --options "subvol=$SNAPSHOT_NAME" "$btrfs_dev" "$subvolume"
