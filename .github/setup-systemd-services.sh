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
repo=${4:?repository url required}
password=${5:?repository password required}

sudo mkdir -p /usr/local/lib/systemd/system/
sudo mkdir -p /usr/local/bin
sudo cp systemd/*.service /usr/local/lib/systemd/system/
sudo cp scripts/*.sh /usr/local/bin

sudo mkdir /usr/local/lib/systemd/system/btrfs-restic-backup@test.service.d

sudo tee /usr/local/lib/systemd/system/btrfs-restic-backup@test.service.d/env.conf << EOF
[Service]
Environment="BTRFS_SUBVOL=$sub_vol_mount"
Environment="BACKUP_PATHS=$sub_vol_mount"
Environment="RESTIC_REPOSITORY=$repo"
Environment="RESTIC_PASSWORD=$password"
Environment="BACKUP_EXCLUDE_FILE=/usr/local/lib/systemd/system/btrfs-restic-backup@test.service.d/exclude.txt"
# alter content of test file to verify the snapshot is being backed up
ExecStartPre=$GITHUB_WORKSPACE/.github/output_content_to_file.sh foo $root_vol/$sub_vol/file.txt
ExecStart=/usr/bin/echo visual-confirmation-that-this-happens-after-exec-start-in-main-service
EOF

sudo tee /usr/local/lib/systemd/system/btrfs-restic-backup@test.service.d/exclude.txt << EOF
ignored1.txt
sub/
EOF
