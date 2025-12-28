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

snapshot_name="@restic-snapshot"

# TODO can we get the BTRFS_VOL from the BTRFS_SUBVOL?
snapshot="$BTRFS_VOL/$snapshot_name"
subvolume="$BTRFS_SUBVOL"
# TODO lookup device?
btrfs_dev="$BTRFS_DEVICE"

# clean old snapshot
if sudo btrfs subvolume delete "$snapshot"; then
  echo "WARNING: previous run did not cleanly finish, removed old snapshot"
fi

echo "Creating snapshot"

sudo btrfs subvolume snapshot -r "$subvolume" "$snapshot"
trap 'sudo btrfs subvolume delete $snapshot' EXIT

echo "Replacing subvolume with snapshot"
sudo umount "$subvolume"

# TODO
ls -l "$subvolume"

sudo mount --types btrfs --options "subvol=$snapshot_name" "$btrfs_dev" "$subvolume"

# TODO Default BACKUP_PATHS to $BTRFS_SUBVOL?
#resitc ${RESTIC_CACHE:-} backup --verbose --one-file-system ${BACKUP_EXCLUDES:-} ${BACKUP_PATHS}

# TODO
ls -l "$subvolume"
