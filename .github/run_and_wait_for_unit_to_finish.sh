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

unit=${1:?Unit name required}

sudo systemctl daemon-reload

trap 'journalctl --user -xeu $unit' EXIT

sudo systemctl start "$unit"

sleep 5

while systemctl is-active --quiet "$unit"; do
  sleep 5
  echo "."
  journalctl --lines=20 -u "$unit"
done
