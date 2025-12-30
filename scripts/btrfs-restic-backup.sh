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
#  - ExecStartPost which performs the trimming
#  - ExecStopPost which deletes the completed snapshot
# Splitting up would allow _another_ ExecStartPre to be added which injects another file into the subvolume & lists the contents to prove the files backed up are the snapshot
# https://unix.stackexchange.com/questions/348450/confused-by-execstartpre-entries-in-systemd-unit-file
# As the service is a `oneshot`, multiple ExecStart could be added to the unit via `.d` directory backing up to many locations

ls -l "${BACKUP_PATHS}"

# TODO Default BACKUP_PATHS to $BTRFS_SUBVOL?
restic ${RESTIC_CACHE:-} backup --verbose --one-file-system ${BACKUP_EXCLUDES:-} ${BACKUP_PATHS}

restic ${RESTIC_CACHE:-} forget --prune --max-unused 5G --verbose \
    --keep-daily "${RETENTION_DAYS:-7}" \
    --keep-weekly "${RETENTION_WEEKS:-4}" \
    --keep-monthly "${RETENTION_MONTHS:-6}" \
    --keep-yearly "${RETENTION_YEARS:-0}"
