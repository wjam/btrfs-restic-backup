#!/usr/bin/env bash

# Script which runs check when relevant

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

last_check_file="$STATE_DIRECTORY/last_check_time"

since_last_run="1000000000"
if [ -e "$last_check_file" ]; then
  since_last_run="$(($(date +%s) - $(date -r "$last_check_file" +%s)))"
fi

if [ "$since_last_run" -lt "$CHECK_INTERVAL_SECONDS" ]; then
  exit 0
fi

restic check "$@"

touch "$last_check_file"
