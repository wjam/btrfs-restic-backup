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

# TODO split this script up?
#  - ExecStartPre which creates the snapshot
#  - ExecStart which performs the backup
#  - ExecSStopPost which deletes the completed snapshot
# Splitting up would allow _another_ ExecStartPre to be added which injects another file into the subvolume & lists the contents to prove the files backed up are the snapshot
# https://unix.stackexchange.com/questions/348450/confused-by-execstartpre-entries-in-systemd-unit-file
# As the service is a `oneshot`, multiple ExecStart could be added to the unit via `.d` directory backing up to many locations

# TODO better name for this snapshot? From systemd unit name?
snapshot_name="@btrfs-restic-backup"

# TODO Given the subvolume path, can the btrfs volume & subvolume name be found?
# If so, when using PrivateTmp, the root can be mounted to /tmp/btrfs and actions performed there
# thus avoiding the need for the root volume to be always mounted - something the flat layout says isn't needed

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

# TODO need to fix needing everything to be sudoed to work:
# Able to get the mount to be owned by the current user?
# Put the systemd files into /usr/local/lib/systemd/system/?
# Prefix the ExecStart with /usr/bin/sudo using override?
# Rewrite the unit files to run this script with sudo?

sudo btrfs subvolume snapshot -r "$subvolume" "$snapshot"
trap 'sudo btrfs subvolume delete $snapshot' EXIT

echo "Replacing subvolume with snapshot"
sudo umount --verbose "$subvolume" 2>&1

# TODO
ls -l "$subvolume"

sudo mount --types btrfs --options "subvol=$snapshot_name" "$btrfs_dev" "$subvolume"

# TODO Default BACKUP_PATHS to $BTRFS_SUBVOL?
resitc ${RESTIC_CACHE:-} backup --verbose --one-file-system ${BACKUP_EXCLUDES:-} ${BACKUP_PATHS}

# TODO
ls -l "$subvolume"
ls -l "$RESTIC_REPOSITORY"
