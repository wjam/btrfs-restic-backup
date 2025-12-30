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

path=${1:?/backed up path required}
expected=${2:?expected content required}

actual="$(sudo restic dump latest "$path")"

if [ "$actual" == "$expected" ]; then
  exit 0
fi

echo "expected '$expected', got '$actual'"
exit 1
