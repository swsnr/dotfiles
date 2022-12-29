#!/usr/bin/bash

set -euo pipefail

certname=intermediate-"$1"

keyfile="$(mktemp basti-ca-root.XXX.key)"
trap '{ rm -f -- "$keyfile"; }' EXIT

op document get 'Basti CA root key' --output="$keyfile"
step-cli certificate create \
    "$certname" "$certname".crt "$certname".key \
    --profile intermediate-ca \
    --ca ./basti-ca-root.crt --ca-key "./${keyfile}" \
    --not-after=8766h # Valid for 1 year
